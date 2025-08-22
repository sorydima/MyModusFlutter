import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:logger/logger.dart';
import 'package:dotenv/dotenv.dart';

import '../lib/database.dart';
import '../lib/handlers/auth_handler.dart';
import '../lib/handlers/ai_handler.dart';
import '../lib/handlers/ai_analytics_handler.dart';
import '../lib/handlers/avito_handler.dart';
import '../lib/handlers/ai_personal_shopper_handler.dart';
import '../lib/handlers/ar_fitting_handler.dart'; // Added
import '../lib/handlers/blockchain_loyalty_handler.dart'; // Added
import '../lib/handlers/social_analytics_handler.dart'; // Added
import '../lib/handlers/ai_color_matcher_handler.dart'; // Added
import '../lib/handlers/social_commerce_handler.dart'; // Added
import '../lib/handlers/notification_handler.dart'; // Added
import '../lib/handlers/notification_integration_handler.dart'; // Added
import '../lib/handlers/mobile_capabilities_handler.dart'; // Added
import '../lib/handlers/blockchain_ecosystem_handler.dart'; // Added
import '../lib/services/ai_service.dart';
import '../lib/services/ai_analytics_service.dart';
import '../lib/services/ai_personal_shopper_service.dart';
import '../lib/services/ar_fitting_service.dart'; // Added
import '../lib/services/blockchain_loyalty_service.dart'; // Added
import '../lib/services/social_analytics_service.dart'; // Added
import '../lib/services/ai_color_matcher_service.dart'; // Added
import '../lib/services/social_commerce_service.dart'; // Added
import '../lib/services/notification_service.dart'; // Added
import '../lib/services/notification_integration_service.dart'; // Added
import '../lib/services/mobile_capabilities_service.dart'; // Added
import '../lib/services/blockchain_ecosystem_service.dart'; // Added
import '../lib/services/jwt_service.dart';
import '../lib/scrapers/scraper_manager.dart';

void main(List<String> args) async {
  // Инициализация логгера
  final logger = Logger();
  
  try {
    logger.i('🚀 Starting MyModus Backend Server...');
    
    // Загрузка переменных окружения
    final env = DotEnv()..load();
    final port = int.parse(env['PORT'] ?? '8080');
    
    // Инициализация базы данных
    logger.i('📊 Initializing database...');
    await DatabaseService.runMigrations();
    await DatabaseService.seedInitialData();
    logger.i('✅ Database initialized successfully');
    
    // Инициализация сервисов
    logger.i('🤖 Initializing AI services...');
    final aiService = AIService();
    final aiAnalyticsService = AIAnalyticsService();
    final personalShopperService = AIPersonalShopperService(
      db: DatabaseService(),
      aiService: aiService,
    );
    final arFittingService = ARFittingService(db: DatabaseService()); // Added
    final blockchainLoyaltyService = BlockchainLoyaltyService(db: DatabaseService()); // Added
    final socialAnalyticsService = SocialAnalyticsService(db: DatabaseService()); // Added
    final aiColorMatcherService = AIColorMatcherService(db: DatabaseService()); // Added
    final socialCommerceService = SocialCommerceService(db: DatabaseService()); // Added
    final notificationService = NotificationService(); // Added
    final notificationIntegrationService = NotificationIntegrationService( // Added
      notificationService: notificationService,
    );
    final mobileCapabilitiesService = MobileCapabilitiesService( // Added
      notificationService: notificationService,
    );
    final blockchainEcosystemService = BlockchainEcosystemService( // Added
      notificationService: notificationService,
    );
    final jwtService = JWTService();
    final scraperManager = ScraperManager(DatabaseService());
    
    // Инициализация handlers
    logger.i('🔧 Setting up API handlers...');
    final authHandler = AuthHandler(jwtService);
    final aiHandler = AIHandler(aiService);
    final aiAnalyticsHandler = AIAnalyticsHandler(aiAnalyticsService);
    final avitoHandler = AvitoHandler(scraperManager: scraperManager, db: DatabaseService());
    final personalShopperHandler = AIPersonalShopperHandler(
      personalShopperService: personalShopperService,
      db: DatabaseService(),
    );
    final arFittingHandler = ARFittingHandler( // Added
      arService: arFittingService,
      db: DatabaseService(),
    );
    final blockchainLoyaltyHandler = BlockchainLoyaltyHandler( // Added
      loyaltyService: blockchainLoyaltyService,
      db: DatabaseService(),
    );
    final socialAnalyticsHandler = SocialAnalyticsHandler( // Added
      analyticsService: socialAnalyticsService,
      db: DatabaseService(),
    );
    final aiColorMatcherHandler = AIColorMatcherHandler( // Added
      colorMatcherService: aiColorMatcherService,
      db: DatabaseService(),
    );
    final socialCommerceHandler = SocialCommerceHandler( // Added
      socialCommerceService: socialCommerceService,
      db: DatabaseService(),
    );
    final notificationHandler = NotificationHandler( // Added
      notificationService: notificationService,
      db: DatabaseService(),
    );
    final notificationIntegrationHandler = NotificationIntegrationHandler( // Added
      integrationService: notificationIntegrationService,
      db: DatabaseService(),
    );
    final mobileCapabilitiesHandler = MobileCapabilitiesHandler( // Added
      mobileService: mobileCapabilitiesService,
      db: DatabaseService(),
    );
    final blockchainEcosystemHandler = BlockchainEcosystemHandler( // Added
      blockchainService: blockchainEcosystemService,
      db: DatabaseService(),
    );
    
    // Создание основного роутера
    final app = Router();
    
    // API маршруты
    app.mount('/api/auth', authHandler.router);
    app.mount('/api/ai', aiHandler.router);
    app.mount('/api/ai-analytics', aiAnalyticsHandler.router);
    app.mount('/api/avito', avitoHandler.router);
    app.mount('/api/personal-shopper', personalShopperHandler.router);
    app.mount('/api/ar-fitting', arFittingHandler.router); // Added
    app.mount('/api/loyalty', blockchainLoyaltyHandler.router); // Added
    app.mount('/api/social-analytics', socialAnalyticsHandler.router); // Added
    app.mount('/api/color-matcher', aiColorMatcherHandler.router); // Added
    app.mount('/api/social-commerce', socialCommerceHandler.router); // Added
    app.mount('/api/notifications', notificationHandler.router); // Added
    app.mount('/api/notification-integration', notificationIntegrationHandler.router); // Added
    app.mount('/api/mobile', mobileCapabilitiesHandler.router); // Added
    app.mount('/api/blockchain', blockchainEcosystemHandler.router); // Added
    
    // Health check endpoint
    app.get('/health', (Request request) {
      return Response.ok(
        '{"status": "healthy", "service": "MyModus Backend", "timestamp": "${DateTime.now().toIso8601String()}"}',
        headers: {'content-type': 'application/json'},
      );
    });
    
    // API info endpoint
    app.get('/api', (Request request) {
      return Response.ok(
        '{"service": "MyModus Backend API", "version": "1.0.0", "endpoints": {'
        '"auth": "/api/auth", '
        '"ai": "/api/ai", '
        '"ai-analytics": "/api/ai-analytics", '
        '"avito": "/api/avito", '
        '"personal-shopper": "/api/personal-shopper", '
        '"ar-fitting": "/api/ar-fitting", '
        '"loyalty": "/api/loyalty", '
        '"social-analytics": "/api/social-analytics", '
        '"color-matcher": "/api/color-matcher", '
        '"social-commerce": "/api/social-commerce", '
        '"notifications": "/api/notifications", '
        '"notification-integration": "/api/notification-integration", '
        '"mobile": "/api/mobile", '
        '"blockchain": "/api/blockchain"'
        '}, "timestamp": "${DateTime.now().toIso8601String()}"}',
        headers: {'content-type': 'application/json'},
      );
    });
    
    // API documentation endpoint
    app.get('/api/docs', (Request request) {
      return Response.ok(
        '{"title": "MyModus Backend API Documentation", '
        '"version": "1.0.0", '
        '"description": "AI-powered fashion social commerce platform API", '
        '"endpoints": {'
        '"Authentication": {'
        '"POST /api/auth/login": "User login", '
        '"POST /api/auth/register": "User registration", '
        '"POST /api/auth/refresh": "Refresh JWT token"'
        '}, '
        '"AI Services": {'
        '"GET /api/ai/recommendations/{userId}": "Get AI recommendations for user", '
        '"POST /api/ai/generate-description": "Generate product description with AI", '
        '"GET /api/ai/preferences/{userId}": "Analyze user preferences", '
        '"POST /api/ai/generate-hashtags": "Generate hashtags for posts", '
        '"POST /api/ai/moderate-content": "AI content moderation", '
        '"POST /api/ai/personalized-offers": "Generate personalized offers", '
        '"GET /api/ai/trends": "Get AI fashion trends"'
        '}, '
        '"AI Analytics": {'
        '"GET /api/ai-analytics/trends": "Get fashion trends analysis", '
        '"GET /api/ai-analytics/trends/{category}": "Get trends by category", '
        '"GET /api/ai-analytics/behavior/{userId}": "Analyze user behavior", '
        '"GET /api/ai-analytics/effectiveness": "Analyze recommendation effectiveness", '
        '"POST /api/ai-analytics/content": "Analyze content sentiment", '
        '"GET /api/ai-analytics/demand": "Get demand predictions", '
        '"GET /api/ai-analytics/competitors": "Analyze competitors", '
        '"GET /api/ai-analytics/stats": "Get AI performance statistics"'
        '}, '
        '"AR Fitting": {'
        '"POST /api/ar-fitting/analyze-photo": "Analyze user photo for measurements", '
        '"POST /api/ar-fitting/virtual-try-on": "Generate virtual try-on recommendations", '
        '"POST /api/ar-fitting/measurements": "Save user measurements", '
        '"GET /api/ar-fitting/measurements/{userId}": "Get user measurements", '
        '"GET /api/ar-fitting/history/{userId}": "Get AR fitting history", '
        '"POST /api/ar-fitting/rate-fit": "Rate product fit", '
        '"GET /api/ar-fitting/size-recommendations/{category}": "Get size recommendations", '
        '"GET /api/ar-fitting/body-analysis/{userId}": "Get body type analysis"'
        '}, '
        '"Blockchain Loyalty": {'
        '"GET /api/loyalty/profile/{userId}": "Get user loyalty profile", '
        '"POST /api/loyalty/profile": "Create or update loyalty profile", '
        '"GET /api/loyalty/stats/{userId}": "Get user loyalty statistics", '
        '"GET /api/loyalty/transactions/{userId}": "Get transaction history", '
        '"GET /api/loyalty/rewards": "Get available crypto rewards", '
        '"POST /api/loyalty/exchange": "Exchange points for crypto", '
        '"POST /api/loyalty/award-purchase": "Award points for purchase", '
        '"POST /api/loyalty/daily-login": "Award daily login reward", '
        '"POST /api/loyalty/referral": "Create referral relationship", '
        '"GET /api/loyalty/referrals/{userId}": "Get referral statistics", '
        '"GET /api/loyalty/tiers": "Get loyalty tiers", '
        '"GET /api/loyalty/achievements/{userId}": "Get user achievements", '
        '"GET /api/loyalty/wallet/{userId}": "Get user wallet info", '
        '"PUT /api/loyalty/wallet": "Update wallet address"'
        '}, '
        '"Social Analytics": {'
        '"GET /api/social-analytics/trends": "Get category trends analysis", '
        '"GET /api/social-analytics/social-metrics/{productId}": "Get product social metrics", '
        '"GET /api/social-analytics/audience/{category}": "Get audience analysis", '
        '"GET /api/social-analytics/predictions/{category}": "Get trend predictions", '
        '"GET /api/social-analytics/competitors/{category}": "Get competitor analysis", '
        '"POST /api/social-analytics/reports": "Generate analytics reports", '
        '"GET /api/social-analytics/report-types": "Get available report types", '
        '"GET /api/social-analytics/stats/{period}": "Get period statistics", '
        '"GET /api/social-analytics/export/{dataType}": "Export analytics data", '
        '"GET /api/social-analytics/top-products/{category}": "Get top products by category", '
        '"GET /api/social-analytics/seasonality/{category}": "Get seasonality analysis", '
        '"POST /api/social-analytics/compare-periods": "Compare different periods"'
        '}, '
        '"AI Color Matcher": {'
        '"POST /api/color-matcher/analyze-photo": "Analyze photo colors", '
        '"GET /api/color-matcher/personal-palette/{userId}": "Get user personal color palette", '
        '"POST /api/color-matcher/generate-palette": "Generate personal color palette", '
        '"GET /api/color-matcher/harmonious-colors": "Find harmonious colors", '
        '"GET /api/color-matcher/color-theory/{harmonyType}": "Get color theory information", '
        '"GET /api/color-matcher/recommendations/{userId}": "Get color recommendations", '
        '"GET /api/color-matcher/outfit-recommendations/{userId}": "Get outfit color recommendations", '
        '"GET /api/color-matcher/color-trends": "Analyze color trends", '
        '"GET /api/color-matcher/seasonal-palettes": "Get seasonal color palettes", '
        '"POST /api/color-matcher/save-palette": "Save color palette", '
        '"GET /api/color-matcher/user-palettes/{userId}": "Get user color palettes", '
        '"DELETE /api/color-matcher/palette/{paletteId}": "Delete color palette", '
        '"GET /api/color-matcher/history/{userId}": "Get user color history", '
        '"GET /api/color-matcher/stats/{userId}": "Get user color statistics", '
        '"GET /api/color-matcher/export-palette/{paletteId}": "Export color palette", '
        '"POST /api/color-matcher/import-palette": "Import color palette", '
        '"PUT /api/color-matcher/user-preferences/{userId}": "Update user preferences", '
        '"GET /api/color-matcher/user-preferences/{userId}": "Get user preferences"'
        '}, '
        '"Notifications": {'\
        '"POST /api/notifications/register-token": "Register FCM token", '\
        '"GET /api/notifications/{userId}": "Get user notifications", '\
        '"POST /api/notifications/create": "Create notification", '\
        '"PUT /api/notifications/{notificationId}/read": "Mark notification as read", '\
        '"PUT /api/notifications/{userId}/read-all": "Mark all notifications as read", '\
        '"DELETE /api/notifications/{notificationId}": "Delete notification", '\
        '"POST /api/notifications/recommendations": "Notify about new recommendations", '\
        '"POST /api/notifications/price-alert": "Notify about price changes", '\
        '"POST /api/notifications/loyalty-points": "Notify about loyalty points", '\
        '"POST /api/notifications/live-stream-reminder": "Notify about live stream", '\
        '"POST /api/notifications/group-purchase-update": "Notify about group purchase", '\
        '"POST /api/notifications/bulk": "Send bulk notifications", '\
        '"GET /api/notifications/{userId}/stats": "Get notification statistics", '\
        '"POST /api/notifications/{userId}/test": "Send test notification", '\
        '"POST /api/notifications/cleanup": "Cleanup old notifications"'\
        '}, '\
        '"Notification Integration": {'\
        '"POST /api/notification-integration/ai/recommendations": "Notify about AI recommendations", '\
        '"POST /api/notification-integration/ai/price-alert": "Notify about price alerts", '\
        '"POST /api/notification-integration/ai/personalized-offer": "Notify about personalized offers", '\
        '"POST /api/notification-integration/ar/fitting-complete": "Notify about AR fitting completion", '\
        '"POST /api/notification-integration/ar/size-recommendation": "Notify about size recommendations", '\
        '"POST /api/notification-integration/ar/body-analysis-update": "Notify about body analysis updates", '\
        '"POST /api/notification-integration/loyalty/points-earned": "Notify about loyalty points earned", '\
        '"POST /api/notification-integration/loyalty/tier-upgrade": "Notify about loyalty tier upgrades", '\
        '"POST /api/notification-integration/loyalty/referral-bonus": "Notify about referral bonuses", '\
        '"POST /api/notification-integration/loyalty/daily-login": "Notify about daily login rewards", '\
        '"POST /api/notification-integration/loyalty/crypto-reward": "Notify about crypto rewards", '\
        '"POST /api/notification-integration/analytics/trend-alert": "Notify about trend alerts", '\
        '"POST /api/notification-integration/analytics/competitor-update": "Notify about competitor updates", '\
        '"POST /api/notification-integration/analytics/audience-insight": "Notify about audience insights", '\
        '"POST /api/notification-integration/commerce/live-stream-reminder": "Notify about live stream reminders", '\
        '"POST /api/notification-integration/commerce/group-purchase-update": "Notify about group purchase updates", '\
        '"POST /api/notification-integration/commerce/new-review": "Notify about new reviews", '\
        '"POST /api/notification-integration/commerce/partnership-approved": "Notify about partnership approvals", '\
        '"POST /api/notification-integration/system/update": "Send system update notifications", '\
        '"POST /api/notification-integration/system/maintenance": "Send maintenance notifications", '\
        '"POST /api/notification-integration/system/security-alert": "Send security alert notifications", '\
        '"POST /api/notification-integration/bulk/by-category": "Send bulk notifications by category", '\
        '"POST /api/notification-integration/bulk/to-users": "Send bulk notifications to users", '\
        '"POST /api/notification-integration/demo/send-all-types": "Send demo notifications of all types", '\
        '"POST /api/notification-integration/demo/simulate-events": "Simulate module events and send notifications"'\
        '}, '\
        '"Social Commerce": {'
        '"POST /api/social-commerce/live-streams": "Create live stream", '
        '"GET /api/social-commerce/live-streams": "Get live streams", '
        '"GET /api/social-commerce/live-streams/{streamId}": "Get specific live stream", '
        '"PUT /api/social-commerce/live-streams/{streamId}": "Update live stream", '
        '"DELETE /api/social-commerce/live-streams/{streamId}": "Delete live stream", '
        '"POST /api/social-commerce/live-streams/{streamId}/start": "Start live stream", '
        '"POST /api/social-commerce/live-streams/{streamId}/end": "End live stream", '
        '"POST /api/social-commerce/group-purchases": "Create group purchase", '
        '"GET /api/social-commerce/group-purchases": "Get group purchases", '
        '"GET /api/social-commerce/group-purchases/{groupId}": "Get specific group purchase", '
        '"POST /api/social-commerce/group-purchases/{groupId}/join": "Join group purchase", '
        '"POST /api/social-commerce/group-purchases/{groupId}/leave": "Leave group purchase", '
        '"PUT /api/social-commerce/group-purchases/{groupId}": "Update group purchase", '
        '"DELETE /api/social-commerce/group-purchases/{groupId}": "Delete group purchase", '
        '"POST /api/social-commerce/reviews": "Create product review", '
        '"GET /api/social-commerce/reviews": "Get product reviews", '
        '"GET /api/social-commerce/reviews/{reviewId}": "Get specific review", '
        '"PUT /api/social-commerce/reviews/{reviewId}": "Update review", '
        '"DELETE /api/social-commerce/reviews/{reviewId}": "Delete review", '
        '"POST /api/social-commerce/reviews/{reviewId}/like": "Like review", '
        '"POST /api/social-commerce/reviews/{reviewId}/dislike": "Dislike review", '
        '"POST /api/social-commerce/reviews/{reviewId}/helpful": "Mark review helpful", '
        '"POST /api/social-commerce/partnerships": "Create influencer partnership", '
        '"GET /api/social-commerce/partnerships": "Get partnerships", '
        '"GET /api/social-commerce/partnerships/{partnershipId}": "Get specific partnership", '
        '"PUT /api/social-commerce/partnerships/{partnershipId}": "Update partnership", '
        '"DELETE /api/social-commerce/partnerships/{partnershipId}": "Delete partnership", '
        '"POST /api/social-commerce/partnerships/{partnershipId}/approve": "Approve partnership", '
        '"POST /api/social-commerce/partnerships/{partnershipId}/reject": "Reject partnership", '
        '"GET /api/social-commerce/friend-recommendations/{userId}": "Get friend recommendations", '
        '"POST /api/social-commerce/friend-recommendations/{userId}/share": "Share recommendation", '
        '"POST /api/social-commerce/social/share": "Share to social media", '
        '"GET /api/social-commerce/social/platforms": "Get social media platforms", '
        '"GET /api/social-commerce/social/analytics": "Get social media analytics", '
        '"GET /api/social-commerce/analytics/{userId}": "Get social commerce analytics", '
        '"GET /api/social-commerce/analytics/trends": "Get trends analytics", '
        '"GET /api/social-commerce/analytics/engagement": "Get engagement analytics"'
        '}, '
        '"Mobile Capabilities": {'
        '"POST /api/mobile/offline/cache": "Save data to offline cache", '
        '"GET /api/mobile/offline/cache/{userId}/{dataType}": "Get data from offline cache", '
        '"POST /api/mobile/offline/sync": "Sync offline data with server", '
        '"DELETE /api/mobile/offline/cache/{userId}": "Clear offline cache for user", '
        '"POST /api/mobile/location/update": "Update user location", '
        '"GET /api/mobile/location/{userId}": "Get user location", '
        '"GET /api/mobile/location/nearby-offers": "Get nearby offers by location", '
        '"GET /api/mobile/location/stores": "Get nearby stores by location", '
        '"POST /api/mobile/calendar/event": "Add calendar event", '
        '"GET /api/mobile/calendar/events/{userId}": "Get user calendar events", '
        '"PUT /api/mobile/calendar/event/{eventId}": "Update calendar event", '
        '"DELETE /api/mobile/calendar/event/{eventId}": "Delete calendar event", '
        '"POST /api/mobile/background-sync": "Start background sync", '
        '"GET /api/mobile/background-sync/status/{userId}": "Get background sync status", '
        '"POST /api/mobile/background-sync/cleanup": "Cleanup old data", '
        '"POST /api/mobile/demo/simulate-offline": "Simulate offline mode", '
        '"POST /api/mobile/demo/simulate-location": "Simulate location update", '
        '"POST /api/mobile/demo/simulate-calendar": "Simulate calendar event"'
        '}, '
        '"Blockchain Ecosystem": {'
        '"POST /api/blockchain/nft/collections": "Create NFT collection", '
        '"GET /api/blockchain/nft/collections": "Get NFT collections", '
        '"GET /api/blockchain/nft/collections/{collectionId}": "Get NFT collection by ID", '
        '"PUT /api/blockchain/nft/collections/{collectionId}": "Update NFT collection", '
        '"DELETE /api/blockchain/nft/collections/{collectionId}": "Delete NFT collection", '
        '"POST /api/blockchain/nft/tokens/mint": "Mint NFT token", '
        '"GET /api/blockchain/nft/tokens/user/{userId}": "Get user NFT tokens", '
        '"GET /api/blockchain/nft/tokens/{tokenId}": "Get NFT token by ID", '
        '"PUT /api/blockchain/nft/tokens/{tokenId}": "Update NFT token", '
        '"DELETE /api/blockchain/nft/tokens/{tokenId}": "Delete NFT token", '
        '"POST /api/blockchain/marketplace/listings": "Create marketplace listing", '
        '"GET /api/blockchain/marketplace/listings": "Get active marketplace listings", '
        '"GET /api/blockchain/marketplace/listings/{listingId}": "Get marketplace listing by ID", '
        '"PUT /api/blockchain/marketplace/listings/{listingId}": "Update marketplace listing", '
        '"DELETE /api/blockchain/marketplace/listings/{listingId}": "Delete marketplace listing", '
        '"POST /api/blockchain/marketplace/purchase": "Purchase NFT from marketplace", '
        '"GET /api/blockchain/marketplace/orders/user/{userId}": "Get user marketplace orders", '
        '"GET /api/blockchain/marketplace/orders/{orderId}": "Get marketplace order by ID", '
        '"POST /api/blockchain/verification/authenticity": "Create authenticity verification", '
        '"PUT /api/blockchain/verification/authenticity/{verificationId}/approve": "Approve authenticity verification", '
        '"GET /api/blockchain/verification/authenticity/brand/{brandId}": "Get brand verifications", '
        '"GET /api/blockchain/verification/authenticity/{verificationId}": "Get verification by ID", '
        '"POST /api/blockchain/brands/tokens": "Create brand token", '
        '"POST /api/blockchain/brands/tokens/{tokenId}/mint": "Mint brand tokens", '
        '"GET /api/blockchain/brands/tokens": "Get brand tokens", '
        '"GET /api/blockchain/brands/tokens/{tokenId}": "Get brand token by ID", '
        '"PUT /api/blockchain/brands/tokens/{tokenId}": "Update brand token", '
        '"POST /api/blockchain/smart-contracts": "Create smart contract", '
        '"POST /api/blockchain/smart-contracts/{contractId}/deploy": "Deploy smart contract", '
        '"GET /api/blockchain/smart-contracts": "Get smart contracts", '
        '"GET /api/blockchain/smart-contracts/{contractId}": "Get smart contract by ID", '
        '"PUT /api/blockchain/smart-contracts/{contractId}": "Update smart contract", '
        '"GET /api/blockchain/analytics/ecosystem-stats": "Get ecosystem statistics", '
        '"GET /api/blockchain/analytics/user-transactions/{userId}": "Get user transaction history", '
        '"GET /api/blockchain/analytics/ecosystem-health": "Check ecosystem health", '
        '"POST /api/blockchain/demo/create-sample-data": "Create sample blockchain data", '
        '"POST /api/blockchain/demo/simulate-nft-trade": "Simulate NFT trade", '
        '"POST /api/blockchain/demo/simulate-verification": "Simulate verification process"'
        '}'
        '}, '
        '"timestamp": "${DateTime.now().toIso8601String()}"}',
        headers: {'content-type': 'application/json'},
      );
    });
    
    // 404 handler для несуществующих маршрутов
    app.all('/<ignored|.*>', (Request request) {
      return Response.notFound(
        '{"error": "Endpoint not found", "path": "${request.url.path}", "available_endpoints": ["/api", "/api/docs", "/health"]}',
        headers: {'content-type': 'application/json'},
      );
    });
    
    // Настройка CORS
    final handler = const Pipeline()
        .addMiddleware(corsHeaders())
        .addMiddleware(logRequests())
        .addHandler(app);
    
    // Запуск сервера
    logger.i('🌐 Starting server on port $port...');
    final server = await io.serve(handler, InternetAddress.anyIPv4, port);
    
    logger.i('🎉 MyModus Backend Server is running!');
    logger.i('📍 Server URL: http://localhost:$port');
    logger.i('📚 API Documentation: http://localhost:$port/api/docs');
    logger.i('💚 Health Check: http://localhost:$port/health');
    logger.i('🔐 Auth Endpoints: http://localhost:$port/api/auth');
    logger.i('🤖 AI Endpoints: http://localhost:$port/api/ai');
    logger.i('📊 AI Analytics: http://localhost:$port/api/ai-analytics');
    logger.i('🛒 Avito Integration: http://localhost:$port/api/avito');
    logger.i('🛍️ Personal Shopper: http://localhost:$port/api/personal-shopper');
    logger.i('📱 AR Fitting: http://localhost:$port/api/ar-fitting'); // Added
    logger.i('💰 Blockchain Loyalty: http://localhost:$port/api/loyalty'); // Added
    logger.i('📊 Social Analytics: http://localhost:$port/api/social-analytics'); // Added
    logger.i('🎨 AI Color Matcher: http://localhost:$port/api/color-matcher'); // Added
    logger.i('🌟 Social Commerce: http://localhost:$port/api/social-commerce'); // Added
    logger.i('🔔 Notifications: http://localhost:$port/api/notifications'); // Added
    logger.i('🔗 Notification Integration: http://localhost:$port/api/notification-integration'); // Added
    logger.i('📱 Mobile Capabilities: http://localhost:$port/api/mobile'); // Added
    logger.i('⛓️ Blockchain Ecosystem: http://localhost:$port/api/blockchain'); // Added
    
    // Graceful shutdown
    ProcessSignal.sigint.watch().listen((_) async {
      logger.i('🛑 Shutting down server...');
      await server.close();
      await DatabaseService.close();
      logger.i('✅ Server shutdown complete');
      exit(0);
    });
    
    ProcessSignal.sigterm.watch().listen((_) async {
      logger.i('🛑 Shutting down server...');
      await server.close();
      await DatabaseService.close();
      logger.i('✅ Server shutdown complete');
      exit(0);
    });
    
  } catch (e, stackTrace) {
    logger.e('❌ Failed to start server: $e');
    logger.e('Stack trace: $stackTrace');
    exit(1);
  }
}

// Middleware для логирования запросов
Response logRequests(Response response) {
  final logger = Logger();
  logger.i('${response.statusCode} ${response.requestedUri?.path ?? 'unknown'}');
  return response;
}
