import os
from unittest.mock import patch

import pytest
from common.require_auth import require_auth
from fastapi import HTTPException
from jose import jwt


@pytest.fixture()
def get_mock():
    with patch("common.require_auth.get") as mock:
        yield mock


@pytest.fixture()
def get_key_mock(jwk):
    with patch("common.require_auth._get_key") as mock:
        mock.return_value = jwk
        yield mock


@patch("common.require_auth.JWKS_URL", "www.example.com")
def test_require_auth_uses_correct_url(get_mock, good_token):
    with pytest.raises(Exception):
        require_auth(f"Bearer {good_token}")
    get_mock.assert_called_with("www.example.com", timeout=30)


@pytest.mark.parametrize(
    "auth_token",
    [
        ("Bearer badtoken"),
        ("Bearer"),
        (""),
    ],
)
def test_require_auth_raises_401_if_token_cant_be_parsed(auth_token, get_key_mock):
    with pytest.raises(HTTPException, match="401"):
        require_auth(auth_token)


def test_require_auth_raises_403_if_roles_are_incorrect(jwk, get_key_mock):
    token = jwt.encode(
        {"aud": os.environ["RESOURCE_ID"], "roles": ["client.readerwronger"]},
        jwk,
        "RS256",
    )
    with pytest.raises(HTTPException, match="403"):
        require_auth(f"Bearer {token}")


def test_require_auth_raises_403_if_roles_are_missing(jwk, get_key_mock):
    token = jwt.encode({"aud": os.environ["RESOURCE_ID"]}, jwk, "RS256")
    with pytest.raises(HTTPException, match="403"):
        require_auth(f"Bearer {token}")


def test_require_auth_raises_403_if_audience_is_incorrect(jwk, get_key_mock):
    token = jwt.encode({"aud": "bad_token"}, jwk, "RS256")
    with pytest.raises(HTTPException, match="403"):
        require_auth(f"Bearer {token}")


def test_require_auth_does_not_raise_on_valid_token(jwk, good_token, get_key_mock):
    require_auth(f"Bearer {good_token}")
