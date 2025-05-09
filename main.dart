import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Task {
  String title;
  String description;
  DateTime dueDate;
  String category;
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.category,
    this.isCompleted = false,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 179, 0, 110),
      ),
      home: TaskListScreen(),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];
  String searchQuery = '';

  void addTask(String title, String description, DateTime dueDate, String category) {
    setState(() {
      tasks.add(Task(
        title: title,
        description: description,
        dueDate: dueDate,
        category: category,
      ));
    });
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  void toggleCompletion(int index) {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted;
    });
  }

  List<Task> getFilteredTasks() {
    return tasks.where((task) {
      return task.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/b/b3/Asian-college-of-science-and-technology-logo.jpg',
              height: 40,
            ),
            SizedBox(width: 8),
            Text('To-Do App'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: TaskSearchDelegate(tasks),
                );
              },
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: getFilteredTasks().length,
        itemBuilder: (context, index) {
          final task = getFilteredTasks()[index];
          return ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text('${task.description} - Due: ${task.dueDate.toLocal()}'),
            trailing: Checkbox(
              value: task.isCompleted,
              onChanged: (bool? value) {
                toggleCompletion(index);
              },
            ),
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Delete Task'),
                    content: Text('Are you sure you want to delete this task?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          deleteTask(index);
                          Navigator.pop(context);
                        },
                        child: Text('Yes'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('No'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskFormScreen(addTask: addTask),
            ),
          );
          if (newTask != null) {
            addTask(newTask['title'], newTask['description'], newTask['dueDate'], newTask['category']);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class TaskSearchDelegate extends SearchDelegate {
  final List<Task> tasks;

  TaskSearchDelegate(this.tasks);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredTasks = tasks.where((task) {
      return task.title.toLowerCase().contains(query.toLowerCase()) ||
          task.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return ListTile(
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text('${task.description} - Due: ${task.dueDate.toLocal()}'),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}

class TaskFormScreen extends StatefulWidget {
  final Function addTask;

  TaskFormScreen({required this.addTask});

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Academic';
  DateTime _dueDate = DateTime.now();

  final List<String> _categories = ['Academic', 'Personal', 'Work'];

  void _saveTask() {
    final title = _titleController.text;
    final description = _descriptionController.text;
    final category = _selectedCategory;
    final dueDate = _dueDate;

    if (title.isNotEmpty && description.isNotEmpty) {
      widget.addTask(title, description, dueDate, category);
      Navigator.pop(context, {
        'title': title,
        'description': description,
        'dueDate': dueDate,
        'category': category,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
            Row(
              children: [
                Text('Due Date: ${_dueDate.toLocal()}'),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != _dueDate)
                      setState(() {
                        _dueDate = pickedDate;
                      });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTask,
              child: Text('Save Task'),
            ),
          ],
        ),
      ),
    );
  }
}
