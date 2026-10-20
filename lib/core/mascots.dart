import 'app_assets.dart';

class MascotOption {
  final String id;
  final String label;
  final String asset;
  const MascotOption(this.id, this.label, this.asset);
}

class Mascots {
  Mascots._();

  static const String defaultId = 'Harimau';

  static const List<MascotOption> all = [
    MascotOption('Harimau', 'Sumatran Tiger', AppAssets.mascotHarimauSumatera),
    MascotOption('OrangUtan', 'Orangutan', AppAssets.mascotOrangUtan),
    MascotOption('Badak', 'Javan Rhino', AppAssets.mascotBadak),
    MascotOption('Burung', 'Bird of Paradise', AppAssets.mascotBurung),
  ];

  static bool isValid(String id) => all.any((mascot) => mascot.id == id);

  static MascotOption byId(String id) => all.firstWhere((mascot) => mascot.id == id, orElse: () => all.first);
}
