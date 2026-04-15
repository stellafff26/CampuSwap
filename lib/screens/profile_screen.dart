import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_service.dart';
import '../widgets/app_colors.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import '../screens/edit_product_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 75,
        title: const Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Text(
            'Profile',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const DashboardScreen()),
            ),
          ),

          // LOGOUT BUTTON WITH CONFIRMATION
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              final confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Log out"),
                  content: const Text("Are you sure you want to log out?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "Log out",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await AuthService().logout();

                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('sellerId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final listings = snapshot.data?.docs ?? [];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // PROFILE HEADER
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF5B86E5),
                        Color(0xFF36D1DC)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person,
                            size: 30, color: Colors.blue),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text("Welcome",
                              style:
                                  TextStyle(color: Colors.white70)),

                          FutureBuilder<String>(
                            future: AuthService().getUserName(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Text(
                                  "Loading...",
                                  style: TextStyle(color: Colors.white),
                                );
                              }

                              return Text(
                                snapshot.data!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // STATS
                Row(
                  children: [
                    _buildStatCard(
                        "Listings", listings.length.toString()),
                    _buildStatCard("Favourites", "0"),
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  "My Listings",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                // LIST
                Expanded(
                  child: listings.isEmpty
                      ? const Center(child: Text("No listings yet"))
                      : ListView.builder(
                          itemCount: listings.length,
                          itemBuilder: (context, index) {
                            final data =
                                listings[index].data()
                                    as Map<String, dynamic>;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8),
                              child: ListTile(
                                leading: data['imageUrl'] != null
                                    ? Image.network(
                                        data['imageUrl'],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.image),

                                title: Text(data['title']),
                                subtitle:
                                    Text("RM ${data['price']}"),

                                trailing: Row(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  children: [

                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                EditProductScreen(
                                              docId:
                                                  listings[index].id,
                                              data: data,
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    IconButton(
                                      icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red),
                                      onPressed: () async {

                                        final confirm =
                                            await showDialog(
                                          context: context,
                                          builder: (context) =>
                                              AlertDialog(
                                            title: const Text(
                                                "Delete Item"),
                                            content: const Text(
                                                "Are you sure?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                        context,
                                                        false),
                                                child:
                                                    const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                        context,
                                                        true),
                                                child: const Text(
                                                  "Delete",
                                                  style: TextStyle(
                                                      color:
                                                          Colors.red),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          await FirebaseFirestore
                                              .instance
                                              .collection(
                                                  'products')
                                              .doc(listings[index].id)
                                              .delete();

                                          ScaffoldMessenger.of(
                                                  context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    "Deleted")),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// STAT CARD
Widget _buildStatCard(String title, String value) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(title),
        ],
      ),
    ),
  );
}