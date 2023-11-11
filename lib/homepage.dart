import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:presensiflutterv1/model/homeresponse.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //sharedpreferences
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _name, _token;
  HomeResponseModel? homeResponseModel;
  Datum? hariIni;
  List<Datum> riwayat = [];

  //function get
  Future getData() async {
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + await _token
    };
    var response = await http.get(
        Uri.parse('http://192.168.100.57:8000/api/getPresensi'),
        headers: headers);
    homeResponseModel = HomeResponseModel.fromJson(json.decode(response.body));
    riwayat.clear();
    homeResponseModel!.data.forEach((element) {
      if (element.isHariIni) {
        hariIni = element;
      } else {
        riwayat.add(element);
      }
    });
  }

  //inisialisasi
  @override
  void initState() {
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });
    _name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder(
                          future: _name,
                          builder: (BuildContext context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else {
                              if (snapshot.hasData) {
                                print(snapshot.data);
                                return Text(
                                  snapshot.data.toString(),
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                );
                              } else {
                                return Text("-",
                                    style: TextStyle(fontSize: 20));
                              }
                            }
                          }),
                    ],
                  ),
                ),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
