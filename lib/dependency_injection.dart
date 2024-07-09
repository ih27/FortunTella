import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'controllers/fortune_teller.dart';
import 'controllers/openai_fortune_teller.dart';
import 'controllers/purchases.dart';
import 'repositories/firestore_fortune_content_repository.dart';
import 'repositories/firestore_user_repository.dart';
import 'repositories/fortune_content_repository.dart';
import 'repositories/user_repository.dart';
import 'services/auth_service.dart';
import 'services/openai_service.dart';
import 'services/user_service.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Repositories
  getIt.registerLazySingleton<FortuneContentRepository>(
    () => FirestoreFortuneContentRepository(),
  );
  getIt.registerLazySingleton<UserRepository>(
    () => FirestoreUserRepository(),
  );

  // Controllers
  getIt.registerLazySingleton<FortuneTeller>(() => OpenAIFortuneTeller(
        getIt<UserService>(),
        '', // Initial empty persona name
        getIt<OpenAIService>(),
      ));

  getIt.registerLazySingleton<PurchasesController>(
    () => PurchasesController(),
  );

  // Services
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(
        (userId, userData) => getIt<UserService>().addUser(userId, userData)),
  );
  // Ensure UserService is a true singleton
  getIt.registerLazySingleton<UserService>(
      () => UserService(getIt<UserRepository>()));
  getIt.registerLazySingleton<OpenAIService>(
    () => OpenAIService(
      dotenv.env['OPENAI_API_KEY']!,
      '', // Empty string as placeholder, will be set when creating an instance
    ),
  );
}

// Helper function to create FortuneTeller with specific persona
void setFortuneTellerPersona(String personaName, String personaInstructions) {
  getIt<FortuneTeller>().setPersona(personaName, personaInstructions);
}
