import 'package:flutter/material.dart';
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