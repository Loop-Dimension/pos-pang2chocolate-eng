import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BreakTime {
  String startHour = '12';
  String startMin = '00';
  String endHour = '13';
  String endMin = '00';
}

class BusinessHoursBuilder extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onChanged;
  final Map<String, dynamic>? initialValue;

  const BusinessHoursBuilder({super.key, required this.onChanged, this.initialValue});

  @override
  State<BusinessHoursBuilder> createState() => _BusinessHoursBuilderState();
}

class _BusinessHoursBuilderState extends State<BusinessHoursBuilder> {
  // Use Korean day names
  final List<String> days = ['월', '화', '수', '목', '금', '토', '일'];
  final Map<String, String> fullDays = {
    '월': '월요일',
    '화': '화요일',
    '수': '수요일',
    '목': '목요일',
    '금': '금요일',
    '토': '토요일',
    '일': '일요일',
  };

  final Map<String, bool> isClosed = {};

  // Maps day to open/close times
  final Map<String, String> openHour = {};
  final Map<String, String> openMin = {};
  final Map<String, String> closeHour = {};
  final Map<String, String> closeMin = {};

  final Map<String, List<BreakTime>> breakTimes = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      final initial = widget.initialValue!;
      final isClosedInit = initial['isClosed'] as Map<String, dynamic>? ?? {};
      final openInit = initial['openTimes'] as Map<String, dynamic>? ?? {};
      final closeInit = initial['closeTimes'] as Map<String, dynamic>? ?? {};
      final breakInit = initial['breakTimes'] as Map<String, dynamic>? ?? {};

      for (var day in days) {
        isClosed[day] = isClosedInit[day] ?? false;
        
        final op = openInit[day] ?? '09:00';
        final opParts = op.split(':');
        openHour[day] = opParts[0];
        openMin[day] = opParts.length > 1 ? opParts[1] : '00';

        final cl = closeInit[day] ?? '18:00';
        final clParts = cl.split(':');
        closeHour[day] = clParts[0];
        closeMin[day] = clParts.length > 1 ? clParts[1] : '00';

        final btList = breakInit[day] as List<dynamic>? ?? [];
        breakTimes[day] = btList.map((btStr) {
          final bt = BreakTime();
          final parts = btStr.split('-');
          if (parts.length == 2) {
            final stParts = parts[0].split(':');
            if (stParts.length == 2) {
              bt.startHour = stParts[0];
              bt.startMin = stParts[1];
            }
            final endParts = parts[1].split(':');
            if (endParts.length == 2) {
              bt.endHour = endParts[0];
              bt.endMin = endParts[1];
            }
          }
          return bt;
        }).toList();
      }
    } else {
      for (var day in days) {
        isClosed[day] = false;
        openHour[day] = '09';
        openMin[day] = '00';
        closeHour[day] = '18';
        closeMin[day] = '00';
        breakTimes[day] = [];
      }
      isClosed['수'] = true;
      isClosed['목'] = true;
      isClosed['금'] = true;
      isClosed['토'] = true;
      isClosed['일'] = true;
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialValue == null || widget.initialValue!.isEmpty) {
        _notifyChanges();
      }
    });
  }

  void _notifyChanges() {
    widget.onChanged({
      'isClosed': isClosed,
      'openTimes': openHour.map((k, v) => MapEntry(k, '$v:${openMin[k]}')),
      'closeTimes': closeHour.map((k, v) => MapEntry(k, '$v:${closeMin[k]}')),
      'breakTimes': breakTimes.map(
        (k, v) => MapEntry(
          k,
          v
              .map(
                (b) => '${b.startHour}:${b.startMin}-${b.endHour}:${b.endMin}',
              )
              .toList(),
        ),
      ),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '영업시간',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
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
                  Text(
                    '${fullDays[day]} 휴무',
                    style: TextStyle(fontSize: 14.sp, color: Colors.black54),
                  ),
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
                      child: Text(
                        day,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '오픈',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          _buildTimeDropdown(openHour[day]!, true, (val) {
                            setState(() => openHour[day] = val!);
                            _notifyChanges();
                          }),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: Text(
                              ':',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          _buildTimeDropdown(openMin[day]!, false, (val) {
                            setState(() => openMin[day] = val!);
                            _notifyChanges();
                          }),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Text(
                              '-',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Text(
                            '마감',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          _buildTimeDropdown(closeHour[day]!, true, (val) {
                            setState(() => closeHour[day] = val!);
                            _notifyChanges();
                          }),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: Text(
                              ':',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.black54,
                              ),
                            ),
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
                if (breakTimes[day]!.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  ...breakTimes[day]!.asMap().entries.map((entry) {
                    int idx = entry.key;
                    BreakTime bt = entry.value;
                    return Container(
                      margin: EdgeInsets.only(bottom: 6.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '브레이크 타임  시작',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  _buildTimeDropdown(bt.startHour, true, (val) {
                                    setState(() => bt.startHour = val!);
                                    _notifyChanges();
                                  }),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                    ),
                                    child: Text(
                                      ':',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  _buildTimeDropdown(bt.startMin, false, (val) {
                                    setState(() => bt.startMin = val!);
                                    _notifyChanges();
                                  }),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                    ),
                                    child: Text(
                                      '- 종료',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  _buildTimeDropdown(bt.endHour, true, (val) {
                                    setState(() => bt.endHour = val!);
                                    _notifyChanges();
                                  }),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                    ),
                                    child: Text(
                                      ':',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  _buildTimeDropdown(bt.endMin, false, (val) {
                                    setState(() => bt.endMin = val!);
                                    _notifyChanges();
                                  }),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                breakTimes[day]!.removeAt(idx);
                              });
                              _notifyChanges();
                            },
                            child: Icon(
                              Icons.cancel,
                              size: 16.w,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                SizedBox(height: 8.h),
                InkWell(
                  onTap: () {
                    setState(() {
                      breakTimes[day]!.add(BreakTime());
                    });
                    _notifyChanges();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Text(
                      '+ 브레이크타임',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
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

  Widget _buildTimeDropdown(
    String currentValue,
    bool isHour,
    ValueChanged<String?> onChanged,
  ) {
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
          items: items
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
