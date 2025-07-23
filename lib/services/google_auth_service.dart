import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
// FIX: Corrected the import path from '.' to ':'
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;

// Custom HTTP client to include auth headers
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

class GoogleAuthService {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );

  GoogleSignInAccount? currentUser;

  Future<GoogleSignInAccount?> signIn() async {
    if (currentUser != null) return currentUser;
    try {
      final account = await googleSignIn.signIn();
      currentUser = account;
      return account;
    } catch (e) {
      // In a real app, use a proper logging framework
      return null;
    }
  }

  Future<void> signOut() async {
    await googleSignIn.signOut();
    currentUser = null;
  }

  Future<drive.DriveApi?> getDriveApi() async {
    final googleUser = await signIn();
    if (googleUser == null) {
      return null;
    }
    final headers = await googleUser.authHeaders;
    final client = GoogleAuthClient(headers);
    final accessCredentials = auth.AccessCredentials(
        auth.AccessToken('Bearer', headers['Authorization']!.substring(7),
            DateTime.now().toUtc().add(const Duration(hours: 1))),
        null,
        googleSignIn.scopes);

    final authenticatedClient =
        auth.authenticatedClient(client, accessCredentials);
    return drive.DriveApi(authenticatedClient);
  }
}