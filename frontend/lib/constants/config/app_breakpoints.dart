/// Shared responsive layout breakpoints for Web and Mobile.
class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 600.0;
  static const double desktop = 900.0;

  static bool isMobile(double width) => width < mobile;
  static bool isTablet(double width) => width >= mobile && width < desktop;
  static bool isDesktop(double width) => width >= desktop;
}
