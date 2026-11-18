// default entrypoint so `flutter run` without a target still works. it mirrors
// the dev flavor; release builds use main_prod.dart.
import 'main_dev.dart' as dev;

Future<void> main() => dev.main();
