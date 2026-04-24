/// `true` only after [Supabase.initialize] succeeds in [main].
///
/// Router and other code must not call [Supabase.instance] for auth/session
/// until this is `true`, otherwise the client may be uninitialized.
bool supabasePluginReady = false;
