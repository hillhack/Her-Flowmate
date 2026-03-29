/// Week-by-week pregnancy data model.
/// Covers weeks 4–40 with baby development, mom symptoms, and tips.
class PregnancyWeekData {
  final int week;
  final String sizeEmoji;
  final String sizeName;
  final double lengthCm;
  final double weightGrams;
  final String milestone;
  final String bodyUpdate;
  final List<String> momSymptoms;
  final String weeklyTip;
  final String nutritionFocus;
  final String? prenatalCheckup;

  const PregnancyWeekData({
    required this.week,
    required this.sizeEmoji,
    required this.sizeName,
    required this.lengthCm,
    required this.weightGrams,
    required this.milestone,
    required this.bodyUpdate,
    required this.momSymptoms,
    required this.weeklyTip,
    required this.nutritionFocus,
    this.prenatalCheckup,
  });

  String get trimester {
    if (week <= 12) return '1st Trimester';
    if (week <= 27) return '2nd Trimester';
    return '3rd Trimester';
  }

  int get trimesterNumber {
    if (week <= 12) return 1;
    if (week <= 27) return 2;
    return 3;
  }

  String get formattedWeight {
    if (weightGrams < 1) return '< 1g';
    if (weightGrams < 1000) return '${weightGrams.round()}g';
    return '${(weightGrams / 1000).toStringAsFixed(1)} kg';
  }

  String get formattedLength {
    if (lengthCm < 1) return '${(lengthCm * 10).round()} mm';
    return '${lengthCm.toStringAsFixed(1)} cm';
  }
}

/// Returns [PregnancyWeekData] for a given week (clamped to 4–40).
PregnancyWeekData getPregnancyWeekData(int week) {
  final clamped = week.clamp(4, 40);
  return _weekDataMap[clamped] ?? _weekDataMap[40]!;
}

/// Derives the current pregnancy week from a due date.
/// Due date = conception + 280 days. Week = elapsed days / 7 + 1 (approx).
int pregnancyWeekFromDueDate(DateTime dueDate) {
  final today = DateTime.now();
  final conception = dueDate.subtract(const Duration(days: 280));
  final elapsed = today.difference(conception).inDays;
  final week = (elapsed / 7).floor();
  return week.clamp(1, 42);
}

/// Derives days remaining until due date.
int daysUntilDueDate(DateTime dueDate) {
  final today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
  return due.difference(today).inDays.clamp(0, 300);
}

const Map<int, PregnancyWeekData> _weekDataMap = {
  4: PregnancyWeekData(
    week: 4,
    sizeEmoji: '🌱',
    sizeName: 'Poppy Seed',
    lengthCm: 0.1,
    weightGrams: 0.5,
    milestone: 'The fertilized egg has implanted in your uterine lining.',
    bodyUpdate: 'Two cell layers are forming — the epiblast and hypoblast.',
    momSymptoms: ['Missed period', 'Light spotting', 'Mild cramping'],
    weeklyTip:
        'Start taking folic acid (400–800 mcg/day) to protect baby\'s neural tube.',
    nutritionFocus: 'Folic acid, iron, calcium',
    prenatalCheckup: 'Take a pregnancy test to confirm!',
  ),
  5: PregnancyWeekData(
    week: 5,
    sizeEmoji: '🫘',
    sizeName: 'Sesame Seed',
    lengthCm: 0.4,
    weightGrams: 0.5,
    milestone: 'Baby\'s heart is beginning to beat for the first time.',
    bodyUpdate: 'Neural tube forming — this becomes the brain and spinal cord.',
    momSymptoms: ['Fatigue', 'Sore breasts', 'Nausea', 'Frequent urination'],
    weeklyTip: 'Stay well hydrated — aim for 8–10 glasses of water daily.',
    nutritionFocus: 'Folic acid, Vitamin B6 to ease nausea',
  ),
  6: PregnancyWeekData(
    week: 6,
    sizeEmoji: '🫐',
    sizeName: 'Blueberry',
    lengthCm: 0.6,
    weightGrams: 0.8,
    milestone: 'Heart is now beating! Arm and leg buds are appearing.',
    bodyUpdate: 'The brain, eyes, nose, and jaw are beginning to form.',
    momSymptoms: [
      'Morning sickness',
      'Breast tenderness',
      'Bloating',
      'Mood swings',
    ],
    weeklyTip: 'Eat small, frequent meals to help manage morning sickness.',
    nutritionFocus: 'Ginger for nausea, Vitamin B6',
    prenatalCheckup: 'Book your first prenatal appointment (OB/midwife).',
  ),
  7: PregnancyWeekData(
    week: 7,
    sizeEmoji: '🫐',
    sizeName: 'Raspberry',
    lengthCm: 1.3,
    weightGrams: 1.0,
    milestone: 'All essential organs have begun forming.',
    bodyUpdate:
        'Baby\'s hands and feet are forming — tiny webbed digits visible.',
    momSymptoms: ['Nausea', 'Fatigue', 'Frequent urination', 'Food aversions'],
    weeklyTip:
        'Rest when you need to — fatigue is your body working overtime for baby.',
    nutritionFocus: 'Protein, iron, folate',
  ),
  8: PregnancyWeekData(
    week: 8,
    sizeEmoji: '🍓',
    sizeName: 'Strawberry',
    lengthCm: 1.6,
    weightGrams: 1.0,
    milestone: 'Baby is starting to look human! Fingers and toes are forming.',
    bodyUpdate:
        'Eyes, ears and nose are becoming more distinct. Joints can flex.',
    momSymptoms: [
      'Morning sickness',
      'Heightened sense of smell',
      'Headaches',
      'Constipation',
    ],
    weeklyTip:
        'Avoid strong smells that trigger nausea — your sense of smell is at its peak.',
    nutritionFocus: 'Calcium, Vitamin D for bone development',
    prenatalCheckup: 'First OB appointment — confirm heartbeat via ultrasound.',
  ),
  9: PregnancyWeekData(
    week: 9,
    sizeEmoji: '🍇',
    sizeName: 'Grape',
    lengthCm: 2.3,
    weightGrams: 2.0,
    milestone:
        'All joints can flex. Eyes and inner ears are developing rapidly.',
    bodyUpdate:
        'Baby\'s tail is disappearing. Intestines forming in the umbilical cord.',
    momSymptoms: [
      'Nausea',
      'Fatigue',
      'Round ligament discomfort',
      'Emotional sensitivity',
    ],
    weeklyTip: 'Light walks or prenatal yoga can boost energy and mood.',
    nutritionFocus: 'Iron-rich foods to fight fatigue',
  ),
  10: PregnancyWeekData(
    week: 10,
    sizeEmoji: '🍊',
    sizeName: 'Kumquat',
    lengthCm: 3.1,
    weightGrams: 4.0,
    milestone:
        'Critical development phase is nearly complete! Fingernails are forming.',
    bodyUpdate: 'Vital organs are in place. Baby is now classified as a fetus.',
    momSymptoms: [
      'Nausea may peak this week',
      'Visible veins on breasts',
      'Bloating',
    ],
    weeklyTip:
        'Consider telling close family — risk of miscarriage drops significantly now.',
    nutritionFocus: 'Omega-3 fatty acids for brain development',
    prenatalCheckup:
        'NIPT (non-invasive prenatal testing) window opens (weeks 10–13).',
  ),
  11: PregnancyWeekData(
    week: 11,
    sizeEmoji: '🥝',
    sizeName: 'Fig',
    lengthCm: 4.1,
    weightGrams: 7.0,
    milestone: 'Tooth buds are forming. Baby can open and close fists.',
    bodyUpdate:
        'External genitalia beginning to differentiate. Skin is see-through.',
    momSymptoms: [
      'Nausea starting to ease',
      'Increased energy',
      'Mild heartburn',
    ],
    weeklyTip:
        'Begin gentle stretching to ease round ligament pain as uterus grows.',
    nutritionFocus: 'Zinc for immune and cellular development',
  ),
  12: PregnancyWeekData(
    week: 12,
    sizeEmoji: '🍋',
    sizeName: 'Lime',
    lengthCm: 5.4,
    weightGrams: 14.0,
    milestone:
        'All organs, muscles, limbs and bones are in place. Unique fingerprints have formed!',
    bodyUpdate:
        'Baby\'s reflexes are developing — toes curl, fingers open and close.',
    momSymptoms: [
      'Morning sickness often eases',
      'Increased appetite returning',
      'Visible bump starting',
    ],
    weeklyTip:
        'End of 1st trimester — celebrate! Share the news if you haven\'t already.',
    nutritionFocus: 'Continue folic acid, add Vitamin C for iron absorption',
    prenatalCheckup:
        'Nuchal translucency ultrasound (NT scan) for chromosomal screening.',
  ),
  13: PregnancyWeekData(
    week: 13,
    sizeEmoji: '🥝',
    sizeName: 'Kiwi',
    lengthCm: 7.4,
    weightGrams: 23.0,
    milestone:
        'Baby can make facial expressions and vocal cords are developing.',
    bodyUpdate:
        'Intestines move from umbilical cord into abdomen. Tissue becomes bone.',
    momSymptoms: [
      'Energy boost',
      'Reduced nausea',
      'Visible veins on abdomen',
      'Mild back pain',
    ],
    weeklyTip:
        'Welcome to the 2nd trimester! Stay active with walking or swimming.',
    nutritionFocus: 'Protein for rapid muscle development',
  ),
  14: PregnancyWeekData(
    week: 14,
    sizeEmoji: '🍑',
    sizeName: 'Peach',
    lengthCm: 8.7,
    weightGrams: 43.0,
    milestone:
        'Face looks recognizable. Kidneys are producing urine into amniotic fluid.',
    bodyUpdate: 'Baby\'s red blood cells are being produced by the spleen.',
    momSymptoms: [
      'Increased appetite',
      'Skin changes (glow!)',
      'Reduced fatigue',
      'Slight weight gain',
    ],
    weeklyTip: 'Moisturize your belly to stay comfortable as skin stretches.',
    nutritionFocus:
        'Iron and protein — your blood volume is increasing significantly',
  ),
  15: PregnancyWeekData(
    week: 15,
    sizeEmoji: '🍎',
    sizeName: 'Apple',
    lengthCm: 10.1,
    weightGrams: 70.0,
    milestone:
        'Baby can sense light through closed eyelids. Skeleton hardening from cartilage to bone.',
    bodyUpdate:
        'Ears are in final position. Baby may be moving though you can\'t feel it yet.',
    momSymptoms: [
      'Round ligament pain',
      'Nasal congestion',
      'Increased sex drive possible',
    ],
    weeklyTip: 'Sleep on your side — left side is best for blood flow to baby.',
    nutritionFocus: 'Calcium and Vitamin D for skeleton hardening',
    prenatalCheckup:
        'Quad marker screening (blood test) typically done at weeks 15–20.',
  ),
  16: PregnancyWeekData(
    week: 16,
    sizeEmoji: '🥑',
    sizeName: 'Avocado',
    lengthCm: 11.6,
    weightGrams: 100.0,
    milestone: 'Baby can hear your voice! Facial muscles allow expressions.',
    bodyUpdate:
        'Baby making swallowing movements. Amniotic fluid is swallowed and recycled.',
    momSymptoms: [
      'Growing bump',
      'Back pain',
      'Possible constipation',
      'Skin darkening (linea nigra)',
    ],
    weeklyTip: 'Talk and sing to your baby — they can hear you now!',
    nutritionFocus:
        'Magnesium to reduce leg cramps and support muscle function',
  ),
  17: PregnancyWeekData(
    week: 17,
    sizeEmoji: '🍐',
    sizeName: 'Pear',
    lengthCm: 13.0,
    weightGrams: 140.0,
    milestone: 'Fat stores beginning to develop. Sweat glands forming.',
    bodyUpdate: 'Skeleton changing from cartilage to bone rapidly.',
    momSymptoms: [
      'Stretch marks may appear',
      'Increased appetite',
      'Itchy skin on belly',
    ],
    weeklyTip:
        'Apply cocoa butter or stretch mark cream on belly, breasts and thighs.',
    nutritionFocus:
        'Healthy fats (avocado, nuts) for baby\'s fat layer development',
  ),
  18: PregnancyWeekData(
    week: 18,
    sizeEmoji: '🫑',
    sizeName: 'Bell Pepper',
    lengthCm: 14.2,
    weightGrams: 190.0,
    milestone: 'Ears are fully positioned. Baby can yawn and hiccup!',
    bodyUpdate:
        'Nerves forming a protective myelin sheath. All senses are developing.',
    momSymptoms: [
      'Baby flutters (quickening) may begin',
      'Lower back pain',
      'Mild swelling in ankles',
    ],
    weeklyTip:
        'Start sleeping with a pregnancy pillow to support hips and back.',
    nutritionFocus: 'DHA omega-3 for brain and eye development',
  ),
  19: PregnancyWeekData(
    week: 19,
    sizeEmoji: '🥭',
    sizeName: 'Mango',
    lengthCm: 15.3,
    weightGrams: 240.0,
    milestone:
        'First movements (quickening) often felt this week! Vernix (protective coating) forming.',
    bodyUpdate: 'Brain is designating specialized areas for all 5 senses.',
    momSymptoms: [
      'Baby kicks & flutters!',
      'Growing appetite',
      'Dizziness when standing quickly',
    ],
    weeklyTip:
        'Start a kick-counting journal — note patterns of baby movement.',
    nutritionFocus:
        'Iron and Vitamin C — your blood supply is at maximum expansion',
    prenatalCheckup:
        'Anatomy scan (level 2 ultrasound) at weeks 18–20 — a major milestone!',
  ),
  20: PregnancyWeekData(
    week: 20,
    sizeEmoji: '🍌',
    sizeName: 'Banana',
    lengthCm: 16.4,
    weightGrams: 300.0,
    milestone:
        '🎉 Halfway there! Eyebrows, eyelashes and fingernails are fully formed.',
    bodyUpdate:
        'Baby is more active, around 16cm long. Hair growing on the head.',
    momSymptoms: [
      'Braxton Hicks contractions starting',
      'Heartburn',
      'Swollen feet',
      'Hip pain',
    ],
    weeklyTip:
        'Celebrate the halfway point! Take a bump photo to remember this milestone.',
    nutritionFocus: 'Fibre to combat constipation and heartburn',
  ),
  21: PregnancyWeekData(
    week: 21,
    sizeEmoji: '🥕',
    sizeName: 'Carrot',
    lengthCm: 26.7,
    weightGrams: 360.0,
    milestone: 'Baby can taste what you eat through amniotic fluid.',
    bodyUpdate:
        'Bone marrow beginning to make blood cells. Liver and spleen helping too.',
    momSymptoms: [
      'Visible kicks from outside!',
      'Increased backache',
      'Stretch marks',
      'Leg cramps',
    ],
    weeklyTip:
        'Eat a variety of flavors — baby is tasting them all, expanding their palate!',
    nutritionFocus: 'Potassium to reduce leg cramps',
  ),
  22: PregnancyWeekData(
    week: 22,
    sizeEmoji: '🌽',
    sizeName: 'Corn',
    lengthCm: 27.8,
    weightGrams: 430.0,
    milestone:
        'Sleep-wake cycles forming. Face is fully formed with eyebrows and lips.',
    bodyUpdate: 'Tear ducts are developing. Grip reflex is strong.',
    momSymptoms: [
      'Linea nigra darkening',
      'Innie belly button becoming an outie',
      'Heartburn',
    ],
    weeklyTip:
        'Practice relaxation techniques — breathing exercises prepare you for labor.',
    nutritionFocus: 'Calcium for your bones — baby is borrowing yours!',
  ),
  23: PregnancyWeekData(
    week: 23,
    sizeEmoji: '🍆',
    sizeName: 'Eggplant',
    lengthCm: 28.9,
    weightGrams: 501.0,
    milestone:
        'Sense of movement is developing. Lungs are preparing for breathing.',
    bodyUpdate:
        'Skin is still wrinkled — baby will fill it out with fat over coming weeks.',
    momSymptoms: [
      'Braxton Hicks contractions',
      'Swelling (edema)',
      'Increased pigmentation',
    ],
    weeklyTip:
        'Elevate your feet when resting to reduce ankle and foot swelling.',
    nutritionFocus: 'Protein and iron for continued rapid growth',
  ),
  24: PregnancyWeekData(
    week: 24,
    sizeEmoji: '🌽',
    sizeName: 'Ear of Corn',
    lengthCm: 30.0,
    weightGrams: 600.0,
    milestone:
        'Survival possible if born now! Baby responds clearly to sound and touch.',
    bodyUpdate:
        'Lungs developing surfactant — the substance that allows breathing after birth.',
    momSymptoms: [
      'Shortness of breath',
      'Backache',
      'Swollen feet and ankles',
      'Carpal tunnel tingling',
    ],
    weeklyTip:
        'Sleep with your head elevated slightly to ease shortness of breath.',
    nutritionFocus: 'Vitamin K for blood clotting, leafy greens',
    prenatalCheckup: 'Glucose tolerance test (GDM screening) at weeks 24–28.',
  ),
  25: PregnancyWeekData(
    week: 25,
    sizeEmoji: '🥦',
    sizeName: 'Head of Broccoli',
    lengthCm: 34.6,
    weightGrams: 660.0,
    milestone: 'Baby is adding fat stores and growing more hair.',
    bodyUpdate: 'Capillaries forming under skin — baby\'s skin turning pink.',
    momSymptoms: [
      'Sciatica (shooting pain down leg)',
      'Swelling',
      'Hemorrhoids may appear',
    ],
    weeklyTip: 'A warm bath before bed eases sciatica and helps you sleep.',
    nutritionFocus:
        'Omega-3 and collagen — supports skin and joint health for you too',
  ),
  26: PregnancyWeekData(
    week: 26,
    sizeEmoji: '🥬',
    sizeName: 'Scallion Bunch',
    lengthCm: 35.6,
    weightGrams: 760.0,
    milestone:
        '👁️ Baby\'s eyes can open for the first time! Lungs developing surfactant.',
    bodyUpdate:
        'Brain wave activity for hearing and sight detected. Inhaling amniotic fluid.',
    momSymptoms: [
      'Insomnia',
      'Painful Braxton Hicks',
      'Frequent urination returns',
      'Vivid dreams',
    ],
    weeklyTip:
        'Start researching hospitals and birth centers — it\'s time to make your plan.',
    nutritionFocus:
        'Vitamin A (carrots, sweet potato) for baby\'s eye and lung development',
  ),
  27: PregnancyWeekData(
    week: 27,
    sizeEmoji: '🥦',
    sizeName: 'Cauliflower',
    lengthCm: 36.6,
    weightGrams: 875.0,
    milestone: 'Brain is very active. Baby may get hiccups you can feel!',
    bodyUpdate:
        'Last week of the 2nd trimester. Baby sleeping 90% of the time.',
    momSymptoms: [
      'Heartburn',
      'Hemorrhoids',
      'Leg cramps at night',
      'Lower back pain',
    ],
    weeklyTip:
        'Celebrate — final week of your 2nd trimester! You\'re almost in the home stretch.',
    nutritionFocus: 'Fibre and probiotics to combat constipation',
  ),
  28: PregnancyWeekData(
    week: 28,
    sizeEmoji: '🍆',
    sizeName: 'Eggplant',
    lengthCm: 37.6,
    weightGrams: 1000.0,
    milestone:
        'Eyes open and close with light sensitivity. REM sleep begins — baby may dream!',
    bodyUpdate:
        'Brain growing at an incredible rate. Bones fully developed but soft.',
    momSymptoms: [
      'Shortness of breath',
      'Vivid dreams',
      'Discomfort sleeping',
      'Pelvic pressure',
    ],
    weeklyTip:
        'Welcome to the 3rd trimester! Prenatal appointments now every 2 weeks.',
    nutritionFocus:
        'Iron and Vitamin C — prevent iron-deficiency anemia in final trimester',
    prenatalCheckup:
        'Glucose tolerance test results, Rh factor check, Tdap vaccination.',
  ),
  29: PregnancyWeekData(
    week: 29,
    sizeEmoji: '🥜',
    sizeName: 'Butternut Squash',
    lengthCm: 38.6,
    weightGrams: 1150.0,
    milestone:
        'Muscles and lungs maturing. Baby\'s head may be moving into head-down position.',
    bodyUpdate: 'Baby gaining about 200g per week from now until birth.',
    momSymptoms: [
      'Frequent urination',
      'Pelvic girdle pain',
      'Backache',
      'Constipation',
    ],
    weeklyTip:
        'Start kick counting daily — 10 kicks within 2 hours after meals is healthy.',
    nutritionFocus:
        'Calcium, magnesium and Vitamin D for final bone fortification',
  ),
  30: PregnancyWeekData(
    week: 30,
    sizeEmoji: '🥦',
    sizeName: 'Large Cabbage',
    lengthCm: 39.9,
    weightGrams: 1300.0,
    milestone:
        'Bone marrow fully taking over red blood cell production. Toenails fully grown.',
    bodyUpdate:
        'Baby\'s lanugo (soft hair) beginning to disappear. Fat accumulating fast.',
    momSymptoms: [
      'Heartburn',
      'Nesting urge beginning',
      'Swollen hands and face possible',
    ],
    weeklyTip:
        'Look into cord blood banking if interested — decisions needed before birth.',
    nutritionFocus:
        'Protein for rapid muscle and tissue growth in the final stretch',
  ),
  31: PregnancyWeekData(
    week: 31,
    sizeEmoji: '🥥',
    sizeName: 'Coconut',
    lengthCm: 41.1,
    weightGrams: 1500.0,
    milestone:
        'All major fetal development is complete! Rapid weight gain phase begins.',
    bodyUpdate:
        'Baby can turn head, suck thumb. Moving often and hard — you\'ll feel it!',
    momSymptoms: [
      'Leaky colostrum from nipples',
      'Breathlessness',
      'More frequent Braxton Hicks',
    ],
    weeklyTip:
        'Start assembling your hospital bag — include items for you, baby, and your support person.',
    nutritionFocus: 'Continue iron and Vitamin C, add zinc for immune strength',
  ),
  32: PregnancyWeekData(
    week: 32,
    sizeEmoji: '🎃',
    sizeName: 'Small Pumpkin',
    lengthCm: 42.4,
    weightGrams: 1700.0,
    milestone:
        'Baby\'s practice breathing movements are regular. Toenails fully formed.',
    bodyUpdate:
        'Skull remains flexible with soft spots (fontanelles) for passing through birth canal.',
    momSymptoms: [
      'Nesting instinct strong',
      'Pelvic pressure',
      'Diastasis recti',
      'Trouble sleeping',
    ],
    weeklyTip:
        'Write your birth plan — include your preferences for pain relief, atmosphere and visitors.',
    nutritionFocus:
        'Stay hydrated to prevent Braxton Hicks and preterm contractions',
    prenatalCheckup:
        'Group B Strep (GBS) test window approaching (weeks 35–37).',
  ),
  33: PregnancyWeekData(
    week: 33,
    sizeEmoji: '🍍',
    sizeName: 'Pineapple',
    lengthCm: 43.7,
    weightGrams: 1900.0,
    milestone:
        'Immune system building with antibodies from you. Skull is hardening (except fontanelles).',
    bodyUpdate: 'Baby\'s pupils can dilate and contract in response to light.',
    momSymptoms: [
      'Difficulty breathing',
      'Insomnia',
      'Swollen face and hands',
      'Lightning crotch pains',
    ],
    weeklyTip:
        'Take a baby care class or breastfeeding workshop — reduces post-birth anxiety.',
    nutritionFocus: 'Vitamin E and zinc for immune transfer to baby',
  ),
  34: PregnancyWeekData(
    week: 34,
    sizeEmoji: '🥦',
    sizeName: 'Large Broccoli',
    lengthCm: 45.0,
    weightGrams: 2150.0,
    milestone:
        'Central nervous system and lungs nearly mature. Baby settling head-down.',
    bodyUpdate:
        'Vernix (protective coating) thickening. Fingernails now reach fingertips.',
    momSymptoms: [
      'Pelvic pressure intensifies',
      'Frequent urination',
      'Back pain',
      'Fatigue returns',
    ],
    weeklyTip: 'Rest as much as possible — your body is doing enormous work.',
    nutritionFocus:
        'Colostrum production heating up — continue calcium and Vitamin D',
    prenatalCheckup:
        'Weekly appointments may begin at some practices from here.',
  ),
  35: PregnancyWeekData(
    week: 35,
    sizeEmoji: '🍈',
    sizeName: 'Honeydew Melon',
    lengthCm: 46.2,
    weightGrams: 2400.0,
    milestone:
        'Kidneys are fully developed. Brain is only ⅔ of final weight — critical growth continues.',
    bodyUpdate:
        'Baby is gaining half a pound per week now. Most internal organs fully ready.',
    momSymptoms: [
      'Braxton Hicks more intense',
      'Difficulty walking',
      'Pelvic lightening pain',
    ],
    weeklyTip: 'Hospital bag should be packed and ready from now.',
    nutritionFocus: 'Small, frequent meals — baby is taking up stomach space',
    prenatalCheckup: 'Group B Strep (GBS) swab test (weeks 35–37).',
  ),
  36: PregnancyWeekData(
    week: 36,
    sizeEmoji: '🍈',
    sizeName: 'Papaya',
    lengthCm: 47.4,
    weightGrams: 2600.0,
    milestone:
        'Baby may "drop" into the pelvis (lightening). Almost ready to be born!',
    bodyUpdate:
        'Baby\'s gums are rigid — ready for feeding. Skull plates still malleable.',
    momSymptoms: [
      'Easier breathing after baby drops',
      'Increased pelvic pressure',
      'More frequent urination',
    ],
    weeklyTip:
        'Rest, rest, rest. You\'re in the final countdown — just 4 weeks to go!',
    nutritionFocus:
        'Dates have been shown in studies to ease labor — try 6 dates per day',
    prenatalCheckup: 'Weekly appointments from now until birth.',
  ),
  37: PregnancyWeekData(
    week: 37,
    sizeEmoji: '🥬',
    sizeName: 'Swiss Chard Bunch',
    lengthCm: 48.6,
    weightGrams: 2900.0,
    milestone:
        'Early full-term! All body systems are ready for life outside the womb.',
    bodyUpdate:
        'Baby swallowing amniotic fluid — practising digestion. Meconium collecting.',
    momSymptoms: [
      'Strong Braxton Hicks',
      'Cervical changes',
      'Mucus plug may pass',
      'Nesting peaks',
    ],
    weeklyTip:
        'Know the signs of labor: water breaking, contractions every 5 min, bloody show.',
    nutritionFocus: 'Light, easy-to-digest meals — no need for huge calories',
    prenatalCheckup: 'Cervical check to assess dilation and effacement.',
  ),
  38: PregnancyWeekData(
    week: 38,
    sizeEmoji: '🥬',
    sizeName: 'Leek',
    lengthCm: 49.8,
    weightGrams: 3100.0,
    milestone:
        'Lungs and brain are fully mature. Baby is mostly sleeping and conserving energy.',
    bodyUpdate:
        'Amniotic fluid decreasing as baby fills the space. Vernix coming off.',
    momSymptoms: [
      'Intense pelvic pressure',
      'Back labor pain',
      'Diarrhea (sign of labor approaching)',
      'Difficulty sleeping',
    ],
    weeklyTip: 'Have a clear route to hospital planned. Install car seat now!',
    nutritionFocus: 'Stay hydrated; light snacks to keep energy up for labor',
  ),
  39: PregnancyWeekData(
    week: 39,
    sizeEmoji: '🎃',
    sizeName: 'Small Watermelon',
    lengthCm: 50.7,
    weightGrams: 3300.0,
    milestone:
        'Ready to meet the world! Placenta is actively passing antibodies for immune protection.',
    bodyUpdate:
        'Skin is smooth and pink. Lanugo mostly gone. Baby in head-down position.',
    momSymptoms: [
      'Contractions (true or Braxton Hicks)',
      'Extreme fatigue',
      'Emotional nesting',
      'Mucus plug loss',
    ],
    weeklyTip:
        'Any contraction lasting 60+ seconds every 5 min for 1 hour — head to hospital!',
    nutritionFocus:
        'Light meals; avoid heavy foods that may upset stomach during labor',
    prenatalCheckup: 'Final OB appointment before due date.',
  ),
  40: PregnancyWeekData(
    week: 40,
    sizeEmoji: '🍉',
    sizeName: 'Watermelon',
    lengthCm: 51.2,
    weightGrams: 3400.0,
    milestone:
        '🎉 Full term! Baby could arrive any moment. You\'ve done an incredible job!',
    bodyUpdate:
        'Baby is perfectly positioned for birth. Your body knows exactly what to do.',
    momSymptoms: [
      'Strong contractions',
      'Water may break',
      'Extreme pelvic pressure',
      'Eagerness to meet baby!',
    ],
    weeklyTip:
        'Trust your body and your team. You are ready. You\'ve got this! 💕',
    nutritionFocus:
        'Keep snacks on hand for labor energy — dates, bananas, energy bars',
    prenatalCheckup:
        'If no labor by 40+1, discuss induction timeline with your doctor.',
  ),
};
