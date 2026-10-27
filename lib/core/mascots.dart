import 'app_assets.dart';

class MascotOption {
  final String id;
  final String asset;
  const MascotOption(this.id, this.asset);
}

class Mascots {
  Mascots._();

  static const String defaultId = 'Harimau';

  static const List<MascotOption> all = [
    MascotOption('Harimau', AppAssets.mascotHarimauSumatera),
    MascotOption('OrangUtan', AppAssets.mascotOrangUtan),
    MascotOption('Badak', AppAssets.mascotBadak),
    MascotOption('Burung', AppAssets.mascotBurung),
  ];

  static bool isValid(String id) => all.any((mascot) => mascot.id == id);

  static MascotOption byId(String id) => all.firstWhere((mascot) => mascot.id == id, orElse: () => all.first);
}
