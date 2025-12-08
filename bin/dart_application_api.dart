import 'package:dart_application_api/dart_application_api.dart'
    as dart_application_api;
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'dart:convert';

const String baseUrl = 'https://swapi.dev/api';

void main() async {
  // [NUEVO] 1. Creamos el cliente con reintentos
  // Esto crea un cliente que intentará hasta 3 veces (por defecto) si falla la conexión
  final client = RetryClient(http.Client());

  try {
    print('--- INICIANDO CONSULTAS STAR WARS CON RETRY ---');

    // Pasamos el cliente a las funciones
    await listarPlanetas(client);

    print('\n-----------------------------------');
    //await listarHabitantesPorPlaneta(client, 1);

    print('\n-----------------------------------');
    //await infoPlanetaDePersonaje(client, 1);

    print('\n-----------------------------------');
    
    //await infoPeliculaDeVehiculo(client, 4);
  } finally {
    // [NUEVO] 4. Es MUY importante cerrar el cliente al terminar
    client.close();
  }
}

// [NUEVO] Modificamos _fetchData para recibir el 'client'
Future<dynamic> _fetchData(http.Client client, String url) async {
  try {
    // [NUEVO] Usamos 'client.get' en vez de 'http.get'
    final response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Error: Código ${response.statusCode} en $url');
      return null;
    }
  } catch (e) {
    print('Error de conexión tras varios intentos: $e');
    return null;
  }
}

// ---- MÉTODOS ACTUALIZADOS PARA ACEPTAR EL CLIENTE ----

Future<void> listarPlanetas(http.Client client) async {
  print('A. BUSCANDO PLANETAS...');
  // Pasamos el cliente a _fetchData
  var data = await _fetchData(client, '$baseUrl/planets/');

  if (data != null) {
    List<dynamic> results = data['results'];
    for (var planeta in results.take(3)) {
      print('> Planeta: ${planeta['name']}');
    }
  }
}

Future<void> listarHabitantesPorPlaneta(
  http.Client client,
  int idPlaneta,
) async {
  print('B. BUSCANDO HABITANTES...');
  var planeta = await _fetchData(client, '$baseUrl/planets/$idPlaneta/');

  if (planeta != null) {
    List<dynamic> residentesUrls = planeta['residents'];
    for (var url in residentesUrls.take(3)) {
      var residente = await _fetchData(client, url); // Pasamos cliente
      if (residente != null) {
        print('> Residente: ${residente['name']}');
      }
    }
  }
}

Future<void> infoPlanetaDePersonaje(http.Client client, int idPersonaje) async {
  print('C. BUSCANDO PLANETA DE PERSONAJE...');
  var personaje = await _fetchData(client, '$baseUrl/people/$idPersonaje/');

  if (personaje != null) {
    var planeta = await _fetchData(
      client,
      personaje['homeworld'],
    ); // Pasamos cliente
    if (planeta != null) {
      print('> Mundo Natal: ${planeta['name']}');
    }
  }
}

Future<void> infoPeliculaDeVehiculo(http.Client client, int idVehiculo) async {
  print('D. BUSCANDO PELÍCULA DE VEHÍCULO...');
  var vehiculo = await _fetchData(client, '$baseUrl/vehicles/$idVehiculo/');

  if (vehiculo != null) {
    List<dynamic> filmsUrls = vehiculo['films'];
    if (filmsUrls.isNotEmpty) {
      var pelicula = await _fetchData(client, filmsUrls[0]); // Pasamos cliente
      if (pelicula != null) {
        print('> Película: ${pelicula['title']}');
      }
    }
  }
}
