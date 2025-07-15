import 'dart:math';
import 'package:flutter/material.dart';
import 'package:memoire/constants/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:memoire/models/stat_domaine_model.dart';
import 'package:memoire/models/stat_situation_model.dart';
import 'package:memoire/services/statistique_service.dart';

class StatistiquesScreen extends StatefulWidget {
  const StatistiquesScreen({super.key});

  @override
  State<StatistiquesScreen> createState() => _StatistiquesScreenState();
}

class _StatistiquesScreenState extends State<StatistiquesScreen> with TickerProviderStateMixin {
  final StatistiqueService _service = StatistiqueService();

  int? _selectedFiliereId;
  final List<Map<String, dynamic>> _filieres = [
    {'id': 1, 'nom': 'Informatique'},
    {'id': 2, 'nom': 'Électronique'},
    {'id': 3, 'nom': 'Mathématiques'},
    {'id': 4, 'nom': 'Télécommunications'},
    {'id': 5, 'nom': 'Génie Civil'},
  ];

  List<StatDomaineModel> _domaines = [];
  List<StatSituationModel> _situations = [];

  bool _loadingDomaines = false;
  bool _loadingSituations = true;
  bool _showPieChartDomaines = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _chartController;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _chartAnimation = CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutCubic,
    );
    _loadSituationGenerale();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  void _loadSituationGenerale() async {
    setState(() => _loadingSituations = true);
    try {
      final data = await _service.fetchSituationGenerale();
      if (mounted) {
        setState(() {
          _situations = data;
          _loadingSituations = false;
        });
        _chartController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingSituations = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.errorColor,
            content: Text(
              'Erreur de chargement : $e',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  void _loadDomaines(int filiereId) async {
    setState(() {
      _loadingDomaines = true;
      _domaines = [];
    });
    try {
      final data = await _service.fetchDomainesParFiliere(filiereId);
      if (mounted) {
        setState(() {
          _domaines = data;
          _loadingDomaines = false;
        });
        _chartController.reset();
        _chartController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingDomaines = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.errorColor,
            content: Text(
              'Erreur de chargement : $e',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Color _getColor(int index) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.accentColor,
      AppTheme.successColor,
      AppTheme.warningColor,
      AppTheme.errorColor,
      AppTheme.infoColor,
    ];
    return colors[index % colors.length];
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppTheme.subTextColor,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final domainColors = _domaines.asMap().entries.map((entry) => _getColor(entry.key)).toList();
    final situationColors = _situations.asMap().entries.map((entry) => _getColor(entry.key)).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Statistiques',
          style: textTheme.titleLarge?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cartes de statistiques générales
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total Alumni',
                      value: _situations.fold(0, (sum, item) => sum + item.count).toString(),
                      icon: Icons.people,
                      color: colorScheme.secondary,
                      subtitle: 'Membres inscrits',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Filières',
                      value: _filieres.length.toString(),
                      icon: Icons.school,
                      color: AppTheme.successColor,
                      subtitle: 'Domaines d\'étude',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Section Domaines par filière
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Domaines par filière',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.borderColor,
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedFiliereId,
                            hint: Text(
                              'Sélectionner une filière',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppTheme.subTextColor,
                              ),
                            ),
                            isExpanded: true,
                            items: _filieres.map((filiere) {
                              return DropdownMenuItem<int>(
                                value: filiere['id'],
                                child: Text(
                                  filiere['nom'],
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedFiliereId = value);
                              if (value != null) _loadDomaines(value);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.borderColor,
                                width: 1,
                              ),
                            ),
                            child: TextButton.icon(
                              onPressed: () {
                                setState(() => _showPieChartDomaines = !_showPieChartDomaines);
                              },
                              icon: Icon(
                                _showPieChartDomaines ? Icons.bar_chart : Icons.pie_chart,
                                color: colorScheme.secondary,
                                size: 20,
                              ),
                              label: Text(
                                _showPieChartDomaines ? 'Barres' : 'Camembert',
                                style: textTheme.labelMedium?.copyWith(
                                  color: colorScheme.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Graphique des domaines
              Container(
                margin: const EdgeInsets.only(bottom: 24),
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
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Domaines d\'activité',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_loadingDomaines)
                        Container(
                          height: 300,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Chargement des données...',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.subTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (_domaines.isEmpty)
                        Container(
                          height: 300,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.analytics_outlined,
                                  size: 48,
                                  color: AppTheme.subTextColor.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Aucun domaine à afficher',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.subTextColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Column(
                          children: [
                            SizedBox(
                              height: 300,
                              child: AnimatedBuilder(
                                animation: _chartAnimation,
                                builder: (context, child) {
                                  return _showPieChartDomaines
                                      ? PieChart(
                                          PieChartData(
                                            sections: _domaines.asMap().entries.map((entry) {
                                              final i = entry.key;
                                              final d = entry.value;
                                              return PieChartSectionData(
                                                value: d.count.toDouble() * _chartAnimation.value,
                                                title: '${d.domaine}\n(${d.count})',
                                                radius: 80,
                                                color: domainColors[i],
                                                titleStyle: textTheme.bodySmall?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              );
                                            }).toList(),
                                            centerSpaceRadius: 40,
                                            sectionsSpace: 2,
                                          ),
                                        )
                                      : BarChart(
                                          BarChartData(
                                            barGroups: _domaines.asMap().entries.map((entry) {
                                              final i = entry.key;
                                              final d = entry.value;
                                              return BarChartGroupData(
                                                x: i,
                                                barRods: [
                                                  BarChartRodData(
                                                    toY: d.count.toDouble() * _chartAnimation.value,
                                                    width: 20,
                                                    color: domainColors[i],
                                                    borderRadius: const BorderRadius.only(
                                                      topLeft: Radius.circular(4),
                                                      topRight: Radius.circular(4),
                                                    ),
                                                  )
                                                ],
                                              );
                                            }).toList(),
                                            titlesData: FlTitlesData(
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget: (value, meta) {
                                                    final index = value.toInt();
                                                    if (index >= 0 && index < _domaines.length) {
                                                      return Padding(
                                                        padding: const EdgeInsets.only(top: 8),
                                                        child: Text(
                                                          _domaines[index].domaine,
                                                          style: textTheme.bodySmall?.copyWith(
                                                            color: AppTheme.subTextColor,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      );
                                                    }
                                                    return const SizedBox.shrink();
                                                  },
                                                ),
                                              ),
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget: (value, meta) {
                                                    return Text(
                                                      value.toInt().toString(),
                                                      style: textTheme.bodySmall?.copyWith(
                                                        color: AppTheme.subTextColor,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                            ),
                                            gridData: FlGridData(
                                              show: true,
                                              drawVerticalLine: false,
                                              horizontalInterval: 1,
                                              getDrawingHorizontalLine: (value) {
                                                return FlLine(
                                                  color: AppTheme.borderColor.withOpacity(0.3),
                                                  strokeWidth: 1,
                                                );
                                              },
                                            ),
                                            borderData: FlBorderData(
                                              show: true,
                                              border: Border(
                                                bottom: BorderSide(color: AppTheme.borderColor),
                                                left: BorderSide(color: AppTheme.borderColor),
                                              ),
                                            ),
                                          ),
                                        );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _domaines.asMap().entries.map((entry) {
                                final i = entry.key;
                                final d = entry.value;
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: domainColors[i].withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: domainColors[i].withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: domainColors[i],
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${d.domaine} (${d.count})',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // Section Situation professionnelle
              Container(
                margin: const EdgeInsets.only(bottom: 24),
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
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Situation professionnelle',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_loadingSituations)
                        Container(
                          height: 300,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Chargement des données...',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.subTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Column(
                          children: [
                            SizedBox(
                              height: 300,
                              child: AnimatedBuilder(
                                animation: _chartAnimation,
                                builder: (context, child) {
                                  return PieChart(
                                    PieChartData(
                                      sections: _situations.asMap().entries.map((entry) {
                                        final i = entry.key;
                                        final s = entry.value;
                                        return PieChartSectionData(
                                          value: s.count.toDouble() * _chartAnimation.value,
                                          title: '${s.situation}\n(${s.count})',
                                          radius: 80,
                                          color: situationColors[i],
                                          titleStyle: textTheme.bodySmall?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        );
                                      }).toList(),
                                      centerSpaceRadius: 40,
                                      sectionsSpace: 2,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _situations.asMap().entries.map((entry) {
                                final i = entry.key;
                                final s = entry.value;
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: situationColors[i].withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: situationColors[i].withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: situationColors[i],
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${s.situation} (${s.count})',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
