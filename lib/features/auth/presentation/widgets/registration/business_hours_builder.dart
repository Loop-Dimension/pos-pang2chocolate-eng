import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BusinessHoursBuilder extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onChanged;

  const BusinessHoursBuilder({super.key, required this.onChanged});

  @override
  State<BusinessHoursBuilder> createState() => _BusinessHoursBuilderState();
}

class _BusinessHoursBuilderState extends State<BusinessHoursBuilder> {
  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  
  // Maps day to whether they are closed
  final Map<String, bool> isClosed = {};
  
  // Maps day to open/close times (simplified as string ranges for now)
  final Map<String, String> openTimes = {};
  final Map<String, String> closeTimes = {};

  @override
  void initState() {
    super.initState();
    for (var day in days) {
      isClosed[day] = false;
      openTimes[day] = '09:00';
      closeTimes[day] = '18:00';
    }
  }

  void _notifyChanges() {
    widget.onChanged({
      'isClosed': isClosed,
      'openTimes': openTimes,
      'closeTimes': closeTimes,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Business Hours',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        ...days.map((day) {
          final closed = isClosed[day] ?? false;
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40.w,
                  child: Text(day, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
                ),
                if (!closed) ...[
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTimeDropdown(openTimes[day]!, (val) {
                          setState(() => openTimes[day] = val!);
                          _notifyChanges();
                        }),
                        const Text('~'),
                        _buildTimeDropdown(closeTimes[day]!, (val) {
                          setState(() => closeTimes[day] = val!);
                          _notifyChanges();
                        }),
                      ],
                    ),
                  ),
                ] else ...[
                  const Expanded(
                    child: Text('Closed', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  ),
                ],
                SizedBox(width: 8.w),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isClosed[day] = !closed;
                    });
                    _notifyChanges();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: closed ? Colors.black : Colors.grey.shade300,
                    foregroundColor: closed ? Colors.white : Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
                    minimumSize: Size(60.w, 32.h),
                  ),
                  child: const Text('Rest'),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTimeDropdown(String currentValue, ValueChanged<String?> onChanged) {
    return DropdownButton<String>(
      value: currentValue,
      underline: const SizedBox(),
      style: TextStyle(fontSize: 14.sp, color: Colors.black),
      items: ['09:00', '10:00', '11:00', '12:00', '18:00', '20:00', '22:00']
          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
