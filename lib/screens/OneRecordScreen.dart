import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wisebu/data/Category.dart';
import 'package:wisebu/data/Data.dart';
import 'package:wisebu/data/DatabaseHelper.dart';
import 'package:wisebu/screens/MainScreen.dart';
import 'package:wisebu/widgets/Widgets.dart';

class OneRecordScreen extends StatefulWidget {
  final bool isNewExpense;

  // pass if is not new expense and dropdown with all categories should be shown
  final List<Category> expenseList;
  final String expenseCategoryTitle;

  // pass if edit category
  final Category category;

  OneRecordScreen({
    @required this.isNewExpense,
    this.expenseList,
    this.expenseCategoryTitle,
    this.category,
  });

  @override
  OneRecordScreenState createState() => OneRecordScreenState();
}

class OneRecordScreenState extends State<OneRecordScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  List<String> categoryTitles = [];
  DateTime dateTime;
  String dropdownValue;
  Category category;

  @override
  void initState() {
    if (!widget.isNewExpense && widget.category == null) {
      dropdownValue = widget.expenseCategoryTitle;
      widget.expenseList.forEach((item) {
        categoryTitles.add(item.title);
      });
    }

    if (widget.category != null) {
      category = widget.category;
      titleController.text = category.title;
      descriptionController.text = category.description;
      amountController.text = category.amount.toString();
      dateTime = DateTime.parse(category.date);
    } else
      dateTime = DateTime.now();

    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.isNewExpense
              ? "Add Expense"
              : category == null
                  ? "Add Expense"
                  : "Edit expense"),
        ),
        body: GestureDetector(
          onTap: () {
            // hide keyboard when tapped outside of text field
            hideKeyboard(context);
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleText(
                      title: !widget.isNewExpense && category == null
                          ? "Choose a category"
                          : "Category title"),
                  if (widget.isNewExpense || category != null)
                    TextField(
                      controller: titleController,
                      keyboardType: TextInputType.text,
                    ),
                  if (!widget.isNewExpense && category == null)
                    DropdownButton<String>(
                      value: dropdownValue,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Theme.of(context).primaryColor,
                      ),
                      iconSize: 30,
                      elevation: 16,
                      isExpanded: true,
                      onChanged: (String newValue) {
                        setState(() {
                          dropdownValue = newValue;
                        });
                      },
                      items: categoryTitles
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  SizedBox(height: 25),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleText(title: "Description"),
                      TextField(
                        controller: descriptionController,
                        keyboardType: TextInputType.text,
                      )
                    ],
                  ),
                  SizedBox(height: 25),
                  Row(
                    children: [
                      Flexible(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            titleText(title: "Amount"),
                            TextField(
                              maxLines: 1,
                              controller: amountController,
                              decoration: InputDecoration(
                                suffixIcon: Icon(Icons.euro_symbol, size: 15),
                              ),
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                amountInputFormatter,
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: SizedBox()),
                      Flexible(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            titleText(title: "Date"),
                            SizedBox(
                              height: 10,
                            ),
                            datePicker(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 50),
                    alignment: Alignment.bottomRight,
                    child: yellowButton(
                        context: context,
                        onPressed: () {
                          if (category == null) {
                            if (amountController.text.isEmpty)
                              snackBar(
                                  context: context,
                                  infoMessage: "Please enter a valid amount!",
                                  backgroundColor:
                                      Theme.of(context).accentColor);
                            else {
                              Category category = Category(
                                title: widget.isNewExpense
                                    ? titleController.text ?? "Expense"
                                    : dropdownValue,
                                type: expenseType,
                                date: dateTime.toString(),
                                amount: double.parse(amountController.text),
                                description: descriptionController.text,
                              );

                              dbInsertRecord(category).then((_) {
                                pushReplacement(
                                  context: context,
                                  nextScreen: MainScreen(
                                    showSnackBar: true,
                                    snackBarMessage: "Record saved!",
                                    dateTimeMonth: dateTime.toString(),
                                  ),
                                );
                              });
                            }
                          } else {
                            dbUpdateRecord(
                              index: category.id,
                              title: titleController.text ?? "Expense",
                              amount: double.parse(amountController.text),
                              description: descriptionController.text ?? "",
                              date: dateTime.toString(),
                            ).then((_) {
                              pushReplacement(
                                context: context,
                                nextScreen: MainScreen(
                                  showSnackBar: true,
                                  snackBarMessage: "Record updated!",
                                  dateTimeMonth: dateTime.toString(),
                                ),
                              );
                            });
                          }
                        },
                        text: "Save"),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  Widget titleText({@required String title}) {
    return Text(
      title,
      style: TextStyle(color: Colors.grey, fontSize: 16),
    );
  }

  Widget datePicker() {
    return OutlineButton(
      onPressed: () {
        hideKeyboard(context);
        showDatePicker(
                context: context,
                initialDate: dateTime,
                firstDate: DateTime.now().subtract(Duration(days: 365 * 5)),
                lastDate: DateTime.now())
            .then((pickedDate) {
          if (pickedDate != null) {
            setState(() {
              dateTime = pickedDate;
            });
          }
        });
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Text(
        formattedDate(dateTime.toString()),
        textAlign: TextAlign.center,
      ),
    );
  }
}
