import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:wisebu/data/Category.dart';
import 'package:wisebu/data/Data.dart';
import 'package:wisebu/data/DatabaseHelper.dart';
import 'package:wisebu/data/blocs/BlocProvider.dart';
import 'package:wisebu/data/blocs/CategoriesBloc.dart';
import 'package:wisebu/screens/DetailsScreen.dart';
import 'package:wisebu/screens/OneRecordScreen.dart';
import 'package:wisebu/widgets/Widgets.dart';

class MainScreen extends StatefulWidget {
  final bool showSnackBar;
  final String snackBarMessage;
  final String dateTimeMonth;
  final List<Category> incomesSetUpList;
  final List<Category> expensesSetUpList;

  MainScreen({
    this.showSnackBar,
    this.snackBarMessage,
    this.dateTimeMonth,
    this.incomesSetUpList,
    this.expensesSetUpList,
  });

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  CategoriesBloc categoriesBloc;

  PageController pageController = PageController(initialPage: 999);
  bool showDateForward = true;
  DateTime dateTimeShowed;

  double totalIncomes = 0;
  double totalExpenses = 0;
  List<Category> incomeList = [];
  List<Category> expenseList = [];

  @override
  void initState() {
    super.initState();
    categoriesBloc = BlocProvider.of<CategoriesBloc>(context);

    // first time when app opens set up data
    if (widget.incomesSetUpList != null)
      for (var category in widget.incomesSetUpList)
        categoriesBloc.inAddCategory.add(category);
    if (widget.expensesSetUpList != null)
      for (var category in widget.expensesSetUpList)
        categoriesBloc.inAddCategory.add(category);

    // set header date
    if (widget.dateTimeMonth != null)
      dateTimeShowed = DateTime.parse(widget.dateTimeMonth);
    else
      dateTimeShowed = DateTime.now();

    // TODO: update this snackBar feature
    if (widget.showSnackBar != null && widget.showSnackBar)
      // set delay to get context
      Future.delayed(Duration.zero, () {
        snackBar(context: context, infoMessage: widget.snackBarMessage);
      });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void pushToOneCategoryScreen(childScreen) async {
    bool update = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          bloc: CategoriesBloc(),
          child: childScreen,
        ),
      ),
    );

    // If update was set, get all the categories again
    if (update != null) {
      categoriesBloc.getCategories();
    }
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
          automaticallyImplyLeading: false,
          actions: [
            inkwellIcon(
              tooltip: "Go to current month",
              iconData: Icons.calendar_today,
              onTap: () {
                if (dateTimeShowed.toString().substring(0, 7) !=
                    DateTime.now().toString().substring(0, 7)) {
                  dateTimeShowed = DateTime.now();
                  categoriesBloc.getCategories();
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            content(context),
          ],
        ),
      ),
    );
  }

  setData(List<Category> fullCategoryList) {
    totalIncomes = 0;
    totalExpenses = 0;
    incomeList.clear();
    expenseList.clear();

    for (var i in fullCategoryList)
      if (dateWithZeroTime(DateTime.parse(i.date)).toString().substring(0, 7) ==
          dateWithZeroTime(dateTimeShowed).toString().substring(0, 7)) {
        if (i.type == incomeType) {
          totalIncomes = totalIncomes + i.amount;
          incomeList.add(i);
        } else {
          totalExpenses = totalExpenses + i.amount;
          expenseList.add(i);
        }
      }
    incomeList.sort((a, b) => a.title.compareTo(b.title));
    expenseList.sort((a, b) => a.title.compareTo(b.title));
  }

  Widget content(BuildContext context) {
    return Expanded(
      child: StreamBuilder<List<Category>>(
        stream: categoriesBloc.categories,
        builder:
            (BuildContext context, AsyncSnapshot<List<Category>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              return Text('No categories');
            }

            List<Category> categories = snapshot.data;
            setData(categories);

            return PageView.builder(
                physics: NeverScrollableScrollPhysics(),
                controller: pageController,
                itemBuilder: (context, position) {
                  return ListView(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          header(context: context),
                          if (incomeList.length > 0 || expenseList.length > 0)
                            Container(
                              height: 150,
                              padding: EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ListTile(
                                          visualDensity: VisualDensity(
                                              horizontal: -4, vertical: -4),
                                          title: Text(
                                            "${amountTextShown(amount: totalIncomes)} €",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          leading: Container(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 20,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        ListTile(
                                          visualDensity: VisualDensity(
                                              horizontal: -4, vertical: -4),
                                          title: Text(
                                            "${amountTextShown(amount: totalExpenses)} €",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          leading: Container(
                                            color:
                                                Theme.of(context).accentColor,
                                            width: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  circleAvatar(
                                    color: Theme.of(context).primaryColor,
                                    textColor: Colors.white,
                                    mainText:
                                        "${amountTextShown(amount: totalIncomes - totalExpenses)} €",
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
                          if (incomeList.isEmpty && expenseList.isEmpty)
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(top: 20),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 250,
                                    child: Container(
                                      padding: EdgeInsets.only(bottom: 10),
                                      foregroundDecoration: BoxDecoration(
                                        color: Colors.grey,
                                        backgroundBlendMode:
                                            BlendMode.saturation,
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
                                      fontSize: 15,
                                      color: Colors.grey,
                                    ),
                                  )
                                ],
                              ),
                            ),
                        ],
                      ),
                      /* ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      Category category = categories[index];

                      return GestureDetector(
                        onTap: () {
                          // TODO: go to details screen
                          // TODO: put navigateToCategory method in DetailsScreen onTap
                          navigateToCategory(category);
                        },
                        child: Container(
                          height: 50,
                          child: Text(
                            'Category ' + category.id.toString() + category.title,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      );
                    },
                  ),*/
                    ],
                  );
                });
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
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
          Flexible(
            flex: 2,
            child: headerIcon(
                context: context,
                iconData: Icons.arrow_back_ios,
                isForward: false),
          ),
          Flexible(
            flex: 6,
            child: Text(
              DateFormat('MMMM, y').format(dateTimeShowed),
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: headerIcon(
                context: context,
                iconData: Icons.arrow_forward_ios,
                isForward: true),
          ),
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
    if (showDateForward == false) {
      dateTimeShowed =
          DateTime(dateTimeShowed.year, dateTimeShowed.month - 1, 1);
      pageController.previousPage(
          duration: Duration(milliseconds: 1), curve: Curves.linear);
    } else if (showDateForward == true) {
      dateTimeShowed =
          DateTime(dateTimeShowed.year, dateTimeShowed.month + 1, 1);
      pageController.nextPage(
          duration: Duration(milliseconds: 1), curve: Curves.linear);
    }
    // reset data after changing month in header
    categoriesBloc.getCategories();
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
                    if (type == incomeType) {
                      dialogTitleController.clear();
                      dialogAmountController.clear();

                      alertDialogWithFields(
                        context: context,
                        title: type == expenseType
                            ? expenseDialogTitle
                            : incomeDialogTitle,
                        hintText:
                            type == expenseType ? expenseType : incomeType,
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
                              date: dateWithZeroTime(dateTimeShowed).toString(),
                            );

                            categoriesBloc.inAddCategory.add(category);
                            Navigator.of(context).pop();
                          }
                        },
                      );
                    } else
                      // go to add record screen to add new expense
                      pushToOneCategoryScreen(
                        OneRecordScreen(
                          isNewExpenseCategory: true,
                          date: dateTimeShowed.year == DateTime.now().year &&
                                  dateTimeShowed.month == DateTime.now().month
                              ? DateTime.now().toString()
                              : dateWithZeroTime(dateTimeShowed).toString(),
                        ),
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
                  moneyAmount:
                      "${amountTextShown(amount: dataList[index].amount)} €",
                  color: typeColor,
                  onIconPressed: () {
                    // add new expense in existing category
                    if (type == expenseType)
                      pushToOneCategoryScreen(
                        OneRecordScreen(
                          isNewExpenseCategory: false,
                          expenseList: dataList,
                          expenseCategoryTitle: dataList[index].title,
                          date: dateTimeShowed.year == DateTime.now().year &&
                                  dateTimeShowed.month == DateTime.now().month
                              ? DateTime.now().toString()
                              : dateWithZeroTime(dateTimeShowed).toString(),
                        ),
                      );
                  },
                  onTitlePressed: () {
                    if (type == expenseType)
                      // show all expenses for selected category in DetailsScreen
                      navigateToDetails(dataList[index]);
                    else {
                      dialogTitleController.text = dataList[index].title;
                      dialogAmountController.text =
                          dataList[index].amount.toString();
                      alertDialogWithFields(
                        context: context,
                        title: "Edit income",
                        hintText: "Income",
                        onPressedOk: () {
                          // update income record
                          DatabaseHelper.db.updateCategory(Category(
                            id: dataList[index].id,
                            title: dialogTitleController.text ?? "Income",
                            amount: amountFromDialog(),
                            date: dataList[index].date,
                            type: dataList[index].type,
                          ));
                          // get data from db
                          categoriesBloc.getCategories();
                          Navigator.pop(context);
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
                        // update income record
                        DatabaseHelper.db.deleteCategory(dataList[index].id);
                        // get data from db
                        categoriesBloc.getCategories();
                        Navigator.pop(context);
                      },
                    );
                  }),
            );
          },
        ),
      ],
    );
  }

  void navigateToDetails(Category category) async {
    bool update = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          bloc: CategoriesBloc(),
          child: DetailsScreen(
            title: category.title,
            dateTimeMonth: category.date,
          ),
        ),
      ),
    );

    // if update was set, get all the categories again
    if (update != null) {
      categoriesBloc.getCategories();
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
}
