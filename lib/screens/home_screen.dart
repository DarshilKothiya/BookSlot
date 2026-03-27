import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../models/schedule.dart';
import '../models/booking.dart';
import '../utils/minimal_theme.dart';
import 'schedule_detail_screen.dart';
import 'my_bookings_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);

    return Scaffold(
      backgroundColor: MinimalTheme.background,
      appBar: AppBar(
        title: const Text('BookSlot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No notifications')),
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
          _buildSchedulesList(bookingProvider),
          _buildMyBookings(bookingProvider, authProvider.currentUser!.id),
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
            icon: Icon(Icons.calendar_today),
            label: 'Schedules',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'My Bookings',
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulesList(BookingProvider bookingProvider) {
    if (bookingProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookingProvider.schedules.isEmpty) {
      return const Center(
        child: Text('No schedules available'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await bookingProvider.loadData();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookingProvider.schedules.length,
        itemBuilder: (context, index) {
          final schedule = bookingProvider.schedules[index];
          return _buildScheduleCard(schedule, bookingProvider);
        },
      ),
    );
  }

  Widget _buildScheduleCard(Schedule schedule, BookingProvider bookingProvider) {
    final isBooked = bookingProvider.getUserBookings(
      Provider.of<AuthProvider>(context, listen: false).currentUser!.id,
    ).any((booking) => booking.scheduleId == schedule.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: MinimalTheme.getCardDecoration(),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScheduleDetailScreen(schedule: schedule),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
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
                  if (isBooked)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: MinimalTheme.getBadgeDecoration(MinimalTheme.activeBadge),
                      child: const Text(
                        'Booked',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else if (!schedule.isAvailable)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: MinimalTheme.getBadgeDecoration(MinimalTheme.inactiveBadge),
                      child: const Text(
                        'Full',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyBookings(BookingProvider bookingProvider, String userId) {
    final userBookings = bookingProvider.getUserBookings(userId);

    if (userBookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No bookings yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Browse schedules and book your slot',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: userBookings.length,
      itemBuilder: (context, index) {
        final booking = userBookings[index];
        final schedule = bookingProvider.schedules.firstWhere(
          (s) => s.id == booking.scheduleId,
        );
        return _buildBookingCard(booking, schedule, bookingProvider);
      },
    );
  }

  Widget _buildBookingCard(Booking booking, Schedule schedule, BookingProvider bookingProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: MinimalTheme.getCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              schedule.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: MinimalTheme.primaryAccent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              schedule.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: MinimalTheme.subtext,
              ),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: MinimalTheme.getBadgeDecoration(
                    booking.status == 'confirmed' ? MinimalTheme.activeBadge : MinimalTheme.inactiveBadge,
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScheduleDetailScreen(schedule: schedule),
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
                      'View Details',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showCancelBookingDialog(context, booking, bookingProvider);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: MinimalTheme.inactiveBadge),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      'Cancel Booking',
                      style: TextStyle(color: MinimalTheme.inactiveBadge, fontSize: 12),
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

  void _showCancelBookingDialog(BuildContext context, Booking booking, BookingProvider bookingProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              bookingProvider.cancelBooking(booking.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking cancelled successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
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
}
