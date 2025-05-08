import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenue Marie !'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implémenter l’action de recherche ici
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Suggestions mentors',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMentorCard('Sophie', 'assets/sophie.png'),
                _buildMentorCard('Alice', 'assets/alice.png'),
                _buildMentorCard('Marc', 'assets/marc.png'),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Événements à venir',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildEventItem('30 Avril', 'Conférence Réseau'),
            _buildEventItem('12 Mai', 'Salon de l’emploi'),
            _buildEventItem('18 Mai', 'Atelier CV & Lettre de motivation'),
            const SizedBox(height: 24),
            const Text(
              'Dernières publications d’alumni',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildAlumniPost('Alice', 'J’ai trouvé un super stage grâce à la plateforme !'),
            _buildAlumniPost('Marc', 'Je propose un atelier d’orientation samedi prochain.'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          // Navigation à gérer selon l’index
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Événements'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildMentorCard(String name, String imagePath) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage(imagePath),
        ),
        const SizedBox(height: 4),
        Text(name),
        TextButton(onPressed: () {}, child: const Text('Voir profil')),
      ],
    );
  }

  Widget _buildEventItem(String date, String title) {
    return ListTile(
      leading: const Icon(Icons.calendar_today),
      title: Text(title),
      subtitle: Text(date),
      onTap: () {},
    );
  }

  Widget _buildAlumniPost(String name, String content) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.account_circle),
        title: Text(name),
        subtitle: Text(content),
      ),
    );
  }
}

// Rechercher (à personnaliser)
class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [IconButton(onPressed: () => query = '', icon: Icon(Icons.clear))];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(onPressed: () => close(context, null), icon: Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(child: Text('Résultats pour "$query"'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView(
      children: List.generate(3, (index) {
        return ListTile(
          title: Text('Suggestion $index pour "$query"'),
        );
      }),
    );
  }
}
