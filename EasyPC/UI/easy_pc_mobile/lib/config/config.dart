import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

String get apiBaseUrl {
	const port = 5025;
	final baseLocalhost = 'http://localhost:$port';
	final baseAndroidEmulator = 'http://192.168.1.5:$port'; // Use host machine IP

	if (kIsWeb) return baseLocalhost;

	switch (defaultTargetPlatform) {
		case TargetPlatform.android:
			return baseAndroidEmulator;
		default:
			return baseLocalhost;
	}
}