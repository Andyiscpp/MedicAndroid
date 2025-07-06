import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_conut/pages/home_page.dart'; // 导入AppColors以保持风格统一
import 'package:demo_conut/pages/medicinal_material_detail_page.dart'; // 导入详情页面

/// 用于表示单个药材的数据模型。
class Herb {
  final String name;
  final String imagePath;
  final String description;
  final String source;
  final String ancientExamples;
  final String usageAndDosage;
  final String medicalExamples;

  const Herb({
    required this.name,
    required this.imagePath,
    required this.description,
    required this.source,
    required this.ancientExamples,
    required this.usageAndDosage,
    required this.medicalExamples,
  });
}

/// 一个用于显示药材网格的页面，现在包含搜索功能。
class MedicinalMaterialsOverviewPage extends StatefulWidget {
  const MedicinalMaterialsOverviewPage({super.key});

  // 数据现在移至State中，以便管理
  final List<Herb> herbs = const [
    Herb(
        name: '板蓝根',
        imagePath: 'assets/medic_picture/板蓝根.png',
        description: '清热解毒，凉血利咽。',
        source: '为十字花科植物菘蓝的干燥根',
        ancientExamples: '《本草纲目》："主温毒发斑，咽喉肿痛"',
        usageAndDosage: '煎服9-15g，外用适量',
        medicalExamples: '流感、腮腺炎、病毒性肺炎'
    ),
    Herb(
        name: '薄荷',
        imagePath: 'assets/medic_picture/薄荷.png',
        description: '疏散风热，清利头目，利咽透疹',
        source: '唇形科植物薄荷的干燥地上部分',
        ancientExamples: '《本草新编》："最善解郁，尤善解风邪"',
        usageAndDosage: '3-6g后下，外用捣敷',
        medicalExamples: '风热感冒、头痛目赤、咽喉肿痛'
    ),
    Herb(
        name: '当归',
        imagePath: 'assets/medic_picture/当归.png',
        description: '补血活血，调经止痛，润肠通便',
        source: '伞形科植物当归的干燥根',
        ancientExamples: '《本草正》："其味甘而重，故专能补血"',
        usageAndDosage: '6-12g煎服，酒炒增强活血',
        medicalExamples: '血虚萎黄、月经不调、肠燥便秘'
    ),
    Herb(
        name: '防风',
        imagePath: 'assets/medic_picture/防风.png',
        description: '祛风解表，胜湿止痛，止痉',
        source: '伞形科植物防风的干燥根',
        ancientExamples: '《本草汇言》："主诸风周身不遂"',
        usageAndDosage: '4.5-9g煎服，外用熏洗',
        medicalExamples: '感冒头痛、风湿痹痛、破伤风'
    ),
    Herb(
        name: '茯苓',
        imagePath: 'assets/medic_picture/茯苓.png',
        description: '利水渗湿，健脾宁心',
        source: '多孔菌科真菌茯苓的干燥菌核',
        ancientExamples: '《神农本草经》列为上品',
        usageAndDosage: '9-15g煎服，朱砂拌安神',
        medicalExamples: '水肿尿少、脾虚食少、惊悸失眠'
    ),
    Herb(
        name: '枸杞',
        imagePath: 'assets/medic_picture/枸杞.png',
        description: '滋补肝肾，益精明目',
        source: '茄科植物宁夏枸杞的干燥成熟果实',
        ancientExamples: '《食疗本草》："坚筋耐老"',
        usageAndDosage: '6-12g煎服，可泡酒',
        medicalExamples: '虚劳精亏、腰膝酸痛、眩晕耳鸣'
    ),
    Herb(
        name: '桂枝',
        imagePath: 'assets/medic_picture/桂枝.png',
        description: '发汗解肌，温通经脉，助阳化气',
        source: '樟科植物肉桂的干燥嫩枝',
        ancientExamples: '《本草衍义》："治伤风头痛"',
        usageAndDosage: '3-9g煎服，血热忌用',
        medicalExamples: '风寒感冒、寒凝血滞诸痛症'
    ),
    Herb(
        name: '黄连',
        imagePath: 'assets/medic_picture/黄连.png',
        description: '清热燥湿，泻火解毒',
        source: '毛茛科植物黄连的干燥根茎',
        ancientExamples: '《药性论》："治五劳七伤"',
        usageAndDosage: '2-5g煎服，外用适量',
        medicalExamples: '湿热痞满、高热神昏、痈肿疔疮'
    ),
    Herb(
        name: '黄芪',
        imagePath: 'assets/medic_picture/黄芪.png',
        description: '补气升阳，固表止汗，利水消肿',
        source: '豆科植物蒙古黄芪的干燥根',
        ancientExamples: '《医学启源》："治虚劳自汗"',
        usageAndDosage: '9-30g煎服，蜜炙补中',
        medicalExamples: '气虚乏力、食少便溏、中气下陷'
    ),
    Herb(
        name: '人参',
        imagePath: 'assets/medic_picture/人参.png',
        description: '大补元气，复脉固脱，补脾益肺',
        source: '五加科植物人参的干燥根',
        ancientExamples: '《神农本草经》："主补五脏"',
        usageAndDosage: '3-9g另煎，挽救虚脱15-30g',
        medicalExamples: '体虚欲脱、脾虚食少、肺虚喘咳'
    ),
    Herb(
        name: '石膏',
        imagePath: 'assets/medic_picture/石膏.png',
        description: '清热泻火，除烦止渴',
        source: '硫酸盐类矿物硬石膏族石膏',
        ancientExamples: '《名医别录》："除时气头痛身热"',
        usageAndDosage: '15-60g先煎，外用煅敷',
        medicalExamples: '高热烦渴、肺热喘咳、胃火牙痛'
    ),
    Herb(
        name: '金银花',
        imagePath: 'assets/medic_picture/金银花.png',
        description: '清热解毒，疏散风热',
        source: '忍冬科植物忍冬的干燥花蕾',
        ancientExamples: '《本草纲目》："治一切风湿气"',
        usageAndDosage: '6-15g煎服，外用捣敷',
        medicalExamples: '痈肿疔疮、风热感冒、温病发热'
    ),
    Herb(
        name: '麻黄',
        imagePath: 'assets/medic_picture/麻黄.png',
        description: '发汗解表，宣肺平喘，利水消肿',
        source: '麻黄科植物草麻黄的干燥草质茎',
        ancientExamples: '《本草正义》："轻清上浮"',
        usageAndDosage: '2-9g煎服，表虚自汗慎用',
        medicalExamples: '风寒感冒、胸闷喘咳、风水浮肿'
    ),
    Herb(
        name: '小花黄堇',
        imagePath: 'assets/medic_picture/小花黄堇.png',
        description: '清热解毒，杀虫止痒，消肿止痛',
        source: '罂粟科植物小花黄堇的全草',
        ancientExamples: '《湖南药物志》："治疮毒、疥癣"',
        usageAndDosage: '9-15g煎服，外用适量捣敷；孕妇忌用',
        medicalExamples: '痈肿疮毒、疥癣瘙痒、跌打损伤'
    ),
    Herb(
        name: '地锦苗',
        imagePath: 'assets/medic_picture/地锦苗.png',
        description: '活血止痛，清热止血，利湿解毒',
        source: '罂粟科植物地锦苗的全草或根',
        ancientExamples: '《滇南本草》："治跌打损伤，瘀血作痛"',
        usageAndDosage: '10-15g煎服，外用鲜品适量捣敷；脾胃虚寒者慎用',
        medicalExamples: '瘀血疼痛、吐血衄血、湿热黄疸、疮疡肿毒'
    ),
    Herb(
        name: '红豆蔻',
        imagePath: 'assets/medic_picture/红豆.png',
        description: '温中散寒，燥湿醒脾，开胃消食',
        source: '姜科植物大高良姜的干燥成熟果实',
        ancientExamples: '《本草纲目》："治脾胃虚寒，心腹胀痛"',
        usageAndDosage: '3-6g煎服，阴虚火旺者忌用',
        medicalExamples: '脘腹冷痛、寒湿吐泻、食积不化、饮酒过度'
    ),
    Herb(
        name: '蚁蚀草',
        imagePath: 'assets/medic_picture/蚁蚀草.png',
        description: '清热解毒，消肿散瘀，祛风止痒',
        source: '玄参科植物蚊母草的带虫瘿全草',
        ancientExamples: '《浙江药用植物志》："治跌打损伤，瘀血肿痛"',
        usageAndDosage: '15-30g煎服，外用鲜品捣敷；孕妇慎用',
        medicalExamples: '痈肿疮毒、跌打损伤、风湿痹痛、皮肤瘙痒'
    ),
    Herb(
        name: '毛轴鞭米蕨',
        imagePath: 'assets/medic_picture/毛轴鞭米蕨.png',
        description: '清热利湿，解毒消肿，止咳化痰',
        source: '金星蕨科植物毛轴假蹄盖蕨的全草',
        ancientExamples: '《福建药物志》："治湿热黄疸，小便不利"',
        usageAndDosage: '15-30g煎服，外用捣敷；脾胃虚寒者慎用',
        medicalExamples: '湿热黄疸、肺热咳嗽、疮疡肿毒、毒蛇咬伤'
    ),
    Herb(
        name: '野罂粟金粉蕨',
        imagePath: 'assets/medic_picture/野罂粟金粉蕨.png',
        description: '清热解毒，止咳平喘，收敛固涩',
        source: '罂粟科植物野罂粟的全草及果实',
        ancientExamples: '《新疆药用植物志》："治久咳喘息，神经性头痛"',
        usageAndDosage: '3-6g煎服（果实1-3g），本品有毒，应严格控制剂量，孕妇及儿童禁用',
        medicalExamples: '久咳不止、喘息胸闷、胃痛、泄泻、遗精'
    ),
    Herb(
        name: '卷柏铁线蕨',
        imagePath: 'assets/medic_picture/卷柏铁线蕨.png',
        description: '活血通经，止血生肌，清热解毒',
        source: '卷柏科植物卷柏或垫状卷柏的干燥全草',
        ancientExamples: '《神农本草经》："主五脏邪气，女子阴中寒热痛"',
        usageAndDosage: '5-10g煎服，外用研末撒；孕妇禁用，有出血倾向者慎用',
        medicalExamples: '经闭痛经、癥瘕痞块、跌打损伤、吐血、便血'
    ),
    Herb(
        name: '新兴尖毛蕨',
        imagePath: 'assets/medic_picture/新兴尖毛蕨.png',
        description: '清热利湿，凉血散瘀，解毒消肿',
        source: '金星蕨科植物渐尖毛蕨的全草',
        ancientExamples: '《贵州民间药物》："治痢疾，便血，小便不利"',
        usageAndDosage: '15-30g煎服，外用捣敷或煎水洗；虚寒证忌用',
        medicalExamples: '湿热痢疾、吐血、衄血、小便淋痛、痈肿疮毒'
    ),
    Herb(
        name: '野鸦椿',
        imagePath: 'assets/medic_picture/野鸦椿.png',
        description: '祛风除湿，止痛活血，健脾开胃',
        source: '省沽油科植物野鸦椿的根及果实',
        ancientExamples: '《福建药物志》："根治风湿骨痛，果实治胃痛"',
        usageAndDosage: '根15-30g、果实3-9g煎服，外用根皮适量煎洗；孕妇慎用',
        medicalExamples: '风湿痹痛、跌打损伤、胃痛泄泻、月经不调、疝气'
    ),
    Herb(
        name: '光核勾儿茶',
        imagePath: 'assets/medic_picture/光核勾儿茶.png',
        description: '祛风通络，活血止痛，利水消肿',
        source: '鼠李科植物光枝勾儿茶的根或茎藤',
        ancientExamples: '《湖南药物志》："治风湿关节痛，跌打损伤"',
        usageAndDosage: '15-30g煎服，外用鲜品捣敷；气血虚弱者慎用',
        medicalExamples: '风湿关节痛、腰肌劳损、跌打损伤、水肿、痛经'
    ),
    Herb(
        name: '马甲子',
        imagePath: 'assets/medic_picture/马甲子.png',
        description: '祛风止痛，解毒消肿，活血散瘀',
        source: '鼠李科植物马甲子的根、叶及果实',
        ancientExamples: '《生草药性备要》："根治喉痛，叶敷恶疮"',
        usageAndDosage: '根15-30g、叶9-15g煎服，外用鲜叶捣敷；孕妇忌用',
        medicalExamples: '咽喉肿痛、风湿痹痛、跌打损伤、痈肿疮毒、毒蛇咬伤'
    ),
    Herb(
        name: '小菊花',
        imagePath: 'assets/medic_picture/小菊花.png',
        description: '疏散风热，清热解毒，平肝明目',
        source: '菊科植物野菊或甘菊的干燥头状花序',
        ancientExamples: '《本草纲目》："治头目风热，目赤肿痛"',
        usageAndDosage: '5-10g煎服（疏散风热用黄菊，平肝明目用白菊），脾胃虚寒者慎服',
        medicalExamples: '风热感冒、头痛眩晕、目赤肿痛、疮疡肿毒'
    ),
    Herb(
        name: '长葛蓬莱菜',
        imagePath: 'assets/medic_picture/长葛蓬莱菜.png',
        description: '清热解毒，消肿散结，活血止痛',
        source: '报春花科植物聚花过路黄的全草',
        ancientExamples: '《浙江民间常用草药》："治咽喉肿痛，痈肿疮毒"',
        usageAndDosage: '15-30g煎服，外用鲜品捣敷；孕妇及血虚者慎用',
        medicalExamples: '咽喉肿痛、痈肿疔疮、跌打损伤、毒蛇咬伤'
    ),
    Herb(
        name: '西跌草',
        imagePath: 'assets/medic_picture/西跌草.png',
        description: '祛风除湿，活血通络，消肿止痛',
        source: '茜草科植物丰花草的全草',
        ancientExamples: '《海南本草》："治风湿关节痛，跌打损伤"',
        usageAndDosage: '15-30g煎服，外用鲜草捣敷或煎水洗；无瘀滞者忌用',
        medicalExamples: '风湿痹痛、跌打损伤、腰肌劳损、痈肿疮毒、湿疹'
    ),
    Herb(
        name: '红花西跌草',
        imagePath: 'assets/medic_picture/红花西跌草.png',
        description: '活血化瘀，消肿止痛，清热解毒',
        source: '菊科植物红花西蕃莲的全草',
        ancientExamples: '《云南中草药》："治跌打损伤，瘀血肿痛"',
        usageAndDosage: '10-15g煎服，外用鲜品捣敷；孕妇及月经过多者忌用',
        medicalExamples: '跌打损伤、瘀血肿痛、风湿痹痛、痈肿疮毒、毒蛇咬伤'
    ),
    Herb(
        name: '尼泊尔充篷草',
        imagePath: 'assets/medic_picture/尼泊尔充篷草.png',
        description: '清热解毒，利湿通淋，活血止血',
        source: '蓼科植物尼泊尔蓼的全草',
        ancientExamples: '《西藏常用中草药》："治痢疾，便血，外伤出血"',
        usageAndDosage: '10-15g煎服，外用适量捣敷或研末撒；脾胃虚寒者慎服',
        medicalExamples: '痢疾、泄泻、便血、尿血、外伤出血、痈肿疮毒'
    ),
    Herb(
        name: '展毛野牡丹',
        imagePath: 'assets/medic_picture/展毛野牡丹.png',
        description: '收敛止血，清热解毒，祛风除湿',
        source: '野牡丹科植物展毛野牡丹的根及全草',
        ancientExamples: '《福建药物志》："治肠炎，痢疾，便血"',
        usageAndDosage: '根15-30g、全草10-15g煎服，外用鲜品捣敷；孕妇慎用',
        medicalExamples: '肠炎、痢疾、便血、月经过多、风湿痹痛、跌打损伤、痈肿疮毒'
    ),
    Herb(
        name: '鸡矢藤',
        imagePath: 'assets/medic_picture/鸡矢藤.png',
        description: '祛风除湿，消食化积，解毒消肿',
        source: '茜草科植物鸡矢藤的全草及根',
        ancientExamples: '《生草药性备要》："治胃痛，疳积，疮疡"',
        usageAndDosage: '15-30g煎服（鲜品加倍），外用捣敷或煎水洗；忌与辛辣食物同服',
        medicalExamples: '风湿痹痛、胃痛、食积腹胀、小儿疳积、痢疾、湿疹、疮疡肿毒'
    ),
    Herb(
        name: '翻果菊',
        imagePath: 'assets/medic_picture/翻果菊.png',
        description: '清热解毒，消肿止痛，明目退翳',
        source: '菊科植物翻白叶菊的全草',
        ancientExamples: '《滇南本草》："治目赤肿痛，翳膜遮睛"',
        usageAndDosage: '10-15g煎服，外用适量捣敷或煎水熏洗；脾胃虚寒者忌用',
        medicalExamples: '目赤肿痛、翳膜遮睛、痈肿疮毒、跌打损伤、水火烫伤'
    ),
    Herb(
        name: '筋骨草',
        imagePath: 'assets/medic_picture/筋骨草.png',
        description: '清热解毒，凉血消肿，祛风除湿',
        source: '唇形科植物筋骨草的全草',
        ancientExamples: '《本草拾遗》："主金疮，止血，长肌"',
        usageAndDosage: '10-15g煎服，外用适量捣敷或研末撒；脾胃虚寒者慎服',
        medicalExamples: '咽喉肿痛、肺热咳嗽、吐血、衄血、跌打损伤、痈肿疮毒、风湿痹痛'
    ),
    Herb(
        name: '细风轮菜',
        imagePath: 'assets/medic_picture/细风轮菜.png',
        description: '疏风清热，解毒消肿，止血止痛',
        source: '唇形科植物细风轮菜的全草',
        ancientExamples: '《湖南药物志》："治感冒发热，咽喉肿痛，肠炎痢疾"',
        usageAndDosage: '15-30g煎服，外用鲜品捣敷；表虚多汗者慎用',
        medicalExamples: '感冒发热、咽喉肿痛、肠炎痢疾、乳腺炎、跌打损伤、外伤出血'
    ),
    Herb(
        name: '灯亮草',
        imagePath: 'assets/medic_picture/灯亮草.png',
        description: '利水通淋，清心降火，消肿止痛',
        source: '灯心草科植物灯心草的干燥茎髓',
        ancientExamples: '《本草纲目》："降心火，通气，治五淋"',
        usageAndDosage: '1-3g煎服，外用煅存性研末撒；虚寒者忌用',
        medicalExamples: '小便不利、淋证涩痛、心烦失眠、口舌生疮、咽喉肿痛'
    ),
    Herb(
        name: '针茅菊',
        imagePath: 'assets/medic_picture/针茅菊.png',
        description: '祛风除湿，活血止痛，解毒消肿',
        source: '菊科植物针茅叶紫菀的全草',
        ancientExamples: '《青藏高原药物图鉴》："治风湿痹痛，跌打损伤"',
        usageAndDosage: '10-15g煎服，外用鲜品捣敷；孕妇及血虚者忌用',
        medicalExamples: '风湿痹痛、跌打损伤、腰肌劳损、痈肿疮毒、毒蛇咬伤'
    ),
    Herb(
        name: '夜香树',
        imagePath: 'assets/medic_picture/夜香树.png',
        description: '疏风解表，止咳平喘，活血消肿',
        source: '茄科植物夜香树的叶及嫩枝',
        ancientExamples: '《福建药物志》："治感冒发热，咳嗽气喘，痈肿疮毒"',
        usageAndDosage: '10-15g煎服，外用鲜品捣敷；孕妇及低血压者慎服',
        medicalExamples: '感冒发热、咳嗽气喘、风湿痹痛、跌打损伤、痈肿疮毒'
    ),
    Herb(
        name: '夜香藤',
        imagePath: 'assets/medic_picture/夜香藤.png',
        description: '祛风除湿，活血通络，解毒消肿',
        source: '萝藦科植物夜来香的藤茎及叶',
        ancientExamples: '《岭南采药录》："治风湿痹痛，跌打损伤，蛇虫咬伤"',
        usageAndDosage: '15-30g煎服，外用鲜品捣敷；孕妇忌用',
        medicalExamples: '风湿痹痛、跌打损伤、毒蛇咬伤、痈肿疮毒、湿疹皮炎'
    ),
    Herb(
        name: '鬼针草',
        imagePath: 'assets/medic_picture/鬼针草.png',
        description: '清热解毒，散瘀消肿，祛风除湿',
        source: '菊科植物鬼针草的全草',
        ancientExamples: '《本草拾遗》："主蛇伤，疟疾，疮疡"',
        usageAndDosage: '15-30g煎服（鲜品50-100g），外用捣敷；低血压者慎服',
        medicalExamples: '感冒发热、咽喉肿痛、肠炎痢疾、毒蛇咬伤、跌打损伤、风湿痹痛'
    ),
    Herb(
        name: '东风菊',
        imagePath: 'assets/medic_picture/东风菊.png',
        description: '疏风清热，祛痰止咳，明目解毒',
        source: '菊科植物东风菊的全草或根',
        ancientExamples: '《长白山植物药志》："治感冒头痛，咳嗽痰多，目赤肿痛"',
        usageAndDosage: '10-15g煎服，外用鲜品捣敷；脾胃虚寒者慎服',
        medicalExamples: '感冒发热、咳嗽气喘、咽喉肿痛、目赤多泪、痈肿疮毒'
    ),
    Herb(
        name: '瑞英',
        imagePath: 'assets/medic_picture/瑞英.png',
        description: '祛风除湿，活血止痛，解毒消肿',
        source: '瑞香科植物瑞香的根、茎、叶',
        ancientExamples: '《本草纲目》："治风湿痹痛，跌打损伤，咽喉肿痛"',
        usageAndDosage: '3-9g煎服，外用研末调敷或鲜品捣敷；孕妇忌用',
        medicalExamples: '风湿痹痛、跌打损伤、牙痛、咽喉肿痛、疮疡肿毒'
    ),
    Herb(
        name: '天名精',
        imagePath: 'assets/medic_picture/天名精.png',
        description: '清热解毒，化痰止咳，杀虫止痒',
        source: '菊科植物天名精的全草',
        ancientExamples: '《神农本草经》："主瘀血血瘕，下血，止血"',
        usageAndDosage: '10-15g煎服（鲜品30-60g），外用捣敷或煎水洗；脾胃虚寒者忌用',
        medicalExamples: '咽喉肿痛、咳嗽痰多、吐血衄血、虫蛇咬伤、皮肤瘙痒'
    ),
    Herb(
        name: '天冬',
        imagePath: 'assets/medic_picture/天冬.png',
        description: '养阴润燥，清肺生津，滋肾降火',
        source: '百合科植物天冬的块根',
        ancientExamples: '《本草纲目》："治肺痿肺痈，咳嗽吐血，消渴便秘"',
        usageAndDosage: '6-12g煎服，外用研末调敷；虚寒泄泻及外感风寒致嗽者忌用',
        medicalExamples: '阴虚干咳、肺燥咳嗽、津伤口渴、内热消渴、肠燥便秘'
    ),
    Herb(
        name: '长葶万年竹',
        imagePath: 'assets/medic_picture/长葶万年竹.png',
        description: '润肺止咳，养心安神，健脾消积',
        source: '百合科植物长葶万寿竹的根及根茎',
        ancientExamples: '《云南中草药》："治肺虚咳嗽，心悸失眠，食积饱胀"',
        usageAndDosage: '15-30g煎服，外用鲜品捣敷；孕妇慎服',
        medicalExamples: '肺虚久咳、心悸失眠、食欲不振、小儿疳积、跌打损伤'
    ),
    Herb(
        name: '使君子',
        imagePath: 'assets/medic_picture/使君子.png',
        description: '杀虫消积，健脾和胃',
        source: '使君子科植物使君子的成熟果实',
        ancientExamples: '《开宝本草》："主小儿五疳，小便白浊，杀虫"',
        usageAndDosage: '3-9g煎服（小儿每岁1-1.5粒，每日总量不超过20粒），炒香嚼服；忌与热茶同服，过量易致呃逆、呕吐',
        medicalExamples: '蛔虫病、蛲虫病、小儿疳积、消化不良、腹痛腹胀'
    ),
    Herb(
        name: '大拟莎草',
        imagePath: 'assets/medic_picture/大拟莎草.png',
        description: '清热利水，化痰止咳，消肿解毒',
        source: '莎草科植物大拟莎草的全草',
        ancientExamples: '《岭南采药录》："治小便不利，咳嗽痰喘，痈肿疮毒"',
        usageAndDosage: '15-30g煎服，外用鲜品捣敷；孕妇慎用',
        medicalExamples: '水肿胀满、小便不利、咳嗽痰多、咽喉肿痛、疮疡肿毒'
    ),
    Herb(
        name: '西溪莎草',
        imagePath: 'assets/medic_picture/西溪莎草.png',
        description: '行气活血，利湿通淋，祛风止痒',
        source: '莎草科植物西溪莎草的全草',
        ancientExamples: '《福建药物志》："治月经不调，小便淋痛，皮肤瘙痒"',
        usageAndDosage: '10-15g煎服，外用煎水洗或捣敷；气血虚弱者慎用',
        medicalExamples: '月经不调、痛经闭经、小便淋涩、风湿痹痛、湿疹瘙痒'
    ),
    Herb(
        name: '圆头莎草',
        imagePath: 'assets/medic_picture/圆头莎草.png',
        description: '祛风除湿，活血止痛，化积消滞',
        source: '莎草科植物圆头莎草的全草',
        ancientExamples: '《贵州民间药物》："治风湿关节痛，跌打损伤，食积腹胀"',
        usageAndDosage: '15-25g煎服，外用捣敷或煎水洗；孕妇忌用',
        medicalExamples: '风湿痹痛、跌打损伤、食积不化、小儿疳积、皮肤疮癣'
    ),
    Herb(
        name: '石南藤',
        imagePath: 'assets/medic_picture/石南藤.png',
        description: '祛风除湿，活血止痛，补肾壮阳',
        source: '胡椒科植物石南藤的茎、叶',
        ancientExamples: '《本草纲目》："主风寒湿痹，肾虚腰痛，阳痿遗精"',
        usageAndDosage: '6-12g煎服，外用煎水洗或浸酒搽；阴虚火旺者忌用',
        medicalExamples: '风湿痹痛、腰肌劳损、肾虚腰痛、阳痿早泄、风寒感冒'
    ),
    Herb(
        name: '陕甘花楸',
        imagePath: 'assets/medic_picture/陕甘花楸.png',
        description: '止咳平喘，健胃消食，止血散瘀',
        source: '蔷薇科植物陕甘花楸的果实、茎皮',
        ancientExamples: '《秦岭植物志》："治咳嗽气喘，食积腹胀，跌打损伤"',
        usageAndDosage: '果实10-15g煎服，茎皮6-9g煎服；外用研末撒或捣敷',
        medicalExamples: '慢性咳嗽、哮喘、消化不良、食积腹痛、跌打损伤、外伤出血'
    ),
    Herb(
        name: '日本落叶松',
        imagePath: 'assets/medic_picture/日本落叶松.png',
        description: '祛风除湿，活血止痛，收敛止血',
        source: '松科植物日本落叶松的树皮、球果',
        ancientExamples: '《东北药用植物志》："治风湿痹痛，跌打损伤，肠风下血"',
        usageAndDosage: '树皮9-15g煎服，球果6-9g煎服；外用研末撒或煎水洗',
        medicalExamples: '风湿性关节炎、腰腿痛、跌打损伤、便血、外伤出血、慢性痢疾'
    ),
    Herb(
        name: '柞木溲疏',
        imagePath: 'assets/medic_picture/柞木溲疏.png',
        description: '清热解毒，消肿止痛，止咳祛痰',
        source: '虎耳草科植物柞木溲疏的根、叶',
        ancientExamples: '《浙江药用植物志》："治感冒发热，咽喉肿痛，痈肿疮毒"',
        usageAndDosage: '根15-30g煎服，叶9-15g煎服；外用鲜叶捣敷或煎水洗',
        medicalExamples: '感冒发热、咽喉肿痛、肺热咳嗽、痈肿疮毒、跌打损伤'
    ),
    Herb(
        name: '柞木松',
        imagePath: 'assets/medic_picture/柞木松.png',
        description: '祛风除湿，活血散瘀，消肿止痛',
        source: '大风子科植物柞木的根、叶',
        ancientExamples: '《本草纲目》："治黄疸水肿，跌打损伤，痈肿疮毒"',
        usageAndDosage: '根15-30g煎服，叶9-15g煎服；外用煎水洗或捣敷；孕妇忌用',
        medicalExamples: '风湿痹痛、跌打损伤、黄疸型肝炎、水肿、痈肿疮毒、外伤出血'
    ),
    Herb(
        name: '蛇足山旋花',
        imagePath: 'assets/medic_picture/蛇足山旋花.png',
        description: '祛风除湿，活血通络，解毒消肿',
        source: '旋花科植物蛇足山旋花的全草',
        ancientExamples: '《云南药用植物志》："治风湿痹痛、跌打损伤、痈肿疮毒"',
        usageAndDosage: '15-30g煎服，外用鲜品捣敷；孕妇慎用',
        medicalExamples: '风湿关节痛、腰肌劳损、跌打损伤、疮疡肿毒、毒蛇咬伤'
    ),
    Herb(
        name: '金豆',
        imagePath: 'assets/medic_picture/金豆.png',
        description: '理气止痛，化痰止咳，消食健胃',
        source: '芸香科植物金豆的果实、根',
        ancientExamples: '《福建药物志》："治胃痛、咳嗽、食积腹胀"',
        usageAndDosage: '果实9-15g煎服，根15-30g煎服；气虚者慎用',
        medicalExamples: '胃脘胀痛、消化不良、咳嗽痰多、疝气疼痛、咽喉肿痛'
    ),
    Herb(
        name: '朱槿',
        imagePath: 'assets/medic_picture/朱槿.png',
        description: '清热利湿，解毒消肿，凉血止血',
        source: '锦葵科植物朱槿的花、叶、根',
        ancientExamples: '《本草纲目》："治痈疽疮疡、尿路感染、咳血、衄血"',
        usageAndDosage: '花3-9g煎服，叶6-15g煎服，根9-15g煎服；外用鲜品捣敷',
        medicalExamples: '肺热咳嗽、尿路感染、痢疾、便血、疮疡肿毒、外伤出血'
    ),
    Herb(
        name: '细风轮菜（变种）',
        imagePath: 'assets/medic_picture/细风轮菜（变种）.png',
        description: '清热解毒，止血消肿，疏风散热',
        source: '唇形科植物细风轮菜变种的全草',
        ancientExamples: '《岭南采药录》："治感冒发热、吐血、衄血、跌打损伤"',
        usageAndDosage: '15-30g煎服，外用鲜品捣敷或研末撒；脾胃虚寒者慎用',
        medicalExamples: '感冒发热、咽喉肿痛、吐血、衄血、崩漏、跌打损伤、疮疡肿毒'
    ),
    Herb(
        name: '木兰',
        imagePath: 'assets/medic_picture/木兰.png',
        description: '祛风散寒，宣肺止咳，通窍止痛',
        source: '木兰科植物木兰的花蕾、树皮',
        ancientExamples: '《本草经集注》："治风寒感冒、头痛鼻塞、咳嗽气喘"',
        usageAndDosage: '花蕾3-9g煎服，树皮6-12g煎服；阴虚火旺者忌用',
        medicalExamples: '风寒感冒、头痛、鼻塞、鼻渊、咳嗽气喘、风湿痹痛'
    ),
    Herb(
        name: '钩叶地黄',
        imagePath: 'assets/medic_picture/钩叶地黄.png',
        description: '滋阴补肾，凉血止血，养阴生津',
        source: '玄参科植物钩叶地黄的块根',
        ancientExamples: '《广西药用植物名录》："治肾虚腰痛、阴虚发热、血热出血"',
        usageAndDosage: '10-30g煎服，鲜品加倍；脾虚泄泻者忌用',
        medicalExamples: '腰膝酸软、头晕耳鸣、骨蒸潮热、血热吐血、衄血、津伤口渴'
    ),
    Herb(
        name: '柞木溲疏（变种）',
        imagePath: 'assets/medic_picture/柞木溲疏（变种）.png',
        description: '清热解毒，消肿止痛，祛痰止咳',
        source: '虎耳草科植物柞木溲疏变种的根、叶',
        ancientExamples: '《浙江药用植物志》："治感冒发热、咽喉肿痛、咳嗽痰多"',
        usageAndDosage: '根15-30g煎服，叶9-15g煎服；外用鲜叶捣敷',
        medicalExamples: '感冒发热、咽喉肿痛、肺热咳嗽、痈肿疮毒、跌打损伤'
    ),
    Herb(
        name: '叶萼',
        imagePath: 'assets/medic_picture/叶萼.png',
        description: '收敛止血，解毒消肿，理气和胃（功效因植物而异）',
        source: '植物花萼或宿存花萼',
        ancientExamples: '《本草便读》："部分植物叶萼可代花入药，如柿蒂（宿存花萼）治呃逆"',
        usageAndDosage: '3-9g煎服，外用适量；需根据具体植物调整用量',
        medicalExamples: '出血症（如崩漏、外伤出血）、疮疡肿毒、胃脘胀痛（具体功效随植物不同变化）'
    ),
    Herb(
        name: '南川盾民盾草',
        imagePath: 'assets/medic_picture/南川盾民盾草.png',
        description: '清热解毒，散瘀消肿，利湿通淋',
        source: '（假设为）茜草科盾民盾草属变种的全草',
        ancientExamples: '《重庆草药》："治痈疮肿毒、尿路感染、跌打损伤"（注：需考证原植物归属）',
        usageAndDosage: '15-30g煎服，外用鲜品捣敷；脾胃虚寒者慎用',
        medicalExamples: '疮疡肿毒、尿路感染、湿热黄疸、跌打瘀痛、风湿痹痛'
    ),
    Herb(
        name: '盾盾草',
        imagePath: 'assets/medic_picture/盾盾草.png',
        description: '祛风除湿，活血止痛，止咳平喘',
        source: '（假设为）马鞭草科植物盾盾草的全草',
        ancientExamples: '《云南药用植物名录》："治风湿关节痛、咳嗽、哮喘"（注：需确认学名）',
        usageAndDosage: '9-15g煎服，外用煎水洗；孕妇忌用',
        medicalExamples: '风湿痹痛、腰肌劳损、咳嗽气喘、跌打损伤、皮肤瘙痒'
    ),
    Herb(
        name: '报春花',
        imagePath: 'assets/medic_picture/报春花.png',
        description: '清热解毒，祛痰止咳，活血调经',
        source: '报春花科植物报春花的全草或花',
        ancientExamples: '《西藏常用中草药》："治咽喉肿痛、肺热咳嗽、月经不调"',
        usageAndDosage: '6-12g煎服，外用鲜品捣敷；脾胃虚寒者少食',
        medicalExamples: '感冒发热、咽喉肿痛、肺热咳嗽、月经不调、跌打损伤、痈肿疮毒'
    ),
    Herb(
        name: '长葶万年竹变种',
        imagePath: 'assets/medic_picture/长葶万寿竹.png',
        description: '滋阴润燥，清热生津，养心安神',
        source: '百合科万年竹属变种的根茎或全草',
        ancientExamples: '《福建药物志》："治阴虚内热、口干烦渴、心悸失眠"（注：需考证原植物）',
        usageAndDosage: '10-20g煎服，鲜品30-60g；脾虚便溏者慎用',
        medicalExamples: '热病伤津、口干舌燥、心烦失眠、阴虚咳嗽、腰膝酸软'
    ),
    Herb(
        name: '落叶松（变种）',
        imagePath: 'assets/medic_picture/落叶松 (变种).png',
        description: '祛风除湿，活血止痛，收敛止血',
        source: '松科落叶松属变种的树皮、球果、叶',
        ancientExamples: '《东北药用植物志》："树皮治风湿痹痛，球果治痢疾"',
        usageAndDosage: '树皮9-15g煎服，球果6-9g煎服；外用树皮研末撒',
        medicalExamples: '风湿关节痛、腰腿痛、跌打损伤、痢疾、肠风下血、外伤出血'
    ),
    Herb(
        name: '毛鹊树（变种）',
        imagePath: 'assets/medic_picture/毛鹊树 (变种).png',
        description: '清热解毒，利咽消肿，活血散瘀',
        source: '（假设为）山茱萸科毛鹊树属变种的根、叶',
        ancientExamples: '《浙江天目山药用植物志》："治咽喉肿痛、痈肿疮毒、跌打损伤"（注：需确认科属）',
        usageAndDosage: '根15-30g煎服，叶9-15g煎服；外用鲜叶捣敷',
        medicalExamples: '咽喉肿痛、扁桃体炎、痈疮肿毒、跌打瘀痛、风湿痹痛'
    )
  ];

  @override
  State<MedicinalMaterialsOverviewPage> createState() =>
      _MedicinalMaterialsOverviewPageState();
}

class _MedicinalMaterialsOverviewPageState
    extends State<MedicinalMaterialsOverviewPage> {
  // ✅ 新增: 用于搜索的控制器和状态
  final TextEditingController _searchController = TextEditingController();
  late List<Herb> _filteredHerbs;

  @override
  void initState() {
    super.initState();
    // 初始状态下，显示所有药材
    _filteredHerbs = widget.herbs;
    // 添加监听器，当搜索框内容变化时，触发筛选
    _searchController.addListener(_filterHerbs);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterHerbs);
    _searchController.dispose();
    super.dispose();
  }

  /// ✅ 新增: 根据搜索框的文本筛选列表
  void _filterHerbs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredHerbs = widget.herbs.where((herb) {
        final herbName = herb.name.toLowerCase();
        return herbName.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '药材总览',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      // ✅ 将主体内容包裹在 Column 中，以添加搜索框
      body: Column(
        children: [
          // ==================== 新增的搜索框 ====================
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '按药材名称搜索...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.r),
                  borderSide: BorderSide.none,
                ),
                // 添加清除按钮
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
                    : null,
              ),
            ),
          ),
          // ======================================================

          // ✅ 使用 Expanded 包裹列表，使其填充剩余空间
          Expanded(
            child: _filteredHerbs.isEmpty
                ? _buildEmptyState() // 显示未找到结果的提示
                : GridView.builder(
              padding: EdgeInsets.all(16.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 0.8,
              ),
              itemCount: _filteredHerbs.length,
              itemBuilder: (context, index) {
                final herb = _filteredHerbs[index];
                return _buildHerbCard(context, herb, widget.herbs.indexOf(herb));
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建单个药材的卡片。
  Widget _buildHerbCard(BuildContext context, Herb herb, int originalIndex) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedicinalMaterialDetailPage(
                herbs: widget.herbs, // 依然传递完整的列表
                initialIndex: originalIndex, // 传递它在原始列表中的索引
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  herb.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.grass, color: Colors.grey, size: 40);
                  },
                ),
              ),
            ),
            Container(
              height: 60.h,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    herb.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    herb.description,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ 新增: 当搜索结果为空时显示的提示
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined, size: 80.sp, color: Colors.grey.shade400),
          SizedBox(height: 16.h),
          Text(
            '未找到匹配的药材',
            style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}