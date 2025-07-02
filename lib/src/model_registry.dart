// typedef ModelCreator = Future<void> Function();

// class ModelRegistry {
//   static final Map<Type, ModelCreator> _creators = {};

//   static void register<T>(ModelCreator creator) {
//     _creators[T] = creator;
//   }

//   static Future<void> createAllTables() async {
//     for (final creator in _creators.values) {
//       await creator();
//     }
//   }

//   static Future<void> createTableFor<T>() async {
//     final creator = _creators[T];
//     if (creator != null) await creator();
//   }
// }
