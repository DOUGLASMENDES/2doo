Feature: Manage recurring todos
  In order to manage repeating todos
  As a Tracks user
  I want to view, edit, add, or remove recurrence patterns of repeating todos

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"
    And I have a context called "test context"
    And I have a repeat pattern called "run tests"

  @selenium
  Scenario: Being able to select daily, weekly, monthly and yearly pattern
    When I go to the repeating todos page
    And I follow "Add a new recurring action"
    Then I should see the form for "Daily" recurrence pattern
    When I select "Weekly" recurrence pattern
    Then I should see the form for "Weekly" recurrence pattern
    When I select "Monthly" recurrence pattern
    Then I should see the form for "Monthly" recurrence pattern
    When I select "Yearly" recurrence pattern
    Then I should see the form for "Yearly" recurrence pattern
    When I select "Daily" recurrence pattern
    Then I should see the form for "Daily" recurrence pattern

  @selenium
  Scenario: I can mark a repeat pattern as starred
    When I go to the repeating todos page
    And I star the pattern "run tests"
    Then the pattern "run tests" should be starred

  @selenium
  Scenario: I can edit a repeat pattern
    When I go to the repeating todos page
    And I edit the name of the pattern "run tests" to "report test results"
    Then the pattern "report test results" should be in the state list "active"
    And I should not see "run tests"

  @selenium
  Scenario: I can delete a repeat pattern
    When I go to the repeating todos page
    And I delete the pattern "run tests"
    And I should not see "run tests"

  @selenium
  Scenario: I can mark a repeat pattern as done
    When I go to the repeating todos page
    Then the pattern "run tests" should be in the state list "active"
    And the state list "completed" should be empty
    When I mark the pattern "run tests" as complete
    Then the pattern "run tests" should be in the state list "completed"
    And the state list "active" should be empty

  @selenium
  Scenario: I can reactivate a repeat pattern
    Given I have a completed repeat pattern "I'm done"
    When I go to the repeating todos page
    Then the pattern "I'm done" should be in the state list "completed"
    When I mark the pattern "I'm done" as active
    Then the pattern "I'm done" should be in the state list "active"
    And the state list "completed" should be empty

  Scenario: Following the recurring todo link of a todo takes me to the recurring todos page
    Given this is a pending scenario

  Scenario: Deleting a recurring todo with ending pattern will show message
    Given this is a pending scenario

  Scenario: Deleting a recurring todo with active pattern will show new todo
    Given this is a pending scenario
