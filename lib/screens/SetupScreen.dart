import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wisebu/data/Category.dart';
import 'package:wisebu/data/Data.dart';
import 'package:wisebu/data/DatabaseHelper.dart';
import 'package:wisebu/screens/MainScreen.dart';
import 'package:wisebu/widgets/Widgets.dart';

class SetupScreen extends StatefulWidget {
  final String buttonText, type;
  final Color color;
  final List<Category> incomesList;

  SetupScreen(
      {@required this.buttonText,
      @required this.color,
      @required this.type,
      this.incomesList});

  @override
  State<StatefulWidget> createState() => SetupScreenState();
}

class SetupScreenState extends State<SetupScreen> {
  TextEditingController dialogTitleController = TextEditingController();
  TextEditingController dialogAmountController = TextEditingController();

  bool isExpenses;
  List<Category> itemsList = [];
  List<Category> selectedIncomes = [];
  List<Category> selectedExpenses = [];

  @override
  void initState() {
    if (widget.type == expenseType) {
      isExpenses = true;
      itemsList = expenses;
    } else {
      isExpenses = false;
      itemsList = incomes;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              itemCount: itemsList.length,
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
                      dialogTitleController.text = itemsList[index].title;

                      dialogAmountController.text =
                          itemsList[index].amount.toString();

                      if (!isSelected(index)) {
                        alertDialog(
                            context: context,
                            title: isExpenses ? "Add expense" : "Add income",
                            hintText: isExpenses ? "Expense" : "Income",
                            titleController: dialogTitleController,
                            amountController: dialogAmountController,
                            onPressedOk: () {
                              setState(() {
                                itemsList[index].title =
                                    dialogTitleController.text.isNotEmpty
                                        ? dialogTitleController.text
                                        : "Income";

                                itemsList[index].amount = dialogAmountController
                                        .text.isNotEmpty
                                    ? double.parse(dialogAmountController.text)
                                    : 0;

                                isExpenses
                                    ? selectedExpenses.add(itemsList[index])
                                    : selectedIncomes.add(itemsList[index]);
                                selectedIncomes.forEach((element) {
                                  print(element.title);
                                });
                              });
                              Navigator.pop(context);
                            });
                      } else
                        setState(() {
                          isExpenses
                              ? selectedExpenses.remove(itemsList[index])
                              : selectedIncomes.remove(itemsList[index]);
                        });
                    },
                    onLongPress: () {
                      setState(() {
                        isExpenses
                            ? selectedExpenses.remove(itemsList[index])
                            : selectedIncomes.remove(itemsList[index]);
                        itemsList.remove(itemsList[index]);
                      });
                    },
                    child: ListTile(
                      title: Text(
                        itemsList[index].title,
                        style: TextStyle(fontSize: 18),
                      ),
                      trailing: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 7,
                              child: FittedBox(
                                child: Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Text("${itemsList[index].amount} €",
                                      style: TextStyle(fontSize: 15)),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 3,
                              child: Icon(
                                isSelected(index)
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: widget.color,
                                size: 35,
                              ),
                            ),
                          ],
                        ),
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
                onPressed: () {
                  setState(() {
                    dialogTitleController.text = "";
                    dialogAmountController.text = "";
                  });
                  alertDialog(
                      context: context,
                      title: isExpenses ? "Add expense" : "Add income",
                      hintText: isExpenses ? "Expense" : "Income",
                      titleController: dialogTitleController,
                      amountController: dialogAmountController,
                      onPressedOk: () {
                        setState(() {
                          Category item = Category(
                              title: dialogTitleController.text.isNotEmpty
                                  ? dialogTitleController.text
                                  : "Income",
                              type: isExpenses ? expenseType : incomeType,
                              date: dateWithZeroTime(DateTime.now()).toString(),
                              amount: dialogAmountController.text.isNotEmpty
                                  ? double.parse(dialogAmountController.text)
                                  : 0);
                          itemsList.add(item);
                          isExpenses
                              ? selectedExpenses.add(item)
                              : selectedIncomes.add(item);
                        });
                        Navigator.pop(context);
                      });
                },
              ),
            ),
            Container(
              margin: EdgeInsets.all(20),
              alignment: Alignment.bottomRight,
              child: yellowButton(
                context: context,
                onPressed: () {
                  if (isExpenses) {
                    dbInsertCategories(
                            incomes: widget.incomesList,
                            expenses: selectedExpenses)
                        .then((value) =>
                            push(context: context, nextScreen: MainScreen()));
                  } else
                    push(
                      context: context,
                      nextScreen: SetupScreen(
                        type: expenseType,
                        incomesList: selectedIncomes,
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

  bool isSelected(int index) {
    return isExpenses
        ? selectedExpenses.contains(itemsList[index])
        : selectedIncomes.contains(itemsList[index]);
  }
}
