import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/failures.dart';
import '../../l10n/generated/app_localizations.dart';

/// Maps a [Failure] (or any error) to localized user copy.
String failureMessage(BuildContext context, Object error) {
  final l = AppLocalizations.of(context)!;
  if (error is! Failure) return l.errorUnknown;
  return switch (error.kind) {
    FailureKind.network => l.errorNetwork,
    FailureKind.timeout => l.errorTimeout,
    FailureKind.checksum => l.errorChecksum,
    FailureKind.path => l.errorPath,
    FailureKind.disk => l.errorDisk,
    FailureKind.parse => l.errorParse,
    FailureKind.urlInvalid => l.errorUrlInvalid,
    FailureKind.process => l.errorProcess,
    FailureKind.notFound => l.errorNotFound,
    FailureKind.conflict => l.errorConflict,
    FailureKind.cancelled => l.errorCancelled,
    FailureKind.unknown => l.errorUnknown,
  };
}

void showError(BuildContext context, Object error, [StackTrace? stack]) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(failureMessage(context, error)),
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
    ));
}

void showInfo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: scheme.primary),
                const SizedBox(width: 6),
              ],
              Text(label, style: Theme.of(context).textTheme.labelMedium),
            ]),
            const SizedBox(height: 6),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}

/// Standard async wrapper: loading spinner / error with retry / content.
class AsyncView<T> extends ConsumerWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.builder,
    required this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(BuildContext, T) builder;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return value.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => EmptyState(
        icon: Icons.error_outline,
        message: failureMessage(context, e),
      ),
      data: (data) => builder(context, data),
    );
  }
}

/// Section header used across pages.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          ...?actions,
        ],
      ),
    );
  }
}
