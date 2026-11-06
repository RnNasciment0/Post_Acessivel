from pydantic import BaseModel, Field

class PostAccessibilityRequest(BaseModel):
    background_color: str = Field(..., description="Cor de fundo em HEX (ex: #FFFFFF)")
    text_color: str = Field(..., description="Cor do texto em HEX (ex: #000000)")
    alt_text: str = Field(..., description="Texto descritivo da imagem")