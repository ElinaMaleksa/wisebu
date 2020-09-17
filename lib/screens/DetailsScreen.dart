import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wisebu/data/Category.dart';
import 'package:wisebu/widgets/Widgets.dart';

class DetailsScreen extends StatefulWidget {
  final String title;

  DetailsScreen({@required this.title});

  @override
  State<StatefulWidget> createState() => DetailsScreenState();
}

class DetailsScreenState extends State<DetailsScreen> {
  List<Category> categoryList = [];
  double total = 0;

  @override
  void initState() {
    for (var i in expenses)
      if (i.title == widget.title) {
        categoryList.add(i);
        // total = total + i.amount;
      }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              height: MediaQuery.of(context).size.height * 0.2,
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
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.15,
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
                    itemCount: categoryList.length,
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
                          child: ListTile(
                            title: Text("Hello"
                                /* DateFormat('dd/MM/yyyy').format(
                                DateTime.parse(categoryList[index].date),
                              ),*/
                                ),
                            trailing: Text("Hey"
                                // "${categoryList[index].amount.toString()} €",
                                ),
                          ),
                        ),
                      );
                    }),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: addNewItem(
                      text: "Add expense",
                      color: Theme.of(context).accentColor,
                      onPressed: () {}),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
