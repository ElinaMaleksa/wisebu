import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wisebu/data/Category.dart';
import 'package:wisebu/data/Data.dart';
import 'package:wisebu/data/DatabaseHelper.dart';
import 'package:wisebu/screens/OneRecordScreen.dart';
import 'package:wisebu/screens/MainScreen.dart';
import 'package:wisebu/widgets/Widgets.dart';

class DetailsScreen extends StatefulWidget {
  final String title;
  final List<Category> expenseList;
  final String dateTimeMonth;

  DetailsScreen(
      {@required this.title,
      @required this.expenseList,
      @required this.dateTimeMonth});

  @override
  State<StatefulWidget> createState() => DetailsScreenState();
}

class DetailsScreenState extends State<DetailsScreen> {
  List<Category> expenseList = [];
  Future<List<Category>> futureList;
  List<Category> itemsList = [];
  double total = 0;
  String categoryTitle;

  Future<List<Category>> dbGetCategories(title) async {
    return await dbGetRecordsByTitle(title, widget.dateTimeMonth);
  }

  void setData() {
    futureList = dbGetCategories(categoryTitle);
    futureList.then((list) {
      if (this.mounted)
        setState(() {
          list.forEach((item) {
            itemsList.add(item);
            total = total + item.amount;
          });
        });
    });
  }

  @override
  void initState() {
    expenseList = widget.expenseList;
    categoryTitle = widget.title;
    setData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Category details"),
          actions: [
            Tooltip(
              message: "Edit category title",
              child: InkWell(
                customBorder: CircleBorder(),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Icon(Icons.edit),
                ),
                onTap: () {
                  setState(() {
                    dialogTitleController.text = categoryTitle;
                    dialogAmountController.text = total.toString();
                  });
                  alertDialogWithFields(
                    context: context,
                    title: "Edit category title",
                    hintText: "Category title",
                    enabled: false,
                    onPressedOk: () async {
                      if (dialogTitleController.text != categoryTitle &&
                          dialogTitleController.text.isNotEmpty) {
                        // update record titles in db to new title
                        for (var i in itemsList)
                          await dbUpdateRecord(
                            index: i.id,
                            title: dialogTitleController.text ?? categoryTitle,
                            amount: i.amount,
                            description: i.description,
                            date: i.date,
                          );

                        setState(() {
                          // update titles in expenseList to "Add expense" work properly
                          for (var i in expenseList)
                            if (i.title == categoryTitle)
                              i.title = dialogTitleController.text;

                          // update category title
                          categoryTitle =
                              dialogTitleController.text ?? categoryTitle;
                        });
                        resetData();
                      }
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            )
          ],
        ),
        body: Column(
          children: [
            Arc(
              height: 30,
              child: Container(
                color: Theme.of(context).accentColor,
                padding: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.05,
                    left: MediaQuery.of(context).size.width * 0.1,
                    bottom: 15),
                height: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 6,
                      child: Text(
                        categoryTitle,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: circleAvatar(
                            color: Colors.white,
                            textColor: Theme.of(context).accentColor,
                            mainText: "-${total.toStringAsFixed(2)} €"),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: itemsList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[350],
                                  width: 1,
                                ),
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                push(
                                  context: context,
                                  nextScreen: OneRecordScreen(
                                    isNewExpense: false,
                                    category: itemsList[index],
                                  ),
                                );
                                /*  setState(() {
                                  dialogTitleController.text =
                                      itemsList[index].title;
                                  dialogAmountController.text =
                                      itemsList[index].amount.toString();
                                });
                                alertDialogWithFields(
                                  context: context,
                                  title: "Edit expense",
                                  hintText: "Expense",
                                  onPressedOk: () {
                                    dbUpdateRecord(
                                      index: itemsList[index].id,
                                      title: dialogTitleController.text ??
                                          "Expense",
                                      amount: amountFromDialog(),
                                    ).then((_) {
                                      resetData();
                                      Navigator.pop(context);
                                    });
                                  },
                                );*/
                              },
                              onLongPress: () {
                                simpleAlertDialog(
                                    context: context,
                                    onPressedOk: () {
                                      dbDeleteRecord(id: itemsList[index].id)
                                          .then((_) {
                                        resetData();
                                        Navigator.pop(context);
                                      });
                                    },
                                    title: "Delete?",
                                    contentText:
                                        "This record will be gone forever.");
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      flex: 3,
                                      child: FittedBox(
                                        child: Text(
                                          formattedDate(itemsList[index].date),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 5,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          itemsList[index].description ?? "",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 2,
                                      child: FittedBox(
                                        child: Text(
                                          "${itemsList[index].amount.toStringAsFixed(2)} €",
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: newItemListTile(
                      text: "Add expense",
                      color: Theme.of(context).accentColor,
                      onPressed: () {
                        push(
                          context: context,
                          nextScreen: OneRecordScreen(
                            expenseList: expenseList,
                            expenseCategoryTitle: categoryTitle,
                            isNewExpense: false,
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> onWillPop() async {
    pushReplacement(
      context: context,
      nextScreen: MainScreen(
        dateTimeMonth: itemsList.isNotEmpty
            ? itemsList[0].date
            : DateTime.now().toString(),
      ),
    );
    // return true if the route to be popped
    return false;
  }

  void resetData() {
    setState(() {
      total = 0;
      itemsList.clear();
      setData();
    });
  }
}
