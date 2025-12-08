# Práctica: Peticiones Asíncronas en Dart

## 1. Explicación: Peticiones a un servidor externo

Una petición asíncrona es un mecanismo que permite a nuestra aplicación solicitar datos a un servidor sin detener la ejecución del programa principal.

En Dart, los programas se ejecutan en un solo hilo. Si hiciéramos una petición de forma síncrona (bloqueante), la aplicación se "congelaría" totalmente hasta recibir la respuesta. Para evitar esto, utilizamos la asincronía:

1.  **Lanzamiento:** La app envía la petición y recibe inmediatamente un objeto `Future` (una promesa de que el dato llegará).
2.  **Espera no bloqueante:** Mientras el servidor procesa la solicitud, la app sigue funcionando (responde a clics, animaciones, etc.).
3.  **Resolución:** Cuando llegan los datos, utilizamos `await` para retomar el flujo y procesar la respuesta, o `try-catch` para manejar errores.

### Ejemplo 1: Petición GET (Consultar información)
Este método se utiliza para pedir datos al servidor (por ejemplo, leer una noticia).

```dart
import 'package:http/http.dart' as http;

Future<void> obtenerPost() async {
  // Definimos la URL
  final url = Uri.parse('[https://jsonplaceholder.typicode.com/posts/1](https://jsonplaceholder.typicode.com/posts/1)');
  
  // 'await' espera la respuesta sin bloquear la app
  final response = await http.get(url);

  if (response.statusCode == 200) {
    print('Éxito: ${response.body}');
  } else {
    print('Error del servidor: ${response.statusCode}');
  }
}