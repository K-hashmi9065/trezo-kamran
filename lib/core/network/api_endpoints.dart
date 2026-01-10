/// Centralized API endpoint constants for the Trezo app
class ApiEndpoints {
  // Private constructor to prevent instantiation
  ApiEndpoints._();

  /// Base URL for the API
  /// TODO: Replace with your actual API base URL
  /// For development, you can use:
  /// - Local: 'http://localhost:3000'
  /// - Staging: 'https://staging-api.trezo.com'
  /// - Production: 'https://api.trezo.com'
  static const String baseUrl = 'https://api.trezo.com';

  /// API version prefix
  static const String apiVersion = '/api/v1';

  /// Complete base URL with version
  static const String apiBaseUrl = '$baseUrl$apiVersion';

  // ============================================================================
  // Authentication Endpoints
  // ============================================================================

  /// POST - Login with email and password
  /// Body: { "email": string, "password": string }
  /// Response: { "token": string, "user": UserModel }
  static const String login = '$apiBaseUrl/auth/login';

  /// POST - Register new user
  /// Body: { "email": string, "password": string, "name": string }
  /// Response: { "token": string, "user": UserModel }
  static const String register = '$apiBaseUrl/auth/register';

  /// POST - Refresh authentication token
  /// Body: { "refreshToken": string }
  /// Response: { "token": string, "refreshToken": string }
  static const String refreshToken = '$apiBaseUrl/auth/refresh';

  /// POST - Logout
  /// Headers: Authorization: Bearer [token]
  static const String logout = '$apiBaseUrl/auth/logout';

  /// GET - Validate current token
  /// Headers: Authorization: Bearer [token]
  /// Response: { "valid": boolean, "user": UserModel }
  static const String validateToken = '$apiBaseUrl/auth/validate';

  /// POST - Send password reset email
  /// Body: { "email": string }
  static const String forgotPassword = '$apiBaseUrl/auth/forgot-password';

  // ============================================================================
  // Goal Endpoints
  // ============================================================================

  /// GET - Get all goals for current user
  /// Headers: Authorization: Bearer [token]
  /// Response: { "goals": GoalModel[] }
  static const String goals = '$apiBaseUrl/goals';

  /// GET - Get specific goal by ID
  /// Headers: Authorization: Bearer [token]
  /// Response: { "goal": GoalModel }
  /// Usage: goalById('goal-id-123')
  static String goalById(String goalId) => '$apiBaseUrl/goals/$goalId';

  /// POST - Create new goal
  /// Headers: Authorization: Bearer [token]
  /// Body: GoalModel
  /// Response: { "goal": GoalModel }
  static const String createGoal = '$apiBaseUrl/goals';

  /// PUT - Update existing goal
  /// Headers: Authorization: Bearer [token]
  /// Body: GoalModel
  /// Response: { "goal": GoalModel }
  /// Usage: updateGoal('goal-id-123')
  static String updateGoal(String goalId) => '$apiBaseUrl/goals/$goalId';

  /// DELETE - Delete goal
  /// Headers: Authorization: Bearer [token]
  /// Response: { "success": boolean }
  /// Usage: deleteGoal('goal-id-123')
  static String deleteGoal(String goalId) => '$apiBaseUrl/goals/$goalId';

  /// PATCH - Update goal progress
  /// Headers: Authorization: Bearer [token]
  /// Body: { "amount": double }
  /// Response: { "goal": GoalModel }
  /// Usage: updateGoalProgress('goal-id-123')
  static String updateGoalProgress(String goalId) =>
      '$apiBaseUrl/goals/$goalId/progress';

  // ============================================================================
  // Transaction/Record Endpoints
  // ============================================================================

  /// GET - Get all transactions for a specific goal
  /// Headers: Authorization: Bearer [token]
  /// Response: { "transactions": TransactionModel[] }
  /// Usage: goalTransactions('goal-id-123')
  static String goalTransactions(String goalId) =>
      '$apiBaseUrl/goals/$goalId/transactions';

  /// POST - Add transaction to goal (deposit/withdrawal)
  /// Headers: Authorization: Bearer [token]
  /// Body: { "amount": double, "type": string, "date": string, "note": string }
  /// Response: { "transaction": TransactionModel, "goal": GoalModel }
  /// Usage: addGoalTransaction('goal-id-123')
  static String addGoalTransaction(String goalId) =>
      '$apiBaseUrl/goals/$goalId/transactions';

  /// GET - Get specific transaction
  /// Headers: Authorization: Bearer [token]
  /// Response: { "transaction": TransactionModel }
  /// Usage: transactionById('goal-id-123', 'transaction-id-456')
  static String transactionById(String goalId, String transactionId) =>
      '$apiBaseUrl/goals/$goalId/transactions/$transactionId';

  /// DELETE - Delete transaction
  /// Headers: Authorization: Bearer [token]
  /// Response: { "success": boolean, "goal": GoalModel }
  /// Usage: deleteTransaction('goal-id-123', 'transaction-id-456')
  static String deleteTransaction(String goalId, String transactionId) =>
      '$apiBaseUrl/goals/$goalId/transactions/$transactionId';

  // ============================================================================
  // User Profile Endpoints
  // ============================================================================

  /// GET - Get current user profile
  /// Headers: Authorization: Bearer [token]
  /// Response: { "user": UserModel }
  static const String userProfile = '$apiBaseUrl/user/profile';

  /// PUT - Update user profile
  /// Headers: Authorization: Bearer [token]
  /// Body: { "name": string, "email": string, "phone": string, etc. }
  /// Response: { "user": UserModel }
  static const String updateUserProfile = '$apiBaseUrl/user/profile';

  /// POST - Upload user avatar
  /// Headers: Authorization: Bearer [token]
  /// Body: FormData with image file
  /// Response: { "avatarUrl": string }
  static const String uploadAvatar = '$apiBaseUrl/user/avatar';

  /// GET - Get user statistics
  /// Headers: Authorization: Bearer [token]
  /// Response: { "stats": UserStatsModel }
  static const String userStats = '$apiBaseUrl/user/stats';

  // ============================================================================
  // Payment/Subscription Endpoints
  // ============================================================================

  /// GET - Get subscription plans
  /// Response: { "plans": SubscriptionPlanModel[] }
  static const String subscriptionPlans = '$apiBaseUrl/subscriptions/plans';

  /// POST - Subscribe to plan
  /// Headers: Authorization: Bearer [token]
  /// Body: { "planId": string, "paymentMethod": string }
  /// Response: { "subscription": SubscriptionModel }
  static const String subscribe = '$apiBaseUrl/subscriptions/subscribe';

  /// GET - Get current subscription
  /// Headers: Authorization: Bearer [token]
  /// Response: { "subscription": SubscriptionModel }
  static const String currentSubscription = '$apiBaseUrl/subscriptions/current';

  /// POST - Cancel subscription
  /// Headers: Authorization: Bearer [token]
  /// Response: { "success": boolean }
  static const String cancelSubscription = '$apiBaseUrl/subscriptions/cancel';

  // ============================================================================
  // Notification Endpoints
  // ============================================================================

  /// GET - Get notifications
  /// Headers: Authorization: Bearer [token]
  /// Response: { "notifications": NotificationModel[] }
  static const String notifications = '$apiBaseUrl/notifications';

  /// PUT - Mark notification as read
  /// Headers: Authorization: Bearer [token]
  /// Usage: markNotificationRead('notification-id-123')
  static String markNotificationRead(String notificationId) =>
      '$apiBaseUrl/notifications/$notificationId/read';

  /// POST - Register FCM token for push notifications
  /// Headers: Authorization: Bearer [token]
  /// Body: { "token": string, "platform": string }
  static const String registerFcmToken = '$apiBaseUrl/notifications/register';

  // ============================================================================
  // Sync Endpoints
  // ============================================================================

  /// POST - Sync local data with server
  /// Headers: Authorization: Bearer [token]
  /// Body: { "goals": GoalModel[], "transactions": TransactionModel[] }
  /// Response: { "syncedGoals": GoalModel[], "conflicts": ConflictModel[] }
  static const String syncData = '$apiBaseUrl/sync';

  /// GET - Get last sync timestamp
  /// Headers: Authorization: Bearer [token]
  /// Response: { "lastSync": string (ISO 8601) }
  static const String lastSync = '$apiBaseUrl/sync/last';
}
