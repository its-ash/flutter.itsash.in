import 'package:flutter/material.dart';

import 'package:theme/theme.dart';
import '../showcase_tile.dart';

class FormsSection extends StatefulWidget {
  const FormsSection({super.key});

  @override
  State<FormsSection> createState() => _FormsSectionState();
}

class _FormsSectionState extends State<FormsSection> {
  double _rating = 3.5;

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      children: [
        ShowcaseTile(
          title: 'ThemeStatCard',
          child: Row(
            children: [
              Expanded(
                child: ThemeStatCard(
                  label: 'Revenue',
                  value: '\$12,480',
                  icon: Icons.payments_outlined,
                  trend: ThemeStatTrend.up,
                  trendLabel: '+12% this week',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ThemeStatCard(
                  label: 'Refunds',
                  value: '\$320',
                  icon: Icons.replay_outlined,
                  trend: ThemeStatTrend.down,
                  trendLabel: '-4% this week',
                ),
              ),
            ],
          ),
        ),
        ShowcaseTile(
          title: 'ThemeStepper',
          child: ThemeStepper(
            steps: const ['Cart', 'Address', 'Payment', 'Done'],
            currentStep: 1,
          ),
        ),
        ShowcaseTile(
          title: 'ThemeOtpField',
          description: 'Auto-advancing boxed OTP input, one style option',
          child: ThemeOtpField(autofocus: false, onCompleted: (_) {}),
        ),
        ShowcaseTile(
          title: 'ThemeOtpInput',
          description: 'Configurable box shape/size/spacing and obscure mode',
          child: ThemeOtpInput(autofocus: false, boxShape: BoxShape.rectangle, onCompleted: (_) {}),
        ),
        ShowcaseTile(
          title: 'ThemePasswordField',
          child: const ThemePasswordField(hintText: 'Enter your password'),
        ),
        ShowcaseTile(
          title: 'ThemeAppPasswordField',
          description: 'Same as ThemePasswordField, plus an optional strength indicator',
          child: const ThemeAppPasswordField(
            hintText: 'Enter your password',
            showStrengthIndicator: true,
          ),
        ),
        ShowcaseTile(
          title: 'ThemeLabeledField',
          child: ThemeLabeledField(
            label: 'Shipping address',
            required: true,
            helperText: 'We deliver to this address by default.',
            child: const ThemeTextField(hintText: '123 Main St'),
          ),
        ),
        ShowcaseTile(
          title: 'ThemeSearchableDropdown<T>',
          description: 'Filterable dropdown for long option lists',
          child: ThemeSearchableDropdown<String>(
            label: 'Country',
            hint: 'Select a country',
            items: const ['United States', 'India', 'United Kingdom', 'Germany', 'Japan', 'Brazil'],
            onChanged: (_) {},
          ),
        ),
        ShowcaseTile(
          title: 'ThemeRatingInput',
          description: 'Tap-to-rate, with half-star support',
          child: ThemeRatingInput(
            rating: _rating,
            allowHalfRating: true,
            onChanged: (r) => setState(() => _rating = r),
          ),
        ),
        ShowcaseTile(
          title: 'ThemeTagInput',
          description: 'Enter or comma to add a tag',
          child: ThemeTagInput(
            initialTags: const ['flutter', 'dart'],
            hintText: 'Add a tag…',
            onChanged: (_) {},
          ),
        ),
      ],
    );
  }
}
