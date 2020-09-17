import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wisebu/data/Category.dart';
import 'package:wisebu/data/DatabaseHelper.dart';
import 'package:wisebu/screens/MainScreen.dart';
import 'package:wisebu/widgets/Widgets.dart';

class SetupScreen extends StatefulWidget {
  final String buttonText, type;
  final Color color;

  SetupScreen(
      {@required this.buttonText, @required this.color, @required this.type});

  @override
  State<StatefulWidget> createState() => SetupScreenState();
}

class SetupScreenState extends State<SetupScreen> {
  TextEditingController dialogTitleController = TextEditingController();
  TextEditingController dialogAmountController = TextEditingController();
  Future<List<Category>> getCategoriesFromFuture;
  bool isExpenses;

  Future<List<Category>> dbGetCategories() async {
    return await dbGetCategoriesByType(widget.type);
  }

  @override
  void initState() {
    if (widget.type == expenseType)
      isExpenses = true;
    else
      isExpenses = false;

    getCategoriesFromFuture = dbGetCategories();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
        // get categories by type
        future: getCategoriesFromFuture,
        builder:
            (BuildContext context, AsyncSnapshot<List<Category>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            default:
              return Scaffold(
                appBar: AppBar(
                  title: Text(isExpenses ? addExpensesTitle : addIncomesTitle),
                  // disable going back from appBar
                  automaticallyImplyLeading: !isExpenses ? false : true,
                ),
                body: Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: ListView(
                    children: [
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[350],
                                  width: 1,
                                ),
                                left: BorderSide(
                                  color: widget.color,
                                  width: 20,
                                ),
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                dialogTitleController.text =
                                    snapshot.data[index].title;

                                /*dialogAmountController.text = isExpenses
                            ? expenses[index].amount.toString()
                            : incomes[index].amount.toString();*/

                                if (snapshot.data[index].doShow == 0)
                                  alertDialog(
                                      context: context,
                                      title: isExpenses
                                          ? "Add expense"
                                          : "Add income",
                                      labelText:
                                          isExpenses ? "Expense" : "Income",
                                      titleController: dialogTitleController,
                                      amountController: dialogAmountController,
                                      onPressedOk: () {
                                        setState(() {
                                          snapshot.data[index].title =
                                              dialogTitleController
                                                      .text.isNotEmpty
                                                  ? dialogTitleController.text
                                                  : "Income";
                                        });

                                        Navigator.pop(context);
                                      });
                              },
                              child: ListTile(
                                title: Text(
                                  snapshot.data[index].title,
                                  style: TextStyle(fontSize: 18),
                                ),
                                trailing: Icon(
                                  snapshot.data[index].doShow == 1
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: widget.color,
                                  size: 35,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: addNewItem(
                            text: "Add category",
                            color: widget.color,
                            onPressed: () {}),
                      ),
                      Container(
                        margin: EdgeInsets.all(20),
                        alignment: Alignment.bottomRight,
                        child: yellowButton(
                          context: context,
                          onPressed: () {
                            if (isExpenses)
                              push(context: context, nextScreen: MainScreen());
                            else
                              push(
                                context: context,
                                nextScreen: SetupScreen(
                                  type: expenseType,
                                  buttonText: "Finish",
                                  color: Theme.of(context).accentColor,
                                ),
                              );
                          },
                          text: widget.buttonText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
          }
        });
  }
}
