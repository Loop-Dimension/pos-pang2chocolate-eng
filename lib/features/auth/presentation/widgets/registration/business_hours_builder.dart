import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BusinessHoursBuilder extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onChanged;

  const BusinessHoursBuilder({super.key, required this.onChanged});

  @override
  State<BusinessHoursBuilder> createState() => _BusinessHoursBuilderState();
}

class _BusinessHoursBuilderState extends State<BusinessHoursBuilder> {
  // Use Korean day names
  final List<String> days = ['월', '화', '수', '목', '금', '토', '일'];
  final Map<String, String> fullDays = {
    '월': '월요일', '화': '화요일', '수': '수요일', '목': '목요일', '금': '금요일', '토': '토요일', '일': '일요일'
  };
  
  final Map<String, bool> isClosed = {};
  
  // Maps day to open/close times
  final Map<String, String> openHour = {};
  final Map<String, String> openMin = {};
  final Map<String, String> closeHour = {};
  final Map<String, String> closeMin = {};

  @override
  void initState() {
    super.initState();
    for (var day in days) {
      isClosed[day] = false;
      openHour[day] = '09';
      openMin[day] = '00';
      closeHour[day] = '18';
      closeMin[day] = '00';
    }
    // Set some days to closed by default as seen in mockup
    isClosed['수'] = true;
    isClosed['목'] = true;
    isClosed['금'] = true;
    isClosed['토'] = true;
    isClosed['일'] = true;
  }

  void _notifyChanges() {
    widget.onChanged({
      'isClosed': isClosed,
      'openTimes': openHour.map((k, v) => MapEntry(k, '$v:${openMin[k]}')),
      'closeTimes': closeHour.map((k, v) => MapEntry(k, '$v:${closeMin[k]}')),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '영업시간',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        ...days.map((day) {
          final closed = isClosed[day] ?? false;
          
          if (closed) {
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFC4C4C4),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${fullDays[day]} 휴무', style: TextStyle(fontSize: 14.sp, color: Colors.black54)),
                  _buildClosedButton(day, closed),
                ],
              ),
            );
          }

          return Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 20.w,
                      child: Text(day, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('오픈', style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                          SizedBox(width: 4.w),
                          _buildTimeDropdown(openHour[day]!, true, (val) {
                            setState(() => openHour[day] = val!);
                            _notifyChanges();
                          }),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: Text(':', style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
                          ),
                          _buildTimeDropdown(openMin[day]!, false, (val) {
                            setState(() => openMin[day] = val!);
                            _notifyChanges();
                          }),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Text('-', style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                          ),
                          Text('마감', style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
                          SizedBox(width: 4.w),
                          _buildTimeDropdown(closeHour[day]!, true, (val) {
                            setState(() => closeHour[day] = val!);
                            _notifyChanges();
                          }),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: Text(':', style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
                          ),
                          _buildTimeDropdown(closeMin[day]!, false, (val) {
                            setState(() => closeMin[day] = val!);
                            _notifyChanges();
                          }),
                        ],
                      ),
                    ),
                    _buildClosedButton(day, closed),
                  ],
                ),
                SizedBox(height: 8.h),
                Text('+ 브레이크타임', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildClosedButton(String day, bool isClosedVal) {
    return InkWell(
      onTap: () {
        setState(() {
          isClosed[day] = !isClosedVal;
        });
        _notifyChanges();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isClosedVal ? Colors.black : const Color(0xFFC4C4C4),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          '휴무',
          style: TextStyle(
            color: isClosedVal ? Colors.white : Colors.black87,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeDropdown(String currentValue, bool isHour, ValueChanged<String?> onChanged) {
    List<String> items = isHour
        ? List.generate(24, (index) => index.toString().padLeft(2, '0'))
        : ['00', '15', '30', '45'];

    return Container(
      height: 28.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4.r),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 14),
          style: TextStyle(fontSize: 12.sp, color: Colors.black),
          items: items.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

