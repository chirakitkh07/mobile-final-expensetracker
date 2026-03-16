# expense tracker

### โจทย์ แอปบันทึกรายจ่ายส่วนตัว
ให้สร้างแอปบันทึกรายจ่ายส่วนตัว โดยผู้ใช้สามารถเพิ่มรายการรายจ่าย 

## ชื่อผู้จัดทำ
นายจิรกิตติ์ คำป่าตัน 67543210014-6

## ฟีเจอร์หลัก
```
 - ฟีเจอร์หลัก
 - บันทึกค่าใช้จ่าย
 - แก้ไข / ลบรายการ
 จัดหมวดหมู่
 - ค้นหา & กรอง & เรียงลำดับ
 - Dashboard สรุปยอด
 - Pie chart แยกหมวด
```

## โครงสร้าง

```
เปิดแอป → loadData() โหลด DB
    ├─► Dashboard: สรุปยอด + Chart + 5 รายการล่าสุด
    └─► Expenses: ค้นหา/กรอง/เรียงลำดับรายการทั้งหมด
            │
            ├─► กด FAB → ExpenseFormScreen (Add)
            ├─► กด Card → ExpenseDetailScreen
            │       ├─► กด Edit → ExpenseFormScreen (Edit)
            │       └─► กด Delete → ลบ + pop กลับ
            └─► Swipe Card → Dismiss dialog → ลบ
```

## package ที่ใช้
```
flutter
provider
sqflite
path
intl
fl_chart
google_fonts
```

## วิธีรันโปรเจกต์
### ขั้นตอนที่ 1 — ตรวจสอบ Flutter
```
flutter doctor
```

### ขั้นตอนที่ 2 — ติดตั้ง dependencies
```
flutter pub get
```

### ขั้นตอนที่ 3 — รันแอป
# รันบน emulator หรือ device ที่เชื่อมอยู่
```
flutter run
หรือ
flutter run -d android
flutter run -d ios
flutter run -d chrome   # Web
```

### ขั้นตอนที่ 4 — Build release (ถ้าต้องการ)
```
flutter build apk          # Android
flutter build ios          # iOS (ต้องใช้ macOS)
```
