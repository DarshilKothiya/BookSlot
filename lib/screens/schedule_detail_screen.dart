import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/schedule.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import 'map_location_picker_screen.dart';

class ScheduleDetailScreen extends StatefulWidget {
  final Schedule schedule;

  const ScheduleDetailScreen({super.key, required this.schedule});

  @override
  State<ScheduleDetailScreen> createState() => _ScheduleDetailScreenState();
}

class _ScheduleDetailScreenState extends State<ScheduleDetailScreen> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);

    final isBooked = bookingProvider.getUserBookings(authProvider.currentUser!.id)
        .any((booking) => booking.scheduleId == widget.schedule.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.schedule.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      'Description',
                      widget.schedule.description,
                      Icons.description,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Date',
                      DateFormat('EEEE, MMMM dd, yyyy').format(widget.schedule.date),
                      Icons.calendar_today,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Time',
                      '${widget.schedule.startTime.hour.toString().padLeft(2, '0')}:${widget.schedule.startTime.minute.toString().padLeft(2, '0')} - ${widget.schedule.endTime.hour.toString().padLeft(2, '0')}:${widget.schedule.endTime.minute.toString().padLeft(2, '0')}',
                      Icons.access_time,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Location',
                      widget.schedule.location,
                      Icons.location_on,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Availability',
                      '${widget.schedule.currentParticipants}/${widget.schedule.maxParticipants} participants',
                      Icons.people,
                    ),
                    const SizedBox(height: 12),
                    _buildAvailabilityStatus(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Map Display
            if (widget.schedule.latitude != null && widget.schedule.longitude != null)
              Card(
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.map, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Location',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _openMapViewer,
                            child: const Text('View Full Map'),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 200,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(
                              widget.schedule.latitude!,
                              widget.schedule.longitude!,
                            ),
                            initialZoom: 15,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.bookslot',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(
                                    widget.schedule.latitude!,
                                    widget.schedule.longitude!,
                                  ),
                                  width: 40,
                                  height: 40,
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            
            if (!isBooked && widget.schedule.isAvailable) ...[
              const Text(
                'Booking Notes (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: 'Add any special requests or notes...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Consumer<BookingProvider>(
                  builder: (context, bookingProvider, child) {
                    return bookingProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () => _bookSchedule(context, bookingProvider, authProvider.currentUser!.id),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Book This Schedule'),
                          );
                  },
                ),
              ),
            ] else if (isBooked) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'You have booked this schedule',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            const Text('Your booking is confirmed'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (!widget.schedule.isAvailable) ...[
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.schedule.currentParticipants >= widget.schedule.maxParticipants
                              ? 'This schedule is fully booked'
                              : 'This schedule is no longer available',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityStatus() {
    final availabilityPercentage = (widget.schedule.currentParticipants / widget.schedule.maxParticipants) * 100;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bar_chart, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text(
              'Availability Status',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: availabilityPercentage / 100,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            availabilityPercentage >= 80
                ? Colors.red
                : availabilityPercentage >= 50
                    ? Colors.orange
                    : Colors.green,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(100 - availabilityPercentage).toInt()}% slots available',
          style: TextStyle(
            fontSize: 12,
            color: availabilityPercentage >= 80
                ? Colors.red
                : availabilityPercentage >= 50
                    ? Colors.orange
                    : Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _bookSchedule(BuildContext context, BookingProvider bookingProvider, String userId) async {
    final success = await bookingProvider.bookSchedule(
      userId,
      widget.schedule.id,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Schedule booked successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingProvider.errorMessage ?? 'Failed to book schedule'),
          backgroundColor: Colors.red,
        ),
      );
      bookingProvider.clearError();
    }
  }

  void _openMapViewer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPickerScreen(
          initialLatitude: widget.schedule.latitude,
          initialLongitude: widget.schedule.longitude,
        ),
      ),
    );
  }
}
