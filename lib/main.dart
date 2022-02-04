import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:hivetodo/app/data/todo_model.dart';
import 'package:path_provider/path_provider.dart';

import 'app/routes/app_pages.dart';
import 'package:hive/hive.dart';

const String todoBoxName = "todo";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  Hive.registerAdapter(TodoModelAdapter());
  await Hive.openBox<TodoModel>(todoBoxName);
  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
