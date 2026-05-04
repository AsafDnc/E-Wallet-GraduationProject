import 'package:flutter/material.dart';

/// Observes auth stack navigation so screens (e.g. [LoginScreen]) can react when
/// a route pushed on top is popped and this route becomes visible again.
final RouteObserver<PageRoute<dynamic>> authRouteObserver =
    RouteObserver<PageRoute<dynamic>>();
