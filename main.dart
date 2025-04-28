// Dart Temelleri: SharedPreferences ile Kullanıcı Adını Kaydetme
// [Erciyes Üniversitesi] / [Mühendislik Fakültesi] / [Bilgisayar Mühendisliği]
// Ders: Mobile Application Development
// Öğretim Üyesi: [Dr. Öğr. Üyesi Fehim KÖYLÜ]
// Proje Ödevi: SharedPreferences ile Kullanıcı Adını Kaydetme
// 1030520985 - Atakan Arslan

import 'package:flutter/material.dart';
import 'dart:convert';

class MockSharedPreferences {
  static final MockSharedPreferences _instance = MockSharedPreferences._internal();
  Map<String, dynamic> _data = {};

  factory MockSharedPreferences.getInstance() {
    return _instance;
  }

  MockSharedPreferences._internal();

  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  String getString(String key) {
    return _data[key] as String? ?? "";
  }

  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kullanıcı Adı Kaydetme',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  List<String> _userNames = [];

  @override
  void initState() {
    super.initState();
    _loadSavedNames();
  }

  // Kaydedilmiş kullanıcı adlarını yükle
  _loadSavedNames() async {
    final prefs = MockSharedPreferences.getInstance();
    setState(() {
      String namesJson = prefs.getString('userNames');
      if (namesJson.isNotEmpty) {
        try {
          List<dynamic> decoded = jsonDecode(namesJson);
          _userNames = decoded.cast<String>();
        } catch (e) {
          _userNames = [];
        }
      } else {
        _userNames = [];
      }
    });
  }

  // Kullanıcı adını kaydet
  _saveName() async {
    final prefs = MockSharedPreferences.getInstance();
    final name = _nameController.text.trim();
    
    if (name.isNotEmpty) {
      setState(() {
        _userNames.add(name);
      });
      
      // Listeyi JSON olarak kaydet
      await prefs.setString('userNames', jsonEncode(_userNames));
      
      _nameController.clear();
      _showSnackBar("Kullanıcı adı başarıyla kaydedildi!");
    } else {
      _showSnackBar("Lütfen bir kullanıcı adı girin!");
    }
  }

  // Kaydedilen tüm kullanıcı adlarını sil
  _clearNames() async {
    final prefs = MockSharedPreferences.getInstance();
    await prefs.remove('userNames');
    setState(() {
      _userNames = [];
    });
    _showSnackBar("Tüm kullanıcı adları silindi!");
  }

  // Belirli bir kullanıcı adını sil
  _removeName(int index) async {
    setState(() {
      _userNames.removeAt(index);
    });
    
    final prefs = MockSharedPreferences.getInstance();
    await prefs.setString('userNames', jsonEncode(_userNames));
    _showSnackBar("Kullanıcı adı silindi!");
  }

  _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SharedPreferences Örneği'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Dart Temelleri: SharedPreferences',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Kullanıcı Adı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveName,
              child: const Text('Kaydet'),
            ),
            const SizedBox(height: 24),
            if (_userNames.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kaydedilen Kullanıcı Adları (${_userNames.length}):',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: _clearNames,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Tümünü Sil'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _userNames.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          _userNames[index],
                          style: const TextStyle(fontSize: 16),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeName(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              Center(
                child: Text(
                  'Henüz kaydedilmiş kullanıcı adı yok',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
