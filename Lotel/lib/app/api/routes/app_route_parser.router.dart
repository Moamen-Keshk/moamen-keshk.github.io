import 'package:flutter/material.dart';

class AppRouteInformationParser extends RouteInformationParser<Uri> {
  @override
  Future<Uri> parseRouteInformation(RouteInformation routeInformation) async =>
      Uri.parse(routeInformation.uri.toString());

  @override
  RouteInformation restoreRouteInformation(Uri configuration) =>
      RouteInformation(uri: Uri.parse(configuration.toString()));
}
