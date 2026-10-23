import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../models/classification/classification_result.dart';
import '../widgets/dashboard_charts.dart';

class FreshnessTrendsSection extends StatefulWidget {
  final List<ClassificationResult> history;

  const FreshnessTrendsSection({super.key, required this.history});

  @override
  State<FreshnessTrendsSection> createState() => _FreshnessTrendsSectionState();
}

class _FreshnessTrendsSectionState extends State<FreshnessTrendsSection> {
  int _selectedMonthIndex = 4; // May highlighted by default

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final total = widget.history.isNotEmpty ? widget.history.length : 1248;
    final fresh = widget.history.isNotEmpty
        ? widget.history.where((s) => s.isFresh).length
        : 1086;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: SariwaColors.borderLightTeal, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x060A2229),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 24,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Freshness Inspection Overview',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          color: SariwaColors.textPrimaryDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Verified Grade A Catch:  ',
                            style: TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.15,
                              color: SariwaColors.textMutedDark,
                            ),
                          ),
                          Text(
                            '$fresh / $total Scans',
                            style: const TextStyle(
                              fontFamily: 'Geist',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.4,
                              color: SariwaColors.textPrimaryDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDCEAEA),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Total Batch Volume',
                        style: TextStyle(
                          fontSize: 12,
                          color: SariwaColors.textMutedDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: SariwaColors.brandPrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Sariwa (Grade A)',
                        style: TextStyle(
                          fontSize: 12,
                          color: SariwaColors.textSecondaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 22),

              SizedBox(
                height: 230,
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: ['600', '500', '400', '300', '200', '100', '0']
                          .map(
                            (label) => Text(
                              label,
                              style: const TextStyle(
                                fontSize: 11,
                                color: SariwaColors.textMutedDark,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, chartConstraints) {
                          return Stack(
                            children: [
                              Positioned.fill(
                                child: GestureDetector(
                                  onTapDown: (details) {
                                    final relX =
                                        details.localPosition.dx /
                                        chartConstraints.maxWidth;
                                    final idx = (relX * 12).floor().clamp(
                                      0,
                                      11,
                                    );
                                    setState(() => _selectedMonthIndex = idx);
                                  },
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: CustomPaint(
                                      painter: BlockMatrixChartPainter(
                                        selectedMonthIndex: _selectedMonthIndex,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left:
                                    ((_selectedMonthIndex / 12) *
                                            (chartConstraints.maxWidth - 170))
                                        .clamp(
                                          8.0,
                                          math.max(
                                            8.0,
                                            chartConstraints.maxWidth - 175,
                                          ),
                                        ),
                                top: 24,
                                child: Container(
                                  width: 185,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: SariwaColors.borderLightTeal,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x140A2229),
                                        blurRadius: 18,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: SariwaColors.bgDashboard,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          '${_months[_selectedMonthIndex]} 2026',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                SariwaColors.textSecondaryDark,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(
                                                Icons.circle,
                                                size: 7,
                                                color: Color(0xFFBFD8D8),
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                'Inspected',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: SariwaColors
                                                      .textSecondaryDark,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${420 + (_selectedMonthIndex * 19)}',
                                            style: const TextStyle(
                                              fontFamily: 'Geist',
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: -0.2,
                                              color:
                                                  SariwaColors.textPrimaryDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(
                                                Icons.circle,
                                                size: 7,
                                                color:
                                                    SariwaColors.brandPrimary,
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                'Sariwa',
                                                style: TextStyle(
                                                  fontFamily: 'Geist',
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w400,
                                                  color: SariwaColors
                                                      .textSecondaryDark,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${370 + (_selectedMonthIndex * 15)}',
                                            style: const TextStyle(
                                              fontFamily: 'Geist',
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: -0.2,
                                              color: SariwaColors.brandPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.only(left: 34),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_months.length, (i) {
                    final isSelected = i == _selectedMonthIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMonthIndex = i),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Text(
                          _months[i],
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            letterSpacing: -0.15,
                            color: isSelected
                                ? SariwaColors.textPrimaryDark
                                : SariwaColors.textMutedDark,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -2,
          right: -2,
          child: Container(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            decoration: const BoxDecoration(
              color: SariwaColors.bgDashboard,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(22)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: SariwaColors.borderLightTeal),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'This Year',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: SariwaColors.textPrimaryDark,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 15,
                        color: SariwaColors.textSecondaryDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: SariwaColors.borderLightTeal),
                  ),
                  child: const Icon(
                    Icons.more_vert_rounded,
                    size: 16,
                    color: SariwaColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
