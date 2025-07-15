import 'package:flutter/material.dart';
import 'package:memoire/constants/app_theme.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';

class EventCard extends StatefulWidget {
  final EventModel event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // Si dateDebutAffiche est nul, on formate soi-même
    final labelDate = widget.event.dateDebutAffiche ??
        DateFormat.yMMMd(Localizations.localeOf(context).toString())
            .add_Hm()
            .format(widget.event.dateDebut);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  onTapDown: _onTapDown,
                  onTapUp: _onTapUp,
                  onTapCancel: _onTapCancel,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En-tête avec image si disponible
                        if (widget.event.image != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(
                                widget.event.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppTheme.surfaceColor,
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: AppTheme.subTextColor.withOpacity(0.5),
                                      size: 32,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Titre de l'événement
                        Text(
                          widget.event.titre,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Date avec icône
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: colorScheme.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                labelDate,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.subTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Description (si présente)
                        if (widget.event.description != null && widget.event.description!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            widget.event.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppTheme.subTextColor.withOpacity(0.8),
                              height: 1.4,
                            ),
                          ),
                        ],

                        // Statut de validation
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: widget.event.valide 
                                    ? AppTheme.successColor.withOpacity(0.1)
                                    : AppTheme.warningColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: widget.event.valide 
                                      ? AppTheme.successColor.withOpacity(0.3)
                                      : AppTheme.warningColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    widget.event.valide 
                                        ? Icons.check_circle_outline
                                        : Icons.schedule,
                                    size: 14,
                                    color: widget.event.valide 
                                        ? AppTheme.successColor
                                        : AppTheme.warningColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.event.valide 
                                        ? 'Validé'
                                        : 'En attente',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: widget.event.valide 
                                          ? AppTheme.successColor
                                          : AppTheme.warningColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppTheme.subTextColor.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
