import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.accent,
    required this.firebaseReady,
  });

  final Color accent;
  final bool firebaseReady;

  Future<void> _signOut(BuildContext context) async {
    if (!firebaseReady) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Firebase is not configured.')),
        );
      return;
    }
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Sign out failed.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = firebaseReady ? FirebaseAuth.instance.currentUser : null;
    String? firstNonEmpty(Iterable<String?> items) {
      for (final item in items) {
        final value = (item ?? '').trim();
        if (value.isNotEmpty) return value;
      }
      return null;
    }

    final greetingName = firstNonEmpty([
      user?.displayName,
      ...((user?.providerData ?? []).map((info) => info.displayName)),
      user?.email?.split('@').first,
    ]);

    final sections = <Map<String, dynamic>>[
      {
        'title': 'Lifestyle',
        'products': [
          {
            'name': 'Nike Air Max 90',
            'price': '3,669,000 VND',
            'image': 'assets/images/Nike Air Max 90 Side.avif',
          },
          {
            'name': 'Nike Ava Rover',
            'price': '3,829,000 VND',
            'image': 'assets/images/Nike Ava Rover Side.avif',
          },
          {
            'name': 'Nike SB Force 58',
            'price': '4,699,000 VND',
            'image': 'assets/images/Nike SB Force 58 Side.avif',
          },
        ],
      },
      {
        'title': 'Jordan',
        'products': [
          {
            'name': "Air Jordan 40 PF 'Blue Suede'",
            'price': '3,999,000 VND',
            'image': "assets/images/Air Jordan 40 PF 'Blue Suede' Side.avif",
          },
          {
            'name': 'Air Jordan MVP 92',
            'price': '5,699,000 VND',
            'image': 'assets/images/Air Jordan MVP 92 Side.avif',
          },
          {
            'name': 'Jordan CMFT Era',
            'price': '4,199,000 VND',
            'image': 'assets/images/Jordan CMFT Era Side.avif',
          },
        ],
      },
      {
        'title': 'Running',
        'products': [
          {
            'name': "Nike Vaporfly 4 'Eliud Kipchoge'",
            'price': '3,299,000 VND',
            'image': "assets/images/Nike Vaporfly 4 'Eliud Kipchoge' Side.avif",
          },
          {
            'name': 'Nike Zoom Rival Fly 4',
            'price': '4,199,000 VND',
            'image': 'assets/images/Nike Zoom Rival Fly 4 Side.avif',
          },
          {
            'name': 'Nike Maxfly 2',
            'price': '4,899,000 VND',
            'image': 'assets/images/Nike Maxfly 2 Side.avif',
          },
        ],
      },
    ];

    Widget buildSection(Map<String, dynamic> data) {
      final products = data['products'] as List<Map<String, String>>;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['title'] as String,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final product in products)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 260,
                      child: _ProductCard(product: product),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Hi${greetingName != null ? ', $greetingName' : ''}!',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E1A14),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[300]),
        ),
        actions: [
          IconButton(
            onPressed: () => _signOut(context),
            icon: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/icons/sign-out-alt.png',
                width: 22,
                height: 22,
                fit: BoxFit.contain,
              ),
            ),
            color: Colors.black,
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sections.map(buildSection).toList(),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Map<String, String> product;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.asset(product['image'] ?? '', fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  product['price'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
