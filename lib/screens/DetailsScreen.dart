import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wisebu/data/Category.dart';
import 'package:wisebu/data/Data.dart';
import 'package:wisebu/data/blocs/BlocProvider.dart';
import 'package:wisebu/data/blocs/CategoriesBloc.dart';
import 'package:wisebu/screens/OneRecordScreen.dart';
import 'package:wisebu/widgets/Widgets.dart';

class DetailsScreen extends StatefulWidget {
  final String title;
  final String dateTimeMonth;

  DetailsScreen({@required this.title, @required this.dateTimeMonth});

  @override
  State<StatefulWidget> createState() => DetailsScreenState();
}

class DetailsScreenState extends State<DetailsScreen> {
  List<Category> itemsList = [];
  double total = 0;
  String categoryTitle;

  CategoriesBloc categoriesBloc;

  @override
  void initState() {
    categoriesBloc = BlocProvider.of<CategoriesBloc>(context);
    categoryTitle = widget.title;
    super.initState();
  }

  setData(List<Category> fullCategoryList) {
    total = 0;
    itemsList.clear();
    if (fullCategoryList.isNotEmpty)
      for (var i in fullCategoryList)
        if (i.type == expenseType && i.date == widget.dateTimeMonth) {
          total = total + i.amount;
          itemsList.add(i);
        }
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
          title: Text("Category details"),
          actions: [
            inkwellIcon(
              tooltip: "Edit category title",
              iconData: Icons.edit,
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
                    /*if (dialogTitleController.text != categoryTitle &&
                        dialogTitleController.text.isNotEmpty) {
                      // update record titles in db to new title
                      for (var i in itemsList)
                        await DatabaseHelper.db.dbUpdateRecord(
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
                    Navigator.pop(context);*/
                  },
                );
              },
            ),
          ],
        ),
        body: StreamBuilder<List<Category>>(
          // TODO: get all category records from db, not group of them
          stream: categoriesBloc.categories,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
                return Text('No categories');
              }

              List<Category> categories = snapshot.data;
              setData(categories);

              return Column(
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                          Flexible(
                            flex: 4,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: circleAvatar(
                                  color: Colors.white,
                                  textColor: Theme.of(context).accentColor,
                                  mainText:
                                      "-${amountTextShown(amount: total)} €"),
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
                                          isNewExpenseCategory: false,
                                          category: itemsList[index],
                                        ),
                                      );
                                    },
                                    onLongPress: () {
                                      /* simpleAlertDialog(
                                      context: context,
                                      onPressedOk: () {
                                        DatabaseHelper.db.dbDeleteRecord(id: itemsList[index].id)
                                            .then((_) {
                                          resetData();
                                          Navigator.pop(context);
                                        });
                                      },
                                      title: "Delete?",
                                      contentText:
                                          "This record will be gone forever.");*/
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 20),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            flex: 3,
                                            child: FittedBox(
                                              child: Text(
                                                formattedDate(
                                                    itemsList[index].date),
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            flex: 5,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                itemsList[index].description ??
                                                    "",
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
                                                "${amountTextShown(amount: itemsList[index].amount)} €",
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
                                nextScreen: BlocProvider(
                                  bloc: CategoriesBloc(),
                                  child: OneRecordScreen(
                                    expenseCategoryTitle: categoryTitle,
                                    isNewExpenseCategory: false,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              );
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
