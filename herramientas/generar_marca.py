from PIL import Image, ImageDraw, ImageFont

NAVY, BLUE, CIELO, WHITE = (15,31,41), (13,71,255), (84,144,255), (255,255,255)
SS = 4  # se dibuja al cuádruple y se reduce, para que los bordes queden limpios

# Rejilla 0..100. El asta izquierda y la diagonal forman la N; el trazo derecho
# sube y termina en punta: el corredor va de sur a norte, de Panamá a México.
def marca(d, x, y, s, color, acento):
    P = lambda pts: [(x + px*s/100, y + py*s/100) for px, py in pts]
    d.polygon(P([(18,80),(18,20),(33,20),(33,80)]), fill=color)
    d.polygon(P([(18,20),(33,20),(59,80),(44,80)]), fill=color)
    d.polygon(P([(59,80),(59,42),(74,42),(74,80)]), fill=acento)
    d.polygon(P([(50,44),(83,44),(66.5,17)]), fill=acento)

def icono(px, fondo=NAVY, color=WHITE, acento=CIELO, radio=0.22):
    img = Image.new('RGBA', (px*SS, px*SS), (0,0,0,0))
    d = ImageDraw.Draw(img)
    if fondo is not None:
        d.rounded_rectangle([0,0,px*SS-1,px*SS-1], radius=int(px*SS*radio), fill=fondo)
    marca(d, px*SS*0.13, px*SS*0.14, px*SS*0.74, color, acento)
    return img.resize((px,px), Image.LANCZOS)

def solo_marca(px):
    img = Image.new('RGBA', (px*SS, px*SS), (0,0,0,0))
    marca(ImageDraw.Draw(img), -px*SS*0.16, -px*SS*0.15, px*SS*1.28, NAVY, BLUE)
    return img.resize((px,px), Image.LANCZOS)

def horizontal(alto, texto, color, acento, fondo=None):
    f = ImageFont.truetype('assets/fonts/AppSans-Bold.ttf', int(alto*SS*0.44))
    tmp = ImageDraw.Draw(Image.new('RGBA',(10,10)))
    tw = tmp.textbbox((0,0), 'NexCarg', font=f)[2]
    sep = alto*SS*0.10
    x_txt = alto*SS*0.86 + sep
    ancho = int((x_txt + tw + alto*SS*0.12)/SS)
    img = Image.new('RGBA', (ancho*SS, alto*SS), fondo or (0,0,0,0))
    d = ImageDraw.Draw(img)
    marca(d, alto*SS*0.01, alto*SS*0.13, alto*SS*0.78, color, acento)
    d.text((x_txt, alto*SS*0.30), 'NexCarg', font=f, fill=texto)
    return img.resize((ancho,alto), Image.LANCZOS)

o = 'marca/'
icono(1024).save(o+'nexcarg-icono-1024.png')
icono(512).save(o+'nexcarg-icono-512.png')
icono(1024, fondo=WHITE, color=NAVY, acento=BLUE).save(o+'nexcarg-icono-claro-1024.png')
solo_marca(1024).save(o+'nexcarg-marca-sola-1024.png')
horizontal(512, NAVY, NAVY, BLUE).save(o+'nexcarg-horizontal-oscuro.png')
horizontal(512, WHITE, WHITE, CIELO).save(o+'nexcarg-horizontal-blanco.png')
horizontal(1024, NAVY, NAVY, BLUE).save(o+'nexcarg-horizontal-oscuro-2x.png')

# Vector, para imprenta y rótulos grandes donde el PNG se pixelaría
svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="1024" height="1024">
  <title>NexCarg</title>
  <rect width="100" height="100" rx="22" fill="#0F1F29"/>
  <g transform="translate(13,14) scale(0.74)">
    <path d="M18 80 V20 H33 V80 Z" fill="#FFFFFF"/>
    <path d="M18 20 H33 L59 80 H44 Z" fill="#FFFFFF"/>
    <path d="M59 80 V42 H74 V80 Z" fill="#5490FF"/>
    <path d="M50 44 H83 L66.5 17 Z" fill="#5490FF"/>
  </g>
</svg>'''
open(o+'nexcarg-icono.svg','w').write(svg)
print('generado')
