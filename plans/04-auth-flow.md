# 04 - إصلاح تدفق المصادقة (Authentication Flow)

## المشكلة الحالية

1. **تسجيل الدخول لا يعمل** — الزر يوجه مباشرة لـ `/camera` بدون أي API call:
   ```dart
   // login_screen.dart سطر 235
   onTap: () {
     context.go('/camera'); // يتخطى المصادقة تماماً!
   },
   ```

2. **إنشاء حساب لا يعمل** — نفس المشكلة:
   ```dart
   // register_screen.dart سطر 341
   onTap: () {
     context.go('/camera'); // يتخطى التسجيل تماماً!
   },
   ```

3. **لا يوجد TextEditingController** — الحقول لا تحفظ القيم المدخلة

4. **لا يوجد form validation** — لا تحقق من الإيميل أو كلمة المرور

5. **لا يوجد تخزين للتوكن** — بعد تسجيل الدخول يُفقد التوكن

6. **لا يوجد auth guard** — يمكن الوصول لأي شاشة بدون تسجيل دخول

---

## الإصلاحات المطلوبة

### 1. إضافة TextEditingControllers لشاشة الدخول

**الملف:** `lib/features/auth/screens/login_screen.dart`

```dart
class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
```

### 2. إضافة TextEditingControllers لشاشة التسجيل

**الملف:** `lib/features/auth/screens/register_screen.dart`

```dart
final _nameController = TextEditingController();
final _emailController = TextEditingController();
final _phoneController = TextEditingController();
final _passwordController = TextEditingController();
final _confirmPasswordController = TextEditingController();
final _formKey = GlobalKey<FormState>();
bool _isLoading = false;
```

### 3. ربط حقول الإدخال بالـ Controllers

في `_buildTextField`:
```dart
Widget _buildTextField({
  required String label,
  required TextInputType keyboardType,
  required bool isPassword,
  required TextEditingController controller, // إضافة
}) {
  return TextFormField(
    controller: controller,
    validator: (value) {
      if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
      if (keyboardType == TextInputType.emailAddress && !value.contains('@')) {
        return 'بريد إلكتروني غير صالح';
      }
      return null;
    },
    // ...
  );
}
```

### 4. إنشاء AuthService

**الملف الجديد:** `lib/core/services/auth_service.dart`

```dart
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../constants/api_endpoints.dart';

class AuthService {
  final _client = DioClient();
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _client.post(
      ApiEndpoints.authLogin,
      data: {'email': email, 'password': password},
    );
    
    if (response.data['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', response.data['token']);
      await prefs.setString('user_data', jsonEncode(response.data['user']));
    }
    
    return response.data;
  }
  
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? skinType,
  }) async {
    final response = await _client.post(
      ApiEndpoints.authRegister,
      data: {
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'skin_type': skinType,
      },
    );
    
    if (response.data['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', response.data['token']);
      await prefs.setString('user_data', jsonEncode(response.data['user']));
    }
    
    return response.data;
  }
  
  Future<void> logout() async {
    try {
      await _client.post(ApiEndpoints.authLogout);
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
    }
  }
  
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }
}
```

### 5. تحديث دالة تسجيل الدخول

**الملف:** `login_screen.dart` — تغيير `onTap` لزر الدخول:

```dart
onTap: () async {
  if (!_formKey.currentState!.validate()) return;
  
  setState(() => _isLoading = true);
  
  try {
    final authService = AuthService();
    final result = await authService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    
    if (result['success'] == true && mounted) {
      context.go('/camera'); // بعد نجاح تسجيل الدخول فقط
    }
  } on DioException catch (e) {
    if (mounted) {
      final message = e.response?.data['message'] ?? 'فشل الاتصال بالسيرفر';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
},
```

### 6. تحديث دالة إنشاء الحساب

**الملف:** `register_screen.dart` — تغيير `onTap` لزر التسجيل:

```dart
onTap: () async {
  if (!_formKey.currentState!.validate()) return;
  if (!_acceptedTerms) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('يجب الموافقة على الشروط والأحكام')),
    );
    return;
  }
  if (_passwordController.text != _confirmPasswordController.text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('كلمتا المرور غير متطابقتين')),
    );
    return;
  }
  
  setState(() => _isLoading = true);
  
  try {
    final authService = AuthService();
    final result = await authService.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );
    
    if (result['success'] == true && mounted) {
      context.go('/camera');
    }
  } on DioException catch (e) {
    if (mounted) {
      final message = e.response?.data['message'] ?? 'فشل إنشاء الحساب';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
},
```

### 7. إضافة Auth Guard في Router

**الملف:** `lib/core/router/app_router.dart`

```dart
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.containsKey('auth_token');
    final isAuthRoute = state.matchedLocation == '/' 
        || state.matchedLocation == '/login' 
        || state.matchedLocation == '/register';
    
    if (!isLoggedIn && !isAuthRoute) {
      return '/login';
    }
    if (isLoggedIn && isAuthRoute) {
      return '/camera';
    }
    return null;
  },
  // ...
);
```

### 8. إضافة مؤشر التحميل (Loading)

عند الضغط على زر الدخول/التسجيل:
```dart
_isLoading
  ? const CircularProgressIndicator(color: Colors.white)
  : Text("دخول", ...)
```

---

## شريط قوة كلمة المرور (Password Strength)

**المشكلة:** الشريط ثابت على 33% (ضعيفة) ولا يتفاعل مع الإدخال.

**الإصلاح:**
```dart
double _passwordStrength = 0;
String _passwordStrengthText = '';

void _calculatePasswordStrength(String password) {
  double strength = 0;
  if (password.length >= 6) strength += 0.25;
  if (password.length >= 10) strength += 0.25;
  if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
  if (RegExp(r'[0-9!@#\$%^&*]').hasMatch(password)) strength += 0.25;
  
  setState(() {
    _passwordStrength = strength;
    _passwordStrengthText = strength <= 0.25 ? 'ضعيفة' 
        : strength <= 0.5 ? 'متوسطة' 
        : strength <= 0.75 ? 'جيدة' 
        : 'قوية';
  });
}
```

---

## ملخص الملفات المتأثرة

| الملف | التغيير |
|-------|---------|
| `login_screen.dart` | إضافة controllers, validation, API call |
| `register_screen.dart` | إضافة controllers, validation, API call, password strength |
| `api_endpoints.dart` | تحديث URLs |
| `app_router.dart` | إضافة auth redirect guard |
| **جديد:** `auth_service.dart` | إنشاء service للمصادقة |
| **جديد:** `user_model.dart` | إنشاء model للمستخدم |
