import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/schedule.dart';
import '../providers/booking_provider.dart';
import 'map_location_picker_screen.dart';

class AddEditScheduleScreen extends StatefulWidget {
  final Schedule? schedule;

  const AddEditScheduleScreen({super.key, this.schedule});

  @override
  State<AddEditScheduleScreen> createState() => _AddEditScheduleScreenState();
}

class _AddEditScheduleScreenState extends State<AddEditScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxParticipantsController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  bool _isActive = true;
  double? _selectedLatitude;
  double? _selectedLongitude;

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      _titleController.text = widget.schedule!.title;
      _descriptionController.text = widget.schedule!.description;
      _locationController.text = widget.schedule!.location;
      _maxParticipantsController.text = widget.schedule!.maxParticipants.toString();
      _selectedDate = widget.schedule!.date;
      _startTime = widget.schedule!.startTime;
      _endTime = widget.schedule!.endTime;
      _isActive = widget.schedule!.isActive;
      _selectedLatitude = widget.schedule!.latitude;
      _selectedLongitude = widget.schedule!.longitude;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.schedule != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Schedule' : 'Add Schedule'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location *',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openMapPicker,
                      icon: const Icon(Icons.map),
                      label: const Text('Select on Map'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (_selectedLatitude != null && _selectedLongitude != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: IconButton(
                        onPressed: _clearLocation,
                        icon: const Icon(Icons.clear, color: Colors.red),
                        tooltip: 'Clear location',
                      ),
                    ),
                ],
              ),
              if (_selectedLatitude != null && _selectedLongitude != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Selected: ${_selectedLatitude!.toStringAsFixed(6)}, ${_selectedLongitude!.toStringAsFixed(6)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _maxParticipantsController,
                decoration: const InputDecoration(
                  labelText: 'Max Participants *',
                  prefixIcon: Icon(Icons.people),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter max participants';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date & Time',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Date'),
                        subtitle: Text(DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate)),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: _selectDate,
                      ),
                      
                      const Divider(),
                      
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: const Text('Start Time'),
                        subtitle: Text(_startTime.format(context)),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: _selectStartTime,
                      ),
                      
                      const Divider(),
                      
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: const Text('End Time'),
                        subtitle: Text(_endTime.format(context)),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: _selectEndTime,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text(
                        'Active Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Consumer<BookingProvider>(
                builder: (context, bookingProvider, child) {
                  return bookingProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveSchedule,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(isEditing ? 'Update Schedule' : 'Create Schedule'),
                          ),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _saveSchedule() async {
    if (!_formKey.currentState!.validate()) return;

    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;

    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    final schedule = Schedule(
      id: widget.schedule?.id ?? 'schedule_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      date: _selectedDate,
      startTime: _startTime,
      endTime: _endTime,
      maxParticipants: int.parse(_maxParticipantsController.text),
      currentParticipants: widget.schedule?.currentParticipants ?? 0,
      location: _locationController.text.trim(),
      latitude: _selectedLatitude,
      longitude: _selectedLongitude,
      createdBy: 'admin_1',
      isActive: _isActive,
      createdAt: widget.schedule?.createdAt ?? DateTime.now(),
    );

    if (widget.schedule != null) {
      await bookingProvider.updateSchedule(schedule);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Schedule updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      await bookingProvider.addSchedule(schedule);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Schedule created successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }

    Navigator.pop(context);
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<BookingProvider>(context, listen: false)
                  .deleteSchedule(widget.schedule!.id);
              Navigator.pop(context);
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

  Future<void> _openMapPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPickerScreen(
          initialLatitude: _selectedLatitude,
          initialLongitude: _selectedLongitude,
        ),
      ),
    );

    if (result != null && result is Map<String, double>) {
      setState(() {
        _selectedLatitude = result['latitude'];
        _selectedLongitude = result['longitude'];
      });
    }
  }

  void _clearLocation() {
    setState(() {
      _selectedLatitude = null;
      _selectedLongitude = null;
    });
  }
}
