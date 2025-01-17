import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stopor/auth/authentication_service.dart';
import 'package:stopor/models/event.dart';
import 'package:stopor/widgets/event_card.dart';
import 'package:provider/provider.dart';
import '../data.dart';

class NewsFeed extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewsFeed();
  }
}

class _NewsFeed extends State<NewsFeed> {
  @override
  void initState() {
    super.initState();
    fetchUsers();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  List<dynamic> _events = [];
  int _currentTab = 0;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  BottomNavigationBarItem _buildToolbarIcon(int index) {
    return BottomNavigationBarItem(
        icon: Container(
            child: icons[index],
            decoration: (index == 3)
                ? new BoxDecoration(
                    shape: BoxShape.circle,
                    border: new Border.all(
                      color: (_currentTab == 3)
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).scaffoldBackgroundColor,
                      width: 2.0,
                    ),
                  )
                : null),
        label: '');
  }

  void fetchUsers() async {
    try {
      var events = await FirebaseFirestore.instance.collection('events').get();
      var data = events.docs.map((e) => e.data());
      List<Event> eventObjects = [];
      data.forEach((element) {
        Event event = new Event(
            date: DateTime(2020, 9, 17, 17, 30),
            name: element["name"],
            eventImage: element["image"],
            location: element["location"],
            isOnline: element["isOnline"] == null ? false : true);
        eventObjects.add(event);
      });
      _events = eventObjects;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Widget _buildList() {
    return _events.length != 0
        ? SmartRefresher(
            child: ListView(
              children: <Widget>[
                Column(
                  children: [for (var event in _events) EventCard(event)],
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthenticationService>().signOut();
                  },
                  child: Text("Sign out"),
                )
              ],
            ),
            controller: _refreshController,
            onRefresh: _getData,
          )
        : Center(child: CircularProgressIndicator());
  }

  Future<void> _getData() async {
    setState(() {
      fetchUsers();
    });
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.settings,
            color: Colors.green,
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => SettingsScreen()));
          },
        ),
      ),
      body: Container(
        child: _buildList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentTab,
          onTap: (int value) {
            setState(() {
              _currentTab = value;
            });
          },
          unselectedItemColor: Colors.grey,
          selectedItemColor: Theme.of(context).primaryColor,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: icons
              .asMap()
              .entries
              .map(
                (MapEntry map) => _buildToolbarIcon(map.key),
              )
              .toList()),
    );
  }
}
