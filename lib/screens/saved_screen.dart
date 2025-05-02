import 'package:flutter/material.dart';
import '../components/db_helper.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  List<Map<String, dynamic>> savedItems = [];
  String selectedFilter = 'All';
  String searchQuery = '';
  String selectedSort = 'Date Added'; // Options: Date Added, Book Order
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedItems();
  }

  void _loadSavedItems() async {
    setState(() {
      isLoading = true;
    });

    List<Map<String, dynamic>> bookmarks = await DatabaseHelper.instance.queryAllBookmarks();
    List<Map<String, dynamic>> highlights = await DatabaseHelper.instance.queryAllHighlights();
    List<Map<String, dynamic>> notes = await DatabaseHelper.instance.queryAllNotes();

    List<Map<String, dynamic>> allItems = [...bookmarks, ...highlights, ...notes];

    List<Map<String, dynamic>> enrichedItems = [];

    for (var item in allItems) {
      Map<String, dynamic>? verseDetails = await DatabaseHelper.getVerseDetails(item['verse_id']);
      enrichedItems.add({...item, ...?verseDetails});
    }

    setState(() {
      savedItems = enrichedItems;
      isLoading = false;
    });
  }




  void _togglePin(int verseId, String table, bool isPinned) async {
    await DatabaseHelper.togglePin(table, verseId, !isPinned);
    _loadSavedItems(); // Refresh list
  }

  List<Map<String, dynamic>> _applyFilters() {
    List<Map<String, dynamic>> filteredItems = savedItems;

    if (selectedFilter == 'Bookmarks') {
      filteredItems =
          savedItems.where((item) => item['type'] == 'bookmark').toList();
    } else if (selectedFilter == 'Highlights') {
      filteredItems =
          savedItems.where((item) => item['type'] == 'highlight').toList();
    } else if (selectedFilter == 'Notes') {
      filteredItems =
          savedItems.where((item) => item['type'] == 'note').toList();
    }

    if (searchQuery.isNotEmpty) {
      filteredItems =
          filteredItems.where((item) {
            return item['text'].toLowerCase().contains(
              searchQuery.toLowerCase(),
            );
          }).toList();
    }

    return filteredItems;
  }

  void sortItems() {
    savedItems.sort((a, b) {
      // Pinned items should come first
      if (a['pinned'] == 1 && b['pinned'] == 0) {
        return -1;
      } else if (a['pinned'] == 0 && b['pinned'] == 1) {
        return 1;
      }

      // If both items are pinned or both are unpinned, sort by the selected option
      if (selectedSort == 'Date Added') {
        return (b['timestamp'] as int).compareTo(a['timestamp'] as int);
      } else if (selectedSort == 'Book Order') {
        return (a['verse_id'] as int).compareTo(b['verse_id'] as int);
      }

      return 0; // Default case (shouldn't happen)
    });
  }


  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> displayItems = _applyFilters();
    sortItems();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('Saved Items'),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: SavedItemsSearchDelegate(savedItems),
                );
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                setState(() => selectedSort = value);
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'Date Added',
                      child: Text('Sort by Date Added'),
                    ),
                    PopupMenuItem(
                      value: 'Book Order',
                      child: Text('Sort by Book Order'),
                    ),
                  ],
            ),
          ],
        ),
        body: Column(
          children: [
            DropdownButton<String>(
              value: selectedFilter,
              onChanged: (value) => setState(() => selectedFilter = value!),
              items:
                  ['All', 'Bookmarks', 'Highlights', 'Notes'].map((filter) {
                    return DropdownMenuItem(value: filter, child: Text(filter));
                  }).toList(),
            ),
            Expanded(
              child: isLoading ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: displayItems.length,
                itemBuilder: (context, index) {
                  final item = displayItems[index];

                  // Define colors and icons for different item types
                  IconData icon;
                  Color borderColor;
                  Color backgroundColor;

                  switch (item['type']) {
                    case 'bookmark':
                      icon = Icons.bookmark;
                      borderColor = Colors.blue;
                      backgroundColor = Colors.blue.withValues(alpha: (0.1))
                      ;
                      break;
                    case 'highlight':
                      icon = Icons.highlight;
                      borderColor = Colors.yellow;
                      backgroundColor = Colors.yellow.withValues(alpha: 0.1);
                      break;
                    case 'note':
                      icon = Icons.note;
                      borderColor = Colors.green;
                      backgroundColor = Colors.green.withValues(alpha: 0.1);
                      break;
                    default:
                      icon = Icons.book;
                      borderColor = Colors.grey;
                      backgroundColor = Colors.transparent;
                  }

                  return Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: borderColor, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: backgroundColor,
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: ListTile(
                      leading: Icon(icon, color: borderColor),
                      title: Text(item['text']),
                      subtitle: Text('${item['bookName']} ${item['chapter']}:${item['verse']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.push_pin, color: item['pinned'] == 1 ? Colors.amber : Colors.grey),
                        onPressed: () {
                          _togglePin(item['verse_id'], '${item['type']}s', item['pinned'] == 1);
                          setState(() {
                            item['pinned'] = item['pinned'] == 1 ? 0 : 1;
                          });
                        },
                      ),
                    ),
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

class SavedItemsSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> items;
  SavedItemsSearchDelegate(this.items);
  bool isLoading = false;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = items.where((item) => item['text'].toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        // Define colors and icons for different item types
        IconData icon;
        Color borderColor;
        Color backgroundColor;

        switch (item['type']) {
          case 'bookmark':
            icon = Icons.bookmark;
            borderColor = Colors.blue;
            backgroundColor = Colors.blue.withValues(alpha: 0.1);
            break;
          case 'highlight':
            icon = Icons.highlight;
            borderColor = Colors.yellow;
            backgroundColor = Colors.yellow.withValues(alpha: 0.1);
            break;
          case 'note':
            icon = Icons.note;
            borderColor = Colors.green;
            backgroundColor = Colors.green.withValues(alpha: 0.1);
            break;
          default:
            icon = Icons.book;
            borderColor = Colors.grey;
            backgroundColor = Colors.transparent;
        }
        return Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          color: backgroundColor,
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: ListTile(
            leading: Icon(icon, color: borderColor),
            title: Text(item['text']),
            subtitle: Text('${item['bookName']} ${item['chapter']}:${item['verse']}'),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}