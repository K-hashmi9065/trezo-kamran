import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../constants/app_colors.dart';

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    ToastificationType type = ToastificationType.info,
    Duration duration = const Duration(seconds: 3),
    String? title,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.fillColored,
      title: title != null ? Text(title) : null,
      description: Text(message),
      alignment: Alignment.topCenter,
      autoCloseDuration: duration,
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: const [
        BoxShadow(
          color: Color(0x07000000),
          blurRadius: 16,
          offset: Offset(0, 16),
          spreadRadius: 0,
        ),
      ],
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
      primaryColor: _getPrimaryColor(type),
      backgroundColor: _getBackgroundColor(type),
      foregroundColor: Colors.white,
      icon: Icon(_getIcon(type), color: Colors.white),
      callbacks: ToastificationCallbacks(
        onTap: (toastItem) {
          if (onActionPressed != null) {
            onActionPressed();
          }
        },
      ),
    );
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    show(
      context,
      message: message,
      title: title,
      type: ToastificationType.success,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    show(
      context,
      message: message,
      title: title,
      type: ToastificationType.error,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static void showWarning(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    show(
      context,
      message: message,
      title: title,
      type: ToastificationType.warning,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    show(
      context,
      message: message,
      title: title,
      type: ToastificationType.info,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static Color _getPrimaryColor(ToastificationType type) {
    switch (type) {
      case ToastificationType.success:
        return AppColors.success;
      case ToastificationType.error:
        return AppColors.error;
      case ToastificationType.warning:
        return AppColors.warning;
      case ToastificationType.info:
        return AppColors.primaryBlue;
    }
  }

  static Color _getBackgroundColor(ToastificationType type) {
    switch (type) {
      case ToastificationType.success:
        return AppColors.success;
      case ToastificationType.error:
        return AppColors.error;
      case ToastificationType.warning:
        return AppColors.warning;
      case ToastificationType.info:
        return AppColors.primaryBlue;
    }
  }

  static IconData _getIcon(ToastificationType type) {
    switch (type) {
      case ToastificationType.success:
        return Icons.check_circle;
      case ToastificationType.error:
        return Icons.error;
      case ToastificationType.warning:
        return Icons.warning;
      case ToastificationType.info:
        return Icons.info;
    }
  }
}
