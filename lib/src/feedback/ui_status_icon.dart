import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';

extension UiStatusIcon on UiStatus {
  IconData get icon => switch (this) {
        UiStatus.neutral => Icons.notifications_none_rounded,
        UiStatus.info => Icons.info_rounded,
        UiStatus.success => Icons.check_circle_rounded,
        UiStatus.warning => Icons.warning_rounded,
        UiStatus.danger => Icons.error_rounded,
      };
}
