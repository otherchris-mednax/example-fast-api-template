Feature: Project Validation

  Scenario: Health endpoint returns 200 and healthy when API is up
    Given a valid authorization token
    When a user makes a GET request to "/health"
    Then the http response should have a status code of "200"
    Then it should return "UP"

  Scenario: API service has a Swagger document
    Given a valid authorization token
    When a user makes a GET request to "/docs"
    Then the http response should have a status code of "200"
    And it should contain a div "swagger-ui"
