import 'package:flutter/material.dart';
import 'package:memoire/models/user_model.dart';
import 'user_mini_card.dart';

class UserSuggestionSection extends StatelessWidget {
  final List<UserModel> users;

  const UserSuggestionSection({Key? key, required this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text("Aucune suggestion pour le moment."),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: users.length,
        itemBuilder: (context, index) {
          return UserMiniCard(user: users[index]);
        },
      ),
    );
  }
}
