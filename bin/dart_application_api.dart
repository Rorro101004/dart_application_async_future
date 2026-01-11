import 'package:dart_application_api/dart_application_api.dart'
    as dart_application_api;
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'dart:convert';
import 'dart:io';

const String baseUrl = 'https://swapi.tech/api';

void main() async {
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
      print('==========================================');
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
  print(' BUSCANDO PLANETAS');

  var listaData = await conexion(client, '$baseUrl/planets/');

  if (listaData != null) {
    List<dynamic> results = listaData['results'];

    for (var itemSimple in results.take(5)) {
      String urlDetalle = itemSimple['url'];
      var detalleData = await conexion(client, urlDetalle);

      if (detalleData != null) {
        var props = detalleData['result']['properties'];

        print('PLANETA: ${props['name']}');
        print('    Clima: ${props['climate']}');
        print('    Terreno: ${props['terrain']}');
        print('    Población: ${props['population']}');
        print('    Diámetro: ${props['diameter']}');
        print('    Gravedad: ${props['gravity']}');
        print('-----------------------------------');
      }
    }
  }
}

Future<void> listarHabitantesPorPlaneta(
  http.Client client,
  int idPlanetaBuscado,
) async {
  print('ESCANEANDO LA GALAXIA BUSCANDO HABITANTES DE ID $idPlanetaBuscado');
  // 1. Pedimos la lista general de personas (la API nos da las primeras 10 por defecto)
  var dataPersonas = await conexion(client, '$baseUrl/people/');

  if (dataPersonas != null) {
    List<dynamic> listaPersonas = dataPersonas['results'];
    bool encontradoAlguien = false;
    for (var personaSimple in listaPersonas.take(5)) {
      var detallePersona = await conexion(client, personaSimple['url']);

      if (detallePersona != null) {
        var props = detallePersona['result']['properties'];
        String urlMundo = props['homeworld'];
        if (urlMundo.endsWith('/$idPlanetaBuscado') ||
            urlMundo.endsWith('/$idPlanetaBuscado/')) {
          print(' ${props['name']} vive aquí.');
          print('   - Altura: ${props['height']}');
          print('   - Peso: ${props['mass']}');
          print('   - Género: ${props['gender']}');
          print('   - Color de piel: ${props['skin_color']}');
          print('   - Cumpleaños: ${props['birth_year']}');
          print('   - - - - -');
          encontradoAlguien = true;
        }
      }
    }

    if (!encontradoAlguien) {
      print('No hemos encontrado a nadie de este planeta');
    }
  }
}

Future<void> infoPlanetaDePersonaje(http.Client client, int idPersonaje) async {
  print(' BUSCANDO EL MUNDO DE ORIGEN DEL PERSONAJE $idPersonaje ');

  var dataPersonaje = await conexion(client, '$baseUrl/people/$idPersonaje');

  if (dataPersonaje != null) {
    var propsPersonaje = dataPersonaje['result']['properties'];
    String nombre = propsPersonaje['name'];
    String urlMundo = propsPersonaje['homeworld'];

    print(' Personaje encontrado: $nombre');
    var dataPlaneta = await conexion(client, urlMundo);

    if (dataPlaneta != null) {
      var propsPlaneta = dataPlaneta['result']['properties'];

      print('\nMUNDO NATAL: ${propsPlaneta['name']}');
      print('   Clima: ${propsPlaneta['climate']}');
      print('   Terreno: ${propsPlaneta['terrain']}');
      print('   Población: ${propsPlaneta['population']}');
      print('   Gravedad: ${propsPlaneta['gravity']}');
      print('   Diámetro: ${propsPlaneta['diameter']}');
      print('-----------------------------------');
    }
  }
}

Future<void> infoPeliculaDeVehiculo(http.Client client, int idVehiculo) async {
  print('BUSCANDO PELÍCULAS DEL VEHÍCULO $idVehiculo');

  var dataVehiculo = await conexion(client, '$baseUrl/vehicles/$idVehiculo');

  if (dataVehiculo != null) {
    var propsVehiculo = dataVehiculo['result']['properties'];
    print('Vehículo encontrado: ${propsVehiculo['name']}');

    // 2. Extraemos la LISTA de enlaces a películas
    List<dynamic> urlsPeliculas = propsVehiculo['films'];

    if (urlsPeliculas.isEmpty) {
      print('No aparece en ninguna película registrada');
      return;
    }

    print(
      'Aparece en ${urlsPeliculas.length} película(s). Descargando datos...',
    );

    for (var urlFilm in urlsPeliculas) {
      var dataFilm = await conexion(client, urlFilm);

      if (dataFilm != null) {
        var propsFilm = dataFilm['result']['properties'];

        print('\n    TÍTULO: ${propsFilm['title']}');
        print('       Episodio: ${propsFilm['episode_id']}');
        print('       Director: ${propsFilm['director']}');
        print('       Productor: ${propsFilm['producer']}');
        print('       Fecha estreno: ${propsFilm['release_date']}');
      }
    }
  }
}
