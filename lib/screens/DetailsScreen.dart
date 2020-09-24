import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wisebu/data/Category.dart';
import 'package:wisebu/data/DatabaseHelper.dart';
import 'package:wisebu/screens/AddRecordScreen.dart';
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
  Future<List<Category>> futureList;
  List<Category> itemsList = [];
  double total = 0;

  Future<List<Category>> dbGetCategories(title) async {
    return await dbGetRecordsByTitle(title, widget.dateTimeMonth);
  }

  void setData() {
    futureList = dbGetCategories(widget.title);
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
                        widget.title,
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
                            mainText: "-$total €"),
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
                                setState(() {
                                  dialogTitleController.text =
                                      itemsList[index].title;
                                  dialogAmountController.text =
                                      itemsList[index].amount.toString();
                                });
                                alertDialogFields(
                                  context: context,
                                  title: "Edit expense",
                                  hintText: "Expense",
                                  onPressedOk: () {
                                    dbUpdateRecord(
                                            index: itemsList[index].id,
                                            title: dialogTitleController.text ??
                                                "Expense")
                                        .then((_) {
                                      resetData();
                                      Navigator.pop(context);
                                    });
                                  },
                                );
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
                              child: ListTile(
                                title: Text(
                                  formattedDate(itemsList[index].date),
                                ),
                                trailing: Text(
                                  "${itemsList[index].amount} €",
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
                          nextScreen: AddRecordScreen(
                            expenseList: widget.expenseList,
                            expenseCategoryTitle: widget.title,
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
