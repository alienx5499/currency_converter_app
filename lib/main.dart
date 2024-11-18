import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CurrencyConverterScreen(),
    );
  }
}

class CurrencyConverterScreen extends StatefulWidget {
  @override
  _CurrencyConverterScreenState createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  String? _fromCurrency = 'USD';
  String? _toCurrency = 'INR';
  TextEditingController _amountController = TextEditingController();

  double? _convertedAmount;

  // Example function to simulate API call
  Future<double> fetchConversionRate(String from, String to) async {
    // Simulate network latency
    await Future.delayed(Duration(seconds: 1));
    return 75.0; // Mock exchange rate (1 USD = 75 INR)
  }

  void _convertCurrency() async {
    if (_amountController.text.isEmpty || double.tryParse(_amountController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid number.')),
      );
      return;
    }

    double rate = await fetchConversionRate(_fromCurrency!, _toCurrency!);
    setState(() {
      _convertedAmount = double.parse(_amountController.text) * rate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount in $_fromCurrency',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _fromCurrency,
                    items: ['USD', 'EUR', 'INR', 'GBP'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _fromCurrency = newValue;
                      });
                    },
                  ),
                ),
                Icon(Icons.arrow_forward),
                Expanded(
                  child: DropdownButton<String>(
                    value: _toCurrency,
                    items: ['USD', 'EUR', 'INR', 'GBP'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _toCurrency = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _convertCurrency,
              child: Text('Convert'),
            ),
            SizedBox(height: 20),
            Text(
              _convertedAmount == null
                  ? 'Enter amount to convert'
                  : 'Converted Amount: ${_convertedAmount!.toStringAsFixed(2)} $_toCurrency',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
