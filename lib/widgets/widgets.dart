import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

export 'app_logo.dart';

class CareRatingBadge extends StatelessWidget {
  const CareRatingBadge({
    super.key,
    required this.rating,
    required this.l10n,
    this.compact = false,
  });

  final int rating;
  final AppLocalizations l10n;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = CareRatingTheme.colorFor(rating);
    final label = l10n.t(CareRatingTheme.labelKey(rating));

    if (compact) {
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        '$rating · $label',
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.role, required this.l10n});

  final UserRole role;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final label = switch (role) {
      UserRole.superAdmin => l10n.t('role_super_admin'),
      UserRole.manager => l10n.t('role_manager'),
      UserRole.familyMember => l10n.t('role_family_member'),
    };

    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      visualDensity: VisualDensity.compact,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }
}

class DemographicBadge extends StatelessWidget {
  const DemographicBadge({
    super.key,
    required this.demographic,
    required this.l10n,
  });

  final Demographic demographic;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final label = switch (demographic) {
      Demographic.adult => l10n.t('demographic_adult'),
      Demographic.student => l10n.t('demographic_student'),
      Demographic.child => l10n.t('demographic_child'),
    };

    return Text(label, style: Theme.of(context).textTheme.labelMedium);
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.profile,
    required this.l10n,
    this.highlighted = false,
    this.onTap,
    this.compact = false,
  });

  final Profile profile;
  final AppLocalizations l10n;
  final bool highlighted;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ringColor = CareRatingTheme.colorFor(profile.careRating);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: compact ? 100 : 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: highlighted
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: highlighted ? ringColor : Colors.grey.shade300,
            width: highlighted ? 3 : 1,
          ),
          boxShadow: highlighted
              ? [BoxShadow(color: ringColor.withValues(alpha: 0.3), blurRadius: 8)]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: compact ? 20 : 28,
              backgroundColor: ringColor.withValues(alpha: 0.2),
              child: Text(
                profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?',
                style: TextStyle(
                  color: ringColor,
                  fontWeight: FontWeight.bold,
                  fontSize: compact ? 16 : 22,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              profile.fullName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: highlighted ? FontWeight.bold : FontWeight.w500,
                fontSize: compact ? 11 : 13,
              ),
            ),
            if (!compact) ...[
              const SizedBox(height: 4),
              CareRatingBadge(rating: profile.careRating, l10n: l10n, compact: true),
            ],
          ],
        ),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.color,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null)
                Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!),
          ],
        ],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
