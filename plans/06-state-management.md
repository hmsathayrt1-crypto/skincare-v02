# 06 - تفعيل إدارة الحالة (Riverpod State Management)

## المشكلة الحالية

- `flutter_riverpod` مُستورد في `pubspec.yaml` لكنه **غير مستخدم أبداً**
- `main.dart` لا يستخدم `ProviderScope`
- لا يوجد أي Provider في المشروع
- كل البيانات محلية داخل كل widget (لا مشاركة بين الشاشات)
- بيانات المستخدم تضيع عند الانتقال بين الشاشات

---

## الإصلاحات المطلوبة

### 1. تفعيل ProviderScope في main.dart

```dart
void main() {
  runApp(
    const ProviderScope(
      child: DermalyzeApp(),
    ),
  );
}
```

### 2. إنشاء Auth Provider

**الملف الجديد:** `lib/core/providers/auth_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// حالة المصادقة
class AuthState {
  final UserModel? user;
  final String? token;
  final bool isLoading;
  final String? error;
  
  AuthState({this.user, this.token, this.isLoading = false, this.error});
  
  AuthState copyWith({UserModel? user, String? token, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
  
  bool get isAuthenticated => token != null && user != null;
}

// Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  
  AuthNotifier(this._authService) : super(AuthState());
  
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authService.login(email, password);
      if (result['success'] == true) {
        state = AuthState(
          user: UserModel.fromJson(result['user']),
          token: result['token'],
        );
        return true;
      }
      state = state.copyWith(isLoading: false, error: result['message']);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
  
  Future<bool> register({...}) async { /* مشابه */ }
  
  Future<void> logout() async {
    await _authService.logout();
    state = AuthState();
  }
  
  Future<void> loadFromStorage() async {
    // تحميل التوكن والمستخدم من SharedPreferences عند بدء التطبيق
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthService());
});
```

### 3. إنشاء Scan Provider

**الملف الجديد:** `lib/core/providers/scan_provider.dart`

```dart
// الفحص الحالي (نتيجة آخر تحليل)
final currentScanProvider = StateProvider<ScanModel?>((ref) => null);

// سجل الفحوصات
final scanHistoryProvider = FutureProvider<List<ScanModel>>((ref) async {
  final scanService = ScanService();
  return await scanService.getHistory();
});

// حالة التحليل (loading أثناء رفع الصورة)
final isAnalyzingProvider = StateProvider<bool>((ref) => false);
```

### 4. إنشاء Chat Provider

**الملف الجديد:** `lib/core/providers/chat_provider.dart`

```dart
final chatMessagesProvider = StateNotifierProvider<ChatNotifier, List<ChatMessageModel>>((ref) {
  return ChatNotifier(ChatService());
});

class ChatNotifier extends StateNotifier<List<ChatMessageModel>> {
  final ChatService _chatService;
  
  ChatNotifier(this._chatService) : super([]);
  
  Future<void> loadHistory() async {
    final messages = await _chatService.getHistory();
    state = messages;
  }
  
  Future<void> sendMessage(String text, {int? scanId}) async {
    // إضافة رسالة المستخدم محلياً
    state = [...state, ChatMessageModel(role: 'user', message: text, ...)];
    
    // إرسال للباك إند واستقبال الرد
    final reply = await _chatService.sendMessage(text, scanId: scanId);
    state = [...state, reply];
  }
}
```

### 5. إنشاء Profile Provider

```dart
final profileProvider = FutureProvider<UserModel>((ref) async {
  final profileService = ProfileService();
  return await profileService.getProfile();
});
```

---

## كيفية الاستخدام في الشاشات

### في شاشة الدخول:
```dart
class LoginScreen extends ConsumerStatefulWidget { ... }

class _LoginScreenState extends ConsumerState<LoginScreen> {
  void _handleLogin() async {
    final success = await ref.read(authProvider.notifier).login(
      _emailController.text,
      _passwordController.text,
    );
    if (success && mounted) context.go('/camera');
  }
}
```

### في شاشة الكاميرا:
```dart
final isAnalyzing = ref.watch(isAnalyzingProvider);
```

### في شاشة السجل:
```dart
final scansAsync = ref.watch(scanHistoryProvider);

scansAsync.when(
  data: (scans) => _buildTimeline(scans),
  loading: () => const CircularProgressIndicator(),
  error: (err, _) => Text('خطأ: $err'),
);
```

---

## هيكل المجلدات الجديدة

```
lib/core/
├── providers/
│   ├── auth_provider.dart
│   ├── scan_provider.dart
│   ├── chat_provider.dart
│   └── profile_provider.dart
├── services/
│   ├── auth_service.dart
│   ├── scan_service.dart
│   ├── chat_service.dart
│   └── profile_service.dart
├── models/
│   ├── user_model.dart
│   ├── scan_model.dart
│   └── chat_message_model.dart
```

---

## ملاحظة للتنفيذ

بما أن هذا مشروع تخرج — يمكن استخدام Riverpod بشكل بسيط:
- `StateProvider` للقيم البسيطة
- `FutureProvider` لجلب البيانات
- `StateNotifierProvider` للمنطق المعقد

لا تحتاج `riverpod_generator` أو `code_gen` — استخدم Riverpod العادي.
