from colorthief import ColorThief
import io


def rgb_to_hex(rgb: tuple) -> str:
    return '#{:02x}{:02x}{:02x}'.format(rgb[0], rgb[1], rgb[2])


def extract_colors_from_image(image_bytes: bytes):
    # O ColorThief precisa de um objeto do tipo ficheiro, por isso usamos o io.BytesIO
    ct = ColorThief(io.BytesIO(image_bytes))

    # Extrai uma paleta com as 2 cores principais da imagem
    palette = ct.get_palette(color_count=2, quality=1)

    # A primeira cor costuma ser o fundo dominante, a segunda o elemento de maior destaque
    bg_rgb = palette[0]
    text_rgb = palette[1]

    return rgb_to_hex(bg_rgb), rgb_to_hex(text_rgb)