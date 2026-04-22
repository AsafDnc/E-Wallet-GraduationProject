/// Supabase project configuration for [Supabase.initialize].
///
/// The anon key is intended for client use; protect data with Row Level Security (RLS)
/// and never expose the service role key in the app.
abstract final class SupabaseConstants {
  SupabaseConstants._();

  static const String supabaseUrl = 'https://dorasfkniisfiybcjteh.supabase.co';

  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRvcmFzZmtuaWlzZml5YmNqdGVoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY0OTIxNjcsImV4cCI6MjA5MjA2ODE2N30.LXAPUfCRyqgTWPptvYk_Gb_08a-ZhhEzRAyCFdMu13A';
}
