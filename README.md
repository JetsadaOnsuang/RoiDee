# อร่อยดี - สมุดสูตรอาหาร

แอป Flutter สำหรับค้นหา ดูรายละเอียด บันทึกเมนูโปรด และเพิ่มสูตรอาหารของตัวเอง

## ฟีเจอร์

- ดูสูตรอาหารจาก [DummyJSON Recipes API](https://dummyjson.com/docs/recipes)
- ค้นหาเมนูและเลือกประเภทอาหาร
- ดูวัตถุดิบและวิธีทำของแต่ละเมนู
- บันทึกเมนูโปรดและเพิ่มสูตรส่วนตัว ซึ่งเก็บไว้ในอุปกรณ์
- แนบรูปอาหารในสูตรส่วนตัวได้ (ไม่บังคับ) เปลี่ยนหรือลบรูป และแก้ไขสูตรที่บันทึกไว้แล้วได้
- ใช้งานได้ทั้งบนเว็บและอุปกรณ์ Android

> เมนู วัตถุดิบ และวิธีทำของสูตรทั้ง 50 เมนูจาก API แปลเป็นภาษาไทยไว้ในแอปแล้ว ส่วนสูตรใหม่ที่ API อาจเพิ่มภายหลังจะแสดงตามภาษาต้นฉบับจนกว่าจะเพิ่มคำแปล

## เทคโนโลยี

- Flutter และ Dart
- `http` สำหรับดึงสูตรอาหาร
- `image_picker` สำหรับเลือกรูปอาหารจากเครื่อง
- `shared_preferences` สำหรับบันทึกเมนูโปรดและสูตรส่วนตัว

## วิธีเริ่มใช้งาน

1. ติดตั้ง Flutter SDK
2. ติดตั้งแพ็กเกจด้วย `flutter pub get`
3. เปิดแอปบนเว็บด้วย `flutter run -d chrome` หรือใช้ `flutter run` เพื่อเลือกอุปกรณ์

## ทดสอบและตรวจโค้ด

- รันทดสอบ: `flutter test`
- ตรวจโค้ด: `flutter analyze`
- สร้างเว็บ: `flutter build web`

## เผยแพร่ซอร์สโค้ดบน GitHub

สร้าง repository เปล่าในบัญชี GitHub ก่อน แล้วเปิด Terminal ที่โฟลเดอร์โครงการและใช้คำสั่งต่อไปนี้ โดยเปลี่ยน `<username>` และ `<repository>` ให้ตรงกับ repository ของตนเอง:

```bash
git init
git add .
git commit -m "Initial commit: Recipe Book Flutter app"
git branch -M main
git remote add origin https://github.com/<username>/<repository>.git
git push -u origin main
```

โฟลเดอร์ `.venv`, `.dart_tool` และ `build` จะไม่ถูกรวมใน Git; อย่าเพิ่มรหัสผ่าน token หรือข้อมูลส่วนตัวลงใน repository
