import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

class PickTopics extends StatefulWidget {
  const PickTopics({super.key});

  @override
  PickTopicsState createState() => PickTopicsState();
}

class PickTopicsState extends State<PickTopics> {
  List<String> selectedTopics = [];

  final List<String> topics = [
    'Flutter',
    'React',
    'Python',
    'Java',
    'JavaScript',
    'Machine Learning',
    'Blockchain',
    'Cloud Computing',
    'Cybersecurity',
    'Artificial Intelligence',
  ];

  late final String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    // print("got in pick topics");
    // print(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SizedBox(
          width: 320,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPickTopicsText(),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: topics.map((topic) => _buildTopicChip(topic)).toList(),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18.0),
                child: SizedBox(
                  width: 240,
                  child: Text(
                    "Don’t want to add topics right now? No worries, you can add them later!",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSaveTopicsButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickTopicsText() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 23.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          "Pick Topics",
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildTopicChip(String topic) {
    final isSelected = selectedTopics.contains(topic);

    return FilterChip(
      label: Text(topic),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          if (selected) {
            selectedTopics.add(topic);
          } else {
            selectedTopics.remove(topic);
          }
        });
      },
      selectedColor: Colors.yellow[700],
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(
          color:Color.fromARGB(255, 244, 191, 57),
        ),
      ),
    );
  }

  Widget _buildSaveTopicsButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: OutlinedButton(
        onPressed: () async {
          if (_validateInputs()) {
            await _saveTopicsToFirestore();
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Home(),
            ));
          }
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.yellow[700]),
          side: MaterialStateProperty.all(BorderSide.none),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          textStyle: MaterialStateProperty.all(
            const TextStyle(fontWeight: FontWeight.bold),
          ),
          fixedSize: MaterialStateProperty.all(
            const Size(320.0, 40.0),
          ),
          foregroundColor: MaterialStateProperty.all(Colors.black),
          shadowColor: MaterialStateProperty.all(Colors.grey[300]),
          elevation: MaterialStateProperty.all(5),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Text("Save Topics"),
        ),
      ),
    );
  }

  bool _validateInputs() {
    if (selectedTopics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one topic')),
      );
      return false;
    }
    return true;
  }

  Future<void> _saveTopicsToFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'topics': selectedTopics,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save topics: $e')),
      );
    }
  }
}
