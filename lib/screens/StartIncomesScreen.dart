import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StartIncomesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StartIncomesScreenState();
}

class StartIncomesScreenState extends State<StartIncomesScreen> {
  List<String> items = ['Salary', 'Scholarship'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add incomes for current month'),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Container(
                      width: 30,
                      height: 40,
                      color: Colors.green,
                    ),
                    Text(
                      '${items[index]}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Spacer(),
                    Container(
                      child: Text(
                        '__ eur',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text('Checkbox'),
                    ),
                  ],
                );
              },
            ),
          ],
        ));
  }
}
