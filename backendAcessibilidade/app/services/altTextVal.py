def validate_alt_text(text: str) -> dict:
    issues = []
    text_lower = text.lower().strip()

    # Regra 1: Limite de caracteres (Leitores de tela podem fragmentar textos longos)
    if len(text) > 125:
        issues.append("O texto alternativo deve ser conciso e ter no máximo 125 caracteres.")

    # Regra 2: Remoção de redundância (Foco no objeto da imagem)
    redundant_phrases = ["foto de", "imagem de", "uma foto mostrando", "captura de tela"]
    if any(text_lower.startswith(phrase) for phrase in redundant_phrases):
        issues.append("Evite iniciar com 'foto de' ou 'imagem de'. O leitor de tela já anuncia o formato.")

    # Regra 3: Pontuação final (Garante a entonação e pausa do leitor de tela)
    if not text.endswith(('.', '!', '?')):
        issues.append("Termine o texto alternativo com um sinal de pontuação para indicar o fim da frase.")

    return {
        "is_valid": len(issues) == 0,
        "issues": issues
    }