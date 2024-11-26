import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';

import 'AudioPlayerHandler.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator(String url) async {
  getIt.registerSingleton<AudioHandler>(await initAudioService(url));
}
