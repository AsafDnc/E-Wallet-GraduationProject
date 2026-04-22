import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Global Supabase client ([Supabase.initialize] completed in [main]).
///
/// Override in tests: `ProviderScope(overrides: [supabaseClientProvider.overrideWithValue(mockClient)])`.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
