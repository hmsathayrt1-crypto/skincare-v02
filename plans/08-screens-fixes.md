# 08 - إصلاح كل شاشة (تفاصيل دقيقة)

## شاشة 1: WelcomeScreen

**الملف:** `lib/features/onboarding/screens/welcome_screen.dart`

| # | المشكلة | السطر | الإصلاح |
|---|---------|-------|---------|
| 1 | زر "ابدأ الفحص" يذهب لـ /camera بدون login | - | تغيير إلى `/login` |
| 2 | لا يوجد تحقق هل المستخدم مسجل دخول | - | Auth Guard في Router يتكفل |

---

## شاشة 2: LoginScreen

**الملف:** `lib/features/auth/screens/login_screen.dart`

| # | المشكلة | السطر | الإصلاح |
|---|---------|-------|---------|
| 1 | لا يوجد TextEditingController للحقول | - | إضافة controllers |
| 2 | زر الدخول يذهب لـ /camera بدون API call | 235 | ربط بـ AuthService.login() |
| 3 | "نسيت كلمة المرور" يعرض SnackBar فقط | 99 | يبقى كما هو (مشروع تخرج) |
| 4 | لا يوجد form validation | - | إضافة validators |
| 5 | لا يوجد مؤشر تحميل | - | إضافة CircularProgressIndicator |
| 6 | لا يوجد رسائل خطأ من السيرفر | - | عرض response.data['message'] |

---

## شاشة 3: RegisterScreen

**الملف:** `lib/features/auth/screens/register_screen.dart`

| # | المشكلة | السطر | الإصلاح |
|---|---------|-------|---------|
| 1 | لا يوجد TextEditingController | - | إضافة controllers |
| 2 | زر التسجيل يذهب لـ /camera بدون API | 341 | ربط بـ AuthService.register() |
| 3 | شريط قوة كلمة المرور ثابت (33%) | 269 | ربط بـ onChanged |
| 4 | لا تحقق من تطابق كلمتي المرور | - | إضافة validation |
| 5 | الأزرار الاجتماعية تعرض SnackBar | 378 | يبقى (مشروع تخرج) |
| 6 | لا يوجد form validation | - | إضافة validators |
| 7 | لا يوجد مؤشر تحميل | - | إضافة loading |
| 8 | حقل الهاتف موجود لكن لا يُرسل للباك | - | إضافة phone في register API |

---

## شاشة 4: CameraScreen

**الملف:** `lib/features/skin_analysis/screens/camera_screen.dart`

| # | المشكلة | السطر | الإصلاح |
|---|---------|-------|---------|
| 1 | بيانات الطقس ثابتة (24°, 45%, UV:6) | 234 | حذف أو عرض الموقع فقط (الطقس يأتي مع النتيجة) |
| 2 | إحداثيات ثابتة (34.05,-118 = LA!) | 240 | ربط بـ LocationService |
| 3 | الصورة تُلتقط لكن لا تُرسل | 71 | ربط بـ ScanService |
| 4 | لا شاشة تحميل أثناء التحليل | - | إضافة overlay loading |
| 5 | زر القائمة يعرض SnackBar | 189 | حذف أو تحويل لزر رجوع |
| 6 | أيقونة الشخص في AppBar لا تعمل | 201 | حذف أو ربط بـ /profile |
| 7 | خط المسح الأخضر يتحرك مرة واحدة فقط | 274 | TweenAnimationBuilder لا يتكرر — استخدام AnimationController مع repeat() |

**إصلاح خط المسح المتحرك:**
```dart
// التحويل من TweenAnimationBuilder (يعمل مرة واحدة)
// إلى AnimationController.repeat() (يتكرر باستمرار)

late AnimationController _scanLineController;

@override
void initState() {
  super.initState();
  _scanLineController = AnimationController(
    vsync: this, // يحتاج TickerProviderStateMixin
    duration: const Duration(seconds: 2),
  )..repeat();
}

// في الـ build:
AnimatedBuilder(
  animation: _scanLineController,
  builder: (context, child) {
    return Positioned(
      top: _scanLineController.value * frameHeight,
      // ...
    );
  },
),
```
**ملاحظة:** يحتاج تغيير الـ mixin من `WidgetsBindingObserver` إلى `WidgetsBindingObserver, TickerProviderStateMixin`

---

## شاشة 5: AnalysisResultScreen

**الملف:** `lib/features/skin_analysis/screens/analysis_result_screen.dart`

| # | المشكلة | السطر | الإصلاح |
|---|---------|-------|---------|
| 1 | كل البيانات ثابتة (hardcoded) | كامل | استقبال ScanModel وعرض بياناته |
| 2 | الحالة ثابتة "التهاب الجلد التماسي" | 280 | عرض `scanResult.condition` |
| 3 | نسبة الثقة ثابتة 85% | 452-456 | عرض `scanResult.confidence * 100` |
| 4 | الاستشارة ثابتة | 380-382 | عرض `scanResult.consultation` |
| 5 | مؤشرات الاحمرار/الجفاف ثابتة | 290-292 | يمكن حذفها أو إبقاءها كديكور |
| 6 | صورة ثابتة من Google | 242 | عرض الصورة المحلية الملتقطة |
| 7 | "استشارة خبير" يعرض SnackBar | 487 | ربط بـ `/chat` مع سياق الفحص |
| 8 | صورة الأفاتار في AppBar ثابتة | 172 | عرض صورة المستخدم الحقيقية |
| 9 | بيانات الطقس غير معروضة | - | إضافة قسم يعرض الحرارة والرطوبة |

---

## شاشة 6: ChatScreen

**الملف:** `lib/features/ai_chat/screens/chat_screen.dart`

| # | المشكلة | السطر | الإصلاح |
|---|---------|-------|---------|
| 1 | المحادثة وهمية (hardcoded messages) | 46-58 | جلب من chat_messages API |
| 2 | زر الإرسال لا يعمل (SnackBar) | 207 | ربط بـ ChatService.sendMessage() |
| 3 | TextField ثابت (const) — لا يمكن الكتابة | 181 | إزالة const + إضافة controller |
| 4 | رفع صورة لا يعمل (SnackBar) | 174 | يمكن تأجيله |
| 5 | الإدخال الصوتي لا يعمل (SnackBar) | 190 | يمكن تأجيله |
| 6 | خيارات إضافية لا تعمل (SnackBar) | 123 | يمكن حذفها |
| 7 | أزرار "عرض التوصيات" و"تخطي" لا تعمل | 319,332 | ربط بمنطق المحادثة |
| 8 | الشاشة StatelessWidget | 7 | تحويل إلى ConsumerStatefulWidget |
| 9 | صور الأفاتار ثابتة من URLs خارجية | 236,93 | استخدام صور محلية |

**الإصلاح الرئيسي:**
```dart
class ChatScreen extends ConsumerStatefulWidget { ... }

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  
  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    _messageController.clear();
    await ref.read(chatMessagesProvider.notifier).sendMessage(text);
  }
}
```

---

## شاشة 7: HistoryScreen

**الملف:** `lib/features/history/screens/history_screen.dart`

| # | المشكلة | السطر | الإصلاح |
|---|---------|-------|---------|
| 1 | 3 نتائج ثابتة (hardcoded) | 58-86 | جلب من scans API |
| 2 | فلاتر لا تعمل (SnackBar) | 182 | ربط بفلترة حقيقية |
| 3 | بطاقات النتائج غير قابلة للنقر | - | إضافة onTap → /analysis?id=X |
| 4 | زر التصفية في AppBar لا يعمل | 145 | يمكن حذفه |
| 5 | الشاشة StatelessWidget | 35 | تحويل إلى ConsumerWidget |
| 6 | لا يوجد حالة "لا توجد نتائج" | - | إضافة EmptyState widget |
| 7 | لا يوجد loading state | - | إضافة مؤشر تحميل |
| 8 | صور النتائج من URLs خارجية | 65,74,83 | عرض صور الفحوصات الحقيقية |

**إضافة onTap للبطاقات:**
```dart
GestureDetector(
  onTap: () => context.push('/analysis', extra: scanModel),
  child: _buildResultCard(result),
),
```

**إضافة EmptyState:**
```dart
if (scans.isEmpty)
  Center(
    child: Column(
      children: [
        Icon(Icons.history, size: 64, color: Colors.grey),
        Text("لا توجد فحوصات سابقة"),
        Text("ابدأ بالتقاط صورة لبشرتك"),
      ],
    ),
  ),
```

---

## شاشة 8: ProfileScreen

**الملف:** `lib/features/profile/screens/profile_screen.dart`

| # | المشكلة | السطر | الإصلاح |
|---|---------|-------|---------|
| 1 | الاسم والإيميل ثابتان "سارة أحمد" | 112-113 | جلب من profile API |
| 2 | الصورة ثابتة من URL خارجي | 107 | عرض صورة المستخدم الحقيقية |
| 3 | حقول الإدخال ثابتة (initialValue) | 144-148 | ربط بـ controllers + بيانات API |
| 4 | زر "حفظ التغييرات" يعرض SnackBar | 235 | ربط بـ ProfileService.update() |
| 5 | نوع البشرة لا يُحفظ | 196 | إرسال skin_type مع profile update |
| 6 | لا يوجد زر تسجيل خروج | - | إضافة زر logout |
| 7 | زر القائمة والإعدادات لا يعملان | 64,76 | حذف أو إبقاء |
| 8 | لا يوجد loading state | - | إضافة مؤشر تحميل |

**إضافة زر تسجيل الخروج:**
```dart
// بعد زر "حفظ التغييرات"
const SizedBox(height: 16),
TextButton(
  onPressed: () async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) context.go('/login');
  },
  child: const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.logout, color: Colors.red),
      SizedBox(width: 8),
      Text("تسجيل الخروج", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
    ],
  ),
),
```

---

## ملخص عدد الإصلاحات لكل شاشة

| الشاشة | عدد المشاكل | عاجلة | متوسطة | يمكن تأجيلها |
|--------|-------------|-------|--------|--------------|
| Welcome | 2 | 1 | 0 | 1 |
| Login | 6 | 4 | 1 | 1 |
| Register | 8 | 4 | 2 | 2 |
| Camera | 7 | 4 | 2 | 1 |
| Analysis | 9 | 5 | 2 | 2 |
| Chat | 9 | 3 | 2 | 4 |
| History | 8 | 4 | 2 | 2 |
| Profile | 8 | 4 | 2 | 2 |
| **المجموع** | **57** | **29** | **13** | **15** |
