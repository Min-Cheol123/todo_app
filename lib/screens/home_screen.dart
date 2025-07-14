// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';

// 간단한 Todo 클래스 (임시)
class SimpleTodo {
  final String id;
  String text;
  bool completed;
  final String priority;
  final DateTime createdAt;
  final List<String> sharedWith;
  final bool isShared;

  SimpleTodo({
    required this.id,
    required this.text,
    this.completed = false,
    required this.priority,
    required this.createdAt,
    this.sharedWith = const [],
    this.isShared = false,
  });
}

enum FilterType { all, personal, shared, completed }
enum Priority { high, medium, low }

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AuthService _authService = AuthService();

  FilterType _currentFilter = FilterType.all;
  late TabController _tabController;
  List<SimpleTodo> _todos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSampleData();
    print('HomeScreen 초기화 완료');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSampleData() {
    print('샘플 데이터 로드 중...');
    setState(() {
      _todos = [
        SimpleTodo(
          id: '1',
          text: '🎯 투두 앱 완성하기',
          priority: 'high',
          createdAt: DateTime.now().subtract(Duration(hours: 2)),
        ),
        SimpleTodo(
          id: '2',
          text: '🎨 앱 디자인 개선하기',
          priority: 'medium',
          createdAt: DateTime.now().subtract(Duration(hours: 1)),
          completed: true,
        ),
        SimpleTodo(
          id: '3',
          text: '📱 기능 테스트하기',
          priority: 'low',
          createdAt: DateTime.now().subtract(Duration(minutes: 30)),
          sharedWith: ['team@company.com'],
          isShared: true,
        ),
      ];
    });
    print('샘플 데이터 로드 완료: ${_todos.length}개');
  }

  String get _userName => _authService.currentUser?.displayName ?? '사용자';
  String get _userEmail => _authService.currentUser?.email ?? '';

  List<SimpleTodo> _filterTodos(List<SimpleTodo> todos) {
    switch (_currentFilter) {
      case FilterType.personal:
        return todos.where((todo) => !todo.isShared).toList();
      case FilterType.shared:
        return todos.where((todo) => todo.isShared).toList();
      case FilterType.completed:
        return todos.where((todo) => todo.completed).toList();
      default:
        return todos;
    }
  }

  Future<void> _showAddTodoDialog() async {
    print('할일 추가 다이얼로그 열기');
    final TextEditingController controller = TextEditingController();
    String selectedPriority = 'medium';

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.add_task, color: Colors.blue[700], size: 20),
              ),
              SizedBox(width: 12),
              Text('새 할일 추가', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: '할일 내용',
                  hintText: '예: 프로젝트 보고서 작성하기',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: Icon(Icons.edit),
                ),
                autofocus: true,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedPriority,
                decoration: InputDecoration(
                  labelText: '우선순위',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: Icon(Icons.flag),
                ),
                items: [
                  DropdownMenuItem(value: 'high', child: Text('🔴 높음')),
                  DropdownMenuItem(value: 'medium', child: Text('🟡 보통')),
                  DropdownMenuItem(value: 'low', child: Text('🟢 낮음')),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    selectedPriority = value!;
                  });
                },
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
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(context, {
                    'text': controller.text.trim(),
                    'priority': selectedPriority,
                  });
                }
              },
              child: Text('추가'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      print('새 할일 추가: ${result['text']}');
      setState(() {
        _todos.insert(0, SimpleTodo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: result['text']!,
          priority: result['priority']!,
          createdAt: DateTime.now(),
        ));
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('할일이 추가되었습니다! 🎉'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _toggleTodo(String id) {
    print('할일 토글: $id');
    setState(() {
      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        _todos[index].completed = !_todos[index].completed;
      }
    });
  }

  void _deleteTodo(String id) {
    print('할일 삭제: $id');
    setState(() {
      _todos.removeWhere((todo) => todo.id == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.delete, color: Colors.white),
            SizedBox(width: 8),
            Text('할일이 삭제되었습니다'),
          ],
        ),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('HomeScreen build 호출됨');

    List<SimpleTodo> filteredTodos = _filterTodos(_todos);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEBF4FF), Color(0xFFF3E8FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 헤더
              _buildHeader(),

              // 통계
              _buildStats(),

              // 탭 바
              _buildTabBar(),

              // 할일 목록
              Expanded(
                child: filteredTodos.isEmpty
                    ? _buildEmptyState()
                    : _buildTodoList(filteredTodos),
              ),

              // 진행률 표시
              if (_todos.isNotEmpty) _buildProgressBar(filteredTodos),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTodoDialog,
        icon: Icon(Icons.add),
        label: Text('새 할일'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          // 앱 로고
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFFEC4899)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.check_circle, color: Colors.white, size: 28),
          ),

          SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '안녕하세요, $_userName님! 👋',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.today, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      DateFormat('yyyy년 MM월 dd일 EEEE', 'ko_KR').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () async {
              await _authService.signOut();
            },
            icon: Icon(Icons.logout, color: Colors.grey[700]),
            tooltip: '로그아웃',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    int totalCount = _todos.length;
    int personalCount = _todos.where((t) => !t.isShared).length;
    int sharedCount = _todos.where((t) => t.isShared).length;
    int completedCount = _todos.where((t) => t.completed).length;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('전체', totalCount.toString(), Colors.blue, Icons.list_alt)),
          SizedBox(width: 10),
          Expanded(child: _buildStatCard('개인', personalCount.toString(), Colors.green, Icons.person)),
          SizedBox(width: 10),
          Expanded(child: _buildStatCard('공유', sharedCount.toString(), Colors.orange, Icons.group)),
          SizedBox(width: 10),
          Expanded(child: _buildStatCard('완료', completedCount.toString(), Colors.purple, Icons.check_circle)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() {
            _currentFilter = FilterType.values[index];
          });
        },
        tabs: [
          Tab(text: '전체'),
          Tab(text: '개인'),
          Tab(text: '공유'),
          Tab(text: '완료'),
        ],
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.grey[600],
        indicator: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
      ),
    );
  }

  Widget _buildTodoList(List<SimpleTodo> todos) {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return _buildTodoItem(todo);
      },
    );
  }

  Widget _buildTodoItem(SimpleTodo todo) {
    Color priorityColor = todo.priority == 'high' ? Colors.red :
    todo.priority == 'medium' ? Colors.orange : Colors.green;
    String priorityText = todo.priority == 'high' ? '🔴 높음' :
    todo.priority == 'medium' ? '🟡 보통' : '🟢 낮음';

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: priorityColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleTodo(todo.id),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: todo.completed ? Colors.green : Colors.grey,
                        width: 2,
                      ),
                      color: todo.completed ? Colors.green : Colors.transparent,
                    ),
                    child: todo.completed
                        ? Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    todo.text,
                    style: TextStyle(
                      fontSize: 16,
                      decoration: todo.completed ? TextDecoration.lineThrough : null,
                      color: todo.completed ? Colors.grey : Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _deleteTodo(todo.id),
                  icon: Icon(Icons.delete, color: Colors.red, size: 20),
                  constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  tooltip: '삭제하기',
                ),
              ],
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flag, size: 14, color: priorityColor),
                    SizedBox(width: 4),
                    Text(
                      priorityText,
                      style: TextStyle(
                        fontSize: 12,
                        color: priorityColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
                    SizedBox(width: 4),
                    Text(
                      DateFormat('MM-dd HH:mm').format(todo.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                if (todo.isShared)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.group, size: 14, color: Colors.orange[600]),
                      SizedBox(width: 4),
                      Text(
                        '공유됨',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    String emoji;

    switch (_currentFilter) {
      case FilterType.personal:
        message = '개인 할일이 없습니다.\n새로운 할일을 추가해보세요!';
        emoji = '📝';
        break;
      case FilterType.shared:
        message = '공유된 할일이 없습니다.\n팀원과 할일을 공유해보세요!';
        emoji = '👥';
        break;
      case FilterType.completed:
        message = '완료된 할일이 없습니다.\n할일을 완료해보세요!';
        emoji = '🎉';
        break;
      default:
        message = '할일이 없습니다.\n새로운 할일을 추가해보세요!';
        emoji = '📋';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: TextStyle(fontSize: 80)),
          SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _showAddTodoDialog,
            icon: Icon(Icons.add),
            label: Text('첫 할일 추가하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(List<SimpleTodo> todos) {
    if (todos.isEmpty) return Container();

    int completedCount = todos.where((t) => t.completed).length;
    double progress = completedCount / todos.length;

    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '진행률',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '${(progress * 100).round()}% ($completedCount/${todos.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: progress == 1.0 ? Colors.green : Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? Colors.green : Colors.blue,
              ),
              minHeight: 8,
            ),
          ),
          if (progress == 1.0) ...[
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.celebration, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text(
                  '모든 할일을 완료했습니다! 🎉',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}