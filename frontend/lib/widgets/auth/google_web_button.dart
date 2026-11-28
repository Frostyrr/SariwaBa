import 'package:material_ui/material_ui.dart';
import 'package:google_sign_in_web/web_only.dart' as google_web;

Widget buildGoogleWebButton() {
  return LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth.clamp(0.0, 400.0);
      return Center(
        child: SizedBox(
          width: width,
          height: 44,
          child: google_web.renderButton(
            configuration: google_web.GSIButtonConfiguration(
              locale: 'en',
              theme: google_web.GSIButtonTheme.filledBlack,
              size: google_web.GSIButtonSize.large,
              shape: google_web.GSIButtonShape.pill,
              minimumWidth: width,
            ),
          ),
        ),
      );
    },
  );
}
