// lib/data/models/medicinal_data.dart


// 主数据类，对应最外层的JSON结构
class MedicinalData {
  final Herb herb;
  final List<Location> locations;
  final List<GrowthData> growthData;
  final List<ImageData> images;

  MedicinalData({
    required this.herb,
    required this.locations,
    required this.growthData,
    required this.images,
  });

  factory MedicinalData.fromMap(Map<String, dynamic> map) {
    return MedicinalData(
      herb: Herb.fromMap(map['herb'] ?? {}),
      locations: (map['locations'] as List? ?? [])
          .map((item) => Location.fromMap(item))
          .toList(),
      growthData: (map['growth_data'] as List? ?? [])
          .map((item) => GrowthData.fromMap(item))
          .toList(),
      images: (map['images'] as List? ?? [])
          .map((item) => ImageData.fromMap(item))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'herb': herb.toMap(),
      'locations': locations.map((item) => item.toMap()).toList(),
      'growth_data': growthData.map((item) => item.toMap()).toList(),
      'images': images.map((item) => item.toMap()).toList(),
    };
  }
}

// 药材基本信息
class Herb {
  int? id;
  final String name;
  final String scientificName;
  final String description;
  final String? uploaderName;

  Herb({
    this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    this.uploaderName,
  });

  // ✅ *** 核心修正点 ***
  // 为所有可能从JSON中接收到null的String字段提供默认值
  factory Herb.fromMap(Map<String, dynamic> map) {
    return Herb(
      id: map['id'],
      name: map['name'] ?? '未知名称', // 如果name为null，则默认为'未知名称'
      scientificName: map['scientificName'] ?? '', // 如果scientificName为null，则默认为空字符串
      description: map['description'] ?? '', // 如果description为null，则默认为空字符串
      uploaderName: map['uploaderName'], // uploaderName本身是可空的，所以无需??
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      // ✅ 后端字段名为 scientificName，请确保这里也一致
      'scientificName': scientificName,
      'description': description,
      'uploaderName': uploaderName,
    };
  }
}

// 地理位置信息
class Location {
  int? id;
  int? herbId;
  final double longitude;
  final double latitude;
  final String province;
  final String city;
  final String address;
  final int observationYear;

  Location({
    this.id,
    this.herbId,
    required this.longitude,
    required this.latitude,
    required this.province,
    required this.city,
    required this.address,
    required this.observationYear,
  });

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'],
      herbId: map['herb_id'],
      longitude: (map['longitude'] as num? ?? 0.0).toDouble(),
      latitude: (map['latitude'] as num? ?? 0.0).toDouble(),
      province: map['province'] ?? '',
      city: map['city'] ?? '',
      address: map['address'] ?? '',
      observationYear: map['observation_year'] ?? DateTime.now().year,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'herb_id': herbId,
      'longitude': longitude,
      'latitude': latitude,
      'province': province,
      'city': city,
      'address': address,
      'observation_year': observationYear,
    };
  }
}

// 生长数据
class GrowthData {
  int? id;
  int? locationId;
  final String metricName;
  final String metricValue;
  final String metricUnit;
  final DateTime recordedAt;

  GrowthData({
    this.id,
    this.locationId,
    required this.metricName,
    required this.metricValue,
    required this.metricUnit,
    required this.recordedAt,
  });

  factory GrowthData.fromMap(Map<String, dynamic> map) {
    return GrowthData(
      id: map['id'],
      locationId: map['location_id'],
      metricName: map['metric_name'] ?? '',
      metricValue: map['metric_value'] ?? '',
      metricUnit: map['metric_unit'] ?? '',
      recordedAt: DateTime.tryParse(map['recorded_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'location_id': locationId,
      'metric_name': metricName,
      'metric_value': metricValue,
      'metric_unit': metricUnit,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }
}

// 图片数据
class ImageData {
  int? id;
  int? herbId;
  final String url;
  final int isPrimary;
  final String description;

  ImageData({
    this.id,
    this.herbId,
    required this.url,
    required this.isPrimary,
    required this.description,
  });

  factory ImageData.fromMap(Map<String, dynamic> map) {
    return ImageData(
      id: map['id'],
      herbId: map['herb_id'],
      url: map['url'] ?? '',
      isPrimary: map['is_primary'] ?? 0,
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'herb_id': herbId,
      'url': url,
      'is_primary': isPrimary,
      'description': description,
    };
  }
}