import 'package:flutter/material.dart';
import '../components/db_helper.dart';
import '../components/verse_card.dart';

class VersesDisplay extends StatefulWidget {
  final int bookId;
  final int chapter;
  final String bookName;

  const VersesDisplay({
    super.key,
    required this.bookId,
    required this.chapter,
    required this.bookName,
  });

  @override
  State<VersesDisplay> createState() => _VersesDisplayState();
}

class _VersesDisplayState extends State<VersesDisplay> {
  // Flag to control if we're in multi-select mode.
  bool isSelectionMode = false;
  // Store the IDs (or indexes) of selected verses.
  Set<int> selectedVerseIds = {};
  Set<int> bookmarkedVerseIds = {};
  Set<int> highlightedVerseIds = {}; // Tracks already-highlighted verses.

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
    _loadHighlights();
  }

  void _loadBookmarks() async {
    List<Map<String, dynamic>> bookmarks =
        await DatabaseHelper.instance.queryAllBookmarks();
    // Extract the verse ids from each bookmark row.
    setState(() {
      bookmarkedVerseIds =
          bookmarks
              .map((row) => row[DatabaseHelper.bookmarkVerseId] as int)
              .toSet();
    });
  }

  // Bookmark callback.
  void _bookmarkVerse(Map<String, dynamic> verse) {
    // Implement your bookmark functionality here.
    int verseId = verse['id'];
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String userId = 'user1';

    Map<String, dynamic> bookmarkRow = {
      DatabaseHelper.bookmarkVerseId: verseId,
      DatabaseHelper.bookmarkTimestamp: timestamp,
      DatabaseHelper.bookmarkUserId: userId,
    };
    DatabaseHelper.instance.insertBookmark(bookmarkRow);
    print('Bookmarked verse: ${verse['verse']}');

    // Refresh the bookmarked verses set.
    _loadBookmarks();
  }

  // Remove bookmark callback.
  void _removeBookmark(Map<String, dynamic> verse) {
    // Implement your remove bookmark functionality here.
    int verseId = verse['id'];
    DatabaseHelper.instance.deleteBookmark(verseId);
    print('Removed bookmark from verse: ${verse['verse']}');

    // Refresh the bookmarked verses set.
    _loadBookmarks();
  }

  // Note callback.
  void _noteVerse(Map<String, dynamic> verse, String noteText) {
    // Implement your note functionality here.
    int verseId = verse['id'];
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String userId = 'user1';
    String note = noteText;

    Map<String, dynamic> noteRow = {
      DatabaseHelper.noteVerseId: verseId,
      DatabaseHelper.noteText: note,
      DatabaseHelper.noteTimestamp: timestamp,
      DatabaseHelper.noteUserId: userId,
    };
    DatabaseHelper.instance.insertNote(noteRow);
    print('Noteed on verse: ${verse['verse']}');
  }

  // Toggle selection for a verse.
  void _toggleSelection(int verseId, bool selected) {
    setState(() {
      if (selected) {
        selectedVerseIds.add(verseId);
      } else {
        selectedVerseIds.remove(verseId);
      }
    });
  }

  void _loadHighlights() async {
    List<Map<String, dynamic>> highlights =
        await DatabaseHelper.instance.queryAllHighlights();
    setState(() {
      highlightedVerseIds =
          highlights
              .map((row) => row[DatabaseHelper.highlightVerseId] as int)
              .toSet();
    });
  }

  // Example method to apply highlighting to selected verses.
  void _toggleHighlight() {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String userId = 'user1';
    String color = Theme.of(context).colorScheme.primary.toString();

    for (int verseId in selectedVerseIds) {
      if (highlightedVerseIds.contains(verseId)) {
        // If the verse is already highlighted, remove the highlight.
        DatabaseHelper.instance.deleteHighlight(verseId);
        print('Removed highlight from verse ID: $verseId');
        highlightedVerseIds.remove(verseId); // Update the state.
      } else {
        // Apply a new highlight if it's not already highlighted.
        DatabaseHelper.instance.insertHighlight({
          DatabaseHelper.highlightVerseId: verseId,
          DatabaseHelper.highlightColor: color,
          DatabaseHelper.highlightTimestamp: timestamp,
          DatabaseHelper.highlightUserId: userId,
        });
        print('Highlighted verse ID: $verseId');
        highlightedVerseIds.add(verseId); // Update the state.
      }
    }
    setState(() {
      selectedVerseIds.clear(); // Clear the selection.
      isSelectionMode = false; // Exit selection mode.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.bookName} ${widget.chapter}'),
        actions: [
          // Toggle button for selection mode.
          IconButton(
            icon: Icon(isSelectionMode ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                isSelectionMode = !isSelectionMode;
                // Clear any previous selection if exiting selection mode.
                if (!isSelectionMode) selectedVerseIds.clear();
              });
            },
          ),
          // Show a highlight button if in selection mode.
          if (isSelectionMode)
            IconButton(
              icon: Icon(Icons.highlight),
              onPressed: _toggleHighlight,
            ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.getVerses(
          widget.bookId,
          widget.chapter,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No verses available'));
          }
          final verses = snapshot.data!;
          return ListView.builder(
            itemCount: verses.length,
            itemBuilder: (context, index) {
              final verse = verses[index];
              final verseId = verse['id'] as int;
              return VerseCard(
                verse: verse,
                isSelectable: isSelectionMode,
                isSelected: selectedVerseIds.contains(verseId),
                // Here we pass the bookmarked state:
                isBookmarked: bookmarkedVerseIds.contains(verseId),
                onSelectionChanged:
                    (selected) => _toggleSelection(verseId, selected),
                onBookmark: () => _bookmarkVerse(verse),
                onRemoveBookmark: () => _removeBookmark(verse),
                onSubmitNote:
                    (String noteText) => _noteVerse(verse, noteText),
                onToggleHighlight: () => _toggleHighlight(),
                isHighlighted: highlightedVerseIds.contains(verseId),
              );
            },
          );
        },
      ),
    );
  }
}
