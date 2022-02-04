import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:hivetodo/app/data/todo_model.dart';
import 'package:hivetodo/main.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeView extends StatefulWidget {
  @override
  State<HomeView> createState() => _HomeViewState();
}

enum TodoFilter { ALL, COMPLETED, INCOMPLETED }

class _HomeViewState extends State<HomeView> {
  Box<TodoModel>? todoBox;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController detailController = TextEditingController();
  final TextEditingController idController = TextEditingController();

  TodoFilter filter = TodoFilter.ALL;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    todoBox = Hive.box<TodoModel>(todoBoxName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hive Todo'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value.compareTo("All") == 0) {
                setState(() {
                  filter = TodoFilter.ALL;
                });
              } else if (value.compareTo("Completed") == 0) {
                setState(() {
                  filter = TodoFilter.COMPLETED;
                });
              } else {
                setState(() {
                  filter = TodoFilter.INCOMPLETED;
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return ["All", "Completed", "Incompleted"].map((option) {
                return PopupMenuItem(
                  value: option,
                  child: Text(option),
                );
              }).toList();
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder(
                valueListenable: todoBox!.listenable(),
                builder: (context, Box<TodoModel> todos, _) {
                  List<int> keys;
                  if (filter == TodoFilter.ALL) {
                    keys = todos.keys.cast<int>().toList();
                  } else if (filter == TodoFilter.COMPLETED) {
                    keys = todos.keys
                        .cast<int>()
                        .where((key) => todos.get(key)!.isCompleted)
                        .toList();
                  } else {
                    keys = todos.keys
                        .cast<int>()
                        .where((key) => !todos.get(key)!.isCompleted)
                        .toList();
                  }

                  return ListView.separated(
                    itemBuilder: (_, index) {
                      final int key = keys[index];
                      final TodoModel? todo = todos.get(key);
                      return ListTile(
                          title: Text(todo!.title),
                          subtitle: Text(todo.detail),
                          // leading: Text("$key"),
                          trailing: Wrap(
                            spacing: 12,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    final key = keys[index];
                                    todoBox!.delete(key);
                                  },
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  )),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (_) {
                                        return Dialog(
                                          child: Container(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(32.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextButton(
                                                      onPressed: () {
                                                        TodoModel mTodo =
                                                            TodoModel(
                                                                title:
                                                                    todo.title,
                                                                detail:
                                                                    todo.detail,
                                                                isCompleted:
                                                                    true);
                                                        todoBox?.put(
                                                            key, mTodo);
                                                        Get.back();
                                                      },
                                                      child: Text(
                                                          'Mark as Completed'))
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                },
                                child: Icon(
                                  Icons.check,
                                  color: todo.isCompleted
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ));
                    },
                    separatorBuilder: (_, index) => Divider(),
                    itemCount: keys.length,
                    shrinkWrap: true,
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
              context: context,
              builder: (_) {
                return Dialog(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            decoration: InputDecoration(hintText: 'Title'),
                            controller: titleController,
                          ),
                          TextField(
                            decoration: InputDecoration(hintText: 'Detail'),
                            controller: detailController,
                          ),
                          TextButton(
                              onPressed: () {
                                final String title = titleController.text;
                                final String detail = detailController.text;
                                TodoModel todo = TodoModel(
                                    title: title,
                                    detail: detail,
                                    isCompleted: false);
                                todoBox?.add(todo);
                                Get.back();
                              },
                              child: Text('Add todo'))
                        ],
                      ),
                    ),
                  ),
                );
              });
        },
      ),
    );
  }
}
