import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format.dart';
import '../../../core/motion.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_icons.dart';
import '../data/dashboard_stats.dart';
import '../dashboard_home_strings.dart';
import 'dash_icon_bubble.dart';
import 'home_pill.dart';

/// Hero Net Profit Card per HM1:
/// - Ink background, radius 32
/// - Wallet icon bubble
/// - "Net profit" / "All time"
/// - Big value (white 34 bold)
/// - Delta chip (`"<amount> this month"`, green with trendingUp or red with trendingDown)
/// - 6-bar mini chart (last 6 months net, last bar yellow) and "Last 6 months"
/// - Chevron icon
/// - Tap -> /home/profit
class HomeHeroProfitCard extends StatelessWidget {
  const HomeHeroProfitCard({
    super.key,
    required this.netProfitValue,
    required this.thisMonthNetValue,
    required this.last6MonthFlows,
    this.onTap,
  });

  final double netProfitValue;
  final double thisMonthNetValue;
  final List<MonthFlow> last6MonthFlows;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const BorderRadius radius = BorderRadius.all(Radius.circular(32));
    final bool isPositive = thisMonthNetValue >= 0;
    final String deltaSign = isPositive ? '+' : '-';
    final String deltaText =
        '$deltaSign${formatAmount(thisMonthNetValue.abs())} ${DashboardHomeStrings.thisMonth}';

    // Calculate max net for scaling the 6 bars (min height 8, max height 38)
    double maxAbsNet = 1.0;
    for (final MonthFlow flow in last6MonthFlows) {
      if (flow.net.abs() > maxAbsNet) {
        maxAbsNet = flow.net.abs();
      }
    }

    return Material(
      color: AppColors.ink,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () => context.push('/home/profit'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Wallet icon bubble, Net profit / All time, and chevron
              Row(
                children: [
                  const DashIconBubble(
                    icon: AppIcons.wallet,
                    background: Color(0xFF333338),
                    foreground: AppColors.white,
                    size: 36,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DashboardHomeStrings.netProfit,
                        style: AppText.caption.copyWith(
                          color: AppColors.placeholder,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        DashboardHomeStrings.allTime,
                        style: AppText.captionSm.copyWith(
                          color: const Color(0xFF8A8A93),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(
                    AppIcons.chevronRight,
                    color: Color(0xFF8A8A93),
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Middle row: Big value on left, 6-bar mini chart on right
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: netProfitValue),
                      duration: AppMotion.reduced(context)
                          ? Duration.zero
                          : AppMotion.page,
                      curve: AppMotion.enterCurve,
                      builder: (BuildContext context, double value, Widget? _) {
                        return Text(
                          formatMoney(value),
                          style: AppText.title.copyWith(
                            color: AppColors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 38,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (int i = 0; i < 6; i++) ...[
                              if (i > 0) const SizedBox(width: 4),
                              Builder(
                                builder: (context) {
                                  final double val = i < last6MonthFlows.length
                                      ? last6MonthFlows[i].net.abs()
                                      : 0.0;
                                  final double ratio = (val / maxAbsNet).clamp(
                                    0.15,
                                    1.0,
                                  );
                                  final double barHeight = 8.0 + (ratio * 30.0);
                                  final bool isLast = i == 5;
                                  return Container(
                                    width: 7,
                                    height: barHeight,
                                    decoration: BoxDecoration(
                                      color: isLast
                                          ? AppColors.yellow
                                          : const Color(0xFF4A4A54),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DashboardHomeStrings.last6Months,
                        style: AppText.captionSm.copyWith(
                          color: const Color(0xFF8A8A93),
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Bottom row: Delta chip
              HomePill(
                label: deltaText,
                icon: isPositive ? AppIcons.trendingUp : AppIcons.trendingDown,
                backgroundColor: isPositive
                    ? AppColors.greenBg
                    : AppColors.redBg,
                textColor: isPositive ? AppColors.green : AppColors.red,
                iconColor: isPositive ? AppColors.green : AppColors.red,
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
