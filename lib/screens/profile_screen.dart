import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/app_colors.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'edit_product_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int selectedTab = 0; // 0=posted, 1=fav, 2=sold
  final user = FirebaseAuth.instance.currentUser;
  final service = FirestoreService();
  final _auth = AuthService();

  String _name = '';
  String _email = '';
  String _university = '';
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final data = await _auth.getUserData();
    if (data != null && mounted) {
      setState(() {
        _name = data['username'] ?? '';
        _email = data['email'] ?? '';
        _university = data['university'] ?? '';
        _isLoadingUser = false;
      });
    }
  }

  String get _initials {
    final parts = _name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Logout',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          content: const Text('Are you sure you want to logout?',
              style: TextStyle(color: AppColors.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout',
                  style: TextStyle(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      await AuthService().logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.darkNavy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: AppColors.campuDark),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Insights',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const DashboardScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoadingUser
          ? const Center(
              child:
                  CircularProgressIndicator(color: AppColors.blue))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  // ═══ USER INFO HEADER (no Welcome text) ═══
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.border, width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.blue.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _initials,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.blue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                _name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _email,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.blue
                                      .withOpacity(0.08),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.school_outlined,
                                        size: 12,
                                        color: AppColors.blue),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        _university,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.blue,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                        overflow:
                                            TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ═══ TAB CARDS ═══
                  Row(
                    children: [
                      _buildMenuCard(
                          'Posted', Icons.inventory_2_outlined, 0),
                      _buildMenuCard(
                          'Favourites', Icons.favorite_border, 1),
                      _buildMenuCard(
                          'Sold', Icons.check_circle_outline, 2),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ═══ TAB CONTENT ═══
                  Expanded(
                    child: selectedTab == 0
                        ? _buildListings()
                        : selectedTab == 1
                            ? _buildFavourites()
                            : _buildSold(),
                  ),
                ],
              ),
            ),
    );
  }

  // ── Tab card ──────────────────────────────────────────────

  Widget _buildMenuCard(String title, IconData icon, int index) {
    final isSelected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.orange : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected ? AppColors.orange : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 22,
                  color: isSelected
                      ? Colors.white
                      : AppColors.textSecondary),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────

  Widget _emptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: AppColors.inputBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                size: 28, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Product card ──────────────────────────────────────────

  Widget _productCard({
    required String imageUrl,
    required String title,
    required dynamic price,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 60,
              height: 60,
              color: AppColors.inputBg,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_outlined,
                    color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'RM $price',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blue,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  // ── Posted Products ───────────────────────────────────────

  Widget _buildListings() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('sellerId', isEqualTo: user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child:
                  CircularProgressIndicator(color: AppColors.blue));
        }
        final listings = snapshot.data!.docs;
        if (listings.isEmpty) {
          return _emptyState(
              'No posted products yet', Icons.inventory_2_outlined);
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 4),
          itemCount: listings.length,
          itemBuilder: (context, index) {
            final data =
                listings[index].data() as Map<String, dynamic>;
            final docId = listings[index].id;

            return _productCard(
              imageUrl: data['imageUrl'] ?? '',
              title: data['title'] ?? '',
              price: data['price'],
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: AppColors.blue, size: 20),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProductScreen(
                            docId: docId,
                            data: data,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.error, size: 20),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16)),
                            title: const Text('Delete Product',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary)),
                            content: const Text(
                                'Are you sure you want to delete this product?',
                                style: TextStyle(
                                    color: AppColors
                                        .textSecondary)),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancel',
                                    style: TextStyle(
                                        color: AppColors
                                            .textSecondary)),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Delete',
                                    style: TextStyle(
                                        color: AppColors.error,
                                        fontWeight:
                                            FontWeight.w700)),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        await FirebaseFirestore.instance
                            .collection('products')
                            .doc(docId)
                            .delete();
                        if (mounted) _showSnack('Product deleted');
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Favourites ────────────────────────────────────────────

  Widget _buildFavourites() {
    return StreamBuilder(
      stream: service.getFavourites(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child:
                  CircularProgressIndicator(color: AppColors.blue));
        }
        final favs = snapshot.data!.docs;
        if (favs.isEmpty) {
          return _emptyState('No favourites yet', Icons.favorite_border);
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 4),
          itemCount: favs.length,
          itemBuilder: (context, index) {
            final productId = favs[index]['productId'];

            return FutureBuilder(
              future: service.getProductById(productId),
              builder: (context, snap) {
                if (!snap.hasData) return const SizedBox();
                if (!snap.data!.exists) return const SizedBox();

                final data =
                    snap.data!.data() as Map<String, dynamic>;

                return _productCard(
                  imageUrl: data['imageUrl'] ?? '',
                  title: data['title'] ?? '',
                  price: data['price'],
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite,
                        color: AppColors.error, size: 20),
                    onPressed: () async {
                      await service.removeFavourite(productId);
                      if (mounted) {
                        setState(() {});
                        _showSnack('Removed from favourites');
                      }
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ── Sold (placeholder) ────────────────────────────────────

  Widget _buildSold() {
    return _emptyState(
        'No sold products yet', Icons.check_circle_outline);
  }
}
