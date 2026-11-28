import 'package:material_ui/material_ui.dart';
import '../../constants/theme/app_theme.dart';

/// Keeps dashboard controls and their overlay routes on the unified light theme.
class DashboardLightTheme extends StatelessWidget {
  final Widget child;

  const DashboardLightTheme({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: child,
    );
  }
}
