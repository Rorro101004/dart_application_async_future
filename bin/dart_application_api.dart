import 'package:dart_application_api/dart_application_api.dart'
    as dart_application_api;
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'dart:convert';
import 'dart:io';

const String baseUrl = 'https://swapi.tech/api';

void main() async {
  // 1. Iniciamos el cliente una sola vez

  final client = RetryClient(http.Client());
  try {
    bool continuar = true;

    while (continuar) {
      print('\n==========================================');
      print('       STAR WARS API MENU ');
      print('==========================================');
      print('1. Listar Planetas');
      print('2. Ver habitantes de un planeta');
      print('3. Ver planeta de un personaje');
      print('4. Ver película de un vehículo');
      print('5. Salir');
      print('------------------------------------------');
      stdout.write('Elige una opción (1-5): ');

      // Leemos lo que escribe el usuario
      String? opcion = stdin.readLineSync();

      print('\n'); // Salto de línea estético

      // Decidimos qué hacer
      switch (opcion) {
        case '1':
          await listarPlanetas(client);
          break;

        case '2':
          int? id = pedirId('Introduce el ID del planeta: ');
          if (id != null) await listarHabitantesPorPlaneta(client, id);
          break;

        case '3':
          int? id = pedirId('Introduce el ID del personaje: ');
          if (id != null) await infoPlanetaDePersonaje(client, id);
          break;

        case '4':
          int? id = pedirId('Introduce el ID del vehículo: ');
          if (id != null) await infoPeliculaDeVehiculo(client, id);
          break;

        case '5':
          continuar = false;
          break;

        default:
          print(' Opción no válida. Inténtalo de nuevo.');
      }

      if (continuar) {
        print('\nPresiona ENTER para volver al menú');
        stdin.readLineSync();
      }
    }
  } finally {
    // Cerramos el cliente al salir del bucle
    client.close();
  }
}

int? pedirId(String mensaje) {
  print('$mensaje ');
  String? entrada = stdin.readLineSync();
  int? id = int.tryParse(entrada ?? '');

  if (id == null) {
    print('Error: Debes introducir un número válido.');
  }
  return id;
}

Future<dynamic> conexion(http.Client client, String url) async {
  try {
    final response = await client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print(' Error: Código ${response.statusCode} en $url');
      return null;
    }
  } catch (e) {
    print(' Error de conexión: $e');
    return null;
  }
}

Future<void> listarPlanetas(http.Client client) async {
  print(' BUSCANDO PLANETAS ');
  var data = await conexion(client, '$baseUrl/planets/');
  if (data != null) {
    List<dynamic> results = data['results'];
    for (var planeta in results.take(10)) {
      // Muestro 5 para que se vea mejor
      print('Planeta: ${planeta['name']}');
    }
  }
}

Future<void> listarHabitantesPorPlaneta(
  http.Client client,
  int idPlaneta,
) async {
  print('BUSCANDO HABITANTES DEL PLANETA $idPlaneta ');
  var planeta = await conexion(client, '$baseUrl/planets/$idPlaneta/');

  if (planeta != null) {
    print('Planeta: ${planeta['name']}');
    List<dynamic> residentesUrls = planeta['residents'];

    if (residentesUrls.isEmpty) {
      print('(Sin habitantes registrados)');
      return;
    }
    //Limitamos a 5 residentes
    for (var url in residentesUrls.take(5)) {
      var residente = await conexion(client, url);
      if (residente != null) {
        print('👤 Residente: ${residente['name']}');
      }
    }
  }
}

Future<void> infoPlanetaDePersonaje(http.Client client, int idPersonaje) async {
  print('BUSCANDO PLANETA DEL PERSONAJE $idPersonaje');
  var personaje = await conexion(client, '$baseUrl/people/$idPersonaje/');

  if (personaje != null) {
    print('Personaje: ${personaje['name']}');
    if (personaje['homeworld'] != null) {
      var planeta = await conexion(client, personaje['homeworld']);
      if (planeta != null) {
        print('Mundo Natal: ${planeta['name']}');
      }
    }
  }
}

Future<void> infoPeliculaDeVehiculo(http.Client client, int idVehiculo) async {
  print('BUSCANDO PELÍCULA DEL VEHÍCULO $idVehiculo');
  var vehiculo = await conexion(client, '$baseUrl/vehicles/$idVehiculo/');

  if (vehiculo != null) {
    print('Vehículo: ${vehiculo['name']}');
    List<dynamic> filmsUrls = vehiculo['films'];

    if (filmsUrls.isNotEmpty) {
      var pelicula = await conexion(client, filmsUrls[0]);
      if (pelicula != null) {
        print(
          'Película: ${pelicula['title']} (Episodio ${pelicula['episode_id']})',
        );
      }
    } else {
      print('   (No aparece en ninguna película registrada)');
    }
  }
}
