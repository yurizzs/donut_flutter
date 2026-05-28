import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/donut_provider.dart';
import '../../widgets/app_loading.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final donutsAsync = ref.watch(donutsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildHeroCarousel(donutsAsync),
              const SizedBox(height: 48),
              // ... Top Sellers and Why Section (keeping existing) ...
              _buildSectionTitle('Top Sellers'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildTopSellersList(donutsAsync),
              ),
              _buildSectionTitle('Why Choose Us?'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildWhySection(),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.accent, width: 3)),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo/logo.jpg', width: 40, height: 40),
            const SizedBox(width: 8),
            Text('Doughlicious',
                style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryText)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCarousel(AsyncValue<List> donutsAsync) {
    return SizedBox(
      height: 450,
      child: donutsAsync.when(
        data: (donuts) => PageView.builder(
          controller: _pageController,
          onPageChanged: (int page) => setState(() => _currentPage = page),
          itemCount: donuts.take(4).length,
          itemBuilder: (context, index) {
            final donut = donuts[index];
            return Container(
              margin: const EdgeInsets.only(right: 16),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: donut.image ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FRESHLY GLAZED.\nDAILY CRAVED.',
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            height: 0.9,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero),
                          ),
                          child: Text('SHOP LATEST DROPS',
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        loading: () => const AppLoading(),
        error: (_, __) => const SizedBox(),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Text(title,
          style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.accent)),
    );
  }

  Widget _buildTopSellersList(AsyncValue<List> donutsAsync) {
    return donutsAsync.when(
      data: (donuts) => Column(
        children: donuts.take(3).map((donut) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                      imageUrl: donut.image ?? '',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover)),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(donut.name,
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText)),
                      const SizedBox(height: 4),
                      Text('₱${donut.price.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                              fontSize: 15, 
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent)),
                    ]),
              ),
            ],
          ),
        )).toList(),
      ),
      loading: () => const AppLoading(),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildWhySection() {
    final whyItems = [
      {
        'num': '01',
        'title': 'Freshly Baked',
        'desc': 'Small batches keep every box soft, warm, and ready for the first bite.'
      },
      {
        'num': '02',
        'title': 'Premium Ingredients',
        'desc': 'Real butter, balanced glazes, and toppings that taste as good as they look.'
      },
      {
        'num': '03',
        'title': 'Fast Delivery',
        'desc': 'From our counter to your table while the glaze still has its shine.'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: whyItems.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['num']!,
                style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent)),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title']!,
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText)),
                  const SizedBox(height: 8),
                  Text(item['desc']!,
                      style: GoogleFonts.inter(
                          color: AppColors.textSecondary, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}
