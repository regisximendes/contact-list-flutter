import 'dart:io';

import 'package:contact_list/helpers/contact_helper.dart';
import 'package:contact_list/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Contacts"),
          centerTitle: true,
          backgroundColor: Colors.orange,
        ),
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            navigateToContact();
          },
          backgroundColor: Colors.orange,
          child: Icon(Icons.add),
        ),
        body: ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              return contactCard(context, index);
            }));
  }

  Contact getContactByIndex(int index) {
    return contacts[index];
  }

  Widget contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: <Widget>[
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: getContactByIndex(index).img != null
                            ? FileImage(File(getContactByIndex(index).img))
                            : AssetImage("images/person.png"))),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  children: <Widget>[
                    Text(
                      getContactByIndex(index).name ?? "",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                    Text(
                      getContactByIndex(index).email ?? "",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      getContactByIndex(index).phone ?? "",
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        showOptions(context, index);
      },
    );
  }

  void showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      FlatButton(
                          onPressed: () {
                            launch("tel:${getContactByIndex(index).phone}");
                            Navigator.pop(context);
                          },
                          child: Text("Ligar")),
                      FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                            navigateToContact(
                                contact: getContactByIndex(index));
                          },
                          child: Text("Editar")),
                      FlatButton(
                          onPressed: () {
                            setState(() {
                              helper.deletContact(
                                  getContactByIndex(index).hashCode);
                              contacts.removeAt(index);
                            });
                            Navigator.pop(context);
                          },
                          child: Text("Deletar"))
                    ],
                  ),
                );
              });
        });
  }

  void _getAllContacts() {
    helper.getAllContacts().then((value) => {
          setState(() {
            contacts = value;
          })
        });
  }

  void navigateToContact({Contact contact}) async {
    final contactResponse = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact)));

    if (contactResponse != null) {
      if (contact != null) {
        await helper.updateContact(contactResponse);
      } else {
        await helper.saveContact(contactResponse);
      }
      _getAllContacts();
    }
  }
}
