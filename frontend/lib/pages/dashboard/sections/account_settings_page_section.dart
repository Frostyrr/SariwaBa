import '../../../widgets/common/user_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../controllers/auth/auth_controller.dart';
import '../../../controllers/classification/classification_controller.dart';
import '../../../models/auth/user_model.dart';
import '../../../widgets/dashboard/frosted_glass_card.dart';

/// Dedicated Account Settings page allowing authenticated users to review profile info,
/// audit data handling, delete classification history, and delete their account.
class AccountSettingsPageSection extends StatefulWidget {
  final UserModel? user;
  final bool isGuestUser;
  final bool isDesktop;
  final ScrollController? scrollController;
  final AuthController authController;
  final ClassificationController classificationController;
  final VoidCallback onSignIn;

  const AccountSettingsPageSection({
    super.key,
    required this.user,
    required this.isGuestUser,
    required this.isDesktop,
    this.scrollController,
    required this.authController,
    required this.classificationController,
    required this.onSignIn,
  });

  @override
  State<AccountSettingsPageSection> createState() =>
      _AccountSettingsPageSectionState();
}

class _AccountSettingsPageSectionState
    extends State<AccountSettingsPageSection> {
  bool _isClearingHistory = false;
  bool _isDeletingAccount = false;
  String? _statusBannerMessage;
  bool _isStatusBannerError = false;

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Active Account';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(CupertinoIcons.trash, color: Color(0xFFDC2626), size: 20),
            SizedBox(width: 8),
            Text(
              'Clear All History?',
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: const Text(
          'This permanently deletes your saved scans and their photos. Your account stays active. This cannot be undone.',
          style: TextStyle(
            fontFamily: 'Geist',
            fontSize: 13,
            color: Color(0xFF475569),
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
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              color: Color(0xFFDC2626),
              size: 22,
            ),
            SizedBox(width: 10),
            Text(
              'Delete SariwaBa Account?',
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF991B1B),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to permanently delete your SariwaBa? account?',
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Your account and saved scans will be deleted, and you will be signed out. Your Google account will not be deleted. This cannot be undone.',
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: 12.5,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep Account'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
        // Successful deletion redirects to landing automatically via AuthController
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(CupertinoIcons.shield_slash, color: Color(0xFFDC2626), size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Geist',
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Geist',
            fontSize: 13,
            color: Color(0xFF334155),
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = widget.isDesktop ? 32.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        controller: widget.scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Section Header
                _buildHeader(),

                const SizedBox(height: 20),

                // Status Banner (if any)
                if (_statusBannerMessage != null) ...[
                  _buildStatusBanner(),
                  const SizedBox(height: 16),
                ],

                // Guest Mode Callout (if unauthenticated)
                if (widget.isGuestUser) ...[
                  _buildGuestCallout(),
                  const SizedBox(height: 20),
                ],

                // 1. Profile Information Card
                _buildProfileInfoCard(),

                const SizedBox(height: 20),

                // 2. Privacy & Data Handling Card
                _buildPrivacyDataCard(),

                const SizedBox(height: 20),

                // 3. Sessions & Security Card
                _buildSessionsSecurityCard(),

                const SizedBox(height: 24),

                // 4. Danger Zone Card (Only for authenticated users)
                if (!widget.isGuestUser) ...[
                  _buildDangerZoneCard(),
                  const SizedBox(height: 32),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: SariwaColors.brandPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: SariwaColors.brandPrimary.withValues(alpha: 0.2),
                ),
              ),
              child: const Text(
                'ACCOUNT MANAGEMENT',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: SariwaColors.brandPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Account Settings',
          style: TextStyle(
            fontFamily: 'Geist',
            fontSize: 26,
            fontWeight: FontWeight.w600,
            letterSpacing: AppTypography.defaultLetterSpacing,
            color: SariwaColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Manage your profile, saved scans, and account.',
          style: TextStyle(
            fontFamily: 'Geist',
            fontSize: 14,
            fontWeight: FontWeight.w300,
            letterSpacing: AppTypography.defaultLetterSpacing,
            color: SariwaColors.textSecondaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _isStatusBannerError
            ? const Color(0xFFFEF2F2)
            : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isStatusBannerError
              ? const Color(0xFFFECACA)
              : const Color(0xFFBBF7D0),
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
                ? const Color(0xFFDC2626)
                : const Color(0xFF16A34A),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _statusBannerMessage ?? '',
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: _isStatusBannerError
                    ? const Color(0xFF991B1B)
                    : const Color(0xFF166534),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.xmark, size: 14),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            color: const Color(0xFF64748B),
            onPressed: () => setState(() => _statusBannerMessage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestCallout() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.person_crop_circle_badge_exclam,
            color: Color(0xFFD97706),
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Guest Session Active',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Guest scans stay on this device. Sign in with Google to save future scans to your account.',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFB45309),
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
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoCard() {
    final displayName = widget.user?.displayName ?? 'Guest Evaluator';
    final email = widget.user?.email ?? 'No email linked (Guest session)';
    final role = widget.user?.isAdmin == true
        ? 'Administrator'
        : widget.isGuestUser
            ? 'Guest'
            : 'Inspector';
    final dateJoinedFormatted = widget.isGuestUser
        ? 'Current Session'
        : _formatDate(widget.user?.dateJoined);

    return FrostedGlassCard(
      padding: const EdgeInsets.all(22),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Information',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your name and photo come from your Google account.',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 12.5,
              fontWeight: FontWeight.w300,
              color: SariwaColors.textSecondaryDark,
            ),
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),

          Row(
            children: [
              UserAvatar(user: widget.user, radius: 28),
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
                              fontWeight: FontWeight.w600,
                              color: SariwaColors.textPrimaryDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: widget.user?.isAdmin == true
                                ? const Color(0xFF8B5CF6).withValues(alpha: 0.12)
                                : widget.isGuestUser
                                    ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                                    : const Color(0xFF10B981).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            role,
                            style: TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: widget.user?.isAdmin == true
                                  ? const Color(0xFF7C3AED)
                                  : widget.isGuestUser
                                      ? const Color(0xFFD97706)
                                      : const Color(0xFF059669),
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
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: SariwaColors.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Account Created: $dateJoinedFormatted',
                      style: const TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyDataCard() {
    return FrostedGlassCard(
      padding: const EdgeInsets.all(22),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Privacy & Saved Scans',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Review or delete your saved scans.',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 12.5,
              fontWeight: FontWeight.w300,
              color: SariwaColors.textSecondaryDark,
            ),
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),

          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                CupertinoIcons.lock_shield,
                size: 20,
                color: Color(0xFF10B981),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your photos and account',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Signed-in scans are saved to your account. You can delete them below. Guest history stays on this device.',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF64748B),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 18),

          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clear Scan History',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Permanently remove all scan records and associated fish photos belonging to your account.',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                key: const Key('btn_clear_all_history'),
                onPressed: _isClearingHistory ? null : _confirmClearAllHistory,
                icon: _isClearingHistory
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(CupertinoIcons.trash, size: 15),
                label: Text(
                  _isClearingHistory ? 'Clearing...' : 'Clear All History',
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsSecurityCard() {
    return FrostedGlassCard(
      padding: const EdgeInsets.all(22),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sign-in & Security',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'You sign in using your Google account.',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 12.5,
              fontWeight: FontWeight.w300,
              color: SariwaColors.textSecondaryDark,
            ),
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),

          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(
                  CupertinoIcons.checkmark_shield_fill,
                  size: 20,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Google sign-in',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Manage your Google password and sign-in options in your Google account.',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Connected',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFECACA), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                CupertinoIcons.exclamationmark_triangle_fill,
                color: Color(0xFFDC2626),
                size: 20,
              ),
              SizedBox(width: 10),
              Text(
                'Danger Zone',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF991B1B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Deleting your account is permanent.',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 12.5,
              fontWeight: FontWeight.w300,
              color: Color(0xFFB91C1C),
            ),
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFFCA5A5)),

          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delete SariwaBa Account',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7F1D1D),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Delete your account and all saved scans. This cannot be undone.',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF991B1B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              ElevatedButton.icon(
                key: const Key('btn_delete_account'),
                onPressed: _isDeletingAccount ? null : _confirmDeleteAccount,
                icon: _isDeletingAccount
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(CupertinoIcons.trash_fill, size: 15),
                label: Text(
                  _isDeletingAccount ? 'Deleting...' : 'Delete Account',
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
