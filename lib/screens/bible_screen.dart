import 'package:flutter/material.dart';
import '../components/nt_book_list.dart';
import '../components/ot_book_list.dart';

class BibleScreen extends StatelessWidget {
  const BibleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text('The Holy Bible'),
            bottom: TabBar(
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'OT'),
                Tab(text: 'NT'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              OTBookList(), // Old Testament books widget
              NTBookList(), // New Testament books widget
            ],
          ),
        ),
      ),
    );
  }
}
