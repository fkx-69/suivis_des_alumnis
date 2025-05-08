import 'package:flutter/material.dart';
import 'package:memoire/services/auth_service.dart';

class ProfileAlumni extends StatefulWidget {
  @override
  _ProfileAlumniState createState() => _ProfileAlumniState();
}

class _ProfileAlumniState extends State<ProfileAlumni> {
  Map<String, dynamic>? profileData;
  Map<String, dynamic>? filteredData;
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProfile();
    searchController.addListener(_filterData);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterData() {
    final query = searchController.text.toLowerCase();

    if (query.isEmpty) {
      setState(() {
        filteredData = profileData;
      });
    } else {
      final Map<String, dynamic> newFiltered = {};
      profileData?.forEach((key, value) {
        final valueString = value?.toString().toLowerCase() ?? '';
        final keyString = key.toLowerCase();
        if (keyString.contains(query) || valueString.contains(query)) {
          newFiltered[key] = value;
        }
      });
      setState(() {
        filteredData = newFiltered;
      });
    }
  }

  Future<void> fetchProfile() async {
    String accessToken = 'accessToken';
    final response = await AuthService.getUserInfo(accessToken);
    if (response['success']) {
      setState(() {
        profileData = response['data'];
        filteredData = response['data'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement : ${response['message']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainBlue = Color(0xFF2196F3);

    return Scaffold(
      appBar: AppBar(
        title: Text('Mon profil'),
        backgroundColor: mainBlue,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, '/edit-profile').then((_) => fetchProfile());
            },
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: mainBlue))
          : profileData == null
          ? Center(child: Text("Aucune donnée disponible."))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Barre de recherche
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // Liste filtrée
            Expanded(
              child: ListView(
                children: filteredData!.entries.map((entry) {
                  return ListTile(
                    title: Text(
                      entry.key.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(entry.value?.toString() ?? ''),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
