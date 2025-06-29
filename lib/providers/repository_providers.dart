import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart'; // UserModel をインポート
import '../repositories/firebase_repository.dart';
import '../services/youtube_service.dart'; // YoutubeService をインポート
import '../services/translation_service.dart'; // TranslationService をインポート

final firebaseRepositoryProvider = Provider<FirebaseRepository>((ref) {
  return FirebaseRepository();
});

final userDocumentProvider = StreamProvider<UserModel?>((ref) {
  final firebaseRepository = ref.watch(firebaseRepositoryProvider);
  return firebaseRepository.currentUserDocumentStream();
});

final youtubeServiceProvider = Provider<YoutubeService>((ref) {
  return YoutubeService();
});

final translationServiceProvider = Provider<TranslationService>((ref) {
  // TODO: 適切なTranslationServiceの実装を提供する
  return GoogleTranslationService();
});
