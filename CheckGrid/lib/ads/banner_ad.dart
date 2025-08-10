import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// ------------- [NEED TO ADD REAL AD ID'S] -------------
///
/// Widget for displaying a Google Mobile Ads banner.
///
/// Handles loading, adaptive sizing, and retry on failure.
/// Manages its own ad state independently.
class BannerAdWidget extends StatefulWidget {
  static final ValueNotifier<double> bannerHeightNotifier = ValueNotifier(0);

  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  AnchoredAdaptiveBannerAdSize? _adSize;
  bool _isLoaded = false;
  static double bannerHeight = 60;

  final String adUnitId =
      Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/9214589741' // Test ID for Android banner ad
          : 'ca-app-pub-3940256099942544/2435281174'; // Test ID for iOS banner ad

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadBannerAd() async {
    // Get the size of the ad
    _adSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.sizeOf(context).width.truncate(),
    );

    // Fail, exit
    if (_adSize == null) {
      debugPrint('Failed to get ad size.');
      return;
    }

    _bannerAd?.dispose();

    // Create a banner ad
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: _adSize!,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
          BannerAdWidget.bannerHeightNotifier.value =
              _bannerAd!.size.height.toDouble();
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
          setState(() {
            _bannerAd = null;
            _isLoaded = false;
          });
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) _loadBannerAd();
          });
        },
      ),
    );

    // Load the banner ad
    await _bannerAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    bannerHeight = _bannerAd!.size.height.toDouble();

    return SafeArea(
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        height: bannerHeight,
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
