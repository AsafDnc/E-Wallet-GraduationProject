import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_pin_repository.dart';

final appPinRepositoryProvider = Provider<AppPinRepository>((ref) {
  return SharedPreferencesAppPinRepository();
});
