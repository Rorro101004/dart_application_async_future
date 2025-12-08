## Peticiones a un servidor externo

Una petición asíncrona es un mecanismo que permite a nuestra aplicación solicitar datos a un servidor sin detener la ejecución del programa principal.
Esto nos ayuda para que la aplicación no se quede congelada con una sola operación y tarea, y creamos varios hilos para que el programa haga varias funciones al mismo tiempo como la rama de un árbol, y no como una línea recta.


Paso 1.  **Envío de petición** El cliente envía la petición y recibe inmediatamente un objeto `Future` (una promesa de que el dato llegará).
Paso 2.  **Espera no bloqueante:** Mientras el servidor procesa la solicitud, la app sigue funcionando (responde a clics, animaciones, etc.).
Paso 3.  **Resolución:** Cuando llegan los datos, utilizamos `await` para retomar el flujo y procesar la respuesta, o `try-catch` para manejar errores.

### Ejemplo 1: Petición GET (Conexión con la API)
Realizamos una petición GET a la API de Star Wars. El código verifica que el servidor responda correctamente (código 200) y utiliza jsonDecode para transformar el texto de respuesta en un Mapa de Dart, permitiendo así acceder a los datos.

```dart
import 'package:http/http.dart' as http;
import 'dart:convert'; 

Future<dynamic> obtenerDatosStarWars() async {
  // 1. Definimos la URL base
  final urlStarWars = 'https://swapi.dev/api/people/1/'; 

  try {
    // 2. Realizamos la petición con el await para no bloquear la aplicación
    final response = await http.get(Uri.parse(urlStarWars));

    // 3. Verificamos el código de estado HTTP
    if (response.statusCode == 200) {
      // 4. Éxito: Parseamos el JSON de texto a un mapa de Dart
      print('Dato encontrado: ${response.body}');
      return jsonDecode(response.body);
    } else {
      // 5. Error del servidor (ej. 404 No Encontrado)
      print('Error del servidor: Código ${response.statusCode}');
      return null;
    }
  } catch (e) {
    // 6. Error de conexión 
    print('Error crítico de conexión: $e');
    return null;
  }
}
