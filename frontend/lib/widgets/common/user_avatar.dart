import 'package:flutter/material.dart';

import '../../models/auth/user_model.dart';

/// Displays the Google profile photo with initials while loading or on failure.
class UserAvatar extends StatelessWidget {
  final UserModel? user;
  final double radius;

  const UserAvatar({super.key, required this.user, this.radius = 18});

  @override
  Widget build(BuildContext context) {
    final url = user?.profilePicture?.trim();
    final name = user?.displayName.trim() ?? '';
    final fallback = ColoredBox(
      color: const Color(0xFFE6F6F4),
      child: Center(
        child: Text(
          name.isEmpty ? 'G' : name.characters.first.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Geist',
            fontSize: radius * .8,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF0F766E),
          ),
        ),
      ),
    );
    return Semantics(
      label: name.isEmpty ? 'Guest profile' : '$name profile picture',
      image: true,
      child: ClipOval(
        child: SizedBox.square(
          dimension: radius * 2,
          child: url == null || url.isEmpty
              ? fallback
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  // Google-hosted photos may not permit canvas image requests.
                  webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                  errorBuilder: (context, error, stackTrace) => fallback,
                  loadingBuilder: (context, child, progress) =>
                      progress == null ? child : fallback,
                ),
        ),
      ),
    );
  }
}
