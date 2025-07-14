import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/auth_service.dart';

class ShareTodoDialog extends StatefulWidget {
  final Todo todo;
  final Function(List<String> emails) onShare;

  const ShareTodoDialog({
    Key? key,
    required this.todo,
    required this.onShare,
  }) : super(key: key);

  @override
  _ShareTodoDialogState createState() => _ShareTodoDialogState();
}

class _ShareTodoDialogState extends State<ShareTodoDialog> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  List<String> _sharedEmails = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sharedEmails = List.from(widget.todo.sharedWith);
  }

  void _addEmail() {
    String email = _emailController.text.trim().toLowerCase();
    String currentEmail = _authService.currentUser?.email?.toLowerCase() ?? '';

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
    } else if (_sharedEmails.contains(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미 추가된 이메일입니다')),
      );
    }
  }

  void _removeEmail(String email) {
    setState(() {
      _sharedEmails.remove(email);
    });
  }

  Future<void> _saveSharing() async {
    setState(() => _isLoading = true);

    try {
      await widget.onShare(_sharedEmails);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _sharedEmails.isEmpty ? '공유가 해제되었습니다' : '공유 설정이 완료되었습니다'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('공유 설정 실패: $e')),
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
        constraints: BoxConstraints(maxHeight: MediaQuery
            .of(context)
            .size
            .height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Row(
              children: [
                Icon(Icons.share, color: Colors.blue, size: 28),
                SizedBox(width: 12),
                Text(
                  '할일 공유',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            // 할일 내용 표시
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.task_alt, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.todo.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // 설명
            Text(
              '공유할 사용자의 이메일을 입력하세요',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),

            // 이메일 입력
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: '이메일 주소',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),

            // 공유된 사용자 목록
            if (_sharedEmails.isNotEmpty) ...[
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.group, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '공유된 사용자 (${_sharedEmails.length}명)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _sharedEmails.map((email) =>
                          Chip(
                            avatar: CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              child: Icon(Icons.person, size: 16,
                                  color: Colors.blue[700]),
                            ),
                            label: Text(email, style: TextStyle(fontSize: 12)),
                            onDeleted: () => _removeEmail(email),
                            deleteIconColor: Colors.red,
                            backgroundColor: Colors.blue[50],
                            side: BorderSide(color: Colors.blue[200]!),
                          )).toList(),
                    ),
                  ),
                ),
              ),
            ] else
              ...[
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey[500]),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '아직 공유된 사용자가 없습니다',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
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
                    onPressed: _isLoading ? null : _saveSharing,
                    child: _isLoading
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save, size: 18),
                        SizedBox(width: 4),
                        Text('저장'),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}