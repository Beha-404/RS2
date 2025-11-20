import 'package:desktop/models/case.dart';
import 'package:desktop/models/graphics_card.dart';
import 'package:desktop/models/manufacturer.dart';
import 'package:desktop/models/motherboard.dart';
import 'package:desktop/models/pc.dart';
import 'package:desktop/models/pc_type.dart';
import 'package:desktop/models/power_supply.dart';
import 'package:desktop/models/processor.dart';
import 'package:desktop/models/ram.dart';

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
