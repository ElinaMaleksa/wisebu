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

  // full expenses list for OneRecordScreen
  final List<Category> expenseList;
  final String dateTimeMonth;
  final bool allowToEditData;

  DetailsScreen(
      {@required this.title,
      @required this.expenseList,
      @required this.dateTimeMonth,
      @required this.allowToEditData});

  @override
  State<StatefulWidget> createState() => DetailsScreenState();
}

class DetailsScreenState extends State<DetailsScreen> {
  // full expenses list for OneRecordScreen
  List<Category> expenseList = [];
  List<Category> itemsList = [];
  double total = 0;
  String categoryTitle;

  CategoriesBloc categoriesBloc;

  @override
  void initState() {
    categoriesBloc = BlocProvider.of<CategoriesBloc>(context);
    expenseList = widget.expenseList;
    categoryTitle = widget.title;
    super.initState();
  }

  setData(List<Category> fullCategoryList) async {
    total = 0;
    itemsList.clear();
    if (fullCategoryList.isNotEmpty)
      for (var i in fullCategoryList)
        if (i.type == expenseType &&
            i.date.substring(0, 7) == widget.dateTimeMonth.substring(0, 7) &&
            i.title == widget.title) {
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
            if (widget.allowToEditData)
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
                      if (dialogTitleController.text != categoryTitle &&
                          dialogTitleController.text.isNotEmpty) {
                        // update record titles in db to new title
                        for (var i in itemsList)
                          categoriesBloc.handleUpdateCategory(Category(
                            id: i.id,
                            title: dialogTitleController.text ?? categoryTitle,
                            amount: i.amount,
                            description: i.description,
                            date: i.date,
                            type: i.type,
                          ));
                      }
                      Navigator.pop(context);
                      // go to MainScreen
                      Navigator.of(context).pop(true);
                      snackBar(
                          context: context,
                          infoMessage: "Category title updated!");
                    },
                  );
                },
              ),
          ],
        ),
        body: StreamBuilder<List<Category>>(
          stream: categoriesBloc.categories,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              setData(snapshot.data);
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
                                    onTap: widget.allowToEditData
                                        ? () {
                                            navigateToOneRecordScreen(
                                              childScreen: OneRecordScreen(
                                                isNewExpenseCategory: false,
                                                category: itemsList[index],
                                              ),
                                            );
                                          }
                                        : null,
                                    onLongPress: widget.allowToEditData
                                        ? () {
                                            simpleAlertDialog(
                                                context: context,
                                                onPressedOk: () {
                                                  categoriesBloc
                                                      .inDeleteCategory
                                                      .add(itemsList[index].id);
                                                  Navigator.pop(context);

                                                  // update local list
                                                  itemsList.removeAt(index);
                                                  if (itemsList.length == 0)
                                                    Navigator.of(context)
                                                        .pop(true);

                                                  snackBar(
                                                      context: context,
                                                      infoMessage:
                                                          "Record deleted!");
                                                },
                                                title: "Delete?",
                                                contentText:
                                                    "This record will be gone forever.");
                                          }
                                        : null,
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
                        if (widget.allowToEditData)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: newItemListTile(
                              text: "Add expense",
                              color: Theme.of(context).accentColor,
                              onPressed: () {
                                navigateToOneRecordScreen(
                                  childScreen: OneRecordScreen(
                                    expenseList: expenseList,
                                    expenseCategoryTitle: categoryTitle,
                                    isNewExpenseCategory: false,
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

  void navigateToOneRecordScreen({@required Widget childScreen}) async {
    bool update = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          bloc: CategoriesBloc(),
          child: childScreen,
        ),
      ),
    );

    // if update was set, get all the categories again
    if (update != null) {
      categoriesBloc.getCategories();
    }
  }
}
