import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wisebu/data/Category.dart';
import 'package:wisebu/data/Data.dart';
import 'package:wisebu/data/DatabaseHelper.dart';
import 'package:wisebu/screens/DetailsScreen.dart';
import 'package:wisebu/widgets/Widgets.dart';

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  PageController pageController = PageController(initialPage: 999);
  Future<List<Category>> futureIncomeList, futureExpenseList;
  Future<String> futureTotal;
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
    return Scaffold(
      appBar: AppBar(
        title: Text("BUDGET"),
        // disable going back from appBar
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
              )),
        ],
      ),
    );
  }

  Widget header({context,
    showDateForward,
    changeText(showDateForward),
    String text,
    double headerHeight,
    double arrowSize}) {
    return Container(
      height: MediaQuery
          .of(context)
          .size
          .height * headerHeight,
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            padding: EdgeInsets.only(left: 10),
            icon: Icon(Icons.arrow_back_ios,
                size: MediaQuery
                    .of(context)
                    .size
                    .width * arrowSize),
            color: Theme
                .of(context)
                .primaryColor,
            onPressed: () =>
            {showDateForward = false, changeText(showDateForward)},
          ),
          Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontSize:
              MediaQuery
                  .of(context)
                  .size
                  .height * headerHeight * 0.35,
            ),
          ),
          IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            padding: EdgeInsets.only(right: 10),
            icon: Icon(Icons.arrow_forward_ios,
                size: MediaQuery
                    .of(context)
                    .size
                    .width * arrowSize),
            color: Theme
                .of(context)
                .primaryColor,
            onPressed: () =>
            {showDateForward = true, changeText(showDateForward)},
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
          height: MediaQuery
              .of(context)
              .size
              .height * 0.2,
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
                        color: Theme
                            .of(context)
                            .primaryColor,
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
                        color: Theme
                            .of(context)
                            .accentColor,
                        width: 20,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 65,
                backgroundColor: Theme
                    .of(context)
                    .primaryColor,
                child: Container(
                  padding: EdgeInsets.all(20),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: FittedBox(
                          child: Text(
                            "${totalIncomes - totalExpenses} €",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Text(
                        "left",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        categoryData(
            context: context,
            title: incomeType,
            dataList: incomeList,
            color: Theme
                .of(context)
                .primaryColor),
        categoryData(
            context: context,
            title: expenseType,
            dataList: expenseList,
            color: Theme
                .of(context)
                .accentColor)
      ],
    );
  }

  Widget categoryData({@required BuildContext context,
    @required String title,
    @required List<Category> dataList,
    @required Color color}) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          height: 60,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: color,
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity(horizontal: -4),
                onPressed: () {},
                icon: Icon(Icons.add_circle, size: 35, color: color),
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
                  showIcon: title == incomeType ? false : true,
                  title: dataList[index].title,
                  moneyAmount: "${calcTotal(dataList[index].title)}",
                  //"${dataList[index].amount.toString()} €",
                  color: color,
                  onPressed: () {
                    if (title != incomeType)
                      push(
                        context: context,
                        nextScreen: DetailsScreen(
                          title: dataList[index].title,
                          list: expenseList,
                        ),
                      );
                  }),
            );
          },
        ),
      ],
    );
  }

  Future<List<Category>> dbGetCategories(type) async {
    return await dbGetCategoriesByType(type);
  }

  Future<String> calc(title) async {
    return await calculateTotal(title);
  }

  List<String> calcTotal(title) {
    futureTotal = calc(title);
    futureTotal.then((value) {
      // print(value);
    });
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
}
