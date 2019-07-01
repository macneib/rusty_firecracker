import 'package:simple_auth/simple_auth.dart';
import "package:http/http.dart" as http;

class KeycloakConfig extends OAuthApi {
  KeycloakConfig(String identifier, String clientId, String clientSecret,
      String authorizationUrl, String tokenUrl, String redirectUrl,
      {List<String> scopes,
      http.Client client,
      Converter converter,
      AuthStorage authStorage})
      : super(identifier, clientId, clientSecret, authorizationUrl, tokenUrl,
            redirectUrl,
            client: client,
            scopes: scopes,
            converter: converter,
            authStorage: authStorage);
}