import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FileNameSize {
  String name;
  int size;

  FileNameSize(this.name, this.size);
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Code Lines & Files Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
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
    'dart',
    'java',
    'kt',
    'py',
    'php',
    'c',
    'cpp',
    'js',
    'ts',
    'xml',
    'html',
    'css',
    'json',
    'swift',
    'cs',
    'go',
    'rb',
    'r',
    'cobol',
    'py3',
    'py2',
    'pl',
    'rust',
  ];

  String selectedLanguage = 'dart';
  String? selectedFolderPath;
  String? result;

  int totalLines = 0;
  int totalFiles = 0;

  List<FileNameSize> fileNames = [];

  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Code Lines & Files Calculator'),
            centerTitle: true,
            pinned: true,
            actions: [
              IconButton(
                onPressed: () => clearVariables(),
                icon: const Icon(Icons.clean_hands_rounded),
              ),
              IconButton(
                onPressed: () => sortBySize(),
                icon: const Icon(Icons.sort),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Code Lines & Files Calculator'),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                  'You can count files and read how many lines of code your write for the project. You have to do select the folder and select the language after selecting those then click on calculate button it will show the result. See the screenshots.'),
                              SizedBox(height: 20),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                    'Develop by: S.m. Kamal Hussain Shahi'),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
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
                        child: Text(capitalize(programmingLanguages[index])),
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
                      const Text(
                        'Show File names',
                        overflow: TextOverflow.ellipsis,
                      ),
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
                    if (fileNames.isNotEmpty) _buildChipBuild(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Wrap _buildChipBuild() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(fileNames.length, (index) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.black26,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: Text(fileNames[index].name)),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  fileNames[index].size.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
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
            int value = await readLine(fileContent[i].path);
            fileNames
                .add(FileNameSize(fileContent[i].path.split('/').last, value));
            totalFiles += 1;
            totalLines += value;
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

  void sortBySize() {
    if (fileNames.isNotEmpty) {
      fileNames.sort((a, b) => a.size.compareTo(b.size));
      setState(() {});
    }
  }

  void clearVariables() {
    setState(() {
      selectedLanguage = 'dart';
      selectedFolderPath = null;
      result = null;
      totalLines = 0;
      totalFiles = 0;
      fileNames = [];
      isChecked = false;
    });
  }

  String capitalize(String str) {
    List<String> words = str.split(' ');
    List<String> capitalizedWords = [];
    for (String word in words) {
      String capitalizedWord =
          word[0].toUpperCase() + word.substring(1, word.length);
      capitalizedWords.add(capitalizedWord);
    }
    return capitalizedWords.join(' ');
  }
}
