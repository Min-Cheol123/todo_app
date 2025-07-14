import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AddTodoDialog extends StatefulWidget {
  final Function(String text, String priority, List<String> sharedEmails) onAdd;

  const AddTodoDialog({Key? key, required this.onAdd}) : super(key: key);

  @override
  _AddTodoDialogState createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedPriority = 'medium';
  List<String> _sharedEmails = [];
  bool _isLoading = false;

  void _addEmail() {
    String email = _emailController.text.trim().toLowerCase();
    String currentEmail = AuthService().currentUser?.email?.toLowerCase() ?? '';

    if (email.isNotEmpty &&
        email.contains('@') &&
        !_sharedEmails.contains(email) &&
        email != currentEmail) {
      setState(() {
        _sharedEmails.add(email);
        _emailController.clear();
      });
    } else if (email == currentEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('자신의 이메일은 추가할 수 없습니다')),
      );
    }
  }

  void _removeEmail(String email) {
    setState(() {
      _sharedEmails.remove(email);
    });
  }

  Future<void> _addTodo() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('할일 내용을 입력해주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.onAdd(_textController.text.trim(), _selectedPriority, _sharedEmails);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('할일이 추가되었습니다'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('할일 추가 실패: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(24),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Row(
                children: [
                  Icon(Icons.add_task, color: Colors.blue, size: 28),
                  SizedBox(width: 12),
                  Text(
                    '새 할일 추가',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // 할일 입력
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: '할일을 입력하세요',
                  hintText: '예: 프로젝트 보고서 작성하기',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: Icon(Icons.edit),
                ),
                maxLines: 2,
                autofocus: true,
              ),

              SizedBox(height: 16),

              // 우선순위 선택
              Text(
                '우선순위',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildPriorityChip('high', '🔴 높음'),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildPriorityChip('medium', '🟡 보통'),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildPriorityChip('low', '🟢 낮음'),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // 공유 설정
              Row(
                children: [
                  Icon(Icons.group, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '공유 설정 (선택)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: '이메일 주소 입력',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onSubmitted: (_) => _addEmail(),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addEmail,
                    child: Text('추가'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),

              // 추가된 이메일 목록
              if (_sharedEmails.isNotEmpty) ...[
                SizedBox(height: 12),
                Container(
                  constraints: BoxConstraints(maxHeight: 120),
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _sharedEmails.map((email) => Chip(
                        label: Text(email, style: TextStyle(fontSize: 12)),
                        onDeleted: () => _removeEmail(email),
                        deleteIconColor: Colors.red,
                        backgroundColor: Colors.blue[50],
                        side: BorderSide(color: Colors.blue[200]!),
                      )).toList(),
                    ),
                  ),
                ),
              ],

              SizedBox(height: 24),

              // 버튼들
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('취소'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addTodo,
                      child: _isLoading
                          ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 18),
                          SizedBox(width: 4),
                          Text('추가'),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String priority, String label) {
    bool isSelected = _selectedPriority == priority;
    return GestureDetector(
      onTap: () => setState(() => _selectedPriority = priority),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.blue[700] : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}