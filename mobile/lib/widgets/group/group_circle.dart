import 'package:flutter/material.dart';
import 'package:memoire/constants/app_theme.dart';

class GroupCircle extends StatefulWidget {
  final String nom;
  final bool isMember;
  final VoidCallback? onJoin;
  final VoidCallback? onTap;
  final String? photoProfil; // Ajout optionnel

  const GroupCircle({
    super.key,
    required this.nom,
    this.isMember = false,
    this.onJoin,
    this.onTap,
    this.photoProfil,
  });

  @override
  State<GroupCircle> createState() => _GroupCircleState();
}

class _GroupCircleState extends State<GroupCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController = AnimationController(
    duration: const Duration(milliseconds: 150),
    vsync: this,
  );

  late final Animation<double> _scaleAnimation = Tween<double>(
    begin: 1.0,
    end: 0.95,
  ).animate(CurvedAnimation(
    parent: _scaleController,
    curve: Curves.easeInOut,
  ));

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final displayName =
    widget.nom.length > 6 ? '${widget.nom.substring(0, 6)}…' : widget.nom;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    onTapDown: _handleTapDown,
                    onTapUp: _handleTapUp,
                    onTapCancel: _handleTapCancel,
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: widget.isMember
                            ? AppTheme.accentGradient
                            : LinearGradient(
                          colors: [
                            AppTheme.surfaceColor,
                            AppTheme.surfaceColor,
                          ],
                        ),
                        border: Border.all(
                          color: widget.isMember
                              ? colorScheme.secondary.withAlpha(77)
                              : AppTheme.borderColor,
                          width: 2,
                        ),
                        image: widget.photoProfil != null && widget.photoProfil!.isNotEmpty
                            ? DecorationImage(
                          image: NetworkImage(widget.photoProfil!),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: widget.photoProfil == null || widget.photoProfil!.isEmpty
                          ? Center(
                        child: Text(
                          widget.nom[0].toUpperCase(),
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.isMember
                                ? Colors.white
                                : AppTheme.primaryColor,
                          ),
                        ),
                      )
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 60,
                child: Text(
                  displayName,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                    fontSize: 9,
                  ),
                ),
              ),
              if (!widget.isMember && widget.onJoin != null) ...[
                const SizedBox(height: 4),
                SizedBox(
                  width: 60,
                  height: 22,
                  child: ElevatedButton(
                    onPressed: widget.onJoin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.secondary,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Rejoindre',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontSize: 7.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
