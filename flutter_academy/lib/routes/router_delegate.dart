import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_academy/pages/about_page.dart';
import 'package:flutter_academy/pages/contact_page.dart';
import 'package:flutter_academy/pages/course_details_page.dart';
import 'package:flutter_academy/pages/courses_page.dart';
import 'package:flutter_academy/pages/error_404_page.dart';
import 'package:flutter_academy/pages/home_page.dart';

class AppRouterDelegate extends RouterDelegate<Uri>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Uri> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  Uri _path = Uri.parse('/');

  AppRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  @override
  Uri get currentConfiguration => _path;

  @override
  Widget build(BuildContext context) {
    final pages = _getRoutes(_path);
    return Navigator(
      key: navigatorKey,
      pages: pages,
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        if (pages.isNotEmpty) {
          _path = _path.replace(
              pathSegments: _path.pathSegments
                  .getRange(0, _path.pathSegments.length - 1));
          _safeNotifyListeners();
          return true;
        }
        return false;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(Uri configuration) async =>
      go(configuration.toString());

  go(String path) {
    _path = Uri.parse(path);
    _safeNotifyListeners();
  }

  List<Page> _getRoutes(Uri path) {
    final pages = [
      const MaterialPage(child: HomePage(), key: ValueKey('home')),
    ];
    if (path.pathSegments.isEmpty) {
      return pages;
    }
    switch (path.pathSegments[0]) {
      case 'contact':
        pages.add(const MaterialPage(
          key: ValueKey('contact'),
          child: ContactPage(),
        ));
        break;
      case 'about':
        pages.add(const MaterialPage(
          key: ValueKey('about'),
          child: AboutPage(),
        ));
        break;
      case 'courses':
        pages.add(const MaterialPage(
          key: ValueKey('courses'),
          child: CoursesPage(),
        ));
        break;
      default:
        pages.add(
            const MaterialPage(child: Error404Page(), key: ValueKey('error')));
        break;
    }
    if (path.pathSegments.length == 2) {
      if (path.pathSegments[0] == 'courses') {
        pages.add(
          MaterialPage(
            key: ValueKey('course.${path.pathSegments[1]}'),
            child: CourseDetailsPage(
              courseId: int.parse(path.pathSegments[1]),
            ),
          ),
        );
      } else {
        pages.add(
            const MaterialPage(child: Error404Page(), key: ValueKey('error')));
      }
    }
    return pages;
  }

  void _safeNotifyListeners() {
    // this is a hack to fix the following error:
    // The following assertion was thrown while dispatching notifications for
    // GoRouterDelegate: setState() or markNeedsBuild() called during build.
    // ignore: unnecessary_null_comparison
    WidgetsBinding.instance == null
        ? notifyListeners()
        : scheduleMicrotask(notifyListeners);
  }
}