import 'package:flutter/material.dart';
import 'package:wisebu/data/Category.dart';
import 'package:wisebu/data/blocs/bloc_provider.dart';
import 'package:wisebu/data/blocs/categories_bloc.dart';

class AnalyticsScreen extends StatefulWidget {
  AnalyticsScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  AnalyticsScreenState createState() => AnalyticsScreenState();
}

class AnalyticsScreenState extends State<AnalyticsScreen> {
  CategoriesBloc categoriesBloc;

  @override
  void initState() {
    super.initState();

    // Thanks to the BlocProvider providing this page with the CategoriesBloc,
    // we can simply use this to retrieve it
    categoriesBloc = BlocProvider.of<CategoriesBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              // The StreamBuilder allows us to make use of our streams and display
              // that data on our page. It automatically updates when the stream updates.
              // Whenever you want to display stream data, you'll use the StreamBuilder.
              child: StreamBuilder<List<Category>>(
                stream: categoriesBloc.categories,
                builder: (BuildContext context,
                    AsyncSnapshot<List<Category>> snapshot) {
                  print(snapshot.data);
                  // Make sure data exists and is actually loaded
                  if (snapshot.hasData) {
                    // If there are no notes (data), display this message.
                    if (snapshot.data.length == 0) {
                      return Text('No notes');
                    }

                    List<Category> categories = snapshot.data;

                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        Category category = categories[index];

                        return GestureDetector(
                          onTap: () {
                            //_navigateToNote(note);
                          },
                          child: Container(
                            height: 40,
                            child: Text(
                              'Category ' + category.id.toString(),
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  // If the data is loading in, display a progress indicator
                  // to indicate that. You don't have to use a progress
                  // indicator, but the StreamBuilder has to return a widget.
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
