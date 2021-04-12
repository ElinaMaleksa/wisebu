import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wisebu/data/Category.dart';
import 'package:wisebu/data/Data.dart';
import 'package:wisebu/data/blocs/BlocProvider.dart';
import 'package:wisebu/data/blocs/CategoriesBloc.dart';
import 'package:wisebu/widgets/Widgets.dart';

class OneRecordScreen extends StatefulWidget {
  final bool isNewExpenseCategory;
  final String date;

  // pass if is not new expense and dropdown with all categories should be shown
  final List<Category> expenseList;
  final String expenseCategoryTitle;

  // pass if edit category
  final Category category;

  OneRecordScreen({
    @required this.isNewExpenseCategory,
    this.date,
    this.expenseList,
    this.expenseCategoryTitle,
    this.category,
  });

  @override
  OneRecordScreenState createState() => OneRecordScreenState();
}

class OneRecordScreenState extends State<OneRecordScreen> {
  CategoriesBloc categoriesBloc;

  TextEditingController titleController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  List<String> categoryTitles = [];
  DateTime dateTime;
  String dropdownValue;
  Category category;

  @override
  void initState() {
    categoriesBloc = BlocProvider.of<CategoriesBloc>(context);

    if (!widget.isNewExpenseCategory && widget.category == null) {
      dropdownValue = widget.expenseCategoryTitle;
      widget.expenseList.forEach((item) {
        categoryTitles.add(item.title);
      });
      // allow dropdown to contain only unique values
      categoryTitles = categoryTitles.toSet().toList();
    }

    if (widget.category != null) {
      category = widget.category;
      titleController.text = category.title;
      descriptionController.text = category.description;
      amountController.text = category.amount.toString();
      dateTime = DateTime.parse(category.date);
    } else
      dateTime =
          widget.date != null ? DateTime.parse(widget.date) : DateTime.now();

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
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop(true);
        return Future.value(false);
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.isNewExpenseCategory
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
                        title: !widget.isNewExpenseCategory && category == null
                            ? "Choose a category"
                            : "Category title"),
                    if (widget.isNewExpenseCategory || category != null)
                      TextField(
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          textInputFormatter,
                        ],
                        enabled: category == null ? true : false,
                        style: TextStyle(
                          color:
                              category == null ? Colors.black : Colors.black45,
                          fontWeight: category == null ? null : FontWeight.bold,
                        ),
                        controller: titleController,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: null,
                        autocorrect: false,
                        maxLength: 30,
                      ),
                    if (!widget.isNewExpenseCategory && category == null)
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
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            textInputFormatter,
                          ],
                          textCapitalization: TextCapitalization.sentences,
                          controller: descriptionController,
                          keyboardType: TextInputType.text,
                          autocorrect: false,
                          maxLines: null,
                          maxLength: 200,
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
                                textInputAction: TextInputAction.done,
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
                              datePicker(
                                context: context,
                              ),
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
                            if (titleController.text.length > 30) {
                              snackBar(
                                  context: context,
                                  infoMessage:
                                      "Please enter a title with valid length!",
                                  backgroundColor:
                                      Theme.of(context).accentColor);
                            } else if (descriptionController.text.length >
                                200) {
                              snackBar(
                                  context: context,
                                  infoMessage:
                                      "Please enter a description with valid length!",
                                  backgroundColor:
                                      Theme.of(context).accentColor);
                            } else if (amountController.text.isEmpty) {
                              snackBar(
                                  context: context,
                                  infoMessage: "Please enter a valid amount!",
                                  backgroundColor:
                                      Theme.of(context).accentColor);
                            } else {
                              if (category == null) {
                                Category category = Category(
                                  title: widget.isNewExpenseCategory
                                      ? titleController.text
                                                  .trimRight()
                                                  .trimLeft()
                                                  .length ==
                                              0
                                          ? "Expense"
                                          : titleController.text
                                              .trimRight()
                                              .trimLeft()
                                      : dropdownValue,
                                  type: expenseType,
                                  date: dateTime.toString(),
                                  amount: double.parse(amountController.text),
                                  description: descriptionController.text
                                      .trimRight()
                                      .trimLeft(),
                                );

                                categoriesBloc.inAddCategory.add(category);
                                Navigator.of(context).pop(true);
                                snackBar(
                                    context: context,
                                    infoMessage: "Record saved!");
                              } else {
                                categoriesBloc.handleUpdateCategory(Category(
                                    id: category.id,
                                    title: titleController.text
                                                .trimRight()
                                                .trimLeft()
                                                .length ==
                                            0
                                        ? "Expense"
                                        : titleController.text
                                            .trimRight()
                                            .trimLeft(),
                                    amount: double.parse(amountController.text),
                                    description: descriptionController.text
                                            .trimRight()
                                            .trimLeft() ??
                                        "",
                                    date: dateTime.toString(),
                                    type: category.type));

                                Navigator.of(context).pop(true);
                                snackBar(
                                    context: context,
                                    infoMessage: "Record updated!");
                              }
                            }
                          },
                          text: "Save"),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget titleText({@required String title}) {
    return Text(
      title,
      style: TextStyle(color: Colors.grey, fontSize: 16),
    );
  }

  Widget datePicker({@required BuildContext context}) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
      onPressed: () {
        hideKeyboard(context);
        if (dateTime.isAfter(firstDate) && dateTime.isBefore(lastDate))
          showDatePicker(
            context: context,
            initialDate: dateTime,
            firstDate: firstDate.add(Duration(days: 1)),
            lastDate: lastDate.subtract(Duration(days: 1)),
          ).then((pickedDate) {
            if (pickedDate != null &&
                pickedDate.isAfter(firstDate) &&
                pickedDate.isBefore(lastDate)) {
              dateTime = pickedDate;
            }
          });
        else
          snackBar(
            context: context,
            infoMessage:
                "Date exceeds more than a year and could not be edited, sorry",
          );
      },
      child: FittedBox(
        child: Text(
          formattedDate(dateTime.toString()),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
