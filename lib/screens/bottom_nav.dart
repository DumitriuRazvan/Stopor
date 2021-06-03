import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stopor/database/database_service.dart';
import 'package:stopor/models/event.dart';
import 'package:stopor/screens/news_feed.dart';
import 'package:stopor/screens/settings.dart';
import 'package:stopor/util/set_overlay.dart';

import '../data.dart';
import 'add_event.dart';

class BottomNav extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<BottomNav> {
  @override
  void initState() {
    _eventListListener = (pageKey) {
      _fetchPage(pageKey);
    };
    _followedEventListener = (pageKey) {
      _fetchFollowedEvents();
    };
    _pagingController.addPageRequestListener(_eventListListener);
    setOverlayWhite();
    super.initState();
  }

  var _eventListListener;
  var _followedEventListener;
  static const _pageSize = 5;
  String _user;
  final DatabaseService _database = new DatabaseService();
  final PagingController<String, Event> _pagingController =
      PagingController(firstPageKey: "");
  int _currentTab = 0;
  bool _showSaveButton = true;
  final List _screens = [NewsFeed(), Scaffold(), Scaffold(), Scaffold()];

  BottomNavigationBarItem _buildToolbarIcon(int index) {
    return BottomNavigationBarItem(
        icon: Container(
            child: icons[index],
            decoration: (index == 3)
                ? new BoxDecoration(
                    shape: BoxShape.circle,
                    border: new Border.all(
                      color: (_currentTab == 3)
                          ? Theme.of(context).accentColor
                          : Theme.of(context).scaffoldBackgroundColor,
                      width: 2.0,
                    ),
                  )
                : null),
        label: '');
  }

  Future<void> _fetchFollowedEvents() async {
    DatabaseService databaseService = DatabaseService();
    final newItems = await databaseService.getFollowedEventList(_user);
    final nextPageKey = newItems[newItems.length - 1].id;
    _pagingController.appendPage(newItems, nextPageKey);
    _pagingController.appendLastPage([]);
  }

  Future<void> _fetchPage(String pageKey) async {
    try {
      DatabaseService databaseService = DatabaseService();
      final newItems =
          await databaseService.getEventList(pageKey, _pageSize, _user);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = newItems[newItems.length - 1].id;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentTab],
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentTab,
          onTap: (int value) {
            setState(() {
              _currentTab = value;
            });
          },
          unselectedItemColor: Colors.grey,
          selectedItemColor: Theme.of(context).accentColor,
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
