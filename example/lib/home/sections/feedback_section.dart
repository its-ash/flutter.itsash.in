import 'package:flutter/material.dart';

import 'package:theme/theme.dart';
import '../showcase_tile.dart';

class FeedbackSection extends StatelessWidget {
  const FeedbackSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      children: [
        ShowcaseTile(
          title: 'Notify',
          description: 'success | error | warning | info',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ThemeButton(label: 'Success', onPressed: () => Notify.success(context, 'Order placed successfully')),
              ThemeButton(label: 'Error', onPressed: () => Notify.error(context, 'Payment failed, please try again')),
              ThemeButton(label: 'Warning', onPressed: () => Notify.warning(context, 'Low stock remaining')),
              ThemeButton(label: 'Info', onPressed: () => Notify.info(context, 'New update available')),
            ],
          ),
        ),
        ShowcaseTile(
          title: 'ThemeToast',
          description: 'Like Notify, but needs no Scaffold — stacks on repeated calls',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ThemeButton(label: 'Success', onPressed: () => ThemeToast.success(context, 'Order placed successfully')),
              ThemeButton(label: 'Error', onPressed: () => ThemeToast.error(context, 'Payment failed, please try again')),
              ThemeButton(label: 'Warning', onPressed: () => ThemeToast.warning(context, 'Low stock remaining')),
              ThemeButton(label: 'Info', onPressed: () => ThemeToast.info(context, 'New update available')),
            ],
          ),
        ),
        ShowcaseTile(
          title: 'ThemeSnackBar',
          child: ThemeButton(
            label: 'Show snackbar',
            onPressed: () => ThemeSnackBar.show(context, 'A plain themed snackbar'),
          ),
        ),
        ShowcaseTile(
          title: 'ThemeBanner',
          child: ThemeButton(
            label: 'Show banner',
            onPressed: () => ThemeBanner.show(
              context,
              message: 'Your session will expire soon',
              actions: [
                TextButton(onPressed: () => ThemeBanner.hide(context), child: const Text('Dismiss')),
              ],
            ),
          ),
        ),
        ShowcaseTile(
          title: 'ThemeDialog',
          child: ThemeButton(
            label: 'Show dialog',
            onPressed: () => ThemeDialog.show<void>(
              context,
              title: 'Delete item?',
              content: 'This action cannot be undone.',
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Delete')),
              ],
            ),
          ),
        ),
        ShowcaseTile(
          title: 'ThemeBottomSheet',
          child: ThemeButton(
            label: 'Show bottom sheet',
            onPressed: () => ThemeBottomSheet.show<void>(
              context,
              builder: (_) => const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Bottom sheet content'),
              ),
            ),
          ),
        ),
        ShowcaseTile(
          title: 'ThemeProgressIndicator',
          description: 'linear | circular',
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ThemeProgressIndicator(),
              SizedBox(height: 16),
              ThemeProgressIndicator(type: ThemeProgressIndicatorType.linear, value: 0.6),
            ],
          ),
        ),
        ShowcaseTile(
          title: 'ThemeBadge',
          child: ThemeBadge(label: '3', child: const Icon(Icons.notifications_outlined, size: 28)),
        ),
      ],
    );
  }
}
