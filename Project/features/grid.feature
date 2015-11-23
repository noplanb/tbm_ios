
Feature: Grid.
  User should be able to interact with grid view.

@empty-grid
  Scenario: New user installs application and opens grid 
    Given fresh registration
    And I wait until I see "gridView"