# Marca NexCarg

## Concepto

El asta izquierda y la diagonal forman la **N** de NexCarg. El trazo derecho no
cierra la letra: **asciende y termina en punta de flecha**, porque el corredor
que cubre la plataforma va de sur a norte, de Panamá hacia Guatemala.

## Colores

| Uso | Color | Código |
| --- | --- | --- |
| Fondo y texto principal | Azul noche | `#0F1F29` |
| Acento sobre fondo claro | Azul | `#0D47FF` |
| Acento sobre fondo oscuro | Azul cielo | `#5490FF` |

El acento cambia de tono según el fondo: el azul intenso pierde contraste sobre
oscuro, y el celeste se apaga sobre blanco.

## Qué archivo usar

| Archivo | Para qué |
| --- | --- |
| `nexcarg-icono-1024.png` | Foto de perfil en redes, icono de la app, avatar |
| `nexcarg-icono-512.png` | Lo mismo, donde pidan menos peso |
| `nexcarg-icono-claro-1024.png` | Cuando el icono va sobre fondo oscuro |
| `nexcarg-horizontal-oscuro.png` | Logo completo sobre fondo claro o blanco |
| `nexcarg-horizontal-blanco.png` | Logo completo sobre fondo oscuro o foto |
| `nexcarg-horizontal-oscuro-2x.png` | Igual, al doble, para impresión o vallas |
| `nexcarg-marca-sola-1024.png` | Solo el símbolo, sin recuadro ni texto |
| `nexcarg-icono.svg` | Vector: rótulos grandes, vinilos, imprenta |

Los PNG tienen fondo transparente salvo los de icono, que llevan el recuadro.
Para cualquier tamaño grande usá el SVG: no se pixela nunca.

## Reglas de uso

- Dejar alrededor del logo un espacio libre de al menos la altura de la flecha.
- No cambiarle los colores, no estirarlo ni inclinarlo.
- Sobre fotos, usar siempre la versión blanca y asegurarse de que el fondo sea
  oscuro y sin detalle detrás del logo.
- El tamaño mínimo legible del logo horizontal es de 24 px de alto; por debajo,
  usar solo el símbolo.

## Cómo se regenera

Los archivos se producen con `herramientas/generar_marca.py`, que dibuja la
geometría a cuádruple resolución y la reduce para que los bordes queden limpios.
Si algún día cambia un color, se cambia ahí y se vuelven a generar todos.
