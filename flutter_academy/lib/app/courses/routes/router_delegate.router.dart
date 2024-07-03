import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_academy/app/auth/pages/email_verification.page.dart';
import 'package:flutter_academy/app/auth/pages/reset_password.page.dart';
import 'package:flutter_academy/app/auth/pages/login.page.dart';
import 'package:flutter_academy/app/auth/pages/register.page.dart';
import 'package:flutter_academy/app/auth/view_models/auth.vm.dart';
import 'package:flutter_academy/app/courses/pages/about.page.dart';
import 'package:flutter_academy/app/courses/pages/all_notifications.page.dart';
import 'package:flutter_academy/app/courses/pages/contact.page.dart';
import 'package:flutter_academy/app/courses/pages/course_details.page.dart';
import 'package:flutter_academy/app/courses/pages/courses.page.dart';
import 'package:flutter_academy/app/courses/pages/dashboard.page.dart';
import 'package:flutter_academy/app/courses/pages/error_404.page.dart';
import 'package:flutter_academy/app/courses/pages/home.page.dart';
import 'package:flutter_academy/app/courses/pages/load.page.dart';
import 'package:flutter_academy/app/courses/pages/watchlist.page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return Consumer(builder: (context, ref, child) {
      final pages = _getRoutes(_path, ref.watch(authVM));
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
    });
  }

  @override
  Future<void> setNewRoutePath(Uri configuration) async =>
      go(configuration.toString());

  go(String path) {
    _path = Uri.parse(path);
    _safeNotifyListeners();
  }

  List<Page> _getRoutes(Uri path, AuthVM authVM) {
    final pages = <Page>[];
    if (authVM.isLoggedIn) {
      pages.add(const MaterialPage(
          child: DashboardPage(), key: ValueKey('dashboard')));
    } else {
      pages.add(const MaterialPage(child: HomePage(), key: ValueKey('home')));
    }
    if (path.pathSegments.isEmpty) {
      return pages;
    }
    switch (path.pathSegments[0]) {
      case 'register':
        pages.add(const MaterialPage(
          child: RegisterPage(),
          key: ValueKey('register'),
        ));
        break;
      case 'email_verification':
        pages.add(const MaterialPage(
          child: EmailVerificationPage(),
          key: ValueKey('email_verification'),
        ));
        break;
      case 'reset_password':
        pages.add(const MaterialPage(
          child: ResetPasswordPage(),
          key: ValueKey('reset_password'),
        ));
        break;
      case 'load_courses':
        pages.add(const MaterialPage(
          child: LoadCourses(),
          key: ValueKey('load_courses'),
        ));
        break;
      case 'all_notifications':
        pages.add(const MaterialPage(
          child: AllNotificationsPage(),
          key: ValueKey('all_notifications'),
        ));
      case 'contacts':
        pages.add(const MaterialPage(
          key: ValueKey('contacts'),
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
      case 'watchlist':
        pages.add(const MaterialPage(
          child: WatchlistPage(),
          key: ValueKey('watchlist'),
        ));
        break;
      case 'login':
        if (authVM.isLoggedIn) {
          go('/dashboard');
          break;
        }
        pages.add(const MaterialPage(
          key: ValueKey('login'),
          child: LoginPage(),
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
              courseId: int.parse(
                path.pathSegments[1],
              ),
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
