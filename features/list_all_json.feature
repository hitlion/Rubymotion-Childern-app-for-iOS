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
      # TODO: replace with actual story names from the test data
      And table entry 1 should read "My first story"

  Scenario: Multiple stories available
    And there are 3 stories available
    Then I should see a table with 3 entries
      # TODO: replace with actual story names from the test data
      And table entry 1 should read "My first story"
      And table entry 2 should read "My second story"
      And table entry 3 should read "My third story"
