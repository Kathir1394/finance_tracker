import 'dart:convert';
import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'google_auth_service.dart';
import '../models/transaction.dart'; // <-- Added missing import
import '../models/equity.dart';
import '../models/derivative.dart';
import '../models/goal.dart';


class DataBackupService {
  final GoogleAuthService _authService = GoogleAuthService();
  // IMPORTANT: This key should be stored securely and not hardcoded in a real app.
  // Consider using flutter_secure_storage or a similar solution.
  final _encryptionKey = 'YourSuperSecret32ByteEncryptionKey!'; 

  // Method to create a map from a Hive object
  Map<String, dynamic> _hiveObjectToMap(dynamic obj) {
      if (obj is Transaction) return obj.toMap();
      if (obj is Equity) return obj.toMap();
      if (obj is DerivativeTrade) return obj.toMap();
      if (obj is Goal) return obj.toMap();
      return {};
  }


  Future<void> backupData() async {
    final driveApi = await _authService.getDriveApi();
    if (driveApi == null) throw Exception("Authentication failed.");

    final Map<String, dynamic> dataToBackup = {
      'transactions': Hive.box<Transaction>('transactions').values.map(_hiveObjectToMap).toList(),
      'equities': Hive.box<Equity>('equities').values.map(_hiveObjectToMap).toList(),
      'derivatives': Hive.box<DerivativeTrade>('derivatives').values.map(_hiveObjectToMap).toList(),
      'goals': Hive.box<Goal>('goals').values.map(_hiveObjectToMap).toList(),
    };

    final jsonData = jsonEncode(dataToBackup);

    final key = encrypt.Key.fromUtf8(_encryptionKey);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encryptedData = encrypter.encrypt(jsonData, iv: iv);

    final tempDir = await getTemporaryDirectory();
    final backupFile = File('${tempDir.path}/finance_universe_backup.enc');
    await backupFile.writeAsBytes(encryptedData.bytes);

    final driveFile = drive.File()
      ..name = 'FinanceUniverse_Backup_${DateTime.now().toIso8601String()}.enc'
      ..parents = ['appDataFolder'];

    await driveApi.files.create(
      driveFile,
      uploadMedia: drive.Media(backupFile.openRead(), backupFile.lengthSync()),
    );
  }

  Future<void> restoreData() async {
    final driveApi = await _authService.getDriveApi();
    if (driveApi == null) throw Exception("Authentication failed.");

    final fileList = await driveApi.files.list(spaces: 'appDataFolder', $fields: 'files(id, name, createdTime)');
    if (fileList.files == null || fileList.files!.isEmpty) {
      throw Exception("No backup file found.");
    }
    
    final latestFile = fileList.files!.reduce((a, b) => a.createdTime!.isAfter(b.createdTime!) ? a : b);

    final drive.Media fileMedia = await driveApi.files.get(latestFile.id!, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
    
    final List<int> dataStore = [];
    await for (var data in fileMedia.stream) {
      dataStore.addAll(data);
    }
    
    final key = encrypt.Key.fromUtf8(_encryptionKey);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decryptedJson = encrypter.decrypt64(base64.encode(dataStore), iv: iv);
    
    final restoredData = jsonDecode(decryptedJson) as Map<String, dynamic>;

    await Hive.box<Transaction>('transactions').clear();
    for (var item in restoredData['transactions']) {
      Hive.box<Transaction>('transactions').add(Transaction.fromMap(item));
    }

    await Hive.box<Equity>('equities').clear();
    for (var item in restoredData['equities']) {
      Hive.box<Equity>('equities').add(Equity.fromMap(item));
    }

     await Hive.box<DerivativeTrade>('derivatives').clear();
    for (var item in restoredData['derivatives']) {
      Hive.box<DerivativeTrade>('derivatives').add(DerivativeTrade.fromMap(item));
    }

    await Hive.box<Goal>('goals').clear();
    for (var item in restoredData['goals']) {
      Hive.box<Goal>('goals').add(Goal.fromMap(item));
    }
  }
}