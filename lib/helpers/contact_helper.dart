import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class ContactHelper {
  static final _instante = ContactHelper.internal();

  factory ContactHelper() => _instante;

  ContactHelper.internal();

  Database _database;

  Future<Database> _getDatabase() async {
    if (_database != null) {
      return _database;
    } else {
      return _database = await initDatabase();
    }
  }

  Future<Database> initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contacts.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
          await db.execute(
              "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)");
        });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database db = await _getDatabase();
    contact.id = await db.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database db = await _getDatabase();
    List<Map> maps = await db.query(contactTable,
        columns: [nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);

    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deletContact(int id) async {
    Database db = await _getDatabase();
    return await db.delete(
        contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    Database db = await _getDatabase();
    db.update(contactTable, contact.toMap(), where: "$idColumn = ?",
        whereArgs: [contact.id]);
  }

  Future<List> getAllContacts() async {
    Database db = await _getDatabase();
    List listMap = await db.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = List();

    for(Map i in listMap){
      listContact.add(Contact.fromMap(i));
    }
    return listContact;
  }

  Future<int> getCount() async {
    Database db = await _getDatabase();
    return Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future closeDb() async {
    Database db = await _getDatabase();
    db.close();
  }
}

class Contact {
  int id;
  String name;
  String email;
  String phone;
  String img;


  Contact();

  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };

    if (id != null) {
      map[idColumn] = id;
    }

    return map;
  }

  @override
  String toString() {
    return "Contac( id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}
