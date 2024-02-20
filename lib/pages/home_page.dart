import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskly/models/task.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late double _deviceHeight, _deviceWidth;
  Box? _box;

  String? _newTaskContent;
  _HomePageState();

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    //print("Input value : $_newTaskContent");

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Taskly!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        toolbarHeight: _deviceHeight * 0.15,
        // centerTitle: true,
      ),
      body: _tasksView(),
      floatingActionButton: _addTaskButton(),
    );
  }

// circular progress
  Widget _tasksView() {
    return FutureBuilder(
      future: Hive.openBox('tasks'),
      builder: (BuildContext _context, AsyncSnapshot _snapshot) {
        if (_snapshot.hasData) {
          _box = _snapshot.data;
          return _taskList();
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _taskList() {
    List tasks = _box!.values.toList();
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (BuildContext _context, int _index) {
        var task = Task.fromMap(tasks[_index]);
        return ListTile(
          title: Text(
            task.content,
            style: TextStyle(
                decoration: task.done ? TextDecoration.lineThrough : null),
          ),
          subtitle: Text(task.timestamp.toString()),
          trailing: Icon(
            task.done
                ? Icons.check_box_outlined
                : Icons.check_box_outline_blank_outlined,
            color: Theme.of(context).primaryColor,
          ),
          onTap: () {
            setState(() {
              task.done = !task.done;
              _box!.putAt(
                _index,
                task.toMap(),
              );
            });
          },
          onLongPress: () {
            _box!.delete(_index);
            setState(() {
              
            });
          },
        );
      },
    );
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: _displayTaskPopup,
      child: const Icon(Icons.add),
    );
  }

  void _displayTaskPopup() {
    showDialog(
      context: context,
      builder: (BuildContext _context) {
        return AlertDialog(
          title: const Text("Add new task"),
          content: TextField(
            onSubmitted: (_) {
              if (_newTaskContent != null) {
                var _task = Task(
                    content: _newTaskContent!,
                    timestamp: DateTime.now(),
                    done: false);
                _box!.add(_task.toMap());
              }
              setState(() {
                _newTaskContent = null;
                Navigator.pop(context);
              });
            },
            onChanged: (_value) {
              setState(() {
                _newTaskContent = _value;
              });
            },
          ),
        );
      },
    );
  }
}
