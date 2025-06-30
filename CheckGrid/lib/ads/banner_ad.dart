import 'dart:io';
import 'package:checkgrid/providers/ad_provider.dart';
import 'package:flutter/material.dart';
import 'package:checkgrid/providers/general_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  AnchoredAdaptiveBannerAdSize? _adSize;
  final String adUnitId =
      Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/9214589741' // Test ID för Android
          : 'ca-app-pub-3940256099942544/2435281174'; // Test ID för iOS

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
    _adSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.sizeOf(context).width.truncate(),
    );

    if (_adSize == null) {
      debugPrint('Failed to get ad size.');
      return;
    }

    _bannerAd?.dispose();

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: _adSize!,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          // Sätt bannerAdHeight i GeneralProvider när annonsen laddas
          final generalProvider = context.read<GeneralProvider>();
          generalProvider.setBannerAdHeight(
            _bannerAd!.size.height.toDouble() + 12.0,
          ); // Inkludera marginal
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
          setState(() {
            _bannerAd = null;
          });
          // Återställ bannerAdHeight till 0.0 om annonsen misslyckas
          final generalProvider = context.read<GeneralProvider>();
          generalProvider.setBannerAdHeight(0.0);
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) _loadBannerAd();
          });
        },
        onAdOpened: (ad) {},
        onAdClosed: (ad) {},
        onAdImpression: (ad) {},
      ),
    );

    await _bannerAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    final adProvider = context.watch<AdProvider>();

    if (!adProvider.isBannerAdLoaded || adProvider.bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(bottom: 12),
        height: adProvider.bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: adProvider.bannerAd!),
      ),
    );
  }
}
