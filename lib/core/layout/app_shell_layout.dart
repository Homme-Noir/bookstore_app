import 'package:flutter/material.dart';

/// Material 3 navigation rail is intended from ~600dp; use it for laptop/desktop
/// windows so the app reads as a desktop shell instead of a bottom tab bar.
const double kSideNavigationBreakpointWidth = 600;

/// Pinned toolbars without the tall “large” app bar fit desktop density better.
const double kCompactTopChromeBreakpointWidth = 600;

bool useSideNavigationRail(BuildContext context) {
  return MediaQuery.sizeOf(context).width >= kSideNavigationBreakpointWidth;
}

bool useCompactTopChrome(BuildContext context) {
  return MediaQuery.sizeOf(context).width >= kCompactTopChromeBreakpointWidth;
}

/// Extra scroll padding that assumed a [NavigationBar] on phone; not needed with a rail.
double shellScrollBottomPadding(BuildContext context) {
  return useSideNavigationRail(context) ? 24 : 96;
}
