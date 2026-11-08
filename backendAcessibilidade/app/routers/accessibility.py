from typing import List
from fastapi import APIRouter, File, UploadFile, Form
from app.services.contrastCalc import calculate_contrast
from app.services.altTextVal import validate_alt_text
from app.services.colorExtractor import extract_colors_from_image

router = APIRouter()


@router.post("/validate-post")
async def validate_post(
        alt_text: str = Form(...),
        images: List[UploadFile] = File(...)
):
    images_results = []

    for image in images:
        image_bytes = await image.read()
        try:
            # Tenta extrair as cores
            bg_color_hex, text_color_hex = extract_colors_from_image(image_bytes)
            contrast_ratio = calculate_contrast(bg_color_hex, text_color_hex)
            is_contrast_valid = contrast_ratio >= 4.5

            images_results.append({
                "filename": image.filename,
                "contrast_ratio": round(contrast_ratio, 2),
                "is_valid": is_contrast_valid,
                "message": f"Adequado ({bg_color_hex} e {text_color_hex})." if is_contrast_valid else f"Baixo contraste ({bg_color_hex} e {text_color_hex}). Sugestão: Escurecer o texto ou clarear o fundo."
            })
        except Exception as e:
            # Se a imagem tiver formato não suportado ou falhar, não trava o app inteiro
            images_results.append({
                "filename": image.filename,
                "contrast_ratio": 0.0,
                "is_valid": False,
                "message": "Não foi possível extrair as cores desta imagem (formato incompatível)."
            })

    alt_text_analysis = validate_alt_text(alt_text)

    return {
        "accessibility_score": {
            "carousel_analysis": images_results,
            "alt_text": alt_text_analysis
        }
    }