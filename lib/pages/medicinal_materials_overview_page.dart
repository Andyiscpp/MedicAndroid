  import 'package:flutter/material.dart';
  import 'package:flutter_screenutil/flutter_screenutil.dart';
  import 'package:demo_conut/pages/home_page.dart'; // 导入AppColors以保持风格统一
  import 'package:demo_conut/pages/medicinal_material_detail_page.dart'; // ✅ 导入新的详情页面

  /// 用于表示单个药材的数据模型。
  class Herb {
    final String name;
    final String imagePath;
    final String description;
    // ✅ 新增字段
    final String source;
    final String ancientExamples;
    final String usageAndDosage;
    final String medicalExamples;


    const Herb({
      required this.name,
      required this.imagePath,
      required this.description,
      // ✅ 新增字段
      required this.source,
      required this.ancientExamples,
      required this.usageAndDosage,
      required this.medicalExamples,
    });
  }

  /// 一个用于显示药材网格的页面。
  class MedicinalMaterialsOverviewPage extends StatelessWidget {
    const MedicinalMaterialsOverviewPage({super.key});

    // 在实际应用中，这些数据很可能会从数据库或API获取。
    // ✅ 使用更新后的数据模型
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
      )
    ];

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
        body: GridView.builder(
          padding: EdgeInsets.all(16.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 每行显示两个项目
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 0.8, // 调整宽高比以获得更好的视觉布局
          ),
          itemCount: herbs.length,
          itemBuilder: (context, index) {
            final herb = herbs[index];
            return _buildHerbCard(context, herb, index); // ✅ 传递index
          },
        ),
      );
    }

    /// 构建单个药材的卡片。
    Widget _buildHerbCard(BuildContext context, Herb herb, int index) { // ✅ 接收index
      return Card(
        elevation: 2,
        shadowColor: AppColors.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // ✅ 修改这里的逻辑，导航到新的详情页
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MedicinalMaterialDetailPage(
                  herbs: herbs, // 传递整个列表
                  initialIndex: index, // 传递当前点击的索引
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
                      // 图片加载失败时的后备显示
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
  }