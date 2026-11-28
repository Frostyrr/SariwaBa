import '../../../widgets/common/media_permission_gate.dart';
import '../../../widgets/common/user_avatar.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../controllers/auth/auth_controller.dart';
import '../../../controllers/classification/classification_controller.dart';
import '../../../models/auth/user_model.dart';
import '../../../widgets/dashboard/frosted_glass_card.dart';

/// Streamlined Account Settings view with plain, concise copy and zero technical jargon.
class AccountSettingsPageSection extends StatefulWidget {
  final UserModel? user;
  final bool isGuestUser;
  final bool isDesktop;
  final ScrollController? scrollController;
  final AuthController authController;
  final ClassificationController classificationController;
  final VoidCallback onSignIn;
  final VoidCallback? onOpenGuidelines;
  final VoidCallback? onOpenHowItWorks;
  final VoidCallback? onOpenHelpFaq;
  final VoidCallback? onOpenAdmin;
  final VoidCallback? onGoDownloads;
  final VoidCallback? onGoHome;

  const AccountSettingsPageSection({
    super.key,
    required this.user,
    required this.isGuestUser,
    required this.isDesktop,
    this.scrollController,
    required this.authController,
    required this.classificationController,
    required this.onSignIn,
    this.onOpenGuidelines,
    this.onOpenHowItWorks,
    this.onOpenHelpFaq,
    this.onOpenAdmin,
    this.onGoDownloads,
    this.onGoHome,
  });

  @override
  State<AccountSettingsPageSection> createState() =>
      _AccountSettingsPageSectionState();
}

class _AccountSettingsPageSectionState
    extends State<AccountSettingsPageSection> {
  bool _isClearingHistory = false;
  bool _isDeletingAccount = false;
  bool _cameraAllowed = false;
  bool _photosAllowed = false;
  String? _statusBannerMessage;
  bool _isStatusBannerError = false;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final perms = await MediaPermissionGate.getPermissions();
    if (mounted) {
      setState(() {
        _cameraAllowed = perms.cameraAllowed;
        _photosAllowed = perms.photosAllowed;
      });
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Active';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  void _showFeedback(String message, {bool isError = false}) {
    setState(() {
      _statusBannerMessage = message;
      _isStatusBannerError = isError;
    });
  }

  Future<void> _confirmClearAllHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(
              CupertinoIcons.trash,
              color: SariwaColors.statusSpoiled,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Clear All History?',
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        content: const Text(
          'Delete all saved scans and photos? This cannot be undone.',
          style: TextStyle(
            fontFamily: 'Geist',
            fontSize: 14,
            color: SariwaColors.inkSlateSecondary,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SariwaColors.statusSpoiled,
              foregroundColor: SariwaColors.cardSurfaceLight,
              elevation: 0,
              shape: const StadiumBorder(),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete All Records'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isClearingHistory = true);
      try {
        await widget.classificationController.clearAllHistory();
        if (mounted) {
          _showFeedback('Your scan history has been deleted.');
        }
      } catch (e) {
        if (mounted) {
          _showFeedback(
            'Failed to clear history: ${e.toString().replaceFirst('Exception: ', '')}',
            isError: true,
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isClearingHistory = false);
        }
      }
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              color: SariwaColors.statusSpoiled,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Delete SariwaBa Account?',
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: SariwaColors.notFreshText,
              ),
            ),
          ],
        ),
        content: const Text(
          'Your SariwaBa account and saved scans will be permanently deleted. Your Google account will not be affected.',
          style: TextStyle(
            fontFamily: 'Geist',
            fontSize: 14,
            color: SariwaColors.inkSlateMuted,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SariwaColors.statusSpoiled,
              foregroundColor: SariwaColors.cardSurfaceLight,
              elevation: 0,
              shape: const StadiumBorder(),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes, Delete My Account'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isDeletingAccount = true);
      try {
        await widget.authController.deleteAccount();
      } catch (e) {
        if (mounted) {
          final errorMsg = e.toString().replaceFirst('Exception: ', '');
          _showFeedback(errorMsg, isError: true);
          _showErrorDialog('Unable to Delete Account', errorMsg);
        }
      } finally {
        if (mounted) {
          setState(() => _isDeletingAccount = false);
        }
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              CupertinoIcons.shield_slash,
              color: SariwaColors.statusSpoiled,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Geist',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Geist',
            fontSize: 14,
            color: SariwaColors.inkSlateSecondary,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out'),
        content: const Text('Log out of SariwaBa on this device?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: SariwaColors.notFreshPrimary,
              foregroundColor: SariwaColors.cardSurfaceLight,
              shape: const StadiumBorder(),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await widget.authController.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = widget.isDesktop ? 32.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        controller: widget.scrollController,
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          widget.isDesktop ? 24 : 16,
          horizontalPadding,
          widget.isDesktop ? 32 : 104,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),

                if (_statusBannerMessage != null) ...[
                  _buildStatusBanner(),
                  const SizedBox(height: 16),
                ],

                if (widget.isGuestUser)
                  _buildGuestCallout()
                else
                  _buildProfileInfoCard(),
                const SizedBox(height: 16),

                _buildAppResourcesCard(),
                const SizedBox(height: 16),

                if (!widget.isDesktop) ...[
                  _buildPermissionsCard(),
                  const SizedBox(height: 16),
                ],

                _buildSavedScansCard(),

                if (!widget.isGuestUser) ...[
                  const SizedBox(height: 16),
                  _buildAccountAccessCard(),
                  const SizedBox(height: 16),
                  _buildDangerZoneCard(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Account Settings',
      style: TextStyle(
        fontFamily: 'Geist',
        fontSize: widget.isDesktop ? 28 : 24,
        fontWeight: FontWeight.w500,
        letterSpacing: AppTypography.defaultLetterSpacing,
        color: SariwaColors.textPrimaryDark,
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _isStatusBannerError
            ? SariwaColors.notFreshIconBg
            : SariwaColors.freshIconBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isStatusBannerError
              ? SariwaColors.notFreshBorder
              : SariwaColors.freshBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isStatusBannerError
                ? CupertinoIcons.exclamationmark_circle
                : CupertinoIcons.checkmark_circle,
            size: 18,
            color: _isStatusBannerError
                ? SariwaColors.statusSpoiled
                : SariwaColors.statusFresh,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusBannerMessage ?? '',
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: _isStatusBannerError
                    ? SariwaColors.notFreshText
                    : SariwaColors.freshText,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.xmark, size: 14),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            color: SariwaColors.inkSlateMuted,
            onPressed: () => setState(() => _statusBannerMessage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestCallout() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SariwaColors.cardSurfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SariwaColors.colorLine),
      ),
      child: Row(
        children: [
          UserAvatar(user: widget.user, radius: 24),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Guest Mode',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: SariwaColors.textPrimaryDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Scans stay on this device. Sign in to sync across devices.',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: SariwaColors.inkSlateSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: widget.onSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: SariwaColors.brandPrimary,
              foregroundColor: SariwaColors.cardSurfaceLight,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: const StadiumBorder(),
            ),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoCard() {
    final displayName = widget.user?.displayName ?? 'Guest';
    final email = widget.user?.email ?? 'Local device session';
    final role = widget.user?.isAdmin == true
        ? 'Administrator'
        : widget.isGuestUser
            ? 'Guest'
            : 'Inspector';
    final joinedLabel = widget.isGuestUser
        ? null
        : 'Joined ${_formatDate(widget.user?.dateJoined)}';

    return FrostedGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Row(
        children: [
          UserAvatar(user: widget.user, radius: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        style: const TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: SariwaColors.textPrimaryDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.user?.isAdmin == true
                            ? SariwaColors.colorPale
                            : widget.isGuestUser
                                ? SariwaColors.warningBg
                                : SariwaColors.successBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        role,
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: widget.user?.isAdmin == true
                              ? SariwaColors.brandPrimary
                              : widget.isGuestUser
                                  ? SariwaColors.warningText
                                  : SariwaColors.successText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: SariwaColors.textSecondaryDark,
                  ),
                ),
                if (joinedLabel != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    joinedLabel,
                    style: const TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: SariwaColors.inkSlateMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppResourcesCard() {
    Widget buildRow({
      required IconData icon,
      required String title,
      required VoidCallback onTap,
      Color? iconColor,
    }) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (iconColor ?? SariwaColors.brandPrimary)
                        .withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: iconColor ?? SariwaColors.brandPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: SariwaColors.textPrimaryDark,
                    ),
                  ),
                ),
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 14,
                  color: SariwaColors.inkSlateSubtle,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final rows = <Widget>[
      if (widget.onOpenAdmin != null)
        buildRow(
          icon: CupertinoIcons.shield_fill,
          title: 'Admin',
          onTap: widget.onOpenAdmin!,
        ),
      if (widget.onOpenGuidelines != null)
        buildRow(
          icon: CupertinoIcons.checkmark_shield,
          title: 'Freshness Guide',
          onTap: widget.onOpenGuidelines!,
        ),
      if (widget.onOpenHowItWorks != null)
        buildRow(
          icon: CupertinoIcons.book,
          title: 'How to Scan',
          onTap: widget.onOpenHowItWorks!,
        ),
      if (widget.onOpenHelpFaq != null)
        buildRow(
          icon: CupertinoIcons.question_circle,
          title: 'FAQs',
          onTap: widget.onOpenHelpFaq!,
        ),
      if (widget.onGoDownloads != null)
        buildRow(
          icon: CupertinoIcons.device_phone_portrait,
          title: 'Get the App',
          onTap: widget.onGoDownloads!,
        ),
      if (widget.onGoHome != null)
        buildRow(
          icon: CupertinoIcons.house,
          title: 'Home',
          onTap: widget.onGoHome!,
          iconColor: SariwaColors.inkSlateSecondary,
        ),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return FrostedGlassCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Resources',
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: SariwaColors.textPrimaryDark,
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              const Divider(
                height: 1,
                indent: 48,
                color: SariwaColors.colorLineSubtle,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildPermissionsCard() {
    Widget buildPermRow({
      required IconData icon,
      required String title,
      required String subtitle,
      required bool value,
      required ValueChanged<bool> onChanged,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: SariwaColors.brandPrimary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 18,
                color: SariwaColors.brandPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: SariwaColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: SariwaColors.inkSlateMuted,
                    ),
                  ),
                ],
              ),
            ),
            CupertinoSwitch(
              value: value,
              activeTrackColor: SariwaColors.brandPrimary,
              onChanged: (next) async {
                HapticFeedback.selectionClick();
                onChanged(next);
              },
            ),
          ],
        ),
      );
    }

    return FrostedGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Permissions',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 8),
          buildPermRow(
            icon: CupertinoIcons.camera_fill,
            title: 'Camera Access',
            subtitle: _cameraAllowed ? 'Allowed for scans' : 'Ask before opening',
            value: _cameraAllowed,
            onChanged: (val) async {
              setState(() => _cameraAllowed = val);
              await MediaPermissionGate.setPermission(ImageSource.camera, val);
            },
          ),
          const Divider(height: 12, color: SariwaColors.colorLineSubtle),
          buildPermRow(
            icon: CupertinoIcons.photo_fill,
            title: 'Photo Upload',
            subtitle:
                _photosAllowed ? 'Allowed for uploads' : 'Ask before opening',
            value: _photosAllowed,
            onChanged: (val) async {
              setState(() => _photosAllowed = val);
              await MediaPermissionGate.setPermission(ImageSource.gallery, val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSavedScansCard() {
    return FrostedGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: SariwaColors.surfaceSlateWash,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              CupertinoIcons.tray_full,
              size: 18,
              color: SariwaColors.inkSlateSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saved Scans',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: SariwaColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isGuestUser
                      ? 'Stored on this device only.'
                      : 'Remove all saved scans and photos.',
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: SariwaColors.inkSlateMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            key: const Key('btn_clear_all_history'),
            onPressed: _isClearingHistory ? null : _confirmClearAllHistory,
            style: OutlinedButton.styleFrom(
              foregroundColor: SariwaColors.statusSpoiled,
              side: const BorderSide(color: SariwaColors.notFreshBorder),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: const StadiumBorder(),
            ),
            child: Text(
              _isClearingHistory ? 'Clearing...' : 'Clear History',
              style: const TextStyle(
                fontFamily: 'Geist',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountAccessCard() {
    return FrostedGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: SariwaColors.freshIconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.checkmark_shield_fill,
                  size: 18,
                  color: SariwaColors.statusFresh,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Google Sign-In',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: SariwaColors.textPrimaryDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Connected to your Google account.',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: SariwaColors.inkSlateMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: SariwaColors.freshTrack,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Connected',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: SariwaColors.freshText,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: SariwaColors.colorLineSubtle),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: SariwaColors.surfaceSlateWash,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.square_arrow_right,
                  size: 18,
                  color: SariwaColors.textPrimaryDark,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sign Out',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: SariwaColors.textPrimaryDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Log out on this device.',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: SariwaColors.inkSlateMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                key: const Key('settings_sign_out_button'),
                onPressed: _confirmSignOut,
                style: OutlinedButton.styleFrom(
                  foregroundColor: SariwaColors.notFreshText,
                  side: const BorderSide(color: SariwaColors.notFreshBorder),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: const StadiumBorder(),
                ),
                child: const Text('Log Out'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SariwaColors.notFreshIconBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SariwaColors.notFreshBorder),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle_fill,
            color: SariwaColors.statusSpoiled,
            size: 18,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delete Account',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: SariwaColors.notFreshText,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Permanently delete your account and saved scans.',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: SariwaColors.notFreshText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            key: const Key('btn_delete_account'),
            onPressed: _isDeletingAccount ? null : _confirmDeleteAccount,
            style: ElevatedButton.styleFrom(
              backgroundColor: SariwaColors.statusSpoiled,
              foregroundColor: SariwaColors.cardSurfaceLight,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: const StadiumBorder(),
            ),
            child: Text(
              _isDeletingAccount ? 'Deleting...' : 'Delete',
              style: const TextStyle(
                fontFamily: 'Geist',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
