import 'dart:async';
import 'dart:convert';

import 'package:dictionary/full_screen_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Dictionary extends StatefulWidget {
  @override
  _DictionaryState createState() => _DictionaryState();
}

class _DictionaryState extends State<Dictionary> {
  final _controller = TextEditingController();
  StreamController _streamController = StreamController();
  Stream _querySteam;
  static String url = "https://owlbot.info/api/v4/dictionary/";
  static String _token = "ec857dbe4ece54e49615b431977dec2fa81e78c9";

  initQuery() async {
    _streamController.add('waiting');
    try {
      final result = await http.get(url + _controller.text,
          headers: {'Authorization': 'Token ' + _token});

      if (result.statusCode == 200) {
        _streamController.add(json.decode(result.body));
      } else if (result.statusCode == 404) {
        _streamController.add('null_results');
      } else {
        _streamController.addError(result.body);
      }
    } catch (e) {
      _streamController.addError(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _querySteam = _streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrangeAccent,
      appBar: AppBar(
        backgroundColor: Colors.deepOrangeAccent,
        title: Text(
          'Dictionary',
          style: TextStyle(fontSize: 25, letterSpacing: 1.0),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            color: Colors.white),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          child: ListView(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(9.0),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey.shade100),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey.shade100),
                      ),
                      contentPadding: EdgeInsets.all(9),
                      border: InputBorder.none,
                      hintText: 'Search your query here',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.search,
                          color: Colors.grey.shade500,
                        ),
                        onPressed: () {
                          if (_controller.text.length > 0) {
                            initQuery();
                            FocusScope.of(context).unfocus();
                          } else {
                            _streamController.add('non_zero');
                          }
                        },
                      )),
                ),
              ),
              StreamBuilder(
                  stream: _querySteam,
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return Column(
                        children: <Widget>[
                          SizedBox(
                            height: 18,
                          ),
                          Center(
                            child: Text(
                              'Search And Explore',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey.shade500),
                            ),
                          ),
                        ],
                      );
                    } else if (snapshot.data == 'null_results') {
                      return Column(
                        children: <Widget>[
                          SizedBox(
                            height: 18,
                          ),
                          Center(
                            child: Text(
                              'No results found !',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey.shade500),
                            ),
                          ),
                        ],
                      );
                    } else if (snapshot.data == 'non_zero') {
                      return Column(
                        children: <Widget>[
                          SizedBox(
                            height: 18,
                          ),
                          Center(
                            child: Text(
                              'Enter a query before you search !',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey.shade500),
                            ),
                          ),
                        ],
                      );
                    } else if (snapshot.data == 'waiting') {
                      return Column(
                        children: <Widget>[
                          SizedBox(
                            height: 18,
                          ),
                          Center(
                            child: CircularProgressIndicator(),
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.data),
                      );
                    } else {
                      return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data['definitions'].length,
                          itemBuilder: (_, index) {
                            return Container(
                              margin: EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(18)),
                              child: ListTile(
                                leading: snapshot.data['definitions'][index]
                                            ['image_url'] ==
                                        null
                                    ? null
                                    : GestureDetector(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (_) {
                                            return FullScreenImageView(
                                              imageUrl:
                                                  snapshot.data['definitions']
                                                      [index]['image_url'],
                                            );
                                          }));
                                        },
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              snapshot.data['definitions']
                                                  [index]['image_url']),
                                        ),
                                      ),
                                title: Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 9, top: 9),
                                  child: Text(
                                      'Word : ${snapshot.data['word']} , Type : ${snapshot.data['definitions'][index]['type']}'),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                        'Defination : ${snapshot.data['definitions'][index]['definition']}'),
                                    SizedBox(
                                      height: 9,
                                    ),
                                    Text(
                                        'Example : ${snapshot.data['definitions'][index]['example']}')
                                  ],
                                ),
                              ),
                            );
                          });
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}
