import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../models/schedule.dart';
import '../models/booking.dart';
import '../models/user.dart';
import '../services/firebase_service.dart';
import '../utils/minimal_theme.dart';
import 'add_edit_schedule_screen.dart';
import 'manage_users_screen.dart';
import 'profile_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);

    return Scaffold(
      backgroundColor: MinimalTheme.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await bookingProvider.loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data refreshed')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context, authProvider),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardOverview(bookingProvider),
          _buildSchedulesManagement(bookingProvider),
          _buildUsersManagement(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Schedules',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEditScheduleScreen(),
                  ),
                );
              },
              backgroundColor: MinimalTheme.secondaryAccent,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildDashboardOverview(BookingProvider bookingProvider) {
    final totalSchedules = bookingProvider.schedules.length;
    final activeSchedules = bookingProvider.schedules.where((s) => s.isActive).length;
    final totalBookings = bookingProvider.bookings.length;
    final confirmedBookings = bookingProvider.bookings.where((b) => b.status == 'confirmed').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Overview',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: MinimalTheme.primaryAccent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Real-time statistics and insights',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: MinimalTheme.subtext,
            ),
          ),
          const SizedBox(height: 24),
          
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildMinimalStatCard('Total Schedules', totalSchedules.toString(), Icons.calendar_today, MinimalTheme.secondaryAccent)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMinimalStatCard('Active Schedules', activeSchedules.toString(), Icons.check_circle, MinimalTheme.activeBadge)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildMinimalStatCard('Total Bookings', totalBookings.toString(), Icons.book, MinimalTheme.primaryAccent)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMinimalStatCard('Confirmed Bookings', confirmedBookings.toString(), Icons.verified, MinimalTheme.secondaryAccent)),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Recent Bookings',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: MinimalTheme.primaryAccent,
            ),
          ),
          const SizedBox(height: 16),
          
          if (bookingProvider.bookings.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: MinimalTheme.getCardDecoration(),
              child: Column(
                children: [
                  Icon(
                    Icons.book,
                    size: 48,
                    color: MinimalTheme.subtext.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No bookings yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: MinimalTheme.subtext,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bookingProvider.bookings.take(5).length,
              itemBuilder: (context, index) {
                final booking = bookingProvider.bookings[index];
                final schedule = bookingProvider.schedules.firstWhere(
                  (s) => s.id == booking.scheduleId,
                  orElse: () => bookingProvider.schedules.first,
                );
                return _buildMinimalRecentBookingCard(booking, schedule);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMinimalStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 100,
        maxHeight: 140,
      ),
      decoration: MinimalTheme.getCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: MinimalTheme.subtext,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalRecentBookingCard(booking, Schedule schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: MinimalTheme.getCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MinimalTheme.secondaryAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.book, color: MinimalTheme.secondaryAccent, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: MinimalTheme.primaryAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'User ID: ${booking.userId} • ${DateFormat('MMM dd, yyyy').format(booking.bookingTime)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: MinimalTheme.subtext,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: MinimalTheme.getBadgeDecoration(
                booking.status == 'confirmed' ? MinimalTheme.activeBadge : MinimalTheme.inactiveBadge,
              ),
              child: Text(
                booking.status.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 100,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentBookingCard(booking, Schedule schedule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.book, color: Colors.white),
        ),
        title: Text(schedule.title),
        subtitle: Text(
          'User ID: ${booking.userId}\n${DateFormat('MMM dd, yyyy').format(booking.bookingTime)}',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: booking.status == 'confirmed' ? Colors.green : Colors.orange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            booking.status.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSchedulesManagement(BookingProvider bookingProvider) {
    if (bookingProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookingProvider.schedules.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No schedules yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text('Tap the + button to add your first schedule'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookingProvider.schedules.length,
      itemBuilder: (context, index) {
        final schedule = bookingProvider.schedules[index];
        return _buildScheduleManagementCard(schedule, bookingProvider);
      },
    );
  }

  Widget _buildScheduleManagementCard(Schedule schedule, BookingProvider bookingProvider) {
    final bookings = bookingProvider.getScheduleBookings(schedule.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: MinimalTheme.getCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    schedule.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: MinimalTheme.primaryAccent,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditScheduleScreen(schedule: schedule),
                        ),
                      );
                    } else if (value == 'delete') {
                      _showDeleteScheduleDialog(context, schedule, bookingProvider);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              schedule.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: MinimalTheme.subtext,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: MinimalTheme.subtext),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(schedule.date),
                  style: TextStyle(color: MinimalTheme.subtext),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: MinimalTheme.subtext),
                const SizedBox(width: 4),
                Text(
                  '${schedule.startTime.hour.toString().padLeft(2, '0')}:${schedule.startTime.minute.toString().padLeft(2, '0')} - ${schedule.endTime.hour.toString().padLeft(2, '0')}:${schedule.endTime.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: MinimalTheme.subtext),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: MinimalTheme.subtext),
                const SizedBox(width: 4),
                Text(
                  schedule.location,
                  style: TextStyle(color: MinimalTheme.subtext),
                ),
                const Spacer(),
                Icon(Icons.people, size: 16, color: MinimalTheme.subtext),
                const SizedBox(width: 4),
                Text(
                  '${schedule.currentParticipants}/${schedule.maxParticipants}',
                  style: TextStyle(color: MinimalTheme.subtext),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: MinimalTheme.getBadgeDecoration(
                    schedule.isActive ? MinimalTheme.activeBadge : MinimalTheme.inactiveBadge,
                  ),
                  child: Text(
                    schedule.isActive ? 'Active' : 'Inactive',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showBookingsDialog(context, schedule, bookings);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: MinimalTheme.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      'View Bookings (${bookings.length})',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditScheduleScreen(schedule: schedule),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: MinimalTheme.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersManagement() {
    return const ManageUsersScreen();
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MinimalTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Logout',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: MinimalTheme.primaryAccent,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: MinimalTheme.subtext,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: MinimalTheme.subtext),
            ),
          ),
          Container(
            decoration: MinimalTheme.getBadgeDecoration(MinimalTheme.inactiveBadge),
            child: ElevatedButton(
              onPressed: () {
                authProvider.logout();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteScheduleDialog(BuildContext context, Schedule schedule, BookingProvider bookingProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: Text('Are you sure you want to delete "${schedule.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              bookingProvider.deleteSchedule(schedule.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Schedule deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showBookingsDialog(BuildContext context, Schedule schedule, List bookings) async {
    // Fetch all users to get user details
    List<User> users;
    try {
      users = await FirebaseService.getAllUsers();
    } catch (e) {
      users = [];
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bookings for ${schedule.title}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: bookings.isEmpty
              ? const Text('No bookings yet')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    final user = users.firstWhere(
                      (u) => u.id == booking.userId,
                      orElse: () => User(
                        id: booking.userId,
                        name: 'Unknown User',
                        email: 'unknown@example.com',
                        password: '',
                        isAdmin: false,
                      ),
                    );

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                  child: Text(
                                    user.name.isNotEmpty 
                                        ? user.name.substring(0, 2).toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        user.email,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (user.phone != null && user.phone!.isNotEmpty)
                                        Text(
                                          user.phone!,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: booking.status == 'confirmed' ? Colors.green : Colors.orange,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    booking.status.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Booked: ${DateFormat('MMM dd, yyyy HH:mm').format(booking.bookingTime)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.note, size: 16, color: Colors.blue[600]),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Note: ${booking.notes}',
                                        style: TextStyle(
                                          color: Colors.blue[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
