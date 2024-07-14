import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialAdReady = false;
  static bool _isInitialized = false;

  static void initialize() {
    if (!_isInitialized) {
      MobileAds.instance.initialize();
      _isInitialized = true;
    }
  }

  static void loadInterstitialAd() {
    if (_isInitialized) {
      InterstitialAd.load(
        adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Test ad unit ID
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _isInterstitialAdReady = true;
          },
          onAdFailedToLoad: (LoadAdError error) {
            _isInterstitialAdReady = false;
            _interstitialAd = null; // Reset ad instance on failure
          },
        ),
      );
    } else {
      debugPrint('Mobile Ads SDK not initialized.');
    }
  }

  static void showInterstitialAd(VoidCallback onAdClosed) {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          loadInterstitialAd();
          onAdClosed();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          loadInterstitialAd();
          onAdClosed();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      debugPrint('Interstitial ad not ready.');
      onAdClosed();
    }
  }
}
