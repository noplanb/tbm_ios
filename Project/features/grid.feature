
Feature: Grid.
  User should be able to interact with grid view.

@empty-grid
  Scenario: New user installs application and opens grid 
    Given I have fresh registration
    Then I wait to see "gridView"