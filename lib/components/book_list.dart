import 'package:flutter/material.dart';
import 'db_helper.dart';

class BookList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bible Books')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper().getBooks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final books = snapshot.data!;
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(books[index]['name']),  // Assuming 'name' column exists
              );
            },
          );
        },
      ),
    );
  }
}
