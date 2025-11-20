

import 'package:easy_pc/models/case.dart';
import 'package:easy_pc/models/graphics_card.dart';
import 'package:easy_pc/models/motherboard.dart';
import 'package:easy_pc/models/pc_type.dart';
import 'package:easy_pc/models/power_supply.dart';
import 'package:easy_pc/models/processor.dart';
import 'package:easy_pc/models/ram.dart';

class PC {
  static Map<String, dynamic> emptyMap() => {
    'name': '',
    'price': 0,
    'pcTypeId': 0,
    'available': true,
    'processorId': 0,
    'caseId': 0,
    'motherBoardId': 0,
    'powerSupplyId': 0,
    'ramId': 0,
    'graphicsCardId': 0,
    'picture': '',
    'averageRating': 0,
  };

  final int? id;
  final int? price;
  final String? name;
  final int? pcTypeId;
  final PcType? pcType;
  final bool? available;
  final int? processorId;
  final int? caseId;
  final int? motherBoardId;
  final int? powerSupplyId;
  final int? ramId;
  final int? graphicsCardId;
  final String? picture;
  final int? averageRating;
  final GraphicsCard? graphicsCard;
  final Processor? processor;
  final Case? cases;
  final PowerSupply? powerSupply;
  final MotherBoard? motherboard;
  final Ram? ram;

  const PC({
    this.id,
    this.price,
    this.name,
    this.pcTypeId,
    this.pcType,
    this.processorId,
    this.caseId,
    this.motherBoardId,
    this.powerSupplyId,
    this.ramId,
    this.graphicsCardId,
    this.available,
    this.picture,
    this.averageRating,
    this.graphicsCard,
    this.processor,
    this.cases,
    this.powerSupply,
    this.motherboard,
    this.ram,
  });

  factory PC.fromJson(Map<String, dynamic> json) {
    final psuId = json['powerSupplyId'] ?? json['psuId'];
    try{
    return PC(
      id: (json['id'] as num).toInt(),
      price: (json['price'] as num?)?.toInt(),
      name: json['name'] as String,
      processorId: (json['processorId'] as num).toInt(),
      caseId: (json['caseId'] as num).toInt(),
      motherBoardId: (json['motherBoardId'] as num).toInt(),
      powerSupplyId: (psuId as num).toInt(),
      ramId: (json['ramId'] as num).toInt(),
      graphicsCardId: (json['graphicsCardId'] as num).toInt(),
      available: json['available'] as bool,
      pcTypeId: (json['pcTypeId'] as num).toInt(),
      pcType: json['pcType'] != null ? PcType.fromJson(json['pcType']) : null,
      picture: json['picture'] as String?,
      averageRating: (json['averageRating'] as num?)?.toInt(),
      graphicsCard: GraphicsCard.fromJson(
        (json['graphicsCard']) as Map<String, dynamic>,
      ),
      processor: Processor.fromJson(
        (json['processor']) as Map<String, dynamic>,
      ),
      cases: Case.fromJson((json['case']) as Map<String, dynamic>),
      powerSupply: PowerSupply.fromJson(
        ((json['powerSupply'] ?? json['psu'])) as Map<String, dynamic>,
      ),
      motherboard: MotherBoard.fromJson(
        ((json['motherboard'] ?? json['motherBoard'])) as Map<String, dynamic>,
      ),
      ram: Ram.fromJson((json['ram']) as Map<String, dynamic>),
    );
    } catch (e) {
      throw Exception('Error parsing PC: $e');
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'price': price,
    'name': name,
    'processorId': processorId,
    'caseId': caseId,
    'motherBoardId': motherBoardId,
    'powerSupplyId': powerSupplyId,
    'ramId': ramId,
    'graphicsCardId': graphicsCardId,
    'available': available,
    'pcTypeId': pcTypeId,
    'picture': picture,
    'averageRating': averageRating,
    'graphicsCard': graphicsCard?.toJson(),
    'processor': processor?.toJson(),
    'case': cases?.toJson(),
    'powerSupply': powerSupply?.toJson(),
    'motherboard': motherboard?.toJson(),
    'ram': ram?.toJson(),
  };

  factory PC.fromMap(Map<String, dynamic> map) {
    return PC(
      id: map['id'] as int?,
      price: map['price'] is String
          ? int.tryParse(map['price'])
          : map['price'] as int?,
      name: map['name'] as String?,
      processorId: map['processorId'] is String
          ? int.tryParse(map['processorId'])
          : map['processorId'] as int?,
      caseId: map['caseId'] is String
          ? int.tryParse(map['caseId'])
          : map['caseId'] as int?,
      motherBoardId: map['motherBoardId'] is String
          ? int.tryParse(map['motherBoardId'])
          : map['motherBoardId'] as int?,
      powerSupplyId: map['powerSupplyId'] is String
          ? int.tryParse(map['powerSupplyId'])
          : map['powerSupplyId'] as int?,
      ramId: map['ramId'] is String
          ? int.tryParse(map['ramId'])
          : map['ramId'] as int?,
      graphicsCardId: map['graphicsCardId'] is String
          ? int.tryParse(map['graphicsCardId'])
          : map['graphicsCardId'] as int?,
      available: map['available'] as bool?,
      pcTypeId: map['pcTypeId'] is String
          ? int.tryParse(map['pcTypeId'])
          : map['pcTypeId'] as int?,
      picture: map['picture'] as String?,
      averageRating: map['averageRating'] is String
          ? int.tryParse(map['averageRating'])
          : map['averageRating'] as int?,
    );
  }
  Map<String, dynamic> toMap() => {
    'id': id,
    'price': price,
    'name': name,
    'processorId': processorId,
    'caseId': caseId,
    'motherBoardId': motherBoardId,
    'powerSupplyId': powerSupplyId,
    'ramId': ramId,
    'graphicsCardId': graphicsCardId,
    'available': available,
    'pcTypeId': pcTypeId,
    'picture': picture,
    'averageRating': averageRating,
  };
}
