Feature: List All JSON Files
  As a Babbo-User
  I want to be able to see a list of all JSON files
  So I know what stories are available

  Background:
    Given the app is running
      And I am on the Story List screen

  Scenario: No stories available
    Given there are no stories available
    Then I should see an empty table

  Scenario: Single story available
    Given there is 1 story available
    Then I should see a table with 1 entry
      And table entry 1 should read "Mein erster Versuch"

  Scenario: Multiple stories available
    And there are 2 stories available
    Then I should see a table with 2 entries
      And table entry 1 should read "Mein erster Versuch"
      And table entry 2 should read "Teil1"
