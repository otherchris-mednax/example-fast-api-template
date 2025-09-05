Feature: Hello endpoint

Scenario: Hello endpoint returns 401 when bad token provided (good payload)
    Given an invalid authorization token
    When a user makes a POST request to "/hello" with a "good" payload
    Then the http response should have a status code of "401"

Scenario: Hello endpoint returns 401 when bad token provided (bad payload)
    Given an invalid authorization token
    When a user makes a POST request to "/hello" with a "bad" payload
    Then the http response should have a status code of "401"

Scenario: Hello endpoint returns 200 and "ello world" when valid token provided
    Given a valid authorization token
    When a user makes a POST request to "/hello" with a "good" payload
    Then the http response should have a status code of "200"
    And it should return "ello world"
