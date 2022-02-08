class Student {
  //model for sqlite
  int? id;
  String name;

  Student(this.id, this.name);


  //sqlite have map-format. To work it need to implements two methods (toMap, fromMap):
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;

    return map;
  }
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(map['id'], map['name']);
  }

}
