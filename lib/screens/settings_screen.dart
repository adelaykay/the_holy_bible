import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  double fontSize = 16.0;
  String preferredTranslation = "RSV";
  bool isExpandedGeneral = false;
  bool isExpandedSavedItems = false;
  bool isExpandedSearch = false;
  bool isExpandedSync = false;
  bool isExpandedAbout = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,title: Text("Settings")),
        body: ListView(
          children: [
            _buildExpandableTile(
              title: "General",
              subtitle: "Dark Mode, Font-Size, Bible Version",
              icon: Icons.settings,
              isExpanded: isExpandedGeneral,
              onExpand: () => setState(() => isExpandedGeneral = !isExpandedGeneral),
              children: [
                Divider(),
                _buildSimpleTile("Default Start Screen"),
                Divider(),
                _buildSwitchTile("Dark Mode", isDarkMode, (value) {
                  setState(() => isDarkMode = value);
                }),
                Divider(),
                _buildSliderTile("Font Size", fontSize, 12, 24, (value) {
                  setState(() => fontSize = value);
                }),
                Divider(),
                _buildDropdownTile("Preferred Bible Translation", preferredTranslation, ["RSV", "KJV", "NIV"], (value) {
                  setState(() => preferredTranslation = value!);
                }),
                Divider(),
                _buildSwitchTile("Enable Fuzzy Search", true, (value) {}),
                Divider(),
                _buildSwitchTile("Case Sensitivity", false, (value) {}),
              ],
            ),
            _buildExpandableTile(
              title: "Saved Items Management",
              icon: Icons.bookmark,
              isExpanded: isExpandedSavedItems,
              onExpand: () => setState(() => isExpandedSavedItems = !isExpandedSavedItems),
              children: [
                Divider(),
                _buildSimpleTile("Clear Bookmarks"),
                Divider(),
                _buildSimpleTile("Clear Highlights"),
                Divider(),
                _buildSimpleTile("Clear Notes"),
              ], subtitle: 'Clear all saved items',
            ),
            _buildExpandableTile(
              title: "Sync & Backup",
              icon: Icons.cloud_sync,
              isExpanded: isExpandedSync,
              onExpand: () => setState(() => isExpandedSync = !isExpandedSync),
              children: [
                Divider(),
                _buildSwitchTile("Sync with Cloud", true, (value) {}),
                Divider(),
                _buildSimpleTile("Export Data"),
                Divider(),
                _buildSimpleTile("Import Data"),
              ], subtitle: 'Sync your data with the cloud',
            ),
            _buildExpandableTile(
              title: "About",
              icon: Icons.info,
              isExpanded: isExpandedAbout,
              onExpand: () => setState(() => isExpandedAbout = !isExpandedAbout),
              children: [
                Divider(),
                _buildSimpleTile("App Version: 1.0.0"),
                Divider(),
                _buildSimpleTile("Developer: Adeleke Olasope"),
              ], subtitle: 'App and Developer Info',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableTile({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onExpand,
    required List<Widget> children, required String subtitle,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
        child: ExpansionTile(
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          collapsedBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
          title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) => onExpand(),
          children: children,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      tileColor: Colors.transparent,
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSliderTile(String title, double value, double min, double max, Function(double) onChanged) {
    return ListTile(
      tileColor: Colors.transparent,
      title: Text("$title: ${value.toStringAsFixed(0)}"),
      subtitle: Slider(
        value: value,
        min: min,
        max: max,
        divisions: (max - min).toInt(),
        label: value.toStringAsFixed(0),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownTile(String title, String selectedValue, List<String> options, Function(String?) onChanged) {
    return ListTile(
      tileColor: Colors.transparent,
      title: Text(title),
      trailing: DropdownButton<String>(
        value: selectedValue,
        items: options.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSimpleTile(String title) {
    return ListTile(
      tileColor: Colors.transparent,
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }
}
