import os
from time import sleep

from httpx import post

BASE_APP_URL = "http://app"
BASE_OAUTH_URL = "http://mock_oauth2_server:8080"
AUD = os.environ["NON_PROD_RESOURCE_ID"]


def wait_for_oauth_server():
    for _ in range(10):
        try:
            payload = {"grant_type": "client_credentials", "resource": AUD, "aud": AUD}
            response = post(f"{BASE_OAUTH_URL}/token", data=payload, timeout=10)
            return response.json()["access_token"]
        except Exception:
            sleep(1)

    raise Exception("Unable to get response from oauth_server")


def before_all(_):
    wait_for_oauth_server()
