import 'package:flutter/material.dart';
import 'package:lotel_pms/app/auth/pages/email_verification.page.dart';
import 'package:lotel_pms/app/auth/pages/login.page.dart';
import 'package:lotel_pms/app/auth/pages/register.page.dart';
import 'package:lotel_pms/app/auth/pages/reset_password.page.dart';
import 'package:lotel_pms/app/api/pages/about.page.dart';
import 'package:lotel_pms/app/api/pages/amenities_management.page.dart';
import 'package:lotel_pms/app/api/pages/booking.page.dart';
import 'package:lotel_pms/app/api/pages/booking_search.page.dart';
import 'package:lotel_pms/app/api/pages/contact.page.dart';
import 'package:lotel_pms/app/api/pages/course_details.page.dart';
import 'package:lotel_pms/app/api/pages/courses.page.dart';
import 'package:lotel_pms/app/api/pages/dashboard.page.dart';
import 'package:lotel_pms/app/api/pages/edit_floor.page.dart';
import 'package:lotel_pms/app/api/pages/edit_property.page.dart';
import 'package:lotel_pms/app/api/pages/edit_season.page.dart';
import 'package:lotel_pms/app/api/pages/error_404.page.dart';
import 'package:lotel_pms/app/api/pages/home.page.dart';
import 'package:lotel_pms/app/api/pages/hotel_seasons.page.dart';
import 'package:lotel_pms/app/api/pages/housekeeping.page.dart';
import 'package:lotel_pms/app/api/pages/invoices.page.dart';
import 'package:lotel_pms/app/api/pages/load.page.dart';
import 'package:lotel_pms/app/api/pages/categories_management.page.dart';
import 'package:lotel_pms/app/api/pages/new_floor.page.dart';
import 'package:lotel_pms/app/api/pages/new_property.page.dart';
import 'package:lotel_pms/app/api/pages/new_season.page.dart';
import 'package:lotel_pms/app/api/pages/staff_management.page.dart';
import 'package:lotel_pms/app/api/pages/todays.page.dart';
import 'package:lotel_pms/app/api/pages/watchlist.page.dart';
import 'package:lotel_pms/app/api/pages/edit_rate_plan.page.dart';
import 'package:lotel_pms/app/api/pages/hotel_rate_plan.page.dart';
import 'package:lotel_pms/app/api/pages/rate_plan.page.dart';
import 'package:lotel_pms/app/api/pages/all_notifications.page.dart';
import 'package:lotel_pms/app/channel_manager/pages/channel_manager_dashboard.page.dart';

class AppRouterDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final List<Page> _pages = [];

  AppRouterDelegate() {
    _pages.add(_page(const HomePage(), 'home'));
  }

  Page _page(Widget child, String keyName) =>
      MaterialPage(child: child, key: ValueKey(keyName));

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
    );
  }

  void push(String routeName, {int? id, Object? extra, bool force = false}) {
    final keyName = id != null ? '${routeName}_$id' : routeName;

    final alreadyExists = _pages.any((p) => p.key == ValueKey(keyName));
    if (alreadyExists && !force) return;

    switch (routeName) {
      case 'home':
        _pages.add(_page(const HomePage(), 'home'));
        break;
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
      case 'categories_management':
        _pages.add(
            _page(const CategoriesManagementPage(), 'categories_management'));
        break;
      case 'new_floor':
        _pages.add(_page(const NewFloorPage(), 'new_floor'));
        break;
      case 'housekeeping':
        _pages.add(_page(const HousekeepingPage(), 'housekeeping'));
        break;
      case 'contact':
        _pages.add(_page(const ContactPage(), 'contact'));
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
      case 'hotel_rate_plan':
        _pages.add(_page(const HotelRatePlansPage(), 'hotel_rate_plan'));
        break;
      case 'channel_manager':
        _pages.add(_page(const ChannelManagerPage(), 'channel_manager'));
        break;
      case 'new_season':
        _pages.add(_page(const NewSeasonPage(), 'new_season'));
        break;
      case 'edit_season':
        _pages.add(_page(const EditSeasonPage(), 'edit_season'));
        break;
      case 'hotel_seasons':
        _pages.add(_page(const HotelSeasonsPage(), 'hotel_seasons'));
        break;
      case 'todays':
        _pages.add(_page(const TodaysPage(), 'todays'));
        break;
      case 'booking':
        _pages.add(_page(const BookingPage(), 'booking'));
        break;
      case 'invoices':
        _pages.add(_page(const InvoicesPage(), 'invoices'));
        break;
      case 'booking_search':
        _pages.add(_page(const BookingSearchPage(), 'booking_search'));
        break;
      case 'staff_management':
        _pages.add(_page(const StaffManagementPage(), 'staff_management'));
        break;
      case 'amenities_management':
        _pages.add(
            _page(const AmenitiesManagementPage(), 'amenities_management'));
        break;
      case 'watchlist':
        _pages.add(_page(const WatchlistPage(), 'watchlist'));
        break;
      case 'login':
        _pages.add(_page(const LoginPage(), 'login'));
        break;
      case 'course_details':
        if (id != null) {
          final key = 'course_$id';
          _pages.add(_page(CourseDetailsPage(courseId: id), key));
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
    push(route, extra: extra, force: true); // force push to rebuild route
  }

  @override
  Future<void> setNewRoutePath(Object? configuration) async {}

  @override
  Future<bool> popRoute() async {
    if (_pages.length > 1) {
      pop();
      return true;
    }
    return false;
  }
}
