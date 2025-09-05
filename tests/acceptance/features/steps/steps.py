import os

from behave import given, then, when
from httpx import get, post

BASE_APP_URL = "http://app"
BASE_OAUTH_URL = "http://mock_oauth2_server:8080"
AUD = os.environ["NON_PROD_RESOURCE_ID"]


def _build_headers(context):
    return {
        "Authorization": f"Bearer {_get_token(context)}",
        "Content-Type": "application/json",
    }


def _get_token(context):
    if context.has_token:
        payload = {"grant_type": "client_credentials", "resource": AUD, "aud": AUD}
        response = post(f"{BASE_OAUTH_URL}/token", data=payload, timeout=10)
        return response.json()["access_token"]
    else:
        return "aa"


def _send_get_request(context, uri):
    response = get(f"{BASE_APP_URL}{uri}", headers=_build_headers(context), timeout=10)
    return response


def _send_post_request(context, uri, kind):
    if not hasattr(context, "payload"):
        context.payload = {}
    if kind == "good":
        context.payload = {"message": "hello"}
    else:
        context.payload = {"not_message": "bad"}
    response = post(
        f"{BASE_APP_URL}{uri}",
        json=context.payload,
        headers=_build_headers(context),
        timeout=10,
    )
    return response


@given("a valid authorization token")
def _step_impl(context):
    context.has_token = True


@given("an invalid authorization token")
def _step_impl(context):
    context.has_token = False


@when('a user makes a GET request to "{path}"')
def _step_impl(context, path):
    context.response = _send_get_request(context, path)


@when('a user makes a POST request to "{path}" with a "{kind}" payload')
def _step_impl(context, path, kind):
    context.response = _send_post_request(context, path, kind)


@then('the http response should have a status code of "{status_code}"')
def _step_impl(context, status_code):
    expected_status = int(status_code)
    if context.response is not None:
        actual_status = context.response.status_code
    else:
        actual_status = None

    assert expected_status == actual_status, print(
        f"Expected: {expected_status}. Actual: {actual_status}."
    )


@then('it should contain a div "{div_id}"')
def _step_impl(context, div_id):
    assert div_id in context.response.text


@then('it should return "{value}"')
def _step_impl(context, value):
    context.response.encoding = "utf-8"
    assert value in context.response.text, print(
        f"Expected: [{value}]| Actual: {context.response.text}"
    )
