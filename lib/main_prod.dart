import 'data/network/end_points.dart';
import 'main_app.dart';

Future<void> main() => initApp(
      flavorName: 'prod',
      baseUrl: EndPoints.baseUrlProd,
      // never log in release
      enableLogging: false,
    );
