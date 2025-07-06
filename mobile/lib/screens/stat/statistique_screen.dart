import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:memoire/models/stat_domaine_model.dart';
import 'package:memoire/models/stat_situation_model.dart';
import 'package:memoire/services/statistique_service.dart';

class StatistiquesScreen extends StatefulWidget {
  const StatistiquesScreen({super.key});

  @override
  State<StatistiquesScreen> createState() => _StatistiquesScreenState();
}

class _StatistiquesScreenState extends State<StatistiquesScreen> {
  final StatistiqueService _service = StatistiqueService();

  int? _selectedFiliereId;
  final List<Map<String, dynamic>> _filieres = [
    {'id': 1, 'nom': 'Informatique'},
    {'id': 2, 'nom': 'Électronique'},
    {'id': 3, 'nom': 'Mathématiques'},
    // Ajoute ici toutes tes filières
  ];

  List<StatDomaineModel> _domaines = [];
  List<StatSituationModel> _situations = [];

  bool _loadingDomaines = false;
  bool _loadingSituations = true;
  bool _showPieChartDomaines = false;

  @override
  void initState() {
    super.initState();
    _loadSituationGenerale();
  }

  void _loadSituationGenerale() async {
    setState(() => _loadingSituations = true);
    final data = await _service.fetchSituationGenerale();
    setState(() {
      _situations = data;
      _loadingSituations = false;
    });
  }

  void _loadDomaines(int filiereId) async {
    setState(() {
      _loadingDomaines = true;
      _domaines = [];
    });
    final data = await _service.fetchDomainesParFiliere(filiereId);
    setState(() {
      _domaines = data;
      _loadingDomaines = false;
    });
  }

  Color _randomColor() {
    final r = Random();
    return Color.fromARGB(255, r.nextInt(200), r.nextInt(200), r.nextInt(200));
  }

  @override
  Widget build(BuildContext context) {
    final domainColors = _domaines.map((_) => _randomColor()).toList();
    final situationColors = _situations.map((_) => _randomColor()).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Statistiques', style: GoogleFonts.poppins()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Domaines par filière', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButton<int>(
              value: _selectedFiliereId,
              hint: const Text('Sélectionner une filière'),
              isExpanded: true,
              items: _filieres.map((filiere) {
                return DropdownMenuItem<int>(
                  value: filiere['id'],
                  child: Text(filiere['nom']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedFiliereId = value);
                if (value != null) _loadDomaines(value);
              },
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() => _showPieChartDomaines = !_showPieChartDomaines);
                  },
                  icon: Icon(_showPieChartDomaines ? Icons.bar_chart : Icons.pie_chart),
                  label: Text(
                    _showPieChartDomaines ? 'Afficher en barres' : 'Afficher en camembert',
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _loadingDomaines
                ? const Center(child: CircularProgressIndicator())
                : _domaines.isEmpty
                ? const Text('Aucun domaine à afficher.')
                : Column(
              children: [
                SizedBox(
                  height: 300,
                  child: _showPieChartDomaines
                      ? PieChart(
                    PieChartData(
                      sections: _domaines.asMap().entries.map((entry) {
                        final i = entry.key;
                        final d = entry.value;
                        return PieChartSectionData(
                          value: d.count.toDouble(),
                          title: '${d.domaine} (${d.count})',
                          radius: 80,
                          color: domainColors[i],
                          titleStyle: const TextStyle(fontSize: 12),
                        );
                      }).toList(),
                    ),
                  )
                      : BarChart(
                    BarChartData(
                      barGroups: _domaines.asMap().entries.map((entry) {
                        final i = entry.key;
                        final d = entry.value;
                        return BarChartGroupData(
                          x: i,
                          barRods: [BarChartRodData(toY: d.count.toDouble(), width: 20, color: domainColors[i])],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < _domaines.length) {
                                return Text(
                                  _domaines[index].domaine,
                                  style: const TextStyle(fontSize: 10),
                                  overflow: TextOverflow.ellipsis,
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _domaines.asMap().entries.map((entry) {
                    final i = entry.key;
                    final d = entry.value;
                    return Chip(
                      backgroundColor: domainColors[i].withOpacity(0.2),
                      avatar: CircleAvatar(backgroundColor: domainColors[i], radius: 6),
                      label: Text('${d.domaine} (${d.count})', style: GoogleFonts.poppins(fontSize: 12)),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text('Situation professionnelle (tous alumnis)', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _loadingSituations
                ? const Center(child: CircularProgressIndicator())
                : _situations.isEmpty
                ? const Text('Aucune donnée.')
                : Column(
              children: [
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sections: _situations.asMap().entries.map((entry) {
                        final i = entry.key;
                        final s = entry.value;
                        return PieChartSectionData(
                          value: s.count.toDouble(),
                          title: '${s.situation} (${s.count})',
                          radius: 80,
                          color: situationColors[i],
                          titleStyle: const TextStyle(fontSize: 12),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _situations.asMap().entries.map((entry) {
                    final i = entry.key;
                    final s = entry.value;
                    return Chip(
                      backgroundColor: situationColors[i].withOpacity(0.2),
                      avatar: CircleAvatar(backgroundColor: situationColors[i], radius: 6),
                      label: Text('${s.situation} (${s.count})', style: GoogleFonts.poppins(fontSize: 12)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
