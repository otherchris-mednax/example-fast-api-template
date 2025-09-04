from fastapi import Depends, FastAPI
from fastapi.responses import PlainTextResponse
from pediatrix_logging import activate_fastapi_logging_integration

from fast_api_template.common.globals import PROJECT_NAME, VERSION_NUMBER
from fast_api_template.common.require_auth import require_auth

app = FastAPI(
    title=PROJECT_NAME,
    description="Fast API Template",
    version=VERSION_NUMBER,
)
activate_fastapi_logging_integration(app, "fast-api-template")


@app.get("/health", response_class=PlainTextResponse)
async def healthcheck():
    return "UP"


@app.get(
    "/hello",
    response_class=PlainTextResponse,
    dependencies=[
        Depends(require_auth),
    ],
)
async def hello():
    return "ello world"
