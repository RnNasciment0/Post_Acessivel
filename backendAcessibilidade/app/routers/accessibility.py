# app/routers/accessibility.py
from fastapi import APIRouter, File, UploadFile, Form
from app.services.contrastCalc import calculate_contrast
from app.services.altTextVal import validate_alt_text
from app.services.colorExtractor import extract_colors_from_image

router = APIRouter()


@router.post("/validate-post")
async def validate_post(
        # Recebemos o texto como formulário e a imagem como ficheiro
        alt_text: str = Form(...),
        image: UploadFile = File(...)
):
    # 1. Lê a imagem recebida
    image_bytes = await image.read()

    # 2. Extrai as cores reais da imagem
    bg_color_hex, text_color_hex = extract_colors_from_image(image_bytes)

    # 3. Calcula o contraste
    contrast_ratio = calculate_contrast(bg_color_hex, text_color_hex)
    is_contrast_valid = contrast_ratio >= 4.5

    # 4. Valida o texto alternativo
    alt_text_analysis = validate_alt_text(alt_text)

    return {
        "accessibility_score": {
            "contrast": {
                "ratio": round(contrast_ratio, 2),
                "is_valid": is_contrast_valid,
                "message": f"Contraste adequado ({bg_color_hex} e {text_color_hex})." if is_contrast_valid else f"Baixo contraste entre as cores principais ({bg_color_hex} e {text_color_hex})."
            },
            "alt_text": alt_text_analysis
        }
    }