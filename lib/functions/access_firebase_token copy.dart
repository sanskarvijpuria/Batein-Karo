import 'package:googleapis_auth/auth_io.dart';

// NOTE: Please remove the copy from the filename and paste the data below to use this file for sending push notifications.
// For privacy reasons, I have to remove the JSON data. And hence created this file for git.
class AccessFirebaseToken {
  static String fMessagingScope =
      "https://www.googleapis.com/auth/firebase.messaging";

  Future<String> getAccessToken() async {
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": "",
        "private_key_id": "",
        "private_key": "",
        "client_email": "firebase-adminsdk-@iam.gserviceaccount.com",
        "client_id": "",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "",
        "universe_domain": "googleapis.com"
      }),
      [fMessagingScope],
    );

    final accessToken = client.credentials.accessToken.data;
    return accessToken;
  }
}
