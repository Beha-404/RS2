import 'package:easy_pc/models/case.dart';
import 'package:easy_pc/models/graphics_card.dart';
import 'package:easy_pc/models/manufacturer.dart';
import 'package:easy_pc/models/motherboard.dart';
import 'package:easy_pc/models/pc.dart';
import 'package:easy_pc/models/pc_type.dart';
import 'package:easy_pc/models/power_supply.dart';
import 'package:easy_pc/models/processor.dart';
import 'package:easy_pc/models/ram.dart';

class Products {
  final List<Processor>? processors;
  final List<GraphicsCard>? graphicsCards;
  final List<Case>? cases;
  final List<Manufacturer>? manufacturers;
  final List<MotherBoard>? motherBoards;
  final List<PowerSupply>? powerSupplies;
  final List<Ram>? rams;
  final List<PcType>? pcType;
  final List<PC>? pcs;

  const Products({
    this.processors,
    this.graphicsCards,
    this.cases,
    this.manufacturers,
    this.motherBoards,
    this.powerSupplies,
    this.rams,
    this.pcType,
    this.pcs,
  });

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      processors: (json['processors'] as List)
          .map((item) => Processor.fromJson(item))
          .toList(),
      graphicsCards: (json['graphicsCards'] as List)
          .map((item) => GraphicsCard.fromJson(item))
          .toList(),
      cases: (json['cases'] as List)
          .map((item) => Case.fromJson(item))
          .toList(),
      manufacturers: (json['manufacturers'] as List)
          .map((item) => Manufacturer.fromJson(item))
          .toList(),
      motherBoards: (json['motherBoards'] as List)
          .map((item) => MotherBoard.fromJson(item))
          .toList(),
      powerSupplies: (json['powerSupplies'] as List)
          .map((item) => PowerSupply.fromJson(item))
          .toList(),
      rams: (json['rams'] as List).map((item) => Ram.fromJson(item)).toList(),
      pcType: (json['pcType'] as List)
          .map((item) => PcType.fromJson(item))
          .toList(),
      pcs: (json['pcs'] != null ? (json['pcs'] as List)
          .map((item) => PC.fromJson(item))
          .toList() : null),
    );
  }

  Map<String, dynamic> toJson() => {
    'processors': processors?.map((item) => item.toJson()).toList(),
    'graphicsCards': graphicsCards?.map((item) => item.toJson()).toList(),
    'cases': cases?.map((item) => item.toJson()).toList(),
    'manufacturers': manufacturers?.map((item) => item.toJson()).toList(),
    'motherBoards': motherBoards?.map((item) => item.toJson()).toList(),
    'powerSupplies': powerSupplies?.map((item) => item.toJson()).toList(),
    'rams': rams?.map((item) => item.toJson()).toList(),
    'pcType': pcType?.map((item) => item.toJson()).toList(),
    'pcs': pcs?.map((item) => item.toJson()).toList(),
  };
}
