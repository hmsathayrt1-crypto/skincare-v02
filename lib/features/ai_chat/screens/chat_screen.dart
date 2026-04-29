import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildGlassAppBar(context),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. الخلفية مع التوهج
          Container(
            decoration: const BoxDecoration(
              color: AppTheme.background,
              gradient: RadialGradient(
                colors: [Color(0x66FADADD), Colors.transparent],
                center: Alignment(-1, -1),
                radius: 1.0,
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0x66D2E9CA), Colors.transparent],
                  center: Alignment(1, 1),
                  radius: 1.0,
                ),
              ),
            ),
          ),

          // 2. المحتوى (قائمة الرسائل وشريط الإدخال)
          Column(
            children: [
              // قائمة الرسائل
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 100, 16, 120), // مسافات علوية وسفلية للـ AppBar وشريط الإدخال
                  children: [
                    _buildDateDivider("اليوم"),
                    const SizedBox(height: 24),
                    _AiMessage(text: "مرحباً! أنا مساعدك الذكي للعناية بالبشرة. بناءً على تحليلك الأخير، يبدو أن بشرتك تميل إلى الجفاف اليوم. كيف تشعرين بها؟"),
                    const SizedBox(height: 24),
                    _UserMessage(text: "نعم، أشعر ببعض الشد في منطقة الخدين بعد الاستيقاظ."),
                    const SizedBox(height: 24),
                    _AiMessageWithButtons(
                      text: "هذا طبيعي جداً في مثل هذا الطقس. أوصي بزيادة الترطيب في روتينك الصباحي. هل ترغبين في رؤية بعض التوصيات لمنتجات الترطيب العميق؟",
                    ),
                    const SizedBox(height: 24),
                    _UserImageMessage(
                      imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuALkKj3rTq2C_GY0bc7pVF0cFLLbVKieoBZQo8Js0ydncB15MpbaHz0YLgwKl5poZndCZVmruJR2slWubLvqiRjFLwqu6YgysE0TByquBmCf3uHQiAH8ipHYteAoDdKlRLjDoMHlbux0ogdZZJV5zVO5Q-NnoVrKmWkkdSjpPhX9cVW5MZdyV9Q6JefWwkMPPNXOkpZ9Ug8foVdIerUx03iqIVtX8DiIlxbP-DQ_xvau5KfBwfou5dXec5bSskyE9ljQUz1D5nMjio",
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 3. شريط الإدخال (ثابت في الأسفل)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildInputBar(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildGlassAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AppBar(
            backgroundColor: Colors.white.withOpacity(0.7),
            elevation: 0,
            leadingWidth: 0,
            title: Row(
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: CachedNetworkImageProvider("https://lh3.googleusercontent.com/aida-public/AB6AXuDXVIinq1gOZl3hFIR2B1bu741Zk--rqudqErkNtrREjDixZFwIPxMEO3A-vv5lHocoJKRKBX4GOEtWJ76G_BAbijTAWVKLmFUm2PJoVL092t2s7ytyonAaLE0yOWtT6oTvNrlxWrB_U_UwzNljHLtHo6BwYObOSt_mYah_nZ-Qf_aR6jp3Zx3cPYqXfcuI-kCqdKahF1vyOb5bjmGzObLOjzyi8vSBYt6Ewn9eK-rxm68NA5DQIwiQ95-6fO5qrluS3bFEItwAz4E"),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD2E9CA), // secondary-fixed
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("مساعد البشرة الذكي", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                    Text("متصل الآن", style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateDivider(String text) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFEAE7E7).withOpacity(0.5), // surface-container-high/50
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.black54)),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.background.withOpacity(0.0), AppTheme.background],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.add_photo_alternate_outlined, color: Colors.black54)),
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration.collapsed(
                      hintText: "اسألي مساعدك الذكي...",
                      hintStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45),
                    ),
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.mic_none, color: Colors.black54)),
                Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [AppTheme.pinkGlow, AppTheme.greenGlow]),
                  ),
                  child: IconButton(onPressed: () {}, icon: const Icon(Icons.send, color: Colors.black, size: 20)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget مخصص لرسائل الـ AI
class _AiMessage extends StatelessWidget {
  final String text;
  const _AiMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 16,
          backgroundImage: CachedNetworkImageProvider("https://lh3.googleusercontent.com/aida-public/AB6AXuArdyeAEfVRQACREvHmkm1K1Fox494SzieLxVOlBKj7i7XVnOsN-youbji--VMnQDBToEkfaMJxADY9BTP2tTVYIkwjdWPZ1nqHZZGMZgnrds9n5GrYsFQheqjsKcolqcTkAhBVh0fkS2YPuf4YuCWx4WTHfkx9eB4AgjCYRSZ1BBpdy14YToUSb_eyRp_2oc-phXDGGSxQqOdYtbQiZvNQimX5dpTmopWueBZp7TXi5QRG_SZ_VlR3Izdm9mMPbKQwM3cHJs-s4oY"),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
              topRight: Radius.circular(4), // زاوية حادة
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0x99CFE6C7), // secondary-container/60
                child: Text(text, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Widget مخصص لرسائل المستخدم
class _UserMessage extends StatelessWidget {
  final String text;
  const _UserMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4), // زاوية حادة
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0x99FADADD), // primary-container/60
                child: Text(text, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 16,
          backgroundColor: Color(0xFFEAE7E7),
          child: Icon(Icons.person, size: 20, color: Colors.black54),
        ),
      ],
    );
  }
}

// Widget مخصص لرسالة الـ AI التي تحتوي على أزرار
class _AiMessageWithButtons extends StatelessWidget {
  final String text;
  const _AiMessageWithButtons({required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AiMessage(text: text),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(right: 48.0), // محاذاة مع رسالة الـ AI
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0x334F644B), // secondary/20
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                child: const Text("عرض التوصيات", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black26),
                  shape: const StadiumBorder(),
                ),
                child: const Text("تخطي الآن", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        )
      ],
    );
  }
}

// Widget مخصص لرسالة المستخدم التي تحتوي على صورة
class _UserImageMessage extends StatelessWidget {
  final String imageUrl;
  const _UserImageMessage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              color: const Color(0x66FADADD), // primary-container/40
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 192, // w-48
                  height: 192, // h-48
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 16,
          backgroundColor: Color(0xFFEAE7E7),
          child: Icon(Icons.person, size: 20, color: Colors.black54),
        ),
      ],
    );
  }
}