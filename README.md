# Proyecto 3: Piedra, Papel, Tikera, Lagarto, Spock (CI-3661)

- **Nombres:** (Mauricio Fragachán, Alan Argotte, David Díaz)
- **Carnets:** (20-10265, 19-10664, 20-10019)


## Restricciones y notas de instalación

- En la interfaz gráfica, los inputs de "Estrategia" y "Modo de juego" deben escribirse con la primera letra en mayúscula y las siguientes en minúscula (por ejemplo: "Uniforme", "Rondas").

- Tecnologías y versiones utilizadas:
  - Java 24.0.1 (2025-04-15)
  - Java(TM) SE Runtime Environment (build 24.0.1+9-30)
  - Java HotSpot(TM) 64-Bit Server VM (build 24.0.1+9-30, mixed mode, sharing)
  - JRuby 9.4.14
  - Shoes 4.0.0.rc1

- Para la instalación de Shoes con JRuby ejecutar:

  ```bash
  jruby -S gem install shoes --pre
  ```

  (asegurarse de usar JRuby versión 9.4.14 y que se instale la versión de Shoes 4.0.0.rc1)

- Nota importante: no se utilizó un input de tipo lista en la interfaz porque Shoes genera complejidades en su uso que dificultaron su implementación.


## Instrucciones de ejecución

El usuario del programa requiere:

1.  **Para ejecutar la interfaz gráfica:** 
```
jruby main.rb
```
2.  **Ejecución desde la terminal:** el usuario debe modificar directamente el archivo RPTLS.rb y así usar los métodos disponibles para ejecutar el programa. Ya cuenta con mensajes de feedback que informan al usuario sobre el número de puntos de cada jugador, la jugada de cada jugador en la ronda y el estado de la partida una vez inicializada una instancia. También puede ver desde la terminal el estado de la partida iniciando la interfaz gráfica. Feature ;-)
```
jruby RPTLS.rb
```

## Ejemplo de salida
Dado el par de jugadores Mauricio y David con las estrategias `Pensar` cada uno, deben jugar tres rondas para decidir quién comerá la última hamburguesa de pollo que hizo Alan.
```
Estrategias:
 P1: Lagarto, P2: Piedra
Resultado de la ronda:
 P1: 0, P2: 1
Estrategias:
 P1: Papel, P2: Lagarto
Resultado de la ronda:
 P1: 0, P2: 2
Estrategias:
 P1: Papel, P2: Papel
Resultado de la ronda:
 P1: 0, P2: 2
Gana David
```
