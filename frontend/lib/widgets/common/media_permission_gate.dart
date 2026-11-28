import 'dart:ui' as ui;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';

/// iOS 26 Liquid Glass security & privacy permission gate for Camera and Photo Library access.
/// Prompts the user with a clear purpose modal before opening device camera or upload picker,
/// and persists preferences so users can review or revoke them in Account Settings.
class MediaPermissionGate {
  static const String _cameraKey = 'sariwaba_perm_camera_v1';
  static const String _photosKey = 'sariwaba_perm_photos_v1';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static bool? _cachedCameraAllowed;
  static bool? _cachedPhotosAllowed;

  static Future<({bool cameraAllowed, bool photosAllowed})>
      getPermissions() async {
    final cam = await _readFlag(_cameraKey, cached: _cachedCameraAllowed);
    final pho = await _readFlag(_photosKey, cached: _cachedPhotosAllowed);
    _cachedCameraAllowed = cam;
    _cachedPhotosAllowed = pho;
    return (cameraAllowed: cam, photosAllowed: pho);
  }

  static Future<void> setPermission(ImageSource source, bool allowed) async {
    final isCamera = source == ImageSource.camera;
    if (isCamera) {
      _cachedCameraAllowed = allowed;
    } else {
      _cachedPhotosAllowed = allowed;
    }
    try {
      await _storage
          .write(
            key: isCamera ? _cameraKey : _photosKey,
            value: allowed ? 'true' : 'false',
          )
          .timeout(const Duration(milliseconds: 120), onTimeout: () {});
    } catch (_) {
      // Ignore secure storage failures in restricted environments.
    }
  }

  static Future<bool> _readFlag(String key, {required bool? cached}) async {
    if (cached != null) return cached;
    try {
      final raw = await _storage
          .read(key: key)
          .timeout(const Duration(milliseconds: 120), onTimeout: () => null);
      return raw == 'true';
    } catch (_) {
      return false;
    }
  }

  /// Ensures the user has granted SariwaBa permission for [source].
  /// Shows an iOS 26 Liquid Glass confirmation sheet if not yet granted.
  static Future<bool> ensureAllowed(
    BuildContext context, {
    required ImageSource source,
  }) async {
    final isCamera = source == ImageSource.camera;
    final alreadyAllowed = await _readFlag(
      isCamera ? _cameraKey : _photosKey,
      cached: isCamera ? _cachedCameraAllowed : _cachedPhotosAllowed,
    );
    if (alreadyAllowed) return true;
    if (!context.mounted) return false;

    HapticFeedback.mediumImpact();
    final granted = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: SariwaColors.liquidGlassShadow,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetCtx) => _IosMediaPermissionSheet(isCamera: isCamera),
    );

    if (granted == true) {
      await setPermission(source, true);
      return true;
    }
    return false;
  }
}

class _IosMediaPermissionSheet extends StatelessWidget {
  final bool isCamera;

  const _IosMediaPermissionSheet({required this.isCamera});

  @override
  Widget build(BuildContext context) {
    final icon =
        isCamera ? CupertinoIcons.camera_fill : CupertinoIcons.photo_fill;
    final title = isCamera ? 'Allow Camera Access?' : 'Allow Photo Upload?';
    final description = isCamera
        ? 'SariwaBa uses your camera only when you take a fish eye or gill photo. Camera access is never active in the background.'
        : 'SariwaBa only reads the specific photos you choose to inspect for freshness. Your library stays private.';
    final allowLabel = isCamera ? 'Allow Camera' : 'Allow Photo Access';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            decoration: BoxDecoration(
              color: SariwaColors.cardSurfaceLight.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: SariwaColors.colorLine),
              boxShadow: const [
                BoxShadow(
                  color: SariwaColors.shadowSubtle,
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: SariwaColors.lineSlate,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: SariwaColors.colorPale,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: SariwaColors.brandLight),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 24,
                          color: SariwaColors.brandPrimary,
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: SariwaColors.brandPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              CupertinoIcons.lock_shield_fill,
                              size: 10,
                              color: SariwaColors.cardSurfaceLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.4,
                    color: SariwaColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    height: 1.45,
                    color: SariwaColors.inkSlateSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: SariwaColors.colorSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SariwaColors.colorLineSubtle),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.checkmark_shield,
                        size: 14,
                        color: SariwaColors.brandPrimary,
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'You can change this anytime in Settings.',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: SariwaColors.inkSlateMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  key: const Key('permission_allow_button'),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pop(true);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: SariwaColors.brandPrimary,
                    foregroundColor: SariwaColors.cardSurfaceLight,
                    minimumSize: const Size(double.infinity, 48),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: Text(allowLabel),
                ),
                const SizedBox(height: 8),
                TextButton(
                  key: const Key('permission_deny_button'),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pop(false);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: SariwaColors.inkSlateSecondary,
                    minimumSize: const Size(double.infinity, 44),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  child: const Text('Not Now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
