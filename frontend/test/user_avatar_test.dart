import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/auth/user_model.dart';
import 'package:frontend/widgets/common/user_avatar.dart';

void main() {
  testWidgets('Uses OAuth profile_picture and falls back on failed photo', (tester) async {
    final user = UserModel.fromJson({
      'id': 1, 'email': 'test@example.com', 'first_name': 'Maria',
      'profile_picture': 'https://example.com/photo.jpg',
    });
    await tester.pumpWidget(MaterialApp(home: UserAvatar(user: user)));
    final photo = tester.widget<Image>(find.byType(Image));
    expect((photo.image as NetworkImage).url, user.profilePicture);
    await tester.pumpAndSettle();
    expect(find.text('M'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Blank photo URL shows initials without requesting an image', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: UserAvatar(user: UserModel(
      id: '1', email: 'test@example.com', firstName: 'Maria', profilePicture: ' ',
    ))));
    expect(find.text('M'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });
}
