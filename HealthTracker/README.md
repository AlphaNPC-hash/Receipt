# HealthTracker iOS App

แอปติดตามสุขภาพและตารางการทานยา/วิตามิน สร้างด้วย SwiftUI + SwiftData

## Requirements
- iOS 17+
- Xcode 15+
- macOS 13+

## วิธีเปิด Project ใน Xcode

1. เปิด Xcode
2. สร้าง Project ใหม่: **File → New → Project → iOS → App**
3. ตั้งค่า:
   - **Product Name:** `HealthTracker`
   - **Organization Identifier:** `com.yourname` (ใส่ชื่อของคุณ)
   - **Interface:** SwiftUI
   - **Storage:** SwiftData
   - **Language:** Swift
4. เลือก folder ที่ต้องการบันทึก
5. **ลบไฟล์เดิม** ที่ Xcode สร้างให้ (ContentView.swift, Item.swift)
6. **ลาก folder ทั้งหมด** จาก `HealthTracker/` นี้ใส่ใน Xcode project:
   - `Models/`
   - `Views/`
   - `Managers/`
   - `HealthTrackerApp.swift`
   - `ContentView.swift`
7. ตรวจสอบ Framework ใน **Target → Frameworks**: ต้องมี `Charts` (Add via Swift Package Manager หรือ Xcode Built-in)

## ฟีเจอร์

### ยา / วิตามิน
- เพิ่ม/แก้ไข/ลบรายการยาและวิตามิน
- กำหนดเวลาทานได้หลายรอบต่อวัน
- เลือกสีแสดงแต่ละรายการ
- แจ้งเตือนอัตโนมัติทุกวัน

### บันทึกสุขภาพ
- น้ำหนัก
- ความดันโลหิต (SYS/DIA)
- ชีพจร
- น้ำตาลในเลือด
- อารมณ์ (5 ระดับ)
- ชั่วโมงการนอน
- ปริมาณน้ำที่ดื่ม

### ออกกำลังกาย
- วิ่ง, เดินในร่ม, เดิน, ปั่นจักรยาน, ว่ายน้ำ, โยคะ, HIIT, ยิม
- บันทึก: ระยะเวลา, ระยะทาง, ก้าว, แคลอรี่, ชีพจรเฉลี่ย
- คำนวณ Pace อัตโนมัติ
- สถิติรายสัปดาห์

### สถิติ
- กราฟน้ำหนัก (Swift Charts)
- สถิติการออกกำลังกาย
- อัตราการทานยา (Adherence Rate)
- แสดงได้ 7 วัน / 30 วัน / 90 วัน
