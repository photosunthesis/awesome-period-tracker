import 'package:awesome_period_tracker/config/di_keys.dart';
import 'package:awesome_period_tracker/config/environment/env.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

@module
abstract class CycleApiClient {
  @factoryMethod
  @Named(DiKeys.cycleApiClientKey)
  Dio createInstance(Env env) {
    final headers = {
      'X-RapidAPI-Key': env.cyclePhaseApiKey,
      'X-RapidAPI-Host': env.cyclePhaseApiUrl,
    };

    final dio = Dio(
      BaseOptions(baseUrl: env.cyclePhaseApiUrl, headers: headers),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          maxWidth: 120,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
        ),
      );
    }

    return dio;
  }
}
