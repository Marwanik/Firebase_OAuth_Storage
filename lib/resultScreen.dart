import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Reference> _files = [];

  @override
  void initState() {
    super.initState();
    _loadUploadedFiles();
  }

  Future<void> _loadUploadedFiles() async {
    User? user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You need to be signed in to view files')),
      );
      return;
    }

    try {
      final ListResult result = await _storage.ref('uploads/${user.uid}').listAll();
      setState(() {
        _files = result.items;
      });
    } catch (e) {
      print('Failed to load files: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load files: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Uploaded Files'),
      ),
      body: ListView.builder(
        itemCount: _files.length,
        itemBuilder: (context, index) {
          final file = _files[index];
          return ListTile(
            title: Text(file.name),
            onTap: () async {
              final url = await file.getDownloadURL();
              // Handle the file click event, e.g., open the URL in a browser
              print(url);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('File URL: $url')),
              );
            },
          );
        },
      ),
    );
  }
}
