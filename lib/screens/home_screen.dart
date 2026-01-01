import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shoes_store/screens/product_detail_screen.dart';
import 'package:shoes_store/screens/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.accent,
    required this.firebaseReady,
    this.isAdmin = false,
  });

  final Color accent;
  final bool firebaseReady;
  final bool isAdmin;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

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
      // Ensure social sessions are cleared as well.
      await Future.wait([
        _googleSignIn.signOut(),
        FacebookAuth.instance.logOut(),
      ]);
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) =>
              LoginScreen(accent: accent, firebaseReady: firebaseReady),
        ),
        (_) => false,
      );
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
            "name": "Nike Air Max 1 '86 OG G",
            'price': '3,999,000 VND',
            'image': "assets/images/Nike Air Max 1 '86 OG G Side.avif",
          },
          {
            'name': 'Nike Pacific',
            'price': '3,199,000 VND',
            'image': 'assets/images/Nike Pacific Side.avif',
          },
        ],
      },
      {
        'title': 'Training',
        'products': [
          {
            'name': 'Nike Metcon 10',
            'price': '4,199,000 VND',
            'image': 'assets/images/Nike Metcon 10 Side.avif',
          },
          {
            'name': 'Nike MC Trainer 3',
            'price': '2,499,000 VND',
            'image': 'assets/images/Nike MC Trainer 3 Side.avif',
          },
          {
            'name': 'Nike Air Max Alpha Trainer 6',
            'price': '3,059,000 VND',
            'image': 'assets/images/Nike Air Max Alpha Trainer 6 Side.avif',
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
      {
        'title': 'Court',
        'products': [
          {
            'name': 'LeBron TR 1',
            'price': '4,199,000 VND',
            'image': 'assets/images/LeBron TR 1 Side.avif',
          },
          {
            'name': 'Nike G.T. Cut Academy EP',
            'price': '3,559,000 VND',
            'image': 'assets/images/Nike G.T. Cut Academy EP Side.avif',
          },
          {
            'name': 'Sabrina 3 EP',
            'price': '4,099,000 VND',
            'image': 'assets/images/Sabrina 3 EP Side.avif',
          },
        ],
      },
    ];

    Widget buildSection(Map<String, dynamic> data) {
      final products = data['products'] as List<Map<String, String>>;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              data['title'] as String,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const SizedBox(width: 10),
                for (final product in products)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 180,
                      child: _ProductCard(
                        product: product,
                        accent: accent,
                        sectionTitle: data['title'] as String,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    final double bottomInset = isAdmin ? 95 : 20;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      extendBody: true,
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
          if (isAdmin) const _AdminBadge(),
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _BannerCarousel(),
                const SizedBox(height: 20),
                ...sections.map(buildSection),
              ],
            ),
          ),
          if (isAdmin)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _AdminBottomNav(accent: accent),
            ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.accent,
    required this.sectionTitle,
  });

  final Map<String, String> product;
  final Color accent;
  final String sectionTitle;

  ProductDetail _toDetail() {
    final images = _buildImages(product['image']);
    return ProductDetail(
      brand: sectionTitle,
      name: product['name'] ?? '',
      price: product['price'] ?? '',
      sizes: 'M 3.5 / W 5 - M 16 / W 17.5',
      description:
          'By introducing elephant print to the world, Tinker Hatfield and his Air Jordan line forever altered the use of animal-inspired prints on sneakers. This pair riffs on that legacy with mixed materials and bold hits of color that elevate the classic silhouette.',
      images: images,
    );
  }

  List<String> _buildImages(String? path) {
    if (path == null || path.isEmpty) return [];
    const suffix = ' Side.avif';
    if (!path.endsWith(suffix)) return [path];
    final base = path.substring(0, path.length - suffix.length);
    return [
      '$base Side.avif',
      '$base On.avif',
      '$base Over View.avif',
      '$base Under.avif',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                ProductDetailScreen(accent: accent, product: _toDetail()),
          ),
        );
      },
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
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
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    product['price'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.data});

  final _BannerData data;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: SizedBox.expand(
          child: Image.asset(data.image, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel();

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  final _pageController = PageController(viewportFraction: 1.0, initialPage: 0);
  int _currentPage = 0;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoPlay());
  }

  void _startAutoPlay() {
    if (_bannerData.length <= 1) return;
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final nextPage = (_currentPage + 1) % _bannerData.length;
      _currentPage = nextPage;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            padEnds: false,
            itemCount: _bannerData.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final data = _bannerData[index];
              return _BannerCard(data: data);
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < _bannerData.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == _currentPage ? 10 : 6,
                height: i == _currentPage ? 10 : 6,
                decoration: BoxDecoration(
                  color: i == _currentPage
                      ? Colors.black87
                      : Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _BannerData {
  const _BannerData({required this.title, required this.image});

  final String title;
  final String image;
}

const List<_BannerData> _bannerData = [
  _BannerData(
    title: 'Confessions',
    image: "assets/images/Nike Vaporfly 4 'Eliud Kipchoge' Side.avif",
  ),
  _BannerData(
    title: 'New drops',
    image: 'assets/images/Nike Air Max 90 Side.avif',
  ),
  _BannerData(
    title: 'Train harder',
    image: 'assets/images/Nike Metcon 10 Side.avif',
  ),
  _BannerData(
    title: 'Court ready',
    image: 'assets/images/LeBron TR 1 Side.avif',
  ),
  _BannerData(
    title: 'Race day',
    image: 'assets/images/Nike Zoom Fly 6 Side.avif',
  ),
];

class _AdminBadge extends StatelessWidget {
  const _AdminBadge();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'ADMIN',
          style: TextStyle(
            color: Color(0xFF1E3A8A),
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _AdminBottomNav extends StatefulWidget {
  const _AdminBottomNav({required this.accent});

  final Color accent;

  @override
  State<_AdminBottomNav> createState() => _AdminBottomNavState();
}

class _AdminBottomNavState extends State<_AdminBottomNav> {
  int _currentIndex = 0;

  static const _items = [
    {'label': 'Add', 'icon': 'assets/icons/apps-add.png'},
    {'label': 'Edit', 'icon': 'assets/icons/customize-edit.png'},
    {'label': 'Delete', 'icon': 'assets/icons/trash.png'},
    {'label': 'Manage', 'icon': 'assets/icons/dashboard-monitor.png'},
  ];

  void _handleTap(BuildContext context, int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          top: false,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final selected = index == _currentIndex;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    child: InkWell(
                      onTap: () => _handleTap(context, index),
                      borderRadius: BorderRadius.circular(30),
                      child: _NavPill(
                        asset: item['icon']!,
                        label: item['label']!,
                        selected: selected,
                        accent: widget.accent,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavPill extends StatelessWidget {
  const _NavPill({
    required this.asset,
    required this.label,
    required this.selected,
    required this.accent,
  });

  final String asset;
  final String label;
  final bool selected;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    const Color activeBg = Color(0xFFF0F0F3);
    final Color iconColor = selected
        ? Colors.grey.shade900
        : Colors.grey.shade700;
    final Color textColor = selected
        ? Colors.grey.shade900
        : Colors.grey.shade700;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? activeBg : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Image.asset(asset, width: 26, height: 26, color: iconColor),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: textColor,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
