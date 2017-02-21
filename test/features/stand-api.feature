@server=http://127.0.0.1:3001
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
  And keep the result of "body.id" to "myid"
  And keep the result to "myres"
  And expect the stored "myid" equal 1
  And expect the stored "myid" is not equal 0
  And expect the kept "myid" least 1
  And expect the saved "myres" include:
    ---
      status:200
    ---
  And expect the stored "myres" include key "status"
  And expect the stored "myres" include key:
    ---
    [
      "status"
      "statusCode"
    ]
    ---
  When GET `"bottle/#{myid}"`
  Then The last status code should be: 200
  Then The last result should be:
  ----
  id: 1
  a: 1
  ----

  Given this is a general lib
  Given login user:'test1',password:'123123'
  Then The last status code should be: 200
  Then logout user
  Then The last status code should be: 204
  Then exit system
  Then quit system
