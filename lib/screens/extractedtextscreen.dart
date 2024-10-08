import 'package:car_dashcam/provider/extractedtext_provider.dart';
import 'package:car_dashcam/screens/videoplayer/videoscreenplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExtractedTextScreen extends ConsumerStatefulWidget {
  final String videoPath;
  final bool isLoading;

  ExtractedTextScreen({super.key, required this.videoPath, required this.isLoading});

  @override
  _ExtractedTextScreenState createState() => _ExtractedTextScreenState();
}

class _ExtractedTextScreenState extends ConsumerState<ExtractedTextScreen> {
  late TextEditingController _searchController;
  List<Map<int, String>> _filteredTextList = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter the text list based on search query
  void _filterTextList(List<Map<int, String>> textList, String query) {
    setState(() {
      _filteredTextList = textList
          .where((entry) =>
              entry.values.first.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final extractedTextList = ref.watch(ExtractedTextListProvider);

    // Iterate to find the matching videoPath
    for (int i = 0; i < extractedTextList.length; i++) {
      if (extractedTextList[i].videoPath == widget.videoPath) {
        String filepath = extractedTextList[i].videoPath;
        List<Map<int, String>> textList = extractedTextList[i].text;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Extracted Screen Text",
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          body: Column(
            children: [
              // Search bar for filtering text
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    _filterTextList(textList, value);
                  },
                  decoration: InputDecoration(
                    labelText: "Search extracted text",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    suffixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              widget.isLoading?
              SizedBox(
                height: 100.0,
                width: double.infinity,
                child: Center(child: CircularProgressIndicator()),
              ):SizedBox(),
              Expanded(
                child: textList.isEmpty
                    ? Center(child: Text("No Text Found"))
                    : ListView.builder(
                        itemCount: _filteredTextList.isNotEmpty
                            ? _filteredTextList.length
                            : textList.length,
                        itemBuilder: (BuildContext context, int index) {
                          final textEntry = _filteredTextList.isNotEmpty
                              ? _filteredTextList[index]
                              : textList[index];
                          String textWritten = textEntry.values.first;
                          int timeInt = textEntry.keys.first;
                          Duration timeStamp = Duration(seconds: timeInt);

                          return InkWell(
                            onTap: () {
                              // Navigate to VideoScreen at the particular timestamp
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPlayerScreen(
                                    filePath: widget.videoPath,
                                    videoTimestamp: timeStamp,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        textWritten,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      timeStamp.toString(), // Display timestamp
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      }
    }

    // If no video matches, show a fallback screen
    return Scaffold(
      body: Center(
        child: Text("No Text Found"),
      ),
    );
  }
}
