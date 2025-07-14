import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final String currentUserEmail;

  const TodoItem({
    Key? key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.onShare,
    required this.currentUserEmail,
  }) : super(key: key);

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      case 'low': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'high': return '🔴 높음';
      case 'medium': return '🟡 보통';
      case 'low': return '🟢 낮음';
      default: return '보통';
    }
  }

  bool get _isOwner => todo.userId == currentUserEmail || todo.createdBy == currentUserEmail;
  bool get _isShared => todo.isShared || todo.sharedWith.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _getPriorityColor(todo.priority).withOpacity(0.3),
          width: 2,
        ),
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
            // 메인 컨텐츠
            Row(
              children: [
                // 완료 체크박스
                GestureDetector(
                  onTap: onToggle,
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

                // 할일 텍스트
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

                // 액션 버튼들
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_isShared && _isOwner)
                      IconButton(
                        onPressed: onShare,
                        icon: Icon(Icons.share, color: Colors.blue, size: 20),
                        constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                        tooltip: '공유하기',
                      ),

                    if (_isOwner)
                      IconButton(
                        onPressed: onDelete,
                        icon: Icon(Icons.delete, color: Colors.red, size: 20),
                        constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                        tooltip: '삭제하기',
                      ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 12),

            // 메타 정보
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                // 우선순위
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flag, size: 14, color: _getPriorityColor(todo.priority)),
                    SizedBox(width: 4),
                    Text(
                      _getPriorityText(todo.priority),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getPriorityColor(todo.priority),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // 생성 시간
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

                // 작성자 (공유된 경우만)
                if (_isShared && todo.createdBy != currentUserEmail)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person, size: 14, color: Colors.blue[600]),
                      SizedBox(width: 4),
                      Text(
                        todo.createdBy,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                // 공유 표시
                if (_isShared)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.group, size: 14, color: Colors.orange[600]),
                      SizedBox(width: 4),
                      Text(
                        '공유됨 (${todo.sharedWith.length + 1}명)',
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
}