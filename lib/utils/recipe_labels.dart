const _cuisineTranslations = {
  'african': 'แอฟริกัน',
  'american': 'อเมริกัน',
  'asian': 'เอเชีย',
  'brazilian': 'บราซิล',
  'chinese': 'จีน',
  'egyptian': 'อียิปต์',
  'french': 'ฝรั่งเศส',
  'german': 'เยอรมัน',
  'greek': 'กรีก',
  'indian': 'อินเดีย',
  'italian': 'อิตาเลียน',
  'japanese': 'ญี่ปุ่น',
  'korean': 'เกาหลี',
  'lebanese': 'เลบานอน',
  'mediterranean': 'เมดิเตอร์เรเนียน',
  'mexican': 'เม็กซิกัน',
  'moroccan': 'โมร็อกโก',
  'pakistani': 'ปากีสถาน',
  'russian': 'รัสเซีย',
  'smoothie': 'สมูทตี้',
  'spanish': 'สเปน',
  'thai': 'ไทย',
  'turkish': 'ตุรกี',
  'vietnamese': 'เวียดนาม',
  'home kitchen': 'ครัวที่บ้าน',
  'homemade': 'ทำเอง',
};

String cuisineLabel(String cuisine) {
  return _cuisineTranslations[cuisine.trim().toLowerCase()] ?? cuisine;
}

String difficultyLabel(String difficulty) {
  return switch (difficulty.trim().toLowerCase()) {
    'easy' => 'ง่าย',
    'medium' => 'ปานกลาง',
    'hard' => 'ยาก',
    _ => difficulty,
  };
}
