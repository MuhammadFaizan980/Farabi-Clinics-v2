import 'data/network/end_points.dart';
import 'main_app.dart';

Future<void> main() => initApp(
      flavorName: 'dev',
      baseUrl: EndPoints.baseUrlDev,
      enableLogging: true,
    );
