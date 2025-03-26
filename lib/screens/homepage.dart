import 'package:flutter/material.dart';

import '../components/book_list.dart';


class MyHomePage extends StatelessWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(title)), body: BookList(),);
  }
}
