import 'package:flutter/material.dart';
import '../services/blockchain_ecosystem_service.dart';

/// Вкладка верификации подлинности
class VerificationTab extends StatefulWidget {
  final BlockchainEcosystemService blockchainService;

  const VerificationTab({
    super.key,
    required this.blockchainService,
  });

  @override
  State<VerificationTab> createState() => _VerificationTabState();
}

class _VerificationTabState extends State<VerificationTab> {
  final _formKey = GlobalKey<FormState>();
  final _productIdController = TextEditingController();
  final _brandIdController = TextEditingController();
  final _verificationTypeController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Map<String, dynamic>> _verifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVerifications();
  }

  @override
  void dispose() {
    _productIdController.dispose();
    _brandIdController.dispose();
    _verificationTypeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadVerifications() async {
    setState(() => _isLoading = true);
    try {
      final verifications = await widget.blockchainService.getBrandVerifications('demo_brand');
      setState(() {
        _verifications = verifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки верификаций: $e')),
        );
      }
    }
  }

  Future<void> _createVerification() async {
    if (!_formKey.currentState!.validate()) return;

    final verification = await widget.blockchainService.createAuthenticityVerification(
      productId: _productIdController.text,
      brandId: _brandIdController.text,
      verificationType: _verificationTypeController.text,
      verificationData: {
        'created_via': 'mobile_app',
        'timestamp': DateTime.now().toIso8601String(),
      },
      description: _descriptionController.text,
    );

    if (verification != null) {
      setState(() {
        _verifications.insert(0, verification);
      });
      
      // Очистка формы
      _formKey.currentState!.reset();
      _productIdController.clear();
      _brandIdController.clear();
      _verificationTypeController.clear();
      _descriptionController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Верификация успешно создана!')),
        );
      }
    }
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Создать верификацию'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _productIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID продукта',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите ID продукта';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _brandIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID бренда',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите ID бренда';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _verificationTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Тип верификации',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите тип верификации';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите описание';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _createVerification();
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Верификация подлинности',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showCreateDialog,
                icon: const Icon(Icons.verified),
                label: const Text('Создать'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_verifications.isEmpty)
            _buildEmptyState()
          else
            Expanded(
              child: ListView.builder(
                itemCount: _verifications.length,
                itemBuilder: (context, index) {
                  final verification = _verifications[index];
                  return _buildVerificationCard(verification);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Верификации не найдены',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Создайте свою первую верификацию подлинности',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showCreateDialog,
              icon: const Icon(Icons.verified),
              label: const Text('Создать верификацию'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationCard(Map<String, dynamic> verification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.verified,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Верификация #${verification['id']?.substring(0, 8) ?? 'Unknown'}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        verification['verificationType'] ?? 'Неизвестный тип',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(verification['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(verification['status']).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    verification['status'] ?? 'unknown',
                    style: TextStyle(
                      color: _getStatusColor(verification['status']),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              verification['description'] ?? 'Без описания',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip(
                  'Продукт',
                  verification['productId']?.substring(0, 8) ?? 'Unknown',
                  Icons.inventory,
                ),
                const SizedBox(width: 12),
                _buildInfoChip(
                  'Бренд',
                  verification['brandId']?.substring(0, 8) ?? 'Unknown',
                  Icons.branding_watermark,
                ),
                const SizedBox(width: 12),
                _buildInfoChip(
                  'Создана',
                  _formatDate(verification['createdAt']),
                  Icons.calendar_today,
                ),
              ],
            ),
            if (verification['verifiedAt'] != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoChip(
                    'Подтверждена',
                    _formatDate(verification['verifiedAt']),
                    Icons.check_circle,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Неизвестно';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}.${date.month}.${date.year}';
    } catch (e) {
      return 'Неизвестно';
    }
  }
}

