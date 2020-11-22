import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:wisebu/data/Category.dart';
import 'package:wisebu/data/Data.dart';
import 'package:wisebu/data/DatabaseHelper.dart';
import 'package:wisebu/screens/AddRecordScreen.dart';
import 'package:wisebu/screens/DetailsScreen.dart';
import 'package:wisebu/widgets/Widgets.dart';

class MainScreen extends StatefulWidget {
  final bool showSnackBar;
  final String snackBarMessage;
  final String dateTimeMonth;

  MainScreen({this.showSnackBar, this.snackBarMessage, this.dateTimeMonth});

  @override
  State<StatefulWidget> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  PageController pageController = PageController(initialPage: 999);
  Future<List<Category>> futureIncomeList, futureExpenseList;
  bool showDateForward = true;
  double totalIncomes = 0;
  double totalExpenses = 0;
  List<Category> incomeList = [];
  List<Category> expenseList = [];
  DateTime dateTimeNow;

  @override
  void initState() {
    if (widget.dateTimeMonth != null)
      dateTimeNow = DateTime.parse(widget.dateTimeMonth);
    else
      dateTimeNow = DateTime.now();

    setData();
    if (widget.showSnackBar != null && widget.showSnackBar)
      // set delay to get context
      Future.delayed(Duration.zero, () {
        snackBar(
            context: context,
            infoMessage: widget.snackBarMessage,
            backgroundColor: Theme.of(context).primaryColor);
      });

    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        // close app on back pressed
        SystemNavigator.pop();
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("BUDGET"),
          actions: [
            Tooltip(
              message: "Go to current month",
              child: InkWell(
                customBorder: CircleBorder(),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  if (dateTimeNow.toString().substring(0, 7) !=
                      DateTime.now().toString().substring(0, 7)) {
                    setState(() {
                      dateTimeNow = DateTime.now();
                    });
                    resetData();
                  }
                },
              ),
            )
          ],
          // do not show leading back icon in appBar
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            header(context: context),
            Expanded(
              child: PageView.builder(
                physics: NeverScrollableScrollPhysics(),
                controller: pageController,
                itemBuilder: (context, position) {
                  return SingleChildScrollView(child: content(context));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget header({@required BuildContext context}) {
    return Container(
      height: 50,
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          headerIcon(
              context: context,
              iconData: Icons.arrow_back_ios,
              isForward: false),
          Text(
            DateFormat('MMMM, y').format(dateTimeNow),
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          headerIcon(
              context: context,
              iconData: Icons.arrow_forward_ios,
              isForward: true),
        ],
      ),
    );
  }

  IconButton headerIcon(
      {@required BuildContext context,
      @required IconData iconData,
      @required bool isForward}) {
    return IconButton(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: 15),
      icon: Icon(iconData, size: 20),
      color: Theme.of(context).primaryColor,
      onPressed: () {
        showDateForward = isForward;
        changeText(showDateForward);
      },
    );
  }

  void changeText(showDateForward) {
    if (showDateForward == false)
      setState(() {
        dateTimeNow = DateTime(dateTimeNow.year, dateTimeNow.month - 1, 1);
        pageController.previousPage(
            duration: Duration(milliseconds: 1), curve: Curves.linear);
      });
    else if (showDateForward == true)
      setState(() {
        dateTimeNow = DateTime(dateTimeNow.year, dateTimeNow.month + 1, 1);
        pageController.nextPage(
            duration: Duration(milliseconds: 1), curve: Curves.linear);
      });
    // reset data after changing month in header
    resetData();
  }

  Widget content(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (totalIncomes - totalExpenses != 0.0)
          Container(
            height: 150,
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ListTile(
                        visualDensity:
                            VisualDensity(horizontal: -4, vertical: -4),
                        title: Text("${totalIncomes.toStringAsFixed(2)} €"),
                        leading: Container(
                          color: Theme.of(context).primaryColor,
                          width: 20,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ListTile(
                        visualDensity:
                            VisualDensity(horizontal: -4, vertical: -4),
                        title: Text("${totalExpenses.toStringAsFixed(2)} €"),
                        leading: Container(
                          color: Theme.of(context).accentColor,
                          width: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                circleAvatar(
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  // round a double with toStringAsFixed(2)
                  mainText:
                      "${(totalIncomes - totalExpenses).toStringAsFixed(2)} €",
                  secondText: "left",
                )
              ],
            ),
          ),
        categoryData(
            context: context,
            type: incomeType,
            dataList: incomeList,
            typeColor: Theme.of(context).primaryColor),
        SizedBox(height: 10),
        categoryData(
            context: context,
            type: expenseType,
            dataList: expenseList,
            typeColor: Theme.of(context).accentColor),
        if (totalIncomes - totalExpenses == 0.0)
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 20),
            child: Column(
              children: [
                SizedBox(
                  width: 250,
                  child: Container(
                    foregroundDecoration: BoxDecoration(
                      color: Colors.grey,
                      backgroundBlendMode: BlendMode.saturation,
                    ),
                    child: Image.asset(
                      "lib/images/illustration.png",
                    ),
                  ),
                ),
                Text(
                  "NOTHING TO SHOW",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                )
              ],
            ),
          ),
      ],
    );
  }

  Widget categoryData(
      {@required BuildContext context,
      @required String type,
      @required List<Category> dataList,
      @required Color typeColor}) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 25),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: typeColor,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  type,
                  style: TextStyle(
                      fontSize: 18,
                      color: typeColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.15,
                child: IconButton(
                  visualDensity: VisualDensity(horizontal: -4),
                  onPressed: () {
                    dialogTitleController.clear();
                    dialogAmountController.clear();

                    alertDialogWithFields(
                      context: context,
                      title: type == expenseType
                          ? expenseDialogTitle
                          : incomeDialogTitle,
                      hintText: type == expenseType ? expenseType : incomeType,
                      onPressedOk: () {
                        hideKeyboard(context);

                        bool alreadyExists = doExist(
                            title: titleFromDialog(type),
                            type: type,
                            itemsList: dataList);

                        if (alreadyExists) {
                          Navigator.pop(context);
                          simpleAlertDialog(
                              context: context,
                              onPressedOk: () => Navigator.pop(context),
                              title: "Sorry",
                              contentText: "Category already exists.");
                        } else {
                          Category category = Category(
                            title: titleFromDialog(type),
                            type: type,
                            amount: amountFromDialog(),
                            date: dateWithZeroTime(dateTimeNow).toString(),
                          );
                          dbInsertRecord(category);
                          resetData();
                          Navigator.pop(context);
                        }
                      },
                    );
                  },
                  icon: Icon(Icons.add_circle, size: 35, color: typeColor),
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: dataList.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: listTileMainScreen(
                  context: context,
                  isExpense: type == incomeType ? false : true,
                  title: dataList[index].title,
                  moneyAmount: "${dataList[index].amount.toStringAsFixed(2)} €",
                  color: typeColor,
                  onIconPressed: () {
                    if (type == expenseType)
                      push(
                          context: context,
                          nextScreen: AddRecordScreen(
                            expenseList: dataList,
                            expenseCategoryTitle: dataList[index].title,
                          ));
                  },
                  onTitlePressed: () {
                    if (type == expenseType)
                      push(
                        context: context,
                        nextScreen: DetailsScreen(
                          title: dataList[index].title,
                          expenseList: dataList,
                          dateTimeMonth: dateTimeNow.toString(),
                        ),
                      );
                    else {
                      setState(() {
                        dialogTitleController.text = dataList[index].title;
                        dialogAmountController.text =
                            dataList[index].amount.toString();
                      });
                      alertDialogWithFields(
                        context: context,
                        title: "Edit income",
                        hintText: "Income",
                        onPressedOk: () {
                          dbUpdateRecord(
                            index: dataList[index].id,
                            title: dialogTitleController.text ?? "Income",
                            amount: amountFromDialog(),
                          ).then((_) {
                            resetData();
                            Navigator.pop(context);
                          });
                        },
                      );
                    }
                  },
                  onLongPressed: () {
                    simpleAlertDialog(
                      context: context,
                      title: "Delete?",
                      contentText:
                          "\"${dataList[index].title}\" category and it\'s records will be removed forever.",
                      onPressedOk: () {
                        dbDeleteCategory(
                                title: dataList[index].title,
                                type: dataList[index].type,
                                date: dataList[index].date)
                            .then((_) {
                          resetData();
                          Navigator.pop(context);
                        });
                      },
                    );
                  }),
            );
          },
        ),
      ],
    );
  }

  Future<List<Category>> dbGetCategories({@required String type}) async {
    return await dbGetRecordsByType(type, dateTimeNow.toString());
  }

  void setData({String date}) {
    futureIncomeList = dbGetCategories(type: incomeType);
    futureIncomeList.then((list) {
      if (this.mounted)
        setState(() {
          list.forEach((item) {
            incomeList.add(item);
            totalIncomes = totalIncomes + item.amount;
          });
        });
    });

    futureExpenseList = dbGetCategories(type: expenseType);
    futureExpenseList.then((list) {
      if (this.mounted)
        setState(() {
          list.forEach((item) {
            expenseList.add(item);
            totalExpenses = totalExpenses + item.amount;
          });
        });
    });
  }

  void resetData() {
    setState(() {
      totalIncomes = 0;
      totalExpenses = 0;
      incomeList.clear();
      expenseList.clear();
      setData();
    });
  }
}

Widget listTileMainScreen(
    {@required BuildContext context,
    @required String title,
    @required String moneyAmount,
    @required Color color,
    @required onTitlePressed,
    @required onLongPressed,
    onIconPressed,
    @required bool isExpense}) {
  return Container(
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Colors.grey[350],
          width: 1,
        ),
      ),
    ),
    child: InkWell(
      onTap: isExpense ? null : onTitlePressed,
      onLongPress: isExpense ? null : onLongPressed,
      child: ListTile(
        visualDensity: VisualDensity(vertical: -2),
        contentPadding: EdgeInsets.only(left: 5, right: 5),
        title: InkWell(
          onTap: isExpense ? onTitlePressed : null,
          onLongPress: isExpense ? onLongPressed : null,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 7,
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: FittedBox(
                    child: Text(
                      moneyAmount,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        trailing: SizedBox(
          width: MediaQuery.of(context).size.width * 0.15,
          child: isExpense
              ? IconButton(
                  visualDensity: VisualDensity(horizontal: -4),
                  onPressed: isExpense ? onIconPressed : null,
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: color,
                    size: 35,
                  ),
                )
              : Container(),
        ),
      ),
    ),
  );
}
