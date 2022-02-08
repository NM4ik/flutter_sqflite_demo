import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_sqlite_crud_demo/db/database.dart';
import 'package:flutter_sqlite_crud_demo/entity/student.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'SQLite CRUD demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Student>> _studentsList;
  final _studentNameController = TextEditingController();
  bool isUpdate = false;
  late int? studentIDForUpdate;

  @override
  void initState() {
    super.initState();
    updateStudents();
  }

  updateStudents() {
    setState(() {
      _studentsList = DBProvider.dbProvider.getStudents();
      _studentNameController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          elevation: 0,
        ),
        body: Column(
          children: [
            Form(
                child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: _studentNameController,
                    //controller: ,
                    decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.greenAccent,
                        width: 2,
                        style: BorderStyle.solid,
                      )),
                      labelText: 'Student Name',
                      icon: Icon(
                        Icons.people,
                        color: Colors.black,
                      ),
                      fillColor: Colors.white,
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            )),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      if (isUpdate) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'you have successfully update - id: $studentIDForUpdate, name: ${_studentNameController.text}'),
                        ));
                        DBProvider.dbProvider
                            .updateStudent(Student(studentIDForUpdate,
                                _studentNameController.text))
                            .then((data) {
                          setState(() {
                            isUpdate = false;
                          });
                        });
                      } else {
                        DBProvider.dbProvider
                            .insertStudent(
                                Student(null, _studentNameController.text))
                            .then((data) {
                          setState(() {
                            isUpdate = false;
                          });
                        });
                      }

                      _studentNameController.text = '';
                      studentIDForUpdate = null;
                      updateStudents();
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.green)),
                    child: Text(
                      (isUpdate ? 'UPDATE' : 'ADD'),
                      style: const TextStyle(color: Colors.white),
                    )),
                const SizedBox(
                  width: 10,
                  height: 10,
                ),
                ElevatedButton(
                    onPressed: () {
                      if (isUpdate) {
                        _studentNameController.text = '';
                        studentIDForUpdate = null;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Cancelled'),
                        ));
                        setState(() {
                          isUpdate = false;
                        });
                        updateStudents();
                      } else {
                        _studentNameController.text = '';
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Text field cleared'),
                        ));
                        setState(() {
                          isUpdate = false;
                        });
                      }
                      //
                      // _studentNameController.text = '';
                      // studentIDForUpdate = null;
                      // updateStudents();
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red)),
                    child: Text(
                      (isUpdate ? 'CANCEL UPDATE' : 'CLEAR'),
                      style: const TextStyle(color: Colors.white),
                    )),
              ],
            ),
            Expanded(
              child: FutureBuilder(
                  future: _studentsList,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasData) {
                      return studentsGeneratedList(snapshot.data);
                    }
                    if (snapshot.data == null) {
                      const Text('No data');
                    }
                    return (const Text('wtf'));
                  }),
            ),
          ],
        ));
  }

  Widget studentsGeneratedList(List<Student> student) {
    return ListView.builder(
        itemCount: student.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(student[index].name),
            subtitle: Text(student[index].id.toString()),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  DBProvider.dbProvider.deleteStudent(student[index].id!);
                  updateStudents();
                });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      'you have successfully deleted ${student[index].name}'),
                ));
              },
            ),
            onTap: () {
              setState(() {
                isUpdate = true;
              });
              studentIDForUpdate = student[index].id;
              _studentNameController.text = student[index].name;
            },
          );
        });
  }
}
