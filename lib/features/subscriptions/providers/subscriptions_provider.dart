import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/subscription_model.dart';

class SubscriptionsNotifier extends Notifier<List<SubscriptionModel>> {
  @override
  List<SubscriptionModel> build() => List<SubscriptionModel>.from(_seed);

  static final List<SubscriptionModel> _seed = [
    SubscriptionModel(
      id: 'netflix',
      displayName: 'Netflix Premium',
      shortNameUppercase: 'NETFLIX',
      monthlyPrice: 12.99,
      daysUntilRenewal: 1,
      billingCycleDays: 30,
      iconData: Icons.play_circle_fill_rounded.codePoint,
      iconBgColor: const Color(0xFFE50914),
    ),
    SubscriptionModel(
      id: 'prime',
      displayName: 'Prime Video',
      shortNameUppercase: 'PRIME VIDEO',
      monthlyPrice: 15.99,
      daysUntilRenewal: 3,
      billingCycleDays: 30,
      iconData: Icons.video_library_rounded.codePoint,
      iconBgColor: const Color(0xFF00A8E1),
    ),
    SubscriptionModel(
      id: 'apple_music',
      displayName: 'Apple Music',
      shortNameUppercase: 'APPLE MUSIC',
      monthlyPrice: 9.99,
      daysUntilRenewal: 5,
      billingCycleDays: 30,
      iconData: Icons.music_note_rounded.codePoint,
      iconBgColor: const Color(0xFFFC3C44),
    ),
    SubscriptionModel(
      id: 'canva',
      displayName: 'Canva+',
      shortNameUppercase: 'CANVA+',
      monthlyPrice: 22.00,
      daysUntilRenewal: 7,
      billingCycleDays: 30,
      iconData: Icons.design_services_rounded.codePoint,
      iconBgColor: const Color(0xFF00C4CC),
    ),
    SubscriptionModel(
      id: 'youtube_premium',
      displayName: 'Youtube Premium',
      shortNameUppercase: 'YOUTUBE PREMIUM',
      monthlyPrice: 25.99,
      daysUntilRenewal: 4,
      billingCycleDays: 30,
      iconData: Icons.play_circle_outline_rounded.codePoint,
      iconBgColor: const Color(0xFFFF0000),
    ),
  ];

  void removeSubscription(String id) {
    state = state.where((s) => s.id != id).toList();
  }
}

final subscriptionsProvider =
    NotifierProvider<SubscriptionsNotifier, List<SubscriptionModel>>(
      SubscriptionsNotifier.new,
    );
