import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Code Lines & Files Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> programmingLanguages = [
    'Dart',
    'Java',
    'Kotlin',
    'Python',
    'PHP',
    'C',
    'C++',
    'JS',
    'TS',
    'XML',
    'HTML',
    'CSS',
    'JSON',

  ];

  String selectedLanguage = 'Dart';
  String? selectedFolderPath;
  String? result;

  int totalLines = 0;
  int totalFiles = 0;

  List<String> fileNames = [];

  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Code Lines & Files Calculator'),
            centerTitle: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  DropdownButton<String>(
                    hint: const Text('Select you language'),
                    underline: const SizedBox(),
                    items: List.generate(programmingLanguages.length, (index) {
                      return DropdownMenuItem<String>(
                        value: programmingLanguages[index],
                        child: Text(programmingLanguages[index]),
                      );
                    }),
                    value: selectedLanguage,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedLanguage = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: isChecked,
                        onChanged: (value) {
                          setState(() {
                            isChecked = value!;
                          });
                        },
                      ),
                      const SizedBox(width: 20),
                      const Text('Show File names')
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      maximumSize: const Size(300, 50),
                      minimumSize: const Size(300, 50),
                    ),
                    onPressed: pickFolder,
                    child: const Text('Select your folder path'),
                  ),
                  const SizedBox(height: 20),
                  Text(selectedFolderPath ?? 'Not Select any folder yet!'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      maximumSize: const Size(300, 50),
                      minimumSize: const Size(300, 50),
                    ),
                    onPressed: selectedFolderPath == null
                        ? null
                        : () {
                            if (selectedFolderPath != null) {
                              setState(() {
                                totalLines = 0;
                                totalFiles = 0;
                                result = null;
                                fileNames.clear();
                              });
                              calculateFileLine(selectedFolderPath!);
                            }
                          },
                    child: const Text('Start Calculating'),
                  ),
                  const SizedBox(height: 20),
                  if (result != null)
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.headline5!.copyWith(
                            fontWeight: FontWeight.bold, color: Colors.black),
                        children: [TextSpan(text: result)],
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (isChecked)
                    if (fileNames.isNotEmpty)
                      Wrap(
                        children: List.generate(fileNames.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Chip(
                              label: Text(fileNames[index].toUpperCase()),
                            ),
                          );
                        }),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void pickFolder() async {
    String? directory = await FilePicker.platform.getDirectoryPath();
    if (directory != null) {
      setState(() {
        selectedFolderPath = directory;
      });
    }
  }

  void calculateFileLine(String folderPath) async {
    try {
      var fileContent = Directory(folderPath).listSync();

      for (int i = 0; i < fileContent.length; i++) {
        if (await Directory(fileContent[i].path).exists()) {
          calculateFileLine(fileContent[i].path);
        } else {
          if (fileContent[i]
              .path
              .split('/')
              .last
              .contains('.${selectedLanguage.toLowerCase()}')) {
            fileNames.add(fileContent[i].path.split('/').last);
            totalFiles += 1;
            totalLines += await readLine(fileContent[i].path);
          }
        }
      }

      setState(() {
        result = 'Total Files :: $totalFiles\nTotal Lines :: $totalLines';
      });
    } catch (e) {
      debugPrint('Error :: $e');
      setState(() {
        result = e.toString();
      });
    }
  }

  Future<int> readLine(String filePath) async {
    int lines = 0;
    try {
      lines = File(filePath).readAsLinesSync().length;
      debugPrint('Lines :: $lines');
      return lines;
    } catch (e) {
      debugPrint('Error :: $e');
    }
    return lines;
  }
}
