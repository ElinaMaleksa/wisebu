import 'package:circular_check_box/circular_check_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wisebu/screens/MainScreen.dart';
import 'package:wisebu/widgets/Widgets.dart';

class SetupScreen extends StatefulWidget {
  final String buttonText, appBarTitle;
  final Color color;

  SetupScreen(
      {@required this.buttonText,
      @required this.color,
      @required this.appBarTitle});

  @override
  State<StatefulWidget> createState() => SetupScreenState();
}

class SetupScreenState extends State<SetupScreen> {
  bool isExpenses;

  @override
  void initState() {
    if (widget.appBarTitle == addExpensesTitle)
      isExpenses = true;
    else
      isExpenses = false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarTitle),
        // disable going back from appBar
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: isExpenses ? expenses.length : incomes.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[350],
                      width: 1,
                    ),
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.only(left: 0.0, right: 15),
                  title: Text(
                    isExpenses
                        ? '${expenses[index].title}'
                        : '${incomes[index].title}',
                    style: TextStyle(fontSize: 18),
                  ),
                  leading: Container(
                    color: widget.color,
                    width: 20,
                  ),
                  trailing: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Row(
                      children: [
                        Text(
                          isExpenses
                              ? "${expenses[index].value} €"
                              : "${incomes[index].value} €",
                          style: TextStyle(fontSize: 16),
                        ),
                        Spacer(),
                        CircularCheckBox(
                          onChanged: (value) {
                            setState(() {
                              if (isExpenses)
                                expenses[index].doShow =
                                    !expenses[index].doShow;
                              else
                                incomes[index].doShow = !incomes[index].doShow;
                            });
                          },
                          value: isExpenses
                              ? expenses[index].doShow
                              : incomes[index].doShow,
                          activeColor: widget.color,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.only(left: 0.0, right: 15),
            title: Text(
              "Add category",
              style: TextStyle(fontSize: 18, color: Colors.grey[500]),
            ),
            leading: SizedBox(width: 20),
            trailing: IconButton(
              icon: Icon(
                Icons.add_circle,
                size: 30,
              ),
              color: widget.color,
              onPressed: () {},
            ),
          ),
          Container(
            margin: EdgeInsets.all(20),
            alignment: Alignment.bottomRight,
            child: yellowButton(
              context: context,
              onPressed: () {
                if (isExpenses)
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MainScreen(),
                    ),
                  );
                else
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => SetupScreen(
                        appBarTitle: addExpensesTitle,
                        buttonText: "Finish",
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  );
              },
              text: widget.buttonText,
            ),
          ),
        ],
      ),
    );
  }
}
