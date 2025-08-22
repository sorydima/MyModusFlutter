import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/social_commerce_provider.dart';

class CreateLiveStreamScreen extends StatefulWidget {
  const CreateLiveStreamScreen({super.key});

  @override
  State<CreateLiveStreamScreen> createState() => _CreateLiveStreamScreenState();
}

class _CreateLiveStreamScreenState extends State<CreateLiveStreamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _scheduledTime = DateTime.now().add(const Duration(hours: 1));
  List<String> _selectedProductIds = [];
  String? _thumbnailUrl;
  Map<String, dynamic> _settings = {};

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать Live-стрим'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Заголовок
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название стрима *',
                hintText: 'Введите название вашего live-стрима',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.live_tv),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Пожалуйста, введите название';
                }
                if (value.trim().length < 5) {
                  return 'Название должно содержать минимум 5 символов';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Описание
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                hintText: 'Опишите, что будет в вашем стриме',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value != null && value.trim().length > 500) {
                  return 'Описание не должно превышать 500 символов';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Время проведения
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Время проведения *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _selectDate(context),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              'Дата: ${_scheduledTime.day}.${_scheduledTime.month}.${_scheduledTime.year}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _selectTime(context),
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              'Время: ${_scheduledTime.hour.toString().padLeft(2, '0')}:${_scheduledTime.minute.toString().padLeft(2, '0')}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Выбор товаров
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Товары для показа',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildProductSelector(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Превью
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'URL превью',
                hintText: 'Ссылка на изображение превью',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
              ),
              onChanged: (value) => _thumbnailUrl = value.trim().isEmpty ? null : value.trim(),
            ),
            const SizedBox(height: 16),

            // Настройки
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Дополнительные настройки',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsSection(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Кнопка создания
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createLiveStream,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Создать Live-стрим',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSelector() {
    // TODO: Получить реальные товары из API
    final mockProducts = [
      {'id': '1', 'name': 'Стильное платье', 'price': '5000 ₽'},
      {'id': '2', 'name': 'Джинсы классические', 'price': '3000 ₽'},
      {'id': '3', 'name': 'Блузка шелковая', 'price': '2500 ₽'},
      {'id': '4', 'name': 'Юбка миди', 'price': '4000 ₽'},
    ];

    return Column(
      children: mockProducts.map((product) {
        final isSelected = _selectedProductIds.contains(product['id']);
        return CheckboxListTile(
          title: Text(product['name']!),
          subtitle: Text(product['price']!),
          value: isSelected,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedProductIds.add(product['id']!);
              } else {
                _selectedProductIds.remove(product['id']!);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Разрешить комментарии'),
          subtitle: const Text('Зрители смогут оставлять комментарии'),
          value: _settings['allowComments'] ?? true,
          onChanged: (value) {
            setState(() {
              _settings['allowComments'] = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Разрешить покупки'),
          subtitle: const Text('Зрители смогут покупать товары прямо из стрима'),
          value: _settings['allowPurchases'] ?? true,
          onChanged: (value) {
            setState(() {
              _settings['allowPurchases'] = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Запись стрима'),
          subtitle: const Text('Автоматически записывать стрим'),
          value: _settings['recordStream'] ?? false,
          onChanged: (value) {
            setState(() {
              _settings['recordStream'] = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Уведомления'),
          subtitle: const Text('Уведомлять подписчиков о начале стрима'),
          value: _settings['sendNotifications'] ?? true,
          onChanged: (value) {
            setState(() {
              _settings['sendNotifications'] = value;
            });
          },
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _scheduledTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _scheduledTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _scheduledTime.hour,
          _scheduledTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledTime),
    );
    if (picked != null) {
      setState(() {
        _scheduledTime = DateTime(
          _scheduledTime.year,
          _scheduledTime.month,
          _scheduledTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  bool _isLoading = false;

  Future<void> _createLiveStream() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_scheduledTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Время проведения не может быть в прошлом'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<SocialCommerceProvider>();
      await provider.createLiveStream(
        userId: 'current_user', // TODO: Получить реальный ID пользователя
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        scheduledTime: _scheduledTime,
        productIds: _selectedProductIds.isNotEmpty ? _selectedProductIds : null,
        thumbnailUrl: _thumbnailUrl,
        settings: _settings.isNotEmpty ? _settings : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Live-стрим успешно создан!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при создании стрима: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
