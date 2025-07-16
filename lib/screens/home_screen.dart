import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  DateTime selectedDate = DateTime.now();
  DateTime currentMonth = DateTime.now();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  PageController _pageController = PageController(initialPage: 1200);
  bool showDetailView = false;
  bool showCalendar = true; // 달력 표시 여부

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    selectedDate = now;
    currentMonth = DateTime(now.year, now.month, 1);

    // 디버깅: 현재 사용자 UID 출력
    print('Current user UID: ${user?.uid}');
    print('Current selected date: $selectedDate');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F7FF),
              Color(0xFFF0EBFF),
              Color(0xFFE8DDFF),
            ],
          ),
        ),
        child: SafeArea(
          child: showDetailView ? _buildDetailView() : _buildMainView(),
        ),
      ),
    );
  }

  Widget _buildMainView() {
    return Column(
      children: [
        // 상단 헤더
        _buildHeader(),

        // 슬라이딩 달력 (조건부 표시)
        if (showCalendar) _buildSlidingCalendar(),

        // 선택된 날짜 정보
        _buildDateInfo(),

        // 일정 목록 (달력이 숨겨졌을 때)
        if (!showCalendar)
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                if (details.delta.dy > 5) { // 아래로 드래그
                  setState(() {
                    showCalendar = true;
                  });
                }
              },
              child: _buildScheduleList(),
            ),
          ),

        // 하단 버튼들
        _buildBottomButtons(),
      ],
    );
  }

  Widget _buildDetailView() {
    return Column(
      children: [
        // 상단 헤더 (상세 뷰용)
        _buildDetailHeader(),

        // 슬라이딩 달력 (상세 뷰용)
        _buildSlidingCalendar(),

        // 선택된 날짜 정보
        _buildSelectedDateInfo(),

        // 일정 목록
        Expanded(
          child: _buildScheduleList(),
        ),

        // 하단 버튼들
        _buildBottomButtons(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.arrow_back_ios, color: Color(0xFF6B46C1), size: 24),
              SizedBox(width: 10),
              Text(
                '${currentMonth.month}월',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D1B69),
                  letterSpacing: 0.5,
                ),
              ),
              Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B46C1), size: 24),
            ],
          ),
          Row(
            children: [
              Icon(Icons.search, color: Color(0xFF6B46C1), size: 26),
              SizedBox(width: 15),
              Stack(
                children: [
                  Icon(Icons.notifications_outlined, color: Color(0xFF6B46C1), size: 26),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 15),
              Icon(Icons.menu, color: Color(0xFF6B46C1), size: 26),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                showDetailView = false;
              });
            },
            child: Row(
              children: [
                Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B46C1), size: 24),
                SizedBox(width: 10),
                Text(
                  '${currentMonth.month}월',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D1B69),
                    letterSpacing: 0.5,
                    fontFamily: 'BaedalMinjok', // 배민체 적용
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(Icons.search, color: Color(0xFF6B46C1), size: 26),
              SizedBox(width: 15),
              Icon(Icons.menu, color: Color(0xFF6B46C1), size: 26),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlidingCalendar() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF8B5CF6).withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 요일 헤더
          Row(
            children: ['일', '월', '화', '수', '목', '금', '토']
                .asMap()
                .entries
                .map((entry) {
              int index = entry.key;
              String day = entry.value;
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: index == 0
                          ? Color(0xFFE53E3E)
                          : index == 6
                          ? Color(0xFF3182CE)
                          : Color(0xFF4A5568),
                      letterSpacing: 0.3,
                      fontFamily: 'BaedalMinjok',
                    ),
                  ),
                ),
              );
            })
                .toList(),
          ),
          SizedBox(height: 20),

          // 슬라이딩 달력
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  int monthDiff = index - 1200;
                  currentMonth = DateTime(DateTime.now().year, DateTime.now().month + monthDiff);
                });
              },
              itemBuilder: (context, index) {
                int monthDiff = index - 1200;
                DateTime pageMonth = DateTime(DateTime.now().year, DateTime.now().month + monthDiff);
                return _buildCalendarPage(pageMonth);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarPage(DateTime month) {
    return Column(
      children: List.generate(6, (weekIndex) {
        return Expanded(
          child: Row(
            children: List.generate(7, (dayIndex) {
              final date = _getDateForCalendar(weekIndex, dayIndex, month);
              final isCurrentMonth = date.month == month.month;
              final isToday = _isToday(date);
              final isSelected = _isSelected(date);
              final isSunday = dayIndex == 0;
              final isSaturday = dayIndex == 6;

              return Expanded(
                child: GestureDetector(
                  onTap: isCurrentMonth ? () {
                    setState(() {
                      selectedDate = date;
                      currentMonth = DateTime(month.year, month.month, 1);
                      showCalendar = false; // 날짜 선택 시 달력 숨기기
                    });
                  } : null,
                  child: Container(
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(0xFF8B5CF6)
                          : isToday
                          ? Color(0xFFDDD6FE)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday && !isSelected
                          ? Border.all(color: Color(0xFF8B5CF6), width: 2)
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 14, // 글씨 크기 줄임
                            fontWeight: FontWeight.w600,
                            color: !isCurrentMonth
                                ? Color(0xFFA0AEC0)
                                : isSelected
                                ? Colors.white
                                : isToday
                                ? Color(0xFF553C9A)
                                : isSunday
                                ? Color(0xFFE53E3E)
                                : isSaturday
                                ? Color(0xFF3182CE)
                                : Color(0xFF2D3748),
                            letterSpacing: 0.2,
                            fontFamily: 'BaedalMinjok', // 배민체 적용
                          ),
                        ),
                        // 일정 있을 때 점 표시
                        StreamBuilder<QuerySnapshot>(
                          stream: _getSchedulesForDate(date),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty && isCurrentMonth) {
                              return Positioned(
                                bottom: 8,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white : Color(0xFF8B5CF6),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            }
                            return SizedBox();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildDateInfo() {
    final dayNames = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'];
    final dayName = dayNames[selectedDate.weekday % 7];

    return GestureDetector(
      onTap: () {
        if (!showCalendar) {
          setState(() {
            showCalendar = true;
          });
        }
      },
      child: Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF8B5CF6).withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (!showCalendar)
              Icon(Icons.keyboard_arrow_up, color: Color(0xFF6B46C1), size: 20),
            if (!showCalendar) SizedBox(width: 8),
            Text(
              '${selectedDate.month}월 ${selectedDate.day}일 ${dayName.substring(0, 1)}요일',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D1B69),
                letterSpacing: 0.3,
                fontFamily: 'BaedalMinjok',
              ),
            ),
            Spacer(),
            Text(
              '음 6.26',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
                fontFamily: 'BaedalMinjok',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateInfo() {
    final dayNames = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'];
    final dayName = dayNames[selectedDate.weekday % 7];

    return Container(
      padding: EdgeInsets.all(20),
      child: Text(
        '${selectedDate.year}년${selectedDate.month}월 ${selectedDate.day}일(${dayName.substring(0, 1)})',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2D1B69),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildScheduleList() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: StreamBuilder<QuerySnapshot>(
        stream: _getSchedulesForDate(selectedDate),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                '일정이 없습니다',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF718096),
                  fontFamily: 'BaedalMinjok',
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF8B5CF6).withOpacity(0.08),
                      spreadRadius: 0,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getScheduleColor(data['title'] ?? ''),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['title'] ?? '',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D1B69),
                              letterSpacing: 0.2,
                              fontFamily: 'BaedalMinjok',
                            ),
                          ),
                          if (data['description'] != null && data['description'].isNotEmpty)
                            Text(
                              data['description'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF718096),
                                letterSpacing: 0.1,
                                fontFamily: 'BaedalMinjok',
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Color(0xFF718096)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = DateTime.now();
                currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
                _pageController.animateToPage(
                  1200,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              decoration: BoxDecoration(
                color: Color(0xFF718096),
                borderRadius: BorderRadius.circular(25),
              ),
              child:               Text(
                '오늘',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  fontFamily: 'BaedalMinjok',
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _showAddScheduleDialog,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF8B5CF6).withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 일정 추가 다이얼로그
  void _showAddScheduleDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('일정 추가', style: TextStyle(
          color: Color(0xFF2D1B69),
          fontWeight: FontWeight.w700,
          fontSize: 18,
          fontFamily: 'BaedalMinjok',
        )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${selectedDate.month}월 ${selectedDate.day}일',
              style: TextStyle(
                color: Color(0xFF718096),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'BaedalMinjok',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: titleController,
              style: TextStyle(
                color: Color(0xFF2D1B69),
                fontWeight: FontWeight.w500,
                fontFamily: 'BaedalMinjok',
              ),
              decoration: InputDecoration(
                labelText: '제목',
                labelStyle: TextStyle(color: Color(0xFF718096), fontFamily: 'BaedalMinjok'),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF8B5CF6), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              style: TextStyle(
                color: Color(0xFF2D1B69),
                fontWeight: FontWeight.w500,
                fontFamily: 'BaedalMinjok',
              ),
              decoration: InputDecoration(
                labelText: '설명 (선택사항)',
                labelStyle: TextStyle(color: Color(0xFF718096), fontFamily: 'BaedalMinjok'),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF8B5CF6), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: TextStyle(
              color: Color(0xFF718096),
              fontWeight: FontWeight.w500,
              fontFamily: 'BaedalMinjok',
            )),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                _addSchedule(titleController.text.trim(), descriptionController.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('저장', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'BaedalMinjok')),
          ),
        ],
      ),
    );
  }

  // Firestore 관련 메서드들
  Stream<QuerySnapshot> _getSchedulesForDate(DateTime date) {
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    // 디버깅: 쿼리 정보 출력
    print('Querying schedules for date: $dateString');
    print('Current user UID: ${user?.uid}');

    return _firestore
        .collection('schedules')
        .where('userId', isEqualTo: user?.uid)
        .where('date', isEqualTo: dateString)
        .snapshots(); // orderBy 제거
  }

  Future<void> _addSchedule(String title, String description) async {
    try {
      final dateString = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

      // 디버깅: 저장할 데이터 출력
      print('Saving schedule: $title for date: $dateString');

      await _firestore.collection('schedules').add({
        'userId': user?.uid,
        'date': dateString,
        'title': title,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Schedule saved successfully!');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('일정이 저장되었습니다.'),
          backgroundColor: Color(0xFF48BB78),
        ),
      );
    } catch (e) {
      print('Error saving schedule: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('일정 저장에 실패했습니다.'),
          backgroundColor: Color(0xFFE53E3E),
        ),
      );
    }
  }

  // 유틸리티 메서드들
  DateTime _getDateForCalendar(int weekIndex, int dayIndex, DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysFromStart = weekIndex * 7 + dayIndex - firstWeekday;
    return firstDayOfMonth.add(Duration(days: daysFromStart));
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isSelected(DateTime date) {
    return date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;
  }

  Color _getScheduleColor(String title) {
    final colors = [
      Color(0xFF8B5CF6),
      Color(0xFF06B6D4),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF8B5CF6),
    ];
    return colors[title.hashCode % colors.length];
  }
}