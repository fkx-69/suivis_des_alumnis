import 'package:flutter/material.dart';
import 'package:memoire/screens/messaging/mentorship_requests_list.dart';
import 'package:memoire/screens/messaging/mentees_list.dart';

class MentorshipManagementScreen extends StatelessWidget {
  const MentorshipManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: const [
          TabBar(
            tabs: [
              Tab(text: 'Demandes Reçues'),
              Tab(text: 'Mes Mentorés'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                MentorshipRequestsList(),
                MenteesList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
