import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_integration_service.dart';
import '../services/real_notification_service.dart';

/// Экран демонстрации интеграции уведомлений с другими модулями
class NotificationIntegrationDemoScreen extends StatefulWidget {
  const NotificationIntegrationDemoScreen({super.key});

  @override
  State<NotificationIntegrationDemoScreen> createState() => _NotificationIntegrationDemoScreenState();
}

class _NotificationIntegrationDemoScreenState extends State<NotificationIntegrationDemoScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _statusMessage;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔗 Интеграция уведомлений'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'AI', icon: Icon(Icons.psychology)),
            Tab(text: 'AR', icon: Icon(Icons.camera_alt)),
            Tab(text: 'Лояльность', icon: Icon(Icons.star)),
            Tab(text: 'Аналитика', icon: Icon(Icons.analytics)),
            Tab(text: 'Коммерция', icon: Icon(Icons.shopping_cart)),
            Tab(text: 'Система', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Статус сообщение
          if (_statusMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isSuccess ? Colors.green[50] : Colors.red[50],
                border: Border.all(
                  color: _isSuccess ? Colors.green : Colors.red,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _isSuccess ? Icons.check_circle : Icons.error,
                    color: _isSuccess ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _statusMessage!,
                      style: TextStyle(
                        color: _isSuccess ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _statusMessage = null),
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                  ),
                ],
              ),
            ),
          
          // Основной контент
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAITab(),
                _buildARTab(),
                _buildLoyaltyTab(),
                _buildAnalyticsTab(),
                _buildCommerceTab(),
                _buildSystemTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== AI TAB =====

  Widget _buildAITab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🤖 AI Personal Shopper',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Отправка уведомлений о событиях AI модуля',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          _buildDemoButton(
            '🎯 Новые рекомендации',
            'Отправить уведомление о новых AI рекомендациях',
            () => _sendAIRecommendations(),
          ),
          
          _buildDemoButton(
            '💰 Снижение цены',
            'Отправить уведомление о снижении цены на товар',
            () => _sendPriceAlert(),
          ),
          
          _buildDemoButton(
            '🎁 Персональное предложение',
            'Отправить уведомление о персональном предложении',
            () => _sendPersonalizedOffer(),
          ),
        ],
      ),
    );
  }

  // ===== AR TAB =====

  Widget _buildARTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📱 AR Fitting',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Отправка уведомлений о событиях AR модуля',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          _buildDemoButton(
            '👗 Завершение примерки',
            'Отправить уведомление о завершении AR примерки',
            () => _sendARFittingComplete(),
          ),
          
          _buildDemoButton(
            '📏 Рекомендация размера',
            'Отправить уведомление о рекомендации размера',
            () => _sendSizeRecommendation(),
          ),
          
          _buildDemoButton(
            '📊 Обновление анализа тела',
            'Отправить уведомление об обновлении анализа тела',
            () => _sendBodyAnalysisUpdate(),
          ),
        ],
      ),
    );
  }

  // ===== LOYALTY TAB =====

  Widget _buildLoyaltyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⭐ Blockchain Loyalty',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Отправка уведомлений о событиях лояльности',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          _buildDemoButton(
            '💎 Начисление баллов',
            'Отправить уведомление о начислении баллов лояльности',
            () => _sendLoyaltyPointsEarned(),
          ),
          
          _buildDemoButton(
            '🏆 Повышение уровня',
            'Отправить уведомление о повышении уровня лояльности',
            () => _sendTierUpgrade(),
          ),
          
          _buildDemoButton(
            '👥 Реферальный бонус',
            'Отправить уведомление о реферальном бонусе',
            () => _sendReferralBonus(),
          ),
          
          _buildDemoButton(
            '🌅 Ежедневный бонус',
            'Отправить уведомление о ежедневном бонусе',
            () => _sendDailyLoginReward(),
          ),
          
          _buildDemoButton(
            '🪙 Крипто-награда',
            'Отправить уведомление о крипто-награде',
            () => _sendCryptoReward(),
          ),
        ],
      ),
    );
  }

  // ===== ANALYTICS TAB =====

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Social Analytics',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Отправка уведомлений о событиях аналитики',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          _buildDemoButton(
            '📈 Тренд',
            'Отправить уведомление о новом тренде',
            () => _sendTrendAlert(),
          ),
          
          _buildDemoButton(
            '👀 Обновление конкурента',
            'Отправить уведомление об обновлении конкурента',
            () => _sendCompetitorUpdate(),
          ),
          
          _buildDemoButton(
            '👥 Инсайт аудитории',
            'Отправить уведомление об инсайте аудитории',
            () => _sendAudienceInsight(),
          ),
        ],
      ),
    );
  }

  // ===== COMMERCE TAB =====

  Widget _buildCommerceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🌟 Social Commerce',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Отправка уведомлений о событиях коммерции',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          _buildDemoButton(
            '📺 Live-стрим',
            'Отправить напоминание о live-стриме',
            () => _sendLiveStreamReminder(),
          ),
          
          _buildDemoButton(
            '👥 Групповая покупка',
            'Отправить уведомление об обновлении групповой покупки',
            () => _sendGroupPurchaseUpdate(),
          ),
          
          _buildDemoButton(
            '⭐ Новый отзыв',
            'Отправить уведомление о новом отзыве',
            () => _sendNewReview(),
          ),
          
          _buildDemoButton(
            '🤝 Партнерство',
            'Отправить уведомление об одобрении партнерства',
            () => _sendPartnershipApproved(),
          ),
        ],
      ),
    );
  }

  // ===== SYSTEM TAB =====

  Widget _buildSystemTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚙️ Системные уведомления',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Отправка системных уведомлений',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          _buildDemoButton(
            '🔄 Обновление системы',
            'Отправить уведомление об обновлении системы',
            () => _sendSystemUpdate(),
          ),
          
          _buildDemoButton(
            '🔧 Техобслуживание',
            'Отправить уведомление о техобслуживании',
            () => _sendMaintenance(),
          ),
          
          _buildDemoButton(
            '🔒 Безопасность',
            'Отправить уведомление о безопасности',
            () => _sendSecurityAlert(),
          ),
          
          const SizedBox(height: 32),
          
          const Text(
            '🎯 Массовые уведомления',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _buildDemoButton(
            '📢 По категории',
            'Отправить массовые уведомления по категории',
            () => _sendBulkByCategory(),
          ),
          
          _buildDemoButton(
            '👥 Пользователям',
            'Отправить массовые уведомления пользователям',
            () => _sendBulkToUsers(),
          ),
          
          const SizedBox(height: 32),
          
          const Text(
            '🧪 Тестирование',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _buildDemoButton(
            '🎭 Все типы',
            'Отправить демо уведомления всех типов',
            () => _sendDemoNotifications(),
          ),
          
          _buildDemoButton(
            '🎬 Симуляция событий',
            'Симулировать события всех модулей',
            () => _simulateModuleEvents(),
          ),
        ],
      ),
    );
  }

  // ===== DEMO BUTTON BUILDER =====

  Widget _buildDemoButton(String title, String description, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.centerLeft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ===== AI NOTIFICATIONS =====

  Future<void> _sendAIRecommendations() async {
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<NotificationIntegrationService>();
      final success = await service.notifyNewRecommendations(
        userId: 'demo_user_123',
        recommendations: [
          {
            'product': {
              'id': 'demo_product_1',
              'title': 'Демо товар 1',
              'description': 'Описание демо товара',
              'price': 1000,
              'imageUrl': 'https://example.com/image1.jpg',
              'productUrl': 'https://example.com/product1',
              'source': 'demo',
              'sourceId': '1',
              'categoryId': 'demo_category',
            },
            'score': 0.95,
            'reason': 'Демо рекомендация',
          },
        ],
        category: 'Демо категория',
      );
      
      _showStatus(success, 'AI рекомендации отправлены успешно', 'Ошибка отправки AI рекомендаций');
    } catch (e) {
      _showStatus(false, null, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendPriceAlert() async {
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<NotificationIntegrationService>();
      final success = await service.notifyPriceAlert(
        userId: 'demo_user_123',
        product: {
          'id': 'demo_product_2',
          'title': 'Демо товар 2',
          'description': 'Описание демо товара',
          'price': 800,
          'imageUrl': 'https://example.com/image2.jpg',
          'productUrl': 'https://example.com/product2',
          'source': 'demo',
          'sourceId': '2',
          'categoryId': 'demo_category',
        },
        oldPrice: 1000,
        newPrice: 800,
        discount: 200,
      );
      
      _showStatus(success, 'Уведомление о снижении цены отправлено', 'Ошибка отправки уведомления о цене');
    } catch (e) {
      _showStatus(false, null, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendPersonalizedOffer() async {
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<NotificationIntegrationService>();
      final success = await service.notifyPersonalizedOffer(
        userId: 'demo_user_123',
        offerType: 'Скидка',
        description: 'Персональная скидка 20% на ваш любимый бренд',
        offerData: {'discount': 20, 'brand': 'Демо бренд'},
      );
      
      _showStatus(success, 'Персональное предложение отправлено', 'Ошибка отправки персонального предложения');
    } catch (e) {
      _showStatus(false, null, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ===== AR NOTIFICATIONS =====

  Future<void> _sendARFittingComplete() async {
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<NotificationIntegrationService>();
      final success = await service.notifyARFittingComplete(
        userId: 'demo_user_123',
        productName: 'Демо товар для примерки',
        fittingResults: {
          'size': 'M',
          'fit': 'perfect',
          'confidence': 0.95,
        },
      );
      
      _showStatus(success, 'AR примерка отправлена', 'Ошибка отправки AR примерки');
    } catch (e) {
      _showStatus(false, null, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendSizeRecommendation() async {
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<NotificationIntegrationService>();
      final success = await service.notifySizeRecommendation(
        userId: 'demo_user_123',
        productName: 'AR товар',
        recommendedSize: 'L',
        reason: 'На основе ваших параметров',
      );
      
      _showStatus(success, 'Рекомендация размера отправлена', 'Ошибка отправки рекомендации размера');
    } catch (e) {
      _showStatus(false, null, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendBodyAnalysisUpdate() async {
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<NotificationIntegrationService>();
      final success = await service.notifyBodyAnalysisUpdate(
        userId: 'demo_user_123',
        bodyMetrics: {
          'height': 175,
          'weight': 70,
          'chest': 95,
          'waist': 80,
        },
        insight: 'Ваши параметры обновлены на основе последней примерки',
      );
      
      _showStatus(success, 'Обновление анализа тела отправлено', 'Ошибка отправки обновления анализа');
    } catch (e) {
      _showStatus(false, null, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ===== LOYALTY NOTIFICATIONS =====

  Future<void> _sendLoyaltyPointsEarned() async {
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<NotificationIntegrationService>();
      final success = await service.notifyLoyaltyPointsEarned(
        userId: 'demo_user_123',
        points: 100,
        reason: 'Демо активность',
        source: 'demo',
      );
      
      _showStatus(success, 'Баллы лояльности отправлены', 'Ошибка отправки баллов лояльности');
    } catch (e) {
      _showStatus(false, null, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendTierUpgrade() async {
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<NotificationIntegrationService>();
      final success = await service.notifyTierUpgrade(
        userId: 'demo_user_123',
        oldTier: 'Bronze',
        newTier: 'Silver',
        newBenefits: ['Скидка 5%', 'Приоритетная поддержка'],
      );
      
      _showStatus(success, 'Повышение уровня отправлено', 'Ошибка отправки повышения уровня');
    } catch (e) {
      _showStatus(false, null, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendReferralBonus() async {
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<NotificationIntegrationService>();
      final success = await service.notifyReferralBonus(
        userId: 'demo_user_123',
        referredUserName: 'Демо пользователь',
        bonusPoints: 50,
      );
      
      _showStatus(success, 'Реферальный бонус отправлен', 'Ошибка отправки реферального бонуса');
    } catch (e) {
      _showStatus(false, null, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendDailyLoginReward() async {
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<NotificationIntegrationService>();
      final success = await service.notifyDailyLoginReward(
        userId: 'demo_user_123',
        points: 10,
        streakDays: 7,
      );
      
      _showStatus(success, 'Ежедневный бонус отправлен', 'Ошибка отправки ежедневного бонуса');
    } catch (e) {
      _showStatus(false, null, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendCryptoReward() async {
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<NotificationIntegrationService>();
      final success = await service.notifyCryptoReward(
        userId: 'demo_user_123',
        tokenAmount: '0.001',
        tokenSymbol: 'ETH',
        reason: 'Демо активность',
      );
      
      _showStatus(success, 'Крипто-награда отправлена', 'Ошибка отправки крипто-награды');
    } catch (e) {
      _showStatus(false, null, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ===== ANALYTICS NOTIFICATIONS =====

  Future<void> _sendTrendAlert() async {
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<NotificationIntegrationService>();
      final success = await service.notifyTrendAlert(
        userId: 'demo_user_123',
        trendType: 'Мода',
        description: 'Новый тренд в категории "Одежда"',
        trendData: {
          'category': 'Одежда',
          'trend_score': 0.85,
          'growth_rate': '+15%',
        },
      );
      
      _showStatus(success, 'Тренд отправлен', 'Ошибка отправки тренда');
    } catch (e) {
      _showStatus(false, null, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendCompetitorUpdate() async {
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<NotificationIntegrationService>();
      final success = await service.notifyCompetitorUpdate(
        userId: 'demo_user_123',
        competitorName: 'Демо конкурент',
        updateType: 'Новая коллекция',
        description: 'Конкурент выпустил новую коллекцию',
      );
      
      _showStatus(success, 'Обновление конкурента отправлено', 'Ошибка отправки обновления конкурента');
    } catch (e) {
      _showStatus(false, null, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendAudienceInsight() async {
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<NotificationIntegrationService>();
      final success = await service.notifyAudienceInsight(
        userId: 'demo_user_123',
        insightType: 'Демография',
        description: 'Новый инсайт о вашей аудитории',
        insightData: {
          'age_group': '25-34',
          'gender': 'женщины',
          'interests': ['мода', 'красота'],
        },
      );
      
      _showStatus(success, 'Инсайт аудитории отправлен', 'Ошибка отправки инсайта аудитории');
    } catch (e) {
      _showStatus(false, null, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ===== COMMERCE NOTIFICATIONS =====

  Future<void> _sendLiveStreamReminder() async {
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<NotificationIntegrationService>();
      final success = await service.notifyLiveStreamReminder(
        userId: 'demo_user_123',
        streamTitle: 'Демо live-стрим',
        streamTime: DateTime.now().add(const Duration(minutes: 30)),
        hostName: 'Демо ведущий',
      );
      
      _showStatus(success, 'Напоминание о live-стриме отправлено', 'Ошибка отправки напоминания о live-стриме');
    } catch (e) {
      _showStatus(false, null, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendGroupPurchaseUpdate() async {
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<NotificationIntegrationService>();
      final success = await service.notifyGroupPurchaseUpdate(
        userId: 'demo_user_123',
        productName: 'Демо товар для групповой покупки',
        updateType: 'Достигнута минимальная группа',
        description: 'Групповая покупка активирована!',
        updateData: {'group_size': 5, 'discount': 15},
      );
      
      _showStatus(success, 'Обновление групповой покупки отправлено', 'Ошибка отправки обновления групповой покупки');
    } catch (e) {
      _showStatus(false, null, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendNewReview() async {
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<NotificationIntegrationService>();
      final success = await service.notifyNewReview(
        userId: 'demo_user_123',
        productName: 'Демо товар',
        reviewerName: 'Демо пользователь',
        rating: 5,
        comment: 'Отличный товар!',
      );
      
      _showStatus(success, 'Новый отзыв отправлен', 'Ошибка отправки нового отзыва');
    } catch (e) {
      _showStatus(false, null, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendPartnershipApproved() async {
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<NotificationIntegrationService>();
      final success = await service.notifyPartnershipApproved(
        userId: 'demo_user_123',
        partnershipType: 'Инфлюенсер',
        description: 'Ваше партнерство одобрено!',
        partnershipData: {'commission': 10, 'duration': '3 месяца'},
      );
      
      _showStatus(success, 'Партнерство отправлено', 'Ошибка отправки партнерства');
    } catch (e) {
      _showStatus(false, null, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ===== SYSTEM NOTIFICATIONS =====

  Future<void> _sendSystemUpdate() async {
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<NotificationIntegrationService>();
      final success = await service.notifySystemUpdate(
        userId: 'demo_user_123',
        title: 'Обновление системы',
        body: 'Доступна новая версия приложения',
        data: {'version': '2.0.0', 'features': ['Новые функции', 'Улучшения']},
      );
      
      _showStatus(success, 'Системное обновление отправлено', 'Ошибка отправки системного обновления');
    } catch (e) {
      _showStatus(false, null, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMaintenance() async {
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<NotificationIntegrationService>();
      final success = await service.notifyMaintenance(
        userId: 'demo_user_123',
        maintenanceType: 'Плановое',
        startTime: DateTime.now().add(const Duration(hours: 1)),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        description: 'Плановое техническое обслуживание',
      );
      
      _showStatus(success, 'Техобслуживание отправлено', 'Ошибка отправки техобслуживания');
    } catch (e) {
      _showStatus(false, null, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendSecurityAlert() async {
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<NotificationIntegrationService>();
      final success = await service.notifySecurityAlert(
        userId: 'demo_user_123',
        alertType: 'Подозрительная активность',
        description: 'Обнаружена подозрительная активность в вашем аккаунте',
        severity: 'medium',
        securityData: {'ip_address': '192.168.1.1', 'location': 'Москва'},
      );
      
      _showStatus(success, 'Безопасность отправлена', 'Ошибка отправки безопасности');
    } catch (e) {
      _showStatus(false, null, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ===== BULK NOTIFICATIONS =====

  Future<void> _sendBulkByCategory() async {
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<NotificationIntegrationService>();
      final success = await service.sendBulkNotificationsByCategory(
        category: 'demo_category',
        title: 'Массовое уведомление',
        body: 'Это массовое уведомление для демонстрации',
        type: 'systemUpdate',
        data: {'demo': true},
      );
      
      _showStatus(success, 'Массовые уведомления по категории отправлены', 'Ошибка отправки массовых уведомлений по категории');
    } catch (e) {
      _showStatus(false, null, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendBulkToUsers() async {
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<NotificationIntegrationService>();
      final success = await service.sendBulkNotificationsToUsers(
        userIds: ['demo_user_1', 'demo_user_2', 'demo_user_3'],
        title: 'Массовое уведомление',
        body: 'Это массовое уведомление для демонстрации',
        type: 'systemUpdate',
        data: {'demo': true},
      );
      
      _showStatus(success, 'Массовые уведомления пользователям отправлены', 'Ошибка отправки массовых уведомлений пользователям');
    } catch (e) {
      _showStatus(false, null, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ===== DEMO AND TESTING =====

  Future<void> _sendDemoNotifications() async {
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<NotificationIntegrationService>();
      final success = await service.sendDemoNotifications(userId: 'demo_user_123');
      
      _showStatus(success, 'Демо уведомления отправлены', 'Ошибка отправки демо уведомлений');
    } catch (e) {
      _showStatus(false, null, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _simulateModuleEvents() async {
    setState(() => _isLoading = true);
    
    try {
      final service = context.read<NotificationIntegrationService>();
      final success = await service.simulateModuleEvents(userId: 'demo_user_123');
      
      _showStatus(success, 'События модулей симулированы', 'Ошибка симуляции событий модулей');
    } catch (e) {
      _showStatus(false, null, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ===== HELPER METHODS =====

  void _showStatus(bool success, String? successMessage, String errorMessage) {
    setState(() {
      _isSuccess = success;
      _statusMessage = success ? successMessage : errorMessage;
    });
  }
}
