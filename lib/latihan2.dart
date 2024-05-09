import 'package:flutter/material.dart'; // mengimpor package flutter/material.dart untuk menggunakan Flutter UI framework
import 'package:flutter_bloc/flutter_bloc.dart'; // mengimpor package flutter_bloc.dart untuk menggunakan Flutter Bloc
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

class UniversitasCubit extends Cubit<DaftarUniversitas> {
  // class untuk mengelola state aplikasi menggunakan Cubit
  late String selectedCountry; // variabel untuk menyimpan negara yang dipilih

  UniversitasCubit() : super(DaftarUniversitas([])) {
    // constructor untuk class UniversitasCubit
    selectedCountry = 'Indonesia'; // inisialisasi negara yang dipilih
    fetchData(
        selectedCountry); // mengambil data universitas untuk negara yang dipilih
  }

  void updateCountry(String country) {
    // method untuk mengubah negara yang dipilih
    selectedCountry = country;
    fetchData(
        selectedCountry); // mengambil data universitas untuk negara yang dipilih
  }

  Future<void> fetchData(String country) async {
    // method untuk mengambil data universitas dari API
    final response = await http.get(
      Uri.parse('http://universities.hipolabs.com/search?country=$country'),
    );

    if (response.statusCode == 200) {
      // jika request berhasil
      emit(DaftarUniversitas.fromJson(jsonDecode(response
          .body))); // mengeluarkan state baru dengan data daftar universitas
    } else {
      // jika request gagal
      throw Exception('Failed to load universities');
    }
  }
}

void main() {
  // fungsi utama untuk menjalankan aplikasi
  runApp(
    BlocProvider(
      // menggunakan BlocProvider untuk menyediakan UniversitasCubit ke seluruh aplikasi
      create: (context) => UniversitasCubit(),
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
              BlocBuilder<UniversitasCubit, DaftarUniversitas>(
                // widget untuk membangun tampilan berdasarkan state UniversitasCubit
                builder: (context, state) {
                  return DropdownButton<String>(
                    // combobox untuk memilih negara
                    value: context
                        .watch<UniversitasCubit>()
                        .selectedCountry, // nilai combobox berdasarkan negara yang dipilih
                    onChanged: (String? newValue) {
                      // event handler untuk perubahan nilai combobox
                      if (newValue != null) {
                        context.read<UniversitasCubit>().updateCountry(
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
                  );
                },
              ),
              Expanded(
                child: BlocBuilder<UniversitasCubit, DaftarUniversitas>(
                  // widget untuk membangun tampilan berdasarkan state UniversitasCubit
                  builder: (context, state) {
                    if (state.daftar.isEmpty) {
                      // jika daftar universitas kosong
                      return CircularProgressIndicator(); // menampilkan indicator loading
                    } else {
                      return ListView.builder(
                        // widget untuk menampilkan daftar universitas
                        itemCount: state.daftar
                            .length, // jumlah item dalam daftar universitas
                        itemBuilder: (context, index) {
                          // builder untuk setiap item dalam daftar
                          return ListTile(
                            // widget untuk menampilkan item universitas
                            title: Text(state.daftar[index]
                                .nama), // menampilkan nama universitas
                            subtitle: Column(
                              // widget untuk menampilkan domain dan web pages universitas
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Domains: ${state.daftar[index].domains.join(', ')}'),
                                Text(
                                    'Web Pages: ${state.daftar[index].webPages.join(', ')}'),
                              ],
                            ),
                          );
                        },
                      );
                    }
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
