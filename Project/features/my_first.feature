Feature: Login.
  User should be able to login in application.

  Scenario: Credit card number is too long
    When I enter "Oksana" into input field number 1
    When I enter "Kovalchuk" into input field number 2
    When I enter "380" into input field number 3
    When I touch the "Sign In" button
    Then I should see "Error"

