import 'package:flutter/material.dart';
import 'package:the_holy_bible/components/db_helper.dart';

class VerseCard extends StatefulWidget {
  // The verse data as a map.
  final Map<String, dynamic> verse;
  // Whether the verse is bookmarked.
  final bool isBookmarked;
  final bool isHighlighted;
  final VoidCallback onToggleHighlight;
  // Callback for adding a bookmark.
  final VoidCallback onBookmark;
  // Callback for removing a bookmark.
  final VoidCallback onRemoveBookmark;
  // Callback when a note is submitted. Passes the note text.
  final ValueChanged<String> onSubmitNote;
  // Whether the card is in selectable mode.
  final bool isSelectable;
  // Whether the card is currently selected.
  final bool isSelected;
  // Callback when selection state changes.
  final ValueChanged<bool> onSelectionChanged;

  const VerseCard({
    Key? key,
    required this.verse,
    this.isBookmarked = false,
    this.isSelectable = false,
    this.isSelected = false,
    required this.onSelectionChanged,
    required this.onBookmark,
    required this.onRemoveBookmark,
    required this.onSubmitNote, required this.isHighlighted, required this.onToggleHighlight,
  }) : super(key: key);

  @override
  _VerseCardState createState() => _VerseCardState();
}

class _VerseCardState extends State<VerseCard> with SingleTickerProviderStateMixin {
  // Controls whether the expanded options are visible.
  bool _showOptions = false;
  // Controls if the note input box is visible.
  bool _showNoteInput = false;
  // Controls if the highlight input box is visible.
  bool _showHighlightInput = false;
  // Controls if the list of notes is visible.
  bool _showNotesList = false;

  // Controller for the note input field.
  final TextEditingController _noteController = TextEditingController();
  // Controller for the highlight note input field.
  final TextEditingController _highlightController = TextEditingController();

  // Toggle the options area on long press.
  void _handleLongPress() {
    setState(() {
      // Hide any note or highlight inputs or notes list if showing.
      _showNoteInput = false;
      _showHighlightInput = false;
      _showNotesList = false;
      _showOptions = !_showOptions;
    });
  }

  // Toggle note input visibility.
  void _toggleNoteInput() {
    setState(() {
      _showNoteInput = !_showNoteInput;
      // Hide others.
      if (_showNoteInput) {
        _showNotesList = false;
      }
    });
  }

  // Toggle notes list visibility.
  void _toggleNotesList() {
    setState(() {
      _showNotesList = !_showNotesList;
      // Hide note input if showing.
      if (_showNotesList) _showNoteInput = false;
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.isSelected ? Theme.of(context).colorScheme.primary : widget.isHighlighted ? Theme.of(context).colorScheme.secondary : null,
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        onLongPress: _handleLongPress,
        onTap: () {
          // If in selection mode, toggle selection on tap.
          if (widget.isSelectable) {
            widget.onSelectionChanged(!widget.isSelected);
          }
        },
        child: AnimatedSize(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Verse text row with an optional bookmark indicator.
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('${widget.verse['verse']}. ${widget.verse['text']}', style: TextStyle(
                        backgroundColor: Colors.transparent,
                      ),),
                    ),
                    if (widget.isBookmarked)
                      Icon(Icons.bookmark, color: Colors.amber),
                  ],
                ),
              ),
              // Expanded options row.
              if (_showOptions)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Bookmark / Remove Bookmark Button.
                      ElevatedButton.icon(
                        onPressed: () {
                          if (widget.isBookmarked) {
                            print("Removing bookmark for verse id: ${widget.verse['id']}");
                            widget.onRemoveBookmark();
                          } else {
                            print("Bookmarking verse id: ${widget.verse['id']}");
                            widget.onBookmark();
                          }
                        },
                        icon: Icon(widget.isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                        label: Text(widget.isBookmarked ? 'Remove Bookmark' : 'Bookmark'),
                      ),
                      // Note Button: toggles note input box.
                      ElevatedButton.icon(
                        onPressed: _toggleNoteInput,
                        icon: Icon(Icons.note),
                        label: Text('Note'),
                      ),
                      // Note Count Button: toggles notes list view.
                      ElevatedButton(
                        onPressed: _toggleNotesList,
                        child: FutureBuilder(
                          future: DatabaseHelper.instance.getNoteCount(widget.verse['id']),
                          builder: (context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return SizedBox(
                                  width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
                            }
                            return Text('Notes: ${snapshot.data.toString()}');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              // Note input field area.
              if (_showNoteInput)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          hintText: 'Enter your note...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      ElevatedButton(
                        onPressed: () {
                          final noteText = _noteController.text.trim();
                          if (noteText.isNotEmpty) {
                            print("Submitting note for verse id: ${widget.verse['id']}: $noteText");
                            widget.onSubmitNote(noteText);
                            _noteController.clear();
                            setState(() {
                              _showNoteInput = false;
                            });
                          }
                        },
                        child: Text('Save Note'),
                      ),
                    ],
                  ),
                ),
              // Notes list area.
              if (_showNotesList)
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseHelper.instance.queryAllNotes(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('No notes yet.'),
                      );
                    }
                    // Filter notes for this verse.
                    final allNotes = snapshot.data!;
                    final verseNotes = allNotes
                        .where((row) => row[DatabaseHelper.noteVerseId] == widget.verse['id'])
                        .toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: verseNotes.map((note) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                          child: Text('- ${note[DatabaseHelper.noteText]}'),
                        );
                      }).toList(),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
