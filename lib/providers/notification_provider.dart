import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/notification.dart';

class NotificationProvider extends ChangeNotifier {
  final List<Notification> _notifications = [];
  final Uuid _uuid = const Uuid();

  List<Notification> get notifications => List.unmodifiable(_notifications);
  
  List<Notification> get unreadNotifications => 
      _notifications.where((notification) => !notification.isRead).toList();
  
  int get unreadCount => unreadNotifications.length;

  void addNotification({
    required String title,
    required String message,
    required String type,
    String? relatedScheduleId,
    String? relatedBookingId,
  }) {
    final notification = Notification(
      id: _uuid.v4(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
      relatedScheduleId: relatedScheduleId,
      relatedBookingId: relatedBookingId,
    );

    _notifications.insert(0, notification);
    notifyListeners();
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  void addBookingConfirmationNotification(String scheduleTitle, String bookingId) {
    addNotification(
      title: 'Booking Confirmed',
      message: 'Your booking for "$scheduleTitle" has been confirmed.',
      type: 'booking_confirmed',
      relatedBookingId: bookingId,
    );
  }

  void addBookingCancellationNotification(String scheduleTitle, String bookingId) {
    addNotification(
      title: 'Booking Cancelled',
      message: 'Your booking for "$scheduleTitle" has been cancelled.',
      type: 'booking_cancelled',
      relatedBookingId: bookingId,
    );
  }

  void addReminderNotification(String scheduleTitle, String scheduleId) {
    addNotification(
      title: 'Upcoming Schedule',
      message: 'Reminder: "$scheduleTitle" is starting soon.',
      type: 'reminder',
      relatedScheduleId: scheduleId,
    );
  }

  void addGeneralNotification(String title, String message) {
    addNotification(
      title: title,
      message: message,
      type: 'general',
    );
  }

  // Initialize with some sample notifications for testing
  void initializeSampleNotifications() {
    if (_notifications.isEmpty) {
      addNotification(
        title: 'Welcome to BookSlot',
        message: 'Start booking your favorite slots and manage your schedule efficiently.',
        type: 'general',
      );
      
      addNotification(
        title: 'Feature Update',
        message: 'New notification system added! Check the bell icon for updates.',
        type: 'general',
      );
    }
  }
}
