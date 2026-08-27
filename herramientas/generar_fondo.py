"""Genera el fondo de la portada: una red de rutas de noche.

Por qué dibujado y no una foto: una foto de camión de banco de imágenes cuesta
licencia, la usan otras cien empresas, y pesa varios megas. Esto es propio, no
lo puede usar nadie más, y comprime a poco porque es oscuro y suave.

Se dibuja al doble de tamaño y se reduce al final: es la forma barata de tener
curvas de borde limpio sin depender del antialias del dibujante.

    python3 herramientas/generar_fondo.py
"""
from PIL import Image, ImageChops, ImageDraw, ImageFilter

ANCHO, ALTO = 2560, 1440
SUPER = 2

NAVY = (11, 24, 34)
NAVY_MEDIO = (22, 46, 68)
AZUL = (13, 71, 255)
AZUL_CLARO = (92, 134, 255)
VERDE = (0, 200, 150)


def degradado(tamano, desde, hasta):
    """Degradado diagonal. Se pinta chiquito y se agranda: interpolar 64 px a
    2560 da una transición más limpia que calcularla pixel por pixel, y es
    instantáneo."""
    w, h = 64, 36
    base = Image.new('RGB', (w, h))
    px = base.load()
    for y in range(h):
        for x in range(w):
            t = (x / w + y / h) / 2
            px[x, y] = tuple(int(desde[i] + (hasta[i] - desde[i]) * t) for i in range(3))
    return base.resize(tamano, Image.BICUBIC)


def halo(tamano, centro, radio, color, fuerza):
    """Mancha de luz redonda y difusa, devuelta como (capa, máscara)."""
    w, h = tamano
    mascara = Image.new('L', (w // 8, h // 8), 0)
    d = ImageDraw.Draw(mascara)
    cx, cy, r = centro[0] // 8, centro[1] // 8, max(radio // 8, 1)
    for i in range(r, 0, -2):
        d.ellipse([cx - i, cy - i, cx + i, cy + i], fill=int(255 * fuerza * (1 - i / r) ** 2))
    mascara = mascara.resize((w, h), Image.BICUBIC).filter(ImageFilter.GaussianBlur(w // 200))
    return Image.new('RGB', (w, h), color), mascara


def curva(p0, p1, p2, pasos=300):
    """Bézier cuadrática. Rutas rectas se ven como un diagrama; curvas se leen
    como caminos."""
    puntos = []
    for i in range(pasos + 1):
        t = i / pasos
        u = 1 - t
        puntos.append((
            u * u * p0[0] + 2 * u * t * p1[0] + t * t * p2[0],
            u * u * p0[1] + 2 * u * t * p1[1] + t * t * p2[1],
        ))
    return puntos


def sumar(base, luz):
    """Mezcla aditiva. Sumar canal a canal deja el brillo del trazo encima sin
    oscurecer el fondo, que es lo que haría una mezcla normal."""
    return Image.merge('RGB', [ImageChops.add(b, l) for b, l in zip(base.split(), luz.split())])


def main():
    W, H = ANCHO * SUPER, ALTO * SUPER
    esc = lambda p: (p[0] * W, p[1] * H)

    lienzo = degradado((W, H), NAVY, NAVY_MEDIO)

    # Dos luces: una fría arriba a la derecha y una tenue abajo a la izquierda.
    # Sin ellas el fondo queda como un rectángulo plano.
    for centro, radio, color, fuerza in [
        ((int(W * 0.78), int(H * 0.12)), int(W * 0.42), AZUL, 0.55),
        ((int(W * 0.12), int(H * 0.92)), int(W * 0.34), NAVY_MEDIO, 0.5),
    ]:
        capa, mascara = halo((W, H), centro, radio, color, fuerza)
        lienzo = Image.composite(capa, lienzo, mascara)

    # --- Rutas ---
    # Van en una capa aparte y se difuminan antes de mezclar, para que brillen
    # en vez de quedar como alambres pegados encima.
    rutas = Image.new('RGB', (W, H), (0, 0, 0))
    dr = ImageDraw.Draw(rutas)

    for p0, p1, p2 in [
        ((-0.05, 0.72), (0.30, 0.40), (0.62, 0.52)),
        ((0.10, 1.05), (0.45, 0.70), (1.05, 0.58)),
        ((-0.05, 0.30), (0.35, 0.18), (0.72, 0.26)),
        ((0.30, 1.08), (0.68, 0.88), (1.06, 0.86)),
        ((0.48, -0.06), (0.72, 0.22), (1.06, 0.18)),
    ]:
        dr.line(curva(esc(p0), esc(p1), esc(p2)), fill=(22, 38, 58), width=3 * SUPER, joint='curve')

    principal = curva(esc((-0.06, 0.88)), esc((0.38, 0.46)), esc((1.06, 0.30)))
    dr.line(principal, fill=(34, 74, 150), width=5 * SUPER, joint='curve')

    lienzo = sumar(lienzo, rutas.filter(ImageFilter.GaussianBlur(2 * SUPER)))

    # --- Nodos ---
    nodos = Image.new('RGB', (W, H), (0, 0, 0))
    dn = ImageDraw.Draw(nodos)
    for t, color, radio in [(0.16, AZUL_CLARO, 6), (0.46, VERDE, 9), (0.78, AZUL_CLARO, 6)]:
        x, y = principal[int(t * (len(principal) - 1))]
        r = radio * SUPER
        for i in range(r * 5, 0, -2):
            f = (1 - i / (r * 5)) ** 2
            dn.ellipse([x - i, y - i, x + i, y + i], fill=tuple(int(c * f * 0.45) for c in color))
        dn.ellipse([x - r, y - r, x + r, y + r], fill=color)

    lienzo = sumar(lienzo, nodos.filter(ImageFilter.GaussianBlur(SUPER)))

    # Viñeta: apaga los bordes para que el texto de la portada, que va encima,
    # nunca compita con el fondo.
    vinneta = Image.new('L', (W // 8, H // 8), 0)
    dv = ImageDraw.Draw(vinneta)
    dv.ellipse([-W // 20, -H // 12, W // 8 + W // 20, H // 8 + H // 12], fill=255)
    vinneta = vinneta.resize((W, H), Image.BICUBIC).filter(ImageFilter.GaussianBlur(W // 60))
    lienzo = Image.composite(lienzo, Image.new('RGB', (W, H), NAVY), vinneta)

    lienzo = lienzo.resize((ANCHO, ALTO), Image.LANCZOS)
    lienzo.save('assets/fondo-portada.jpg', quality=80, optimize=True, progressive=True)
    print('assets/fondo-portada.jpg', lienzo.size)


if __name__ == '__main__':
    main()
