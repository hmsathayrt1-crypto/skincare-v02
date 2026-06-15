# 01 - تحسين وتوسيع قاعدة البيانات

## الوضع الحالي

3 جداول فقط: `users`, `api_tokens`, `scans`
- لا يوجد جدول للمحادثات
- لا يوجد جدول للمنتجات الموصى بها
- لا يوجد حقل هاتف في جدول المستخدمين
- لا يوجد تاريخ انتهاء للتوكنات
- لا يوجد فهرسة كافية

---

## التغييرات المطلوبة

### 1. تحسين جدول `users`

**إضافة حقول:**
```sql
ALTER TABLE users ADD COLUMN phone VARCHAR(20) NULL AFTER email;
ALTER TABLE users ADD COLUMN avatar_path VARCHAR(255) NULL AFTER skin_type;
ALTER TABLE users ADD COLUMN date_of_birth DATE NULL AFTER avatar_path;
ALTER TABLE users ADD COLUMN gender ENUM('male','female','other') NULL AFTER date_of_birth;
ALTER TABLE users ADD COLUMN updated_at DATETIME NULL ON UPDATE CURRENT_TIMESTAMP;
```

**السبب:**
- `phone`: شاشة التسجيل تطلب رقم الهاتف لكن لا يوجد حقل له في القاعدة
- `avatar_path`: لتخزين صورة المستخدم بدل الصورة الثابتة
- `date_of_birth` + `gender`: بيانات مهمة لتحسين دقة تحليل البشرة (عمر البشرة يختلف)
- `updated_at`: لتتبع آخر تحديث للبروفايل

---

### 2. تحسين جدول `api_tokens`

**إضافة حقل انتهاء الصلاحية:**
```sql
ALTER TABLE api_tokens ADD COLUMN expires_at DATETIME NULL AFTER created_at;
ALTER TABLE api_tokens ADD COLUMN device_name VARCHAR(100) NULL AFTER expires_at;
```

**السبب:**
- `expires_at`: التوكنات حالياً لا تنتهي أبداً — مشكلة أمنية
- `device_name`: لمعرفة من أي جهاز تم تسجيل الدخول

---

### 3. تحسين جدول `scans`

**إضافة حقول:**
```sql
ALTER TABLE scans ADD COLUMN city_name VARCHAR(100) NULL AFTER weather_description;
ALTER TABLE scans ADD COLUMN notes TEXT NULL AFTER nlp_consultation_text;
ALTER TABLE scans ADD COLUMN is_deleted TINYINT(1) DEFAULT 0 AFTER notes;
```

**السبب:**
- `city_name`: اسم المدينة (من OpenWeatherMap) لعرض أفضل
- `notes`: ملاحظات المستخدم الشخصية على الفحص
- `is_deleted`: حذف ناعم (soft delete) بدل حذف فعلي

---

### 4. جدول جديد: `chat_messages` (للمحادثة الذكية)

```sql
CREATE TABLE IF NOT EXISTS chat_messages (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  user_id       INT NOT NULL,
  scan_id       INT NULL,
  role          ENUM('user','assistant') NOT NULL,
  message       TEXT NOT NULL,
  image_path    VARCHAR(255) NULL,
  created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (scan_id) REFERENCES scans(id) ON DELETE SET NULL,
  INDEX idx_chat_user (user_id),
  INDEX idx_chat_scan (scan_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**السبب:** شاشة المحادثة الذكية تحتاج جدول لتخزين المحادثات

---

### 5. جدول جديد: `skin_tips` (نصائح يومية)

```sql
CREATE TABLE IF NOT EXISTS skin_tips (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  skin_type     VARCHAR(50) NULL,
  season        ENUM('summer','winter','spring','autumn') NULL,
  tip_text      TEXT NOT NULL,
  is_active     TINYINT(1) DEFAULT 1,
  created_at    DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**السبب:** لإثراء التطبيق بنصائح يومية حسب نوع البشرة والموسم

---

### 6. جدول جديد: `user_routines` (روتين العناية)

```sql
CREATE TABLE IF NOT EXISTS user_routines (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  user_id       INT NOT NULL,
  routine_type  ENUM('morning','evening') NOT NULL,
  step_order    INT NOT NULL,
  step_name     VARCHAR(150) NOT NULL,
  product_name  VARCHAR(200) NULL,
  is_completed  TINYINT(1) DEFAULT 0,
  created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_routine_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**السبب:** الاستشارة غالباً تتضمن روتين عناية — يمكن حفظه وتتبعه

---

## الملف المطلوب: `migrate_fresh_seed.php`

سيتم إنشاء ملف PHP يعمل مثل `php artisan migrate:fresh --seed`:
1. يحذف كل الجداول
2. يعيد إنشاءها بالهيكل الجديد
3. يضيف بيانات تجريبية (seed data)

**الموقع:** `backend/database/migrate_fresh_seed.php`
**التشغيل:** `http://localhost/backend/database/migrate_fresh_seed.php`

---

## ملاحظات التنفيذ

- يجب تحديث ملفات PHP الخاصة بـ register و profile لتدعم الحقول الجديدة
- يجب تحديث Flutter models لتتوافق مع الجداول الجديدة
- الـ soft delete يتطلب تعديل استعلامات scans.php لإضافة `WHERE is_deleted = 0`
