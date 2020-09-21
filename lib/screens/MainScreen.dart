import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wisebu/data/Category.dart';
import 'package:wisebu/data/Data.dart';
import 'package:wisebu/data/DatabaseHelper.dart';
import 'package:wisebu/screens/AddRecordScreen.dart';
import 'package:wisebu/screens/DetailsScreen.dart';
import 'package:wisebu/widgets/Widgets.dart';

class MainScreen extends StatefulWidget {
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

  @override
  void initState() {
    setData();
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
      // disable going back
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("BUDGET"),
          // do not show leading back icon in appBar
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            header(
                context: context,
                showDateForward: showDateForward,
                changeText: changeText,
                text: 'September, 2020',
                headerHeight: 0.08,
                arrowSize: 0.05),
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

  Widget header(
      {context,
      showDateForward,
      changeText(showDateForward),
      String text,
      double headerHeight,
      double arrowSize}) {
    return Container(
      height: MediaQuery.of(context).size.height * headerHeight,
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            padding: EdgeInsets.only(left: 10),
            icon: Icon(Icons.arrow_back_ios,
                size: MediaQuery.of(context).size.width * arrowSize),
            color: Theme.of(context).primaryColor,
            onPressed: () => {
              showDateForward = false,
              changeText(showDateForward),
            },
          ),
          Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontSize:
                  MediaQuery.of(context).size.height * headerHeight * 0.35,
            ),
          ),
          IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            padding: EdgeInsets.only(right: 10),
            icon: Icon(Icons.arrow_forward_ios,
                size: MediaQuery.of(context).size.width * arrowSize),
            color: Theme.of(context).primaryColor,
            onPressed: () => {
              showDateForward = true,
              changeText(showDateForward),
            },
          )
        ],
      ),
    );
  }

  void changeText(showDateForward) {}

  Widget content(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.2,
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
                      title: Text("$totalIncomes €"),
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
                      title: Text("$totalExpenses €"),
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
                mainText: "${totalIncomes - totalExpenses} €",
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
            typeColor: Theme.of(context).accentColor)
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
              Container(
                width: MediaQuery.of(context).size.width * 0.15,
                child: IconButton(
                  visualDensity: VisualDensity(horizontal: -4),
                  onPressed: () {
                    dialogTitleController.clear();
                    dialogAmountController.clear();

                    alertDialogFields(
                      context: context,
                      title: type == expenseType ? "Add expense" : "Add income",
                      hintText: type == expenseType ? "Expense" : "Income",
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
                            // TODO: get month from PageBuilder and save date as that month
                            date: dateWithZeroTime(DateTime.now()).toString(),
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
                  moneyAmount: "${dataList[index].amount} €",
                  color: typeColor,
                  onIconPressed: () {
                    if (type == expenseType)
                      push(
                        context: context,
                        nextScreen: AddRecordScreen(),
                      );
                  },
                  onTitlePressed: () {
                    if (type == expenseType)
                      push(
                        context: context,
                        nextScreen: DetailsScreen(
                          title: dataList[index].title,
                        ),
                      );
                    else {
                      setState(() {
                        dialogTitleController.text = dataList[index].title;
                        dialogAmountController.text =
                            dataList[index].amount.toString();
                      });
                      alertDialogFields(
                        context: context,
                        title: "Edit income",
                        hintText: "Income",
                        onPressedOk: () {
                          dbUpdateRecord(
                                  index: dataList[index].id,
                                  title: dialogTitleController.text ?? "Income",
                                  // TODO: get month from PageBuilder and save date as that month
                                  date: dateWithZeroTime(DateTime.now())
                                      .toString())
                              .then((_) {
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
                          "\"${dataList[index].title}\" will be removed from $type category forever.",
                      onPressedOk: () {
                        dbDeleteCategory(
                                title: dataList[index].title,
                                type: dataList[index].type)
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

  Future<List<Category>> dbGetCategories(type) async {
    return await dbGetRecordsByType(type);
  }

  void setData() {
    futureIncomeList = dbGetCategories(incomeType);
    futureIncomeList.then((list) {
      if (this.mounted)
        setState(() {
          list.forEach((item) {
            incomeList.add(item);
            totalIncomes = totalIncomes + item.amount;
          });
        });
    });

    futureExpenseList = dbGetCategories(expenseType);
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
