from typing import Annotated

from fastapi import Header, HTTPException
from httpx import get
from jose import jwt
from jose.exceptions import JWTClaimsError, JWTError

from fast_api_template.common.globals import JWKS_URL, NO_ROLES, RESOURCE_ID


def _get_token(header_value: str) -> str:
    try:
        return header_value.split(" ")[1]
    except Exception:
        raise HTTPException(status_code=401)


def _get_key():
    key_response = get(JWKS_URL, timeout=30)
    return key_response.json()["keys"]


def require_auth(authorization: Annotated[str, Header()]):
    token = _get_token(authorization)
    key = _get_key()
    try:
        token_data = jwt.decode(token, key, algorithms=["RS256"], audience=RESOURCE_ID)
        if not _check_roles(token_data):
            raise HTTPException(status_code=403)
    except JWTClaimsError:
        raise HTTPException(status_code=403)
    except JWTError:
        raise HTTPException(status_code=401)


def _check_roles(token_data):
    if NO_ROLES:
        return True
    else:
        return "roles" in token_data and "client.readerwriter" in token_data["roles"]
