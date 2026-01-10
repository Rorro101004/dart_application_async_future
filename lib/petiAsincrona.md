## Peticiones a un servidor externo

Una petición asíncrona es un mecanismo que permite a nuestra aplicación solicitar datos a un servidor sin detener la ejecución del programa principal.
Esto nos ayuda para que la aplicación no se quede congelada con una sola operación y tarea, y creamos varios hilos para que el programa haga varias funciones al mismo tiempo como la rama de un árbol, y no como una línea recta.


Paso 1.  **Envío de petición** El cliente envía la petición y recibe inmediatamente un objeto `Future` (una promesa de que el dato llegará).
Paso 2.  **Espera no bloqueante:** Mientras el servidor procesa la solicitud, la app sigue funcionando (responde a clics, animaciones, etc.).
Paso 3.  **Resolución:** Cuando llegan los datos, utilizamos `await` para retomar el flujo y procesar la respuesta, o `try-catch` para manejar errores.


### Ejemplo 1: Petición GET (Consultar información)
Este método se utiliza para solicitar y recibir datos del servidor, devolviendonos en este caso un dynamic, ya que puede devolver null o un Jsoncode. Es una operación en la que pedimos información pero no cambiamos nada en la base de datos .
```dart
import 'package:http/http.dart' as http;
import 'dart:convert'; 

Future<dynamic> realizarPeticion(http.Client client, String url) async {
  
  print('Solicitando datos a: $url ...');

  try {
    final response = await client.get(Uri.parse(url)); //Esperamos la respuesta usando el await

    print(' El servidor respondió con código: ${response.statusCode}');

    if (response.statusCode == 200) {
      // El servidor nos dio los datos
      print('Decodificando JSON...');
      return jsonDecode(response.body);

    } else if (response.statusCode == 404) {
      //  Recurso no encontrado
      print('Lo que buscas no existe en el servidor.');
      return null;

    } else {
      print('Ocurrió un problema inesperado: ${response.statusCode}');
      return null;
    }

  } catch (e) {
    print('No se pudo contactar con el servidor.');
    print('  Detalle: $e');
    return null;
  }
}
```
### Ejemplo 2: Petición GET con filtros (Búsqueda)
Este método es una variante del GET donde, en lugar de pedir un recurso exacto por su ID, enviamos parámetros de búsqueda en la URL para filtrar la información.

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

// Esta función imprime los resultados encontrados
Future<void> buscarPersonaje(http.Client client, String nombreBusqueda) async {
  
  // En este caso parseamos la url para usarla, no la pedimos por parametro
  final url = Uri.parse('https://swapi.dev/api/people/?search=$nombreBusqueda');

  print('Rastreando a "$nombreBusqueda"');

  try {
    final response = await client.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      int encontrados = data['count'];

      if (encontrados > 0) {
        print('Se han encontrado $encontrados coincidencias:');
        for (var personaje in data['results']) {
          print('   - ${personaje['name']} (Nació en: ${personaje['birth_year']})');
        }
      } else {
        print(' Nadie se llama así.');
      }

    } else {
      print(' Error del servidor: ${response.statusCode}');
    }

  } catch (e) {
    print('Error de conexión: $e');
  }
}
```
