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
  PageController _pageController = PageController(initialPage: 1200); // 큰 숫자로 시작

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더
            _buildHeader(),

            // 달력 (고정 높이) - PageView로 변경
            Container(
              height: MediaQuery.of(context).size.height * 0.45,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    // 1200을 기준으로 월 계산
                    int monthDiff = index - 1200;
                    currentMonth = DateTime(DateTime.now().year, DateTime.now().month + monthDiff);
                  });
                },
                itemBuilder: (context, index) {
                  // 1200을 기준으로 월 계산
                  int monthDiff = index - 1200;
                  DateTime pageMonth = DateTime(DateTime.now().year, DateTime.now().month + monthDiff);
                  return _buildCalendar(pageMonth);
                },
              ),
            ),

            // 선택된 날짜 정보 (고정 높이)
            Container(
              height: 60,
              child: _buildSelectedDateInfo(),
            ),

            // 일정 목록 (나머지 공간)
            Expanded(
              child: _buildScheduleList(),
            ),

            // 하단 버튼들
            _buildBottomButtons(),
          ],
        ),
      ),
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
              GestureDetector(
                onTap: () {
                  _pageController.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Icon(Icons.arrow_back_ios, color: Colors.grey[600], size: 20),
              ),
              SizedBox(width: 10),
              Text(
                '${currentMonth.month}월',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              GestureDetector(
                onTap: () {
                  _showMonthPicker();
                },
                child: Icon(Icons.arrow_drop_down, color: Colors.grey[600], size: 24),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.search, color: Colors.grey[600], size: 24),
              SizedBox(width: 15),
              Stack(
                children: [
                  Icon(Icons.notifications_outlined, color: Colors.grey[600], size: 24),
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
              Icon(Icons.menu, color: Colors.grey[600], size: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar([DateTime? monthToShow]) {
    DateTime displayMonth = monthToShow ?? currentMonth;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 3),
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
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: index == 0
                          ? Colors.red[400]
                          : index == 6
                          ? Colors.blue[400]
                          : Colors.grey[600],
                    ),
                  ),
                ),
              );
            })
                .toList(),
          ),
          SizedBox(height: 15),

          // 달력 날짜들
          Expanded(
            child: Column(
              children: List.generate(6, (weekIndex) {
                return Expanded(
                  child: Row(
                    children: List.generate(7, (dayIndex) {
                      final date = _getDateForCalendar(weekIndex, dayIndex, displayMonth);
                      final isCurrentMonth = date.month == displayMonth.month;
                      final isToday = date.day == DateTime.now().day &&
                          date.month == DateTime.now().month &&
                          date.year == DateTime.now().year;
                      final isSelected = date.day == selectedDate.day &&
                          date.month == selectedDate.month &&
                          date.year == selectedDate.year;
                      final isSunday = dayIndex == 0;
                      final isSaturday = dayIndex == 6;

                      return Expanded(
                        child: GestureDetector(
                          onTap: isCurrentMonth ? () {
                            setState(() {
                              selectedDate = date;
                              currentMonth = displayMonth; // 현재 표시된 월로 업데이트
                            });
                          } : null,
                          child: Container(
                            margin: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue[500]
                                  : isToday
                                  ? Colors.blue[100]
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(color: Colors.blue[600]!, width: 2)
                                  : null,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: !isCurrentMonth
                                        ? Colors.grey[300]
                                        : isSelected
                                        ? Colors.white
                                        : isToday
                                        ? Colors.blue[700]
                                        : isSunday
                                        ? Colors.red[400]
                                        : isSaturday
                                        ? Colors.blue[400]
                                        : Colors.grey[800],
                                    fontWeight: isToday || isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                                // Firestore에서 일정 확인해서 점 표시
                                StreamBuilder<QuerySnapshot>(
                                  stream: _getSchedulesForDate(date),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty && isCurrentMonth) {
                                      return Positioned(
                                        bottom: 6,
                                        child: Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: isSelected ? Colors.white : Colors.blue[500],
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateInfo() {
    final dayNames = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'];
    final dayName = dayNames[selectedDate.weekday % 7];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '${selectedDate.month}월 ${selectedDate.day}일 $dayName',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          Spacer(),
          Text(
            '음 6.26',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: StreamBuilder<QuerySnapshot>(
        stream: _getSchedulesForDate(selectedDate),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    '일정이 없습니다',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: snapshot.data!.docs.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        spreadRadius: 0,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.blue[500],
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
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            if (data['description'] != null && data['description'].isNotEmpty)
                              Text(
                                data['description'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _deleteSchedule(doc.id),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.red[400],
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
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
                currentMonth = DateTime.now();
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                '오늘',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
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
                color: Colors.grey[600],
                shape: BoxShape.circle,
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
        title: Text('일정 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${selectedDate.month}월 ${selectedDate.day}일',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: '설명 (선택사항)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                _addSchedule(titleController.text.trim(), descriptionController.text.trim());
                Navigator.pop(context);
              }
            },
            child: Text('저장'),
          ),
        ],
      ),
    );
  }

  // 월 선택 다이얼로그
  void _showMonthPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('월 선택'),
        content: Container(
          height: 300,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    currentMonth = DateTime(currentMonth.year, index + 1);
                    // PageController도 해당 월로 이동
                    int targetPage = 1200 + (index + 1 - DateTime.now().month);
                    _pageController.animateToPage(
                      targetPage,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: currentMonth.month == index + 1 ? Colors.blue : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}월',
                      style: TextStyle(
                        color: currentMonth.month == index + 1 ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Firestore 관련 메서드들
  Stream<QuerySnapshot> _getSchedulesForDate(DateTime date) {
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _firestore
        .collection('schedules')
        .where('userId', isEqualTo: user?.uid)
        .where('date', isEqualTo: dateString)
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Future<void> _addSchedule(String title, String description) async {
    try {
      final dateString = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
      await _firestore.collection('schedules').add({
        'userId': user?.uid,
        'date': dateString,
        'title': title,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일정이 저장되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일정 저장에 실패했습니다.')),
      );
    }
  }

  Future<void> _deleteSchedule(String scheduleId) async {
    try {
      await _firestore.collection('schedules').doc(scheduleId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일정이 삭제되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일정 삭제에 실패했습니다.')),
      );
    }
  }

  DateTime _getDateForCalendar(int weekIndex, int dayIndex, [DateTime? monthToShow]) {
    DateTime displayMonth = monthToShow ?? currentMonth;
    final firstDayOfMonth = DateTime(displayMonth.year, displayMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysFromStart = weekIndex * 7 + dayIndex - firstWeekday;
    return firstDayOfMonth.add(Duration(days: daysFromStart));
  }
}