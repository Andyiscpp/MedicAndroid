// lib/map/map_page.dart

import 'package:flutter/material.dart';
// 1. 导入 Syncfusion Maps 插件包
import 'package:syncfusion_flutter_maps/maps.dart';

// 导入您项目中的文件
import 'package:demo_conut/data/models/medicinal_data.dart' as model;
import 'package:demo_conut/services/medicinal_data_service.dart';
import 'package:demo_conut/pages/home_page.dart'; // For AppColors

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MedicinalDataService _dataService = MedicinalDataService();
  bool _isLoading = true;

  // 2. 使用新的数据源来存储标记点
  late MapModel _mapModel;

  // 3. 用于控制地图的缩放和中心点
  late MapZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    // 初始化地图数据模型
    _mapModel = MapModel([]);

    // 4. 初始化地图的初始视角
    _zoomPanBehavior = MapZoomPanBehavior(
      focalLatLng: const MapLatLng(29.5630, 106.5516), // 中国中心
      zoomLevel: 8,
      enablePinching: true, // 允许双指缩放
    );

    // 加载您的药材数据
    _loadAllLocations();
  }

  // 加载并显示所有药材位置的标记点
  Future<void> _loadAllLocations() async {
    setState(() {
      _isLoading = true;
    });

    final allData = await _dataService.getAllData();
    final List<MapMarker> newMarkers = [];

    // ✅ 调试点 4: 打印地图页收到的数据数量
    print("--- [MapPage] 地图页收到的数据条数: ${allData.length} ---");


    for (final data in allData) {
      for (final loc in data.locations) {

        // ✅ 调试点 5: 打印正在创建的每个标记的坐标
        print("--- [MapPage] 正在创建标记点，坐标: Lat=${loc.latitude}, Lng=${loc.longitude} ---");

        newMarkers.add(
          MapMarker(
            latitude: loc.latitude,
            longitude: loc.longitude,
            // 5. 您可以自定义标记点的外观
            child: Tooltip(
              message: "${data.herb.name}\n${loc.address}",
              child: const Icon(Icons.location_pin, color: Colors.redAccent, size: 30),
            ),
          ),
        );
      }
    }

    if (!mounted) return;

    // 6. 更新数据源并刷新地图
    setState(() {
      _mapModel = MapModel(newMarkers);
      _isLoading = false;

      // 如果有标记点，将地图视野移动到第一个点的位置
      if (newMarkers.isNotEmpty) {
        _zoomPanBehavior.focalLatLng = MapLatLng(
            newMarkers.first.latitude, newMarkers.first.longitude);
        _zoomPanBehavior.zoomLevel = 10;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '药材地理分布图',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 7. 使用 SfMaps 作为地图主组件
          SfMaps(
            layers: <MapLayer>[
              // 地图瓦片图层，负责显示地图背景
              MapTileLayer(
                urlTemplate: 'https://wprd01.is.autonavi.com/appmaptile?style=7&x={x}&y={y}&z={z}',
                zoomPanBehavior: _zoomPanBehavior,
                // 标记点图层
                initialMarkersCount: _mapModel.markers.length,
                markerBuilder: (BuildContext context, int index) {
                  return _mapModel.markers[index];
                },
              ),
            ],
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}

/// 8. 用于存储地图标记点的数据模型
class MapModel {
  const MapModel(this.markers);
  final List<MapMarker> markers;
}

