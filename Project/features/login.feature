Feature: Login.
  User should be able register or login in application.

  Scenario: User should see error if phone number is not filled
    When I enter "Oksana" into input field number 1
    When I enter "Kovalchuk" into input field number 2
    When I enter "380" into input field number 3
    When I touch the "SignIn" button
    And I wait until I see "Enter a valid country code and mobile number"


  Scenario: User should see error if country code is not filled
    When I enter "Oksana" into input field number 1
    When I enter "Kovalchuk" into input field number 2
    When I enter "913289130" into input field number 4
    When I touch the "SignIn" button
    And I wait until I see "Enter a valid country code and mobile number"

  Scenario: User should be able login successfully
    When I enter "Oksana" into input field number 1
    When I enter "Kovalchuk" into input field number 2
    When I enter "380" into input field number 3
    When I enter "913289130" into input field number 4
    When I touch the "SignIn" button
    And I wait until I don't see "Enter a valid country code and mobile number"