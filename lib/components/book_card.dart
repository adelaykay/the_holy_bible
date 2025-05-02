import 'package:flutter/material.dart';
import '../screens/verses_display.dart';
import 'db_helper.dart';

class BookCard extends StatefulWidget {
  final int bookId;
  final String bookName;

  const BookCard({Key? key, required this.bookId, required this.bookName}) : super(key: key);

  @override
  _BookCardState createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  late Future<List<int>> chaptersFuture;

  @override
  void initState() {
    super.initState();
    chaptersFuture = DatabaseHelper.instance.getChaptersForBook(widget.bookId);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        title: Text(widget.bookName),
        children: [
          FutureBuilder<List<int>>(
            future: chaptersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('No chapters available'),
                );
              }
              final chapters = snapshot.data!;
              return GridView.builder(
                padding: EdgeInsets.all(8.0),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                  childAspectRatio: 2.0,
                ),
                itemCount: chapters.length,
                itemBuilder: (context, index) {
                  final chapterNumber = chapters[index];
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VersesDisplay(
                            bookId: widget.bookId,
                            chapter: chapterNumber,
                            bookName: widget.bookName,
                          ),
                        ),
                      );
                    },
                    child: Text(chapterNumber.toString()),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
