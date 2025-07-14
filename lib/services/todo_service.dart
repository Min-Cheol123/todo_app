import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo.dart';
import 'auth_service.dart';

class TodoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  String get _userId => _authService.currentUser?.uid ?? '';
  String get _userEmail => _authService.currentUser?.email ?? '';

  // 할일 추가
  Future<void> addTodo({
    required String text,
    required String priority,
    String? category,
    List<String> sharedWith = const [],
  }) async {
    if (text.trim().isEmpty) return;

    final todo = Todo(
      id: '',
      text: text.trim(),
      priority: priority,
      createdAt: DateTime.now(),
      userId: _userId,
      createdBy: _userEmail,
      sharedWith: sharedWith,
      isShared: sharedWith.isNotEmpty,
      category: category,
    );

    await _firestore.collection('todos').add(todo.toFirestore());
  }

  // 할일 업데이트
  Future<void> updateTodo(String id, {bool? completed, String? text}) async {
    Map<String, dynamic> updates = {};
    if (completed != null) updates['completed'] = completed;
    if (text != null) updates['text'] = text;

    if (updates.isNotEmpty) {
      await _firestore.collection('todos').doc(id).update(updates);
    }
  }

  // 할일 삭제
  Future<void> deleteTodo(String id) async {
    await _firestore.collection('todos').doc(id).delete();
  }

  // 할일 공유
  Future<void> shareTodo(String todoId, List<String> userEmails) async {
    await _firestore.collection('todos').doc(todoId).update({
      'sharedWith': userEmails,
      'isShared': userEmails.isNotEmpty,
    });
  }

  // 내 할일 스트림 (개인 + 공유받은 것)
  Stream<List<Todo>> getMyTodos() {
    return _firestore
        .collection('todos')
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Todo.fromFirestore(doc)).toList());
  }

  // 공유받은 할일 스트림
  Stream<List<Todo>> getSharedTodos() {
    return _firestore
        .collection('todos')
        .where('sharedWith', arrayContains: _userEmail)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Todo.fromFirestore(doc)).toList());
  }

  // 모든 할일 스트림 (개인 + 공유)
  Stream<List<Todo>> getAllTodos() {
    return _firestore
        .collection('todos')
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((mySnapshot) async {
      final myTodos = mySnapshot.docs.map((doc) => Todo.fromFirestore(doc)).toList();

      final sharedSnapshot = await _firestore
          .collection('todos')
          .where('sharedWith', arrayContains: _userEmail)
          .get();

      final sharedTodos = sharedSnapshot.docs.map((doc) => Todo.fromFirestore(doc)).toList();

      final allTodos = [...myTodos, ...sharedTodos];
      allTodos.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return allTodos;
    });
  }
}