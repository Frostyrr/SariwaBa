import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/widgets/dashboard/dashboard_light_theme.dart';

void main() {
  testWidgets('Dashboard inputs and popup routes stay light under dark app theme', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData.dark(),
      home: DashboardLightTheme(child: Scaffold(body: Column(children: [
        const TextField(),
        PopupMenuButton<String>(
          itemBuilder: (_) => [const PopupMenuItem(value: 'view', child: Text('View details'))],
        ),
      ]))),
    ));
    await tester.enterText(find.byType(TextField), 'Inspector');
    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.style.color, const Color(0xFF0A2229));
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    final context = tester.element(find.text('View details'));
    expect(Theme.of(context).brightness, Brightness.light);
    expect(Theme.of(context).popupMenuTheme.color, const Color(0xFFFFFFFF));
    expect(Theme.of(context).popupMenuTheme.textStyle!.color, const Color(0xFF0A2229));
    expect(tester.takeException(), isNull);
  });
}
