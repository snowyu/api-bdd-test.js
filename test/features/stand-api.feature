@server=http://127.0.0.1:3000
@root=/api
Feature: Standard API Test

Scenario: POST and Get result

  # POST 'http://127.0.0.1:3000/api/bottle'
  # with data
  Given POST "bottle":
  ----
  data:
    id: 1
    a: 1
  ----
  Then The last status code should be: 200
  Then The last status code should be not: 500
  Then The last result should be:
  ----
  id: 1
  a: 1
  ----

  Given this is a general lib
