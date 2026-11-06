def hex_to_rgb(hex_color: str):
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i + 2], 16) for i in (0, 2, 4))


def get_luminance(r: int, g: int, b: int) -> float:
    # Conversão para o espaço de cor sRGB linear
    a = [v / 255.0 for v in (r, g, b)]
    a = [v / 12.92 if v <= 0.03928 else ((v + 0.055) / 1.055) ** 2.4 for v in a]
    return a[0] * 0.2126 + a[1] * 0.7152 + a[2] * 0.0722


def calculate_contrast(color1_hex: str, color2_hex: str) -> float:
    rgb1 = hex_to_rgb(color1_hex)
    rgb2 = hex_to_rgb(color2_hex)

    lum1 = get_luminance(*rgb1)
    lum2 = get_luminance(*rgb2)

    brightest = max(lum1, lum2)
    darkest = min(lum1, lum2)

    return (brightest + 0.05) / (darkest + 0.05)