/// Time-of-day greeting phrase for the dashboard header.
///
/// Periods (local time):
/// - Morning: before 12:00
/// - Noon: 12:00–12:59
/// - Afternoon: 13:00–16:59
/// - Evening: 17:00 and later
String dashboardGreetingPeriod(DateTime dateTime) {
  final hour = dateTime.hour;
  if (hour < 12) return 'Morning';
  if (hour == 12) return 'Noon';
  if (hour < 17) return 'Afternoon';
  return 'Evening';
}

/// Builds "Good {period}, {name}" (comma omitted when [userName] is blank).
String dashboardGreeting({
  required DateTime dateTime,
  String? userName,
}) {
  final period = dashboardGreetingPeriod(dateTime);
  final name = userName?.trim() ?? '';
  if (name.isEmpty) return 'Good $period';
  return 'Good $period, $name';
}
