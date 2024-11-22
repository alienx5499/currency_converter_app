import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: CurrencyConverter(),
    );
  }
}

class CurrencyConverter extends StatefulWidget {
  @override
  _CurrencyConverterState createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  String? from = 'USD';
  String? to = 'INR';
  TextEditingController amountCtrl = TextEditingController();
  List<String> currencies = [];
  double? result;
  bool loading = false;

  final String apiKey = '5de60fda21ba1f959c85332b';
  final String apiBase = 'https://v6.exchangerate-api.com/v6';

  @override
  void initState() {
    super.initState();
    loadCurrencies();
  }

  Future<void> loadCurrencies() async {
    try {
      final response = await http.get(Uri.parse('$apiBase/$apiKey/latest/USD'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          currencies = (data['conversion_rates'] as Map<String, dynamic>)
              .keys
              .toList();
        });
      } else {
        showError('Failed to load currencies');
      }
    } catch (e) {
      showError('Something went wrong: $e');
    }
  }

  Future<double> fetchRate(String from, String to) async {
    final url = Uri.parse('$apiBase/$apiKey/latest/$from');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['conversion_rates'][to];
    } else {
      throw Exception('Failed to load rate');
    }
  }

  void convert() async {
    if (amountCtrl.text.isEmpty ||
        double.tryParse(amountCtrl.text) == null) {
      showError('Enter a valid number');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final rate = await fetchRate(from!, to!);
      setState(() {
        result = double.parse(amountCtrl.text) * rate;
        loading = false;
      });
    } catch (e) {
      showError('Failed to convert: $e');
      setState(() {
        loading = false;
      });
    }
  }

  void swap() {
    setState(() {
      final temp = from;
      from = to;
      to = temp;
    });
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter'),
        centerTitle: true,
      ),
      body: currencies.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: amountCtrl,
              decoration: InputDecoration(
                labelText: 'Amount in $from',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: from,
                    items: currencies.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        from = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'From',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.swap_horiz, size: 30, color: Colors.blue),
                  onPressed: swap,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: to,
                    items: currencies.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        to = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'To',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : convert,
                child: loading
                    ? CircularProgressIndicator(
                  color: Colors.white,
                )
                    : Text('Convert'),
              ),
            ),
            SizedBox(height: 20),
            if (result != null)
              Center(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Converted Amount',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${result!.toStringAsFixed(2)} $to',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
