import 'dart:convert';
import 'package:http/http.dart' as http;

class StockService {
  // IMPORTANT: Replace this with your actual Cloud Function Trigger URL
  final String _cloudFunctionUrl = 'https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net/fetch-bhavcopy';

  Map<String, double>? _priceCache;
  List<String>? _tickerCache;

  Future<bool> refreshData() async {
    try {
      final response = await http.get(Uri.parse(_cloudFunctionUrl));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        final Map<String, dynamic> priceJson = data['prices'];
        _priceCache = priceJson.map((key, value) => MapEntry(key.toUpperCase(), (value as num).toDouble()));
        
        final List<dynamic> tickerJson = data['tickers'];
        _tickerCache = tickerJson.map((e) => e.toString()).toList();
        
        return true; // Success
      }
    } catch (e) {
      // In a real app, use a proper logging framework.
      // print("Error refreshing stock data: $e");
    }
    return false; // Failure
  }

  Future<double?> getCurrentPrice(String ticker) async {
    if (_priceCache == null) {
      await refreshData();
    }
    return _priceCache?[ticker.toUpperCase()];
  }

  Future<List<String>> getTickerSuggestions() async {
    if (_tickerCache == null) {
      await refreshData();
    }
    return _tickerCache ?? [];
  }
}