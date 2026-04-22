/// Set to `true` in [main] only after [Supabase.initialize] completes successfully.
/// Used by routing so we never touch [Supabase.instance] when init failed.
bool supabasePluginReady = false;
