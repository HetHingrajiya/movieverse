class AppConstants {
  // Config
  static const String appName = 'Movieverse';
  
  // API
  // TODO: Replace with your actual TMDB API Key
  static const String tmdbApiKey = 'YOUR_TMDB_API_KEY_HERE'; 
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String tmdbImageBackdropUrl = 'https://image.tmdb.org/t/p/original';
  
  // Firestore Collections
  static const String usersCollection = 'users';
  static const String moviesCollection = 'movies';
  static const String watchlistCollection = 'watchlist';
  static const String historyCollection = 'watch_history';
  static const String plansCollection = 'subscriptions';
  
  // Storage Paths
  static const String userProfilePath = 'user_profiles';
  
  // Assets
  // Ensure these exist in your assets folder if referenced
  static const String logoPath = 'assets/logo.png'; // Placeholder
}
