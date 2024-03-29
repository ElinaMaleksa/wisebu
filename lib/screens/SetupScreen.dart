import 'package:flutter/material.dart';
import 'package:wisebu/data/Category.dart';
import 'package:wisebu/data/Data.dart';
import 'package:wisebu/data/blocs/BlocProvider.dart';
import 'package:wisebu/data/blocs/CategoriesBloc.dart';
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
    return WillPopScope(
      onWillPop: () async => isExpenses ? true : false,
      child: Scaffold(
        appBar: AppBar(
          title: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(isExpenses ? addExpensesTitle : addIncomesTitle)),
          // disable going back from appBar
          automaticallyImplyLeading: isExpenses ? true : false,
        ),
        body: ListView(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: itemsList.length,
                itemBuilder: (cont, index) {
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
                            itemsList[index].amount == 0.0
                                ? ""
                                : itemsList[index].amount.toString();

                        if (!isSelected(index)) {
                          alertDialog(
                              context: context,
                              haveTextFields: true,
                              title: isExpenses
                                  ? expenseDialogTitle
                                  : incomeDialogTitle,
                              hintText: isExpenses ? expenseType : incomeType,
                              onPressedOk: () {
                                setState(() {
                                  itemsList[index].title =
                                      titleFromDialog(itemsList[index].type);

                                  itemsList[index].amount =
                                      dialogAmountController.text.isNotEmpty
                                          ? double.parse(
                                              dialogAmountController.text)
                                          : 0;

                                  isExpenses
                                      ? selectedExpenses.add(itemsList[index])
                                      : selectedIncomes.add(itemsList[index]);
                                  selectedIncomes.forEach((element) {});
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
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                itemsList[index].title,
                                style: TextStyle(fontSize: 17),
                              ),
                            ),
                          ],
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
                                    child: Text(
                                        "${amountTextShown(amount: itemsList[index].amount)} €",
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
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: newItemListTile(
                text: "Add category",
                color: widget.color,
                onPressed: () {
                  setState(() {
                    dialogTitleController.text = "";
                    dialogAmountController.text = "";
                  });
                  alertDialog(
                      context: context,
                      haveTextFields: true,
                      title:
                          isExpenses ? expenseDialogTitle : incomeDialogTitle,
                      hintText: isExpenses ? expenseType : incomeType,
                      onPressedOk: () {
                        bool alreadyExists = doExist(
                            title: titleFromDialog(widget.type),
                            type: widget.type,
                            itemsList: itemsList);

                        if (alreadyExists) {
                          alertDialog(
                              haveTextFields: false,
                              context: context,
                              onPressedOk: () => Navigator.pop(context),
                              title: "Sorry",
                              contentText: "Category already exists.");
                        } else {
                          setState(() {
                            Category item = Category(
                                title: titleFromDialog(
                                    isExpenses ? expenseType : incomeType),
                                type: isExpenses ? expenseType : incomeType,
                                date:
                                    dateWithZeroTime(DateTime.now()).toString(),
                                amount: amountFromDialog());
                            itemsList.add(item);
                            isExpenses
                                ? selectedExpenses.add(item)
                                : selectedIncomes.add(item);
                          });
                        }
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
                    pushReplacement(
                        context: context,
                        nextScreen: BlocProvider(
                            bloc: CategoriesBloc(),
                            child: MainScreen(
                              incomesSetUpList: widget.incomesList,
                              expensesSetUpList: selectedExpenses,
                            )));
                  } else
                    push(
                      context: context,
                      nextScreen: SetupScreen(
                        type: expenseType,
                        incomesList: selectedIncomes,
                        buttonText: "Finish",
                        color: Theme.of(context).colorScheme.secondary,
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
