import 'package:flutter/material.dart'; // mengimpor package flutter/material.dart untuk menggunakan Flutter UI framework
import 'package:provider/provider.dart'; // mengimpor package provider.dart untuk menggunakan state management dengan Provider
import 'package:http/http.dart'
    as http; // mengimpor package http.dart untuk melakukan HTTP requests
import 'dart:convert'; // mengimpor package dart:convert untuk mengonversi JSON

class Universitas {
  // class untuk merepresentasikan data universitas
  String nama; // variabel untuk menyimpan nama universitas
  List<String> domains; // variabel untuk menyimpan domain universitas
  List<String> webPages; // variabel untuk menyimpan halaman web universitas

  Universitas({
    // constructor class Universitas
    required this.nama,
    required this.domains,
    required this.webPages,
  });

  factory Universitas.fromJson(Map<String, dynamic> json) {
    // factory method untuk membuat objek Universitas dari JSON
    return Universitas(
      nama: json['name'],
      domains: List<String>.from(json['domains']),
      webPages: List<String>.from(json['web_pages']),
    );
  }
}

class DaftarUniversitas {
  // class untuk merepresentasikan daftar universitas
  List<Universitas> daftar =
      <Universitas>[]; // variabel untuk menyimpan daftar universitas

  DaftarUniversitas(List<dynamic> json) {
    // constructor class DaftarUniversitas
    for (var val in json) {
      daftar.add(
          Universitas.fromJson(val)); // menambahkan universitas ke dalam daftar
    }
  }

  factory DaftarUniversitas.fromJson(List<dynamic> json) {
    // factory method untuk membuat objek DaftarUniversitas dari JSON
    return DaftarUniversitas(json);
  }
}

class UniversitasProvider extends ChangeNotifier {
  // class untuk menyediakan data universitas ke aplikasi
  late Future<DaftarUniversitas>
      _futureDaftarUniversitas; // future untuk menampung data daftar universitas
  late String _selectedCountry; // variabel untuk menyimpan negara yang dipilih

  UniversitasProvider() {
    // constructor class UniversitasProvider
    _selectedCountry = 'Indonesia'; // inisialisasi negara yang dipilih
    _futureDaftarUniversitas = fetchData(
        _selectedCountry); // mengambil data universitas untuk negara yang dipilih
  }

  Future<DaftarUniversitas> fetchData(String country) async {
    // method untuk mengambil data universitas dari API
    final response = await http.get(
      // melakukan HTTP GET request ke API
      Uri.parse('http://universities.hipolabs.com/search?country=$country'),
    );

    if (response.statusCode == 200) {
      // jika request berhasil
      return DaftarUniversitas.fromJson(jsonDecode(
          response.body)); // mengembalikan data daftar universitas dari json
    } else {
      // jika request gagal
      throw Exception('Failed to load universities');
    }
  }

  void updateCountry(String country) {
    // method untuk mengubah negara yang dipilih
    _selectedCountry = country;
    _futureDaftarUniversitas = fetchData(
        _selectedCountry); // mengambil data universitas untuk negara yang dipilih
    notifyListeners(); // memberitahu listener bahwa data telah berubah
  }

  String get selectedCountry =>
      _selectedCountry; // getter untuk mendapatkan negara yang dipilih

  Future<DaftarUniversitas> get futureDaftarUniversitas =>
      _futureDaftarUniversitas; // getter untuk mendapatkan future data daftar universitas
}

void main() {
  // fungsi utama untuk menjalankan aplikasi
  runApp(
    ChangeNotifierProvider(
      // menggunakan ChangeNotifierProvider untuk menyediakan UniversitasProvider ke seluruh aplikasi
      create: (context) => UniversitasProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // class utama untuk membangun tampilan aplikasi
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Universitas ASEAN',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Daftar Universitas ASEAN'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DropdownButton<String>(
                // combobox untuk memilih negara
                value: context
                    .watch<UniversitasProvider>()
                    .selectedCountry, // nilai combobox berdasarkan negara yang dipilih
                onChanged: (String? newValue) {
                  // event handler untuk perubahan nilai combobox
                  if (newValue != null) {
                    context.read<UniversitasProvider>().updateCountry(
                        newValue); // mengubah negara yang dipilih
                  }
                },
                items: <String>[
                  // daftar negara ASEAN
                  'Indonesia',
                  'Singapore',
                  'Malaysia',
                  'Thailand',
                  'Philippines',
                  'Vietnam',
                  'Myanmar',
                  'Cambodia',
                  'Laos',
                  'Brunei',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              Expanded(
                child: FutureBuilder<DaftarUniversitas>(
                  // widget untuk menampilkan daftar universitas
                  future: context
                      .watch<UniversitasProvider>()
                      .futureDaftarUniversitas, // future untuk memuat data daftar universitas
                  builder: (context, snapshot) {
                    // builder untuk membangun tampilan berdasarkan status future
                    if (snapshot.hasData) {
                      // jika data sudah tersedia
                      return ListView.builder(
                        itemCount: snapshot.data!.daftar
                            .length, // jumlah item dalam daftar universitas
                        itemBuilder: (context, index) {
                          // builder untuk setiap item dalam daftar
                          return ListTile(
                            // widget untuk menampilkan item universitas
                            title: Text(snapshot.data!.daftar[index]
                                .nama), // menampilkan nama universitas
                            subtitle: Column(
                              // widget untuk menampilkan domain dan web pages universitas
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Domains: ${snapshot.data!.daftar[index].domains.join(', ')}'),
                                Text(
                                    'Web Pages: ${snapshot.data!.daftar[index].webPages.join(', ')}'),
                              ],
                            ),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      // jika terjadi error dalam memuat data
                      return Text(
                          '${snapshot.error}'); // menampilkan pesan error
                    }
                    return CircularProgressIndicator(); // menampilkan indicator ketika data sedang dimuat
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
