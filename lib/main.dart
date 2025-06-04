import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(FitbitApp());
}

class FitbitApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitbit Profile',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Fitbit Profile'),
          centerTitle: true,
        ),
        body: FitbitProfileCard(),
      ),
    );
  }
}

class FitbitProfileCard extends StatelessWidget {
  final String accessToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyM1FLNEoiLCJzdWIiOiJDTVpENVkiLCJpc3MiOiJGaXRiaXQiLCJ0eXAiOiJhY2Nlc3NfdG9rZW4iLCJzY29wZXMiOiJyc29jIHJlY2cgcnNldCByaXJuIHJveHkgcm51dCBycHJvIHJzbGUgcmNmIHJhY3QgcnJlcyBybG9jIHJ3ZWkgcmhyIHJ0ZW0iLCJleHAiOjE3NDg5NDcxNDgsImlhdCI6MTc0ODkxODM0OH0.FmJ1Yb_L6h84BkQ6jSL1U9slVGtwaslphRHjMXcrIPg";

  Future<Map<String, dynamic>> fetchFitbitProfile() async {
    final response = await http.get(
      Uri.parse('https://api.fitbit.com/1/user/-/profile.json'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['user'];
    } else {
      throw Exception('Failed to load profile. ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchFitbitProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('❌ ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final user = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('👤 ${user['fullName']}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    buildRow('Age', user['age'].toString()),
                    buildRow('Gender', user['gender']),
                    buildRow('Height', '${user['height']} cm'),
                    buildRow('Weight', '${user['weight']} kg'),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Center(child: Text('No data available.'));
        }
      },
    );
  }

  Widget buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
