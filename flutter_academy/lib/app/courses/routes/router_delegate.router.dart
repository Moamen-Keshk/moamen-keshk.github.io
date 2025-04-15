import 'package:flutter/material.dart';
import 'package:flutter_academy/app/auth/pages/email_verification.page.dart';
import 'package:flutter_academy/app/auth/pages/reset_password.page.dart';
import 'package:flutter_academy/app/auth/pages/login.page.dart';
import 'package:flutter_academy/app/auth/pages/register.page.dart';
import 'package:flutter_academy/app/courses/pages/about.page.dart';
import 'package:flutter_academy/app/courses/pages/all_notifications.page.dart';
import 'package:flutter_academy/app/courses/pages/contact.page.dart';
import 'package:flutter_academy/app/courses/pages/course_details.page.dart';
import 'package:flutter_academy/app/courses/pages/courses.page.dart';
import 'package:flutter_academy/app/courses/pages/dashboard.page.dart';
import 'package:flutter_academy/app/courses/pages/edit_floor.page.dart';
import 'package:flutter_academy/app/courses/pages/edit_property.page.dart';
import 'package:flutter_academy/app/courses/pages/error_404.page.dart';
import 'package:flutter_academy/app/courses/pages/home.page.dart';
import 'package:flutter_academy/app/courses/pages/load.page.dart';
import 'package:flutter_academy/app/courses/pages/new_category.page.dart';
import 'package:flutter_academy/app/courses/pages/new_floor.page.dart';
import 'package:flutter_academy/app/courses/pages/new_property.page.dart';
import 'package:flutter_academy/app/courses/pages/watchlist.page.dart';
import 'package:flutter_academy/app/rates/edit_rate_plan.page.dart';
import 'package:flutter_academy/app/rates/hotel_rate_plan.page.dart';
import 'package:flutter_academy/app/rates/rate_plan.page.dart';

class AppRouterDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final List<Page> _pages = [];

  AppRouterDelegate() {
    _pages.add(_page(const HomePage(), 'home'));
  }

  Page _page(Widget child, String name) =>
      MaterialPage(child: child, key: ValueKey(name));

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: List.of(_pages),
      // ignore: deprecated_member_use
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        _pages.removeLast();
        notifyListeners();
        return true;
      },
      observers: [
        NavigatorObserverWithPopCallback(
          onDidPop: (route, previousRoute) {
            debugPrint('✅ DidPop: ${route.settings.name}');
          },
        ),
      ],
    );
  }

  void push(String routeName, {int? id, Object? extra}) {
    switch (routeName) {
      case 'dashboard':
        _pages.add(_page(const DashboardPage(), 'dashboard'));
        break;
      case 'register':
        _pages.add(_page(const RegisterPage(), 'register'));
        break;
      case 'email_verification':
        _pages.add(_page(const EmailVerificationPage(), 'email_verification'));
        break;
      case 'reset_password':
        _pages.add(_page(const ResetPasswordPage(), 'reset_password'));
        break;
      case 'load_courses':
        _pages.add(_page(const LoadCourses(), 'load_courses'));
        break;
      case 'all_notifications':
        _pages.add(_page(const AllNotificationsPage(), 'all_notifications'));
        break;
      case 'new_property':
        _pages.add(_page(const NewPropertyPage(), 'new_property'));
        break;
      case 'edit_property':
        _pages.add(_page(const EditPropertyPage(), 'edit_property'));
        break;
      case 'edit_floor':
        _pages.add(_page(const EditFloorPage(), 'edit_floor'));
        break;
      case 'new_category':
        _pages.add(_page(const NewCategoryPage(), 'new_category'));
        break;
      case 'new_floor':
        _pages.add(_page(const NewFloorPage(), 'new_floor'));
        break;
      case 'contacts':
        _pages.add(_page(const ContactPage(), 'contacts'));
        break;
      case 'about':
        _pages.add(_page(const AboutPage(), 'about'));
        break;
      case 'courses':
        _pages.add(_page(const CoursesPage(), 'courses'));
        break;
      case 'rate_plan':
        _pages.add(_page(const RatePlanPage(), 'rate_plan'));
        break;
      case 'edit_rate_plan':
        _pages.add(_page(const EditRatePlanPage(), 'edit_rate_plan'));
        break;
      case 'hotel_rate_plans':
        _pages.add(_page(const HotelRatePlansPage(), 'hotel_rate_plans'));
        break;
      case 'watchlist':
        _pages.add(_page(const WatchlistPage(), 'watchlist'));
        break;
      case 'login':
        _pages.add(_page(const LoginPage(), 'login'));
        break;
      case 'course_details':
        if (id != null) {
          _pages.add(_page(CourseDetailsPage(courseId: id), 'course_$id'));
        }
        break;
      default:
        _pages.add(_page(const Error404Page(), 'error'));
        break;
    }
    notifyListeners();
  }

  void pop() {
    if (_pages.length > 1) {
      _pages.removeLast();
      notifyListeners();
    }
  }

  void replaceAllWith(String route, {Object? extra}) {
    _pages.clear();
    push(route, extra: extra);
  }

  @override
  Future<void> setNewRoutePath(void configuration) async {
    // Optional: sync with system route if needed
  }

  @override
  Future<bool> popRoute() async {
    if (_pages.length > 1) {
      pop();
      return true;
    }
    return false;
  }
}

class NavigatorObserverWithPopCallback extends NavigatorObserver {
  final void Function(Route<dynamic>, Route<dynamic>?) onDidPop;

  NavigatorObserverWithPopCallback({required this.onDidPop});

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    onDidPop(route, previousRoute);
  }
}
