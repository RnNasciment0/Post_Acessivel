from fastapi import FastAPI
from routers import accessibility

app = FastAPI(title="API de Acessibilidade DUA")

app.include_router(accessibility.router)
