import 'package:flutter/material.dart';
import '../services/mobile_capabilities_service.dart';

/// Вкладка календаря
class CalendarTab extends StatefulWidget {
  final MobileCapabilitiesService mobileService;

  const CalendarTab({
    super.key,
    required this.mobileService,
  });

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _eventTypeController = TextEditingController();
  
  DateTime _startDate = DateTime.now().add(const Duration(hours: 1));
  DateTime _endDate = DateTime.now().add(const Duration(hours: 2));
  
  bool _isLoading = false;
  String? _statusMessage;
  bool _isSuccess = false;
  List<CalendarEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _userIdController.text = 'demo_user_123';
    _titleController.text = 'Демо событие';
    _descriptionController.text = 'Описание демо события';
    _locationController.text = 'Демо локация';
    _eventTypeController.text = 'demo';
    
    _loadEvents();
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _eventTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          const Text(
            'Календарь событий',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Описание
          const Text(
            'Создавайте и управляйте событиями в календаре',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          
          // Форма добавления события
          _buildAddEventForm(),
          const SizedBox(height: 24),
          
          // Кнопки действий
          _buildActionButtons(),
          const SizedBox(height: 24),
          
          // Статус
          if (_statusMessage != null)
            _buildStatusMessage(),
          
          const SizedBox(height: 24),
          
          // Список событий
          _buildEventsList(),
        ],
      ),
    );
  }

  Widget _buildAddEventForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Добавить событие',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'ID пользователя',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название события',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Место',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _eventTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Тип события',
                      border: OutlineInputBorder(),
                      hintText: 'demo, meeting, reminder',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildDateTimePicker(
                    label: 'Начало',
                    value: _startDate,
                    onChanged: (date) => setState(() => _startDate = date),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateTimePicker(
                    label: 'Окончание',
                    value: _endDate,
                    onChanged: (date) => setState(() => _endDate = date),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required DateTime value,
    required ValueChanged<DateTime> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(value),
              );
              if (time != null) {
                onChanged(DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                ));
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year} '
                  '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _addEvent,
            icon: const Icon(Icons.add),
            label: const Text('Добавить событие'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _loadEvents,
            icon: const Icon(Icons.refresh),
            label: const Text('Обновить'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isSuccess ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isSuccess ? Colors.green : Colors.red,
        ),
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
                color: _isSuccess ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    if (_events.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              'Событий пока нет',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'События (${_events.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: _loadEvents,
              child: const Text('Обновить'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        ..._events.map((event) => _buildEventCard(event)),
      ],
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    final isToday = event.startTime.day == DateTime.now().day &&
                    event.startTime.month == DateTime.now().month &&
                    event.startTime.year == DateTime.now().year;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isToday ? Colors.blue.shade50 : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getEventTypeColor(event.eventType),
          child: Icon(
            _getEventTypeIcon(event.eventType),
            color: Colors.white,
          ),
        ),
        title: Text(
          event.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isToday ? Colors.blue.shade700 : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')} - '
                  '${event.endTime.hour.toString().padLeft(2, '0')}:${event.endTime.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            if (event.location != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    event.location!,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleEventAction(value, event),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Редактировать'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Удалить', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _showEventDetails(event),
      ),
    );
  }

  Color _getEventTypeColor(String? eventType) {
    switch (eventType) {
      case 'demo':
        return Colors.blue;
      case 'meeting':
        return Colors.green;
      case 'reminder':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getEventTypeIcon(String? eventType) {
    switch (eventType) {
      case 'demo':
        return Icons.flash_on;
      case 'meeting':
        return Icons.group;
      case 'reminder':
        return Icons.notifications;
      default:
        return Icons.event;
    }
  }

  // ===== ДЕЙСТВИЯ =====

  Future<void> _addEvent() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = _userIdController.text.trim();
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final location = _locationController.text.trim();
      final eventType = _eventTypeController.text.trim();
      
      if (userId.isEmpty || title.isEmpty || description.isEmpty) {
        _showStatus(false, 'Заполните обязательные поля');
        return;
      }
      
      if (_endDate.isBefore(_startDate)) {
        _showStatus(false, 'Время окончания не может быть раньше начала');
        return;
      }
      
      final success = await widget.mobileService.addCalendarEvent(
        userId: userId,
        title: title,
        description: description,
        startTime: _startDate,
        endTime: _endDate,
        location: location.isEmpty ? null : location,
        eventType: eventType.isEmpty ? null : eventType,
      );
      
      if (success) {
        _showStatus(true, 'Событие добавлено успешно');
        _clearForm();
        _loadEvents();
      } else {
        _showStatus(false, 'Не удалось добавить событие');
      }
      
    } catch (e) {
      _showStatus(false, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = _userIdController.text.trim();
      if (userId.isEmpty) {
        _showStatus(false, 'Введите ID пользователя');
        return;
      }
      
      final events = await widget.mobileService.getCalendarEvents(
        userId: userId,
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 30)),
      );
      
      setState(() {
        _events = events;
      });
      
      _showStatus(true, 'Загружено ${events.length} событий');
      
    } catch (e) {
      _showStatus(false, 'Ошибка: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleEventAction(String action, CalendarEvent event) {
    switch (action) {
      case 'edit':
        _editEvent(event);
        break;
      case 'delete':
        _deleteEvent(event);
        break;
    }
  }

  void _editEvent(CalendarEvent event) {
    // В реальном приложении здесь должна быть форма редактирования
    _showStatus(false, 'Редактирование пока не реализовано');
  }

  void _deleteEvent(CalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить событие?'),
        content: Text('Вы уверены, что хотите удалить событие "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _confirmDeleteEvent(event);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteEvent(CalendarEvent event) {
    // В реальном приложении здесь должно быть удаление события
    setState(() {
      _events.remove(event);
    });
    _showStatus(true, 'Событие удалено');
  }

  void _showEventDetails(CalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Описание: ${event.description}'),
            const SizedBox(height: 16),
            Text('Начало: ${_formatDateTime(event.startTime)}'),
            Text('Окончание: ${_formatDateTime(event.endTime)}'),
            if (event.location != null) Text('Место: ${event.location}'),
            if (event.eventType != null) Text('Тип: ${event.eventType}'),
            Text('Создано: ${_formatDateTime(event.createdAt)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _eventTypeController.clear();
    _startDate = DateTime.now().add(const Duration(hours: 1));
    _endDate = DateTime.now().add(const Duration(hours: 2));
  }

  void _showStatus(bool success, String message) {
    setState(() {
      _isSuccess = success;
      _statusMessage = message;
    });
    
    // Автоматически скрываем сообщение через 5 секунд
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _statusMessage = null;
        });
      }
    });
  }
}
