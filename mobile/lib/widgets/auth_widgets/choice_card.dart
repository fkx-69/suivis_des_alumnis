import 'package:flutter/material.dart';
import 'package:memoire/constants/app_theme.dart';

class ChoiceCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const ChoiceCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  State<ChoiceCard> createState() => _ChoiceCardState();
}

class _ChoiceCardState extends State<ChoiceCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isHovered 
                        ? colorScheme.secondary 
                        : AppTheme.borderColor,
                    width: _isHovered ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.04),
                      blurRadius: _isHovered ? 12 : 8,
                      offset: Offset(0, _isHovered ? 6 : 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icône avec conteneur stylisé
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: _isHovered 
                            ? AppTheme.accentGradient
                            : LinearGradient(
                                colors: [
                                  colorScheme.secondary.withOpacity(0.1),
                                  colorScheme.secondary.withOpacity(0.05),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.secondary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 28,
                        color: _isHovered 
                            ? Colors.white 
                            : colorScheme.secondary,
                      ),
                    ),
                    
                    const SizedBox(width: 20),
                    
                    // Contenu textuel
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.description,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppTheme.subTextColor,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Flèche avec animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: _isHovered 
                            ? colorScheme.secondary 
                            : AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
