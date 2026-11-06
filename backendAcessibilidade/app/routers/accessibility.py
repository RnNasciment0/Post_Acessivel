from fastapi import APIRouter
from app.models.post import PostAccessibilityRequest
from app.services.contrastCalc import calculate_contrast
from app.services.altTextVal import validate_alt_text

router = APIRouter()


@router.post("/validate-post")
async def validate_post(request: PostAccessibilityRequest):
    # Calcula o contraste
    contrast_ratio = calculate_contrast(request.background_color, request.text_color)
    is_contrast_valid = contrast_ratio >= 4.5

    # Valida o texto alternativo
    alt_text_analysis = validate_alt_text(request.alt_text)

    return {
        "accessibility_score": {
            "contrast": {
                "ratio": round(contrast_ratio, 2),
                "is_valid": is_contrast_valid,
                "message": "Contraste adequado." if is_contrast_valid else "Aumente a diferença de luminosidade entre as cores (mínimo 4.5:1)."
            },
            "alt_text": alt_text_analysis
        }
    }