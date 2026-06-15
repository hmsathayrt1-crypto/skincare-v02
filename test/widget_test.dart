import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skincare_v02/main.dart';

void main() {
  testWidgets('Welcome screen renders correctly', (WidgetTester tester) async {
    // بناء التطبيق مع ProviderScope
    await tester.pumpWidget(const ProviderScope(child: DermalyzeApp()));

    // انتظار تحميل الصورة من الإنترنت
    await tester.pumpAndSettle();

    // التحقق من ظهور عنوان الترحيب
    expect(find.text('رؤية أعمق.. لبشرة أفضل'), findsOneWidget);

    // التحقق من وجود زر "ابدأ الفحص الآمن"
    expect(find.text('ابدأ الفحص الآمن'), findsOneWidget);

    // التحقق من وجود رابط "تسجيل الدخول"
    expect(find.text('تسجيل الدخول'), findsOneWidget);
  });
}
