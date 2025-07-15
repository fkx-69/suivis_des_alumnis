import 'package:flutter/material.dart';
import 'package:memoire/constants/app_theme.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const SearchBarWidget({
    Key? key,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Rechercher un utilisateur...',
          hintStyle: textTheme.bodyMedium?.copyWith(
            color: AppTheme.subTextColor.withOpacity(0.7),
            fontSize: 13,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: colorScheme.secondary,
            size: 18,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        style: textTheme.bodyMedium?.copyWith(
          color: AppTheme.primaryColor,
          fontSize: 13,
        ),
      ),
    );
  }
}
