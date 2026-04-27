# Memory Game Digital Chip

Este proyecto implementa un juego de memoria tipo **Simon Says** usando Verilog.

El circuito utiliza una memoria RAM de 16 posiciones por 8 bits para guardar una secuencia. Luego, el sistema muestra la secuencia poco a poco mediante una salida de 2 bits llamada `led_out`. El jugador debe repetir la secuencia usando la entrada `player_input`.

## Archivos

- `ram.v`: memoria RAM de 16x8 bits.
- `memory_game.v`: módulo principal del juego.
- `tb_memory_game.v`: testbench del proyecto.

## Entradas principales

- `clk`: reloj del sistema.
- `reset`: reinicia el juego.
- `prog_mode`: permite programar la RAM.
- `we`: habilita escritura en RAM.
- `prog_addr`: dirección de memoria a escribir.
- `prog_data`: dato que se guarda en memoria.
- `start`: inicia el juego.
- `player_input`: entrada del jugador.
- `enter`: confirma la entrada del jugador.

## Salidas principales

- `led_out`: salida que muestra la secuencia.
- `show_valid`: indica que `led_out` está mostrando un dato válido.
- `correct`: indica una respuesta correcta.
- `error`: indica una respuesta incorrecta.
- `win`: indica que el jugador completó la secuencia.
- `level`: nivel actual del juego.
- `state_out`: estado actual de la máquina de estados.

## Funcionamiento

1. Se programa la RAM con una secuencia de valores.
2. Se inicia el juego con `start`.
3. El sistema muestra la secuencia almacenada.
4. El jugador repite la secuencia usando `player_input`.
5. Si la entrada es correcta, el sistema aumenta el nivel.
6. Si la entrada es incorrecta, se activa la señal `error`.

## Idea general

Este diseño combina:

- Memoria RAM
- Máquina de estados finitos
- Comparador
- Contador de posición
- Control de niveles

El objetivo es presentar un sistema digital sencillo, comprensible y apto para una implementación estudiantil en chip.
