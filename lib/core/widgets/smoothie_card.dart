import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_assets.dart';
import 'package:frontend/core/constants/app_colours.dart';
import '../models/smoothie_model.dart';
import '../utils/currency_formatter.dart';

class SmoothieCard extends StatelessWidget {
  final SmoothieModel smoothie;
  final VoidCallback? onTap;

  const SmoothieCard({
    super.key,
    required this.smoothie,
    this.onTap,
  });

  static String getImageForSmoothie(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('berry') || lower.contains('very')) return AppAssets.veryBerry;
    if (lower.contains('blue') || lower.contains('tru')) return AppAssets.truBlue;
    if (lower.contains('green') || lower.contains('machine')) return AppAssets.machineGreen;
    if (lower.contains('island') || lower.contains('vibez')) return AppAssets.islandVibez;
    if (lower.contains('granola') || lower.contains('punch')) return AppAssets.granolaPunch;
    if (lower.contains('mango') || lower.contains('rich')) return AppAssets.richMango;
    if (lower.contains('energy') || lower.contains('gaad')) return AppAssets.energyGaad;
    if (lower.contains('power')) return AppAssets.powerPunch;
    return AppAssets.placeholderSmoothie;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      getImageForSmoothie(smoothie.name),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.local_drink_rounded,
                          size: 54,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                smoothie.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                smoothie.category,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                CurrencyFormatter.formatJmd(smoothie.startingPrice),
                style: const TextStyle(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
