import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = "";
  bool matchCase = false;
  bool exactMatch = false;
  bool fuzzySearch = true;
  String selectedScope = "Entire Bible";
  String selectedSortOrder = "Relevance";
  List<String> recentSearches = ["Love", "Faith", "John 3:16", "Psalm 23"];
  List<String> searchScopes = ["Entire Bible", "Old Testament", "New Testament", "Saved Items"];
  List<String> sortOrders = ["Relevance", "Chronological"];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text("Search"),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
            ),
            _buildFilterChips(),
            SizedBox(height: 16),
            _buildRecentSearches(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8.0,
      children: [
        DropdownButton<String>(
          value: selectedScope,
          onChanged: (newValue) {
            setState(() {
              selectedScope = newValue!;
            });
          },
          items: searchScopes.map((scope) {
            return DropdownMenuItem(
              value: scope,
              child: Text(scope),
            );
          }).toList(),
        ),
        SwitchListTile(
          title: Text("Match Case"),
          value: matchCase,
          onChanged: (val) {
            setState(() {
              matchCase = val;
            });
          },
        ),
        SwitchListTile(
          title: Text("Exact Match"),
          value: exactMatch,
          onChanged: (val) {
            setState(() {
              exactMatch = val;
            });
          },
        ),
        SwitchListTile(
          title: Text("Fuzzy Search"),
          value: fuzzySearch,
          onChanged: (val) {
            setState(() {
              fuzzySearch = val;
            });
          },
        ),
        DropdownButton<String>(
          value: selectedSortOrder,
          onChanged: (newValue) {
            setState(() {
              selectedSortOrder = newValue!;
            });
          },
          items: sortOrders.map((order) {
            return DropdownMenuItem(
              value: order,
              child: Text(order),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentSearches() {
    return recentSearches.isNotEmpty
        ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Recent Searches", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children: recentSearches.map((search) {
                return Chip(
                  label: Text(search),
                  onDeleted: () {
                    setState(() {
                      recentSearches.remove(search);
                    });
                  },
                );
              }).toList(),
            ),
          ],
        )
        : Container();
  }
}
