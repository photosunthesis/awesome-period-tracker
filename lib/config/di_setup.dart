import 'package:awesome_period_tracker/config/environment/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'di_setup.config.dart';

@InjectableInit()
Future<void> configureDependencies() async => GetIt.I.init();

@module
abstract class ExternalServicesModule {
  @singleton
  SharedPreferencesAsync get sharedPrefs => SharedPreferencesAsync();

  @singleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @singleton
  FirebaseFirestore get firebaseFirestore => FirebaseFirestore.instance;

  @singleton
  FirebaseCrashlytics get firebaseCrashlytics =>
      FirebaseCrashlytics.instance;

  @preResolve
  Future<FirebaseApp> get firebaseApp async =>
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
