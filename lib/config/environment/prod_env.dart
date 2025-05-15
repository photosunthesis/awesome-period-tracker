import 'package:awesome_period_tracker/config/environment/env.dart';
import 'package:envied/envied.dart';
import 'package:injectable/injectable.dart';

part 'prod_env.g.dart';

@Envied(path: '.env', useConstantCase: true, obfuscate: true)
@Singleton(as: Env)
class ProdEnv implements Env {
  @override
  @EnviedField()
  final String loginEmail = _ProdEnv.loginEmail;

  @override
  @EnviedField()
  final String geminiApiKey = _ProdEnv.geminiApiKey;

  @override
  @EnviedField()
  final String systemId = _ProdEnv.systemId;

  @override
  @EnviedField()
  final String cyclePhaseApiKey = _ProdEnv.cyclePhaseApiKey;

  @override
  @EnviedField()
  final String cyclePhaseApiUrl = _ProdEnv.cyclePhaseApiUrl;
}
