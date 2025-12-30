class ApiConfig {
  // API Base URL
  static const String baseUrl = 'https://ghost-z.vercel.app/api';
  
  // Auth Endpoints
  static const String signup = '/auth/signup';
  static const String signin = '/auth/signin';
  static const String guest = '/auth/guest';
  static const String me = '/auth/me';
  static const String signout = '/auth/signout';
  static const String refresh = '/auth/refresh';
  
  // Onboarding
  static const String wakeQuestions = '/user/wake-questions';
  static const String onboardingComplete = '/onboarding/complete';
  
  // Ghost Core
  static const String ghostState = '/ghost/state';
  static const String ghostEvolution = '/ghost/evolution';
  static const String ghostMemory = '/ghost/memory';
  static const String ghostSuggest = '/ghost/suggest';
  static const String ghostOverlay = '/ghost/overlay';
  
  // Chat
  static const String chat = '/chat';
  
  // Tasks & Quests
  static const String tasks = '/task';
  static const String createTask = '/task/create';
  static String completeTask(String id) => '/task/$id/complete';
  static String deleteTask(String id) => '/task/$id';
  static const String quests = '/quest';
  
  // Scanner
  static const String scan = '/scan';
  
  // Study
  static const String schoolSolve = '/school/solve';
  
  // Device Tracking
  static const String deviceActivity = '/device/activity';
  static const String deviceApps = '/device/apps';
  static const String deviceBlock = '/device/block';
  static const String deviceSession = '/device/session';
  
  // Community
  static const String nearbyGhosts = '/community/nearby';
  
  // Leaderboard
  static const String leaderboard = '/leaderboard';
  
  // Shop
  static const String shop = '/shop';
  
  // Appearance
  static const String appearance = '/appearance';
  
  // Tutorial
  static const String tutorialProgress = '/tutorial/progress';
  
  // Feature Access
  static const String featureAccess = '/feature/access';
  
  // Insights
  static const String insights = '/insight';
  static const String generateInsights = '/insight/generate';
  
  // Dashboard
  static const String dashboardStats = '/dashboard/stats';
  
  // Voice
  static const String voiceRecord = '/voice/record';
  static const String voiceTranscribe = '/voice/transcribe';
  static const String notifications = '/voice/notifications';
  static const String badges = '/voice/badges';
  
  // Timeout
  static const Duration timeout = Duration(seconds: 30);
}