import 'package:flutter/material.dart';

class Schedule {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int maxParticipants;
  final int currentParticipants;
  final String location;
  final double? latitude;
  final double? longitude;
  final String createdBy;
  final bool isActive;
  final DateTime createdAt;

  Schedule({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.maxParticipants,
    this.currentParticipants = 0,
    required this.location,
    this.latitude,
    this.longitude,
    required this.createdBy,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isAvailable => isActive && currentParticipants < maxParticipants;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'startTime': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
      'endTime': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': createdBy,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      startTime: TimeOfDay(
        hour: int.parse(json['startTime'].split(':')[0]),
        minute: int.parse(json['startTime'].split(':')[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(json['endTime'].split(':')[0]),
        minute: int.parse(json['endTime'].split(':')[1]),
      ),
      maxParticipants: json['maxParticipants'],
      currentParticipants: json['currentParticipants'] ?? 0,
      location: json['location'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      createdBy: json['createdBy'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Schedule copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int? maxParticipants,
    int? currentParticipants,
    String? location,
    double? latitude,
    double? longitude,
    String? createdBy,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
