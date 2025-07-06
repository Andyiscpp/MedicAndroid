// lib/map/map_page.dart

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

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

  List<MapMarker> _markers = [];
  late MapZoomPanBehavior _zoomPanBehavior;

  Key _mapKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    // Initialize with default behavior
    _zoomPanBehavior = MapZoomPanBehavior(
      focalLatLng: const MapLatLng(36.0, 104.0), // 中国地理中心大致位置
      zoomLevel: 4,
      enablePinching: true,
      enablePanning: true,
    );
    _loadAllLocations();
  }

  Future<void> _loadAllLocations() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final allData = await _dataService.getAllUploadsData();
    final List<MapMarker> newMarkers = [];

    print("--- [MapPage] 地图页收到的数据条数: ${allData.length} ---");

    for (final data in allData) {
      for (final loc in data.locations) {
        if (loc.latitude != 0.0 && loc.longitude != 0.0) {
          print("--- [MapPage] 正在创建标记点，坐标: Lat=${loc.latitude}, Lng=${loc.longitude} ---");
          newMarkers.add(
            MapMarker(
              latitude: loc.latitude,
              longitude: loc.longitude,
              child: Tooltip(
                message: "${data.herb.name}\n${loc.address}",
                child: const Icon(Icons.location_pin, color: Colors.blueAccent, size: 30),
              ),
            ),
          );
        } else {
          print("--- [MapPage] 警告: 跳过一个无效坐标的记录 (0,0) ---");
        }
      }
    }

    if (!mounted) return;

    setState(() {
      _markers = newMarkers;
      _isLoading = false;
      _mapKey = UniqueKey();

      // ✅ *** 核心修复点 ***
      // 当数据更新时，不仅更新markers和key，还要创建一个全新的MapZoomPanBehavior对象
      // 这可以确保新的SfMaps widget得到一个干净的、无状态污染的控制器。
      if (_markers.isNotEmpty) {
        _zoomPanBehavior = MapZoomPanBehavior(
          focalLatLng: MapLatLng(
              _markers.first.latitude, _markers.first.longitude),
          zoomLevel: 8,
          enablePinching: true,
          enablePanning: true,
        );
      } else {
        // 如果没有标记点，则重置回默认的中国视图
        _zoomPanBehavior = MapZoomPanBehavior(
          focalLatLng: const MapLatLng(36.0, 104.0),
          zoomLevel: 4,
          enablePinching: true,
          enablePanning: true,
        );
      }
    });
    print("--- [MapPage] setState 已调用，标记点数量: ${_markers.length} ---");
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
          SfMaps(
            key: _mapKey,
            layers: <MapLayer>[
              MapTileLayer(
                urlTemplate: 'https://wprd01.is.autonavi.com/appmaptile?style=7&x={x}&y={y}&z={z}',
                zoomPanBehavior: _zoomPanBehavior,
                initialMarkersCount: _markers.length,
                markerBuilder: (BuildContext context, int index) {
                  return _markers[index];
                },
                markerTooltipBuilder: (BuildContext context, int index) {
                  final marker = _markers[index];
                  if (marker.child is Tooltip) {
                    final tooltip = marker.child as Tooltip;
                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tooltip.message ?? "未知位置",
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ],
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),

          if (!_isLoading)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '共 ${_markers.length} 个标记点',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ),

          if (!_isLoading)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: AppColors.primary,
                onPressed: _loadAllLocations,
                child: const Icon(Icons.refresh, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
