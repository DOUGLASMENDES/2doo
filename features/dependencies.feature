Feature: dependencies
  As a Tracks user
  In order to keep track of complex todos that are dependent on each other
  I want to assign and manage todo dependencies

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"

  @selenium
  Scenario: Adding dependency to dependency by drag and drop
    Given I have a project "dependencies" with 3 todos
    And "Todo 2" depends on "Todo 1"
    When I go to the "dependencies" project
    And I drag "Todo 3" to "Todo 2"
    Then the successors of "Todo 1" should include "Todo 2"
    And the successors of "Todo 2" should include "Todo 3"
    When I expand the dependencies of "Todo 1"
    Then I should see "Todo 2" within the dependencies of "Todo 1"
    And I should see "Todo 3" within the dependencies of "Todo 1"
    When I expand the dependencies of "Todo 2"
    Then I should see "Todo 3" within the dependencies of "Todo 2"

  @selenium
  Scenario: I can edit a todo to add the todo as a dependency to another
    Given I have a context called "@pc"
    And I have a project "dependencies" that has the following todos
      | description | context |
      | test 1      | @pc     |
      | test 2      | @pc     |
      | test 3      | @pc     |
    When I go to the "dependencies" project
    When I edit the dependency of "test 1" to add "test 2" as predecessor
    Then I should see "test 1" within the dependencies of "test 2"
    And I should see "test 1" in the deferred container
    When I edit the dependency of "test 1" to add "test 3" as predecessor
    Then I should see "test 1" within the dependencies of "test 2"
    Then I should see "test 1" within the dependencies of "test 3"
    When I edit the dependency of "test 1" to remove "test 3" as predecessor
    And I edit the dependency of "test 2" to add "test 3" as predecessor
    Then I should see "test 1" within the dependencies of "test 3"
    Then I should see "test 2" within the dependencies of "test 3"

  @selenium
  Scenario: I can remove a dependency by editing the todo
    Given I have a context called "@pc"
    And I have a project "dependencies" that has the following todos
      | description | context |
      | test 1      | @pc     |
      | test 2      | @pc     |
    And "test 1" depends on "test 2"
    When I go to the "dependencies" project
    Then I should see "test 1" in the deferred container
    When I edit the dependency of "test 1" to remove "test 2" as predecessor
    Then I should not see "test 1" within the dependencies of "test 2"
    And I should not see "test 1" in the deferred container

  @selenium
  Scenario: Completing a predecessor will activate successors
    Given I have a context called "@pc"
    And I have a project "dependencies" that has the following todos
      | description | context |
      | test 1      | @pc     |
      | test 2      | @pc     |
      | test 3      | @pc     |
    And "test 2" depends on "test 1"
    When I go to the "dependencies" project
    Then I should see "test 2" in the deferred container
    And I should see "test 1" in the action container
    When I mark "test 1" as complete
    Then I should see "test 1" in the completed container
    And I should see "test 2" in the action container
    And I should not see "test 2" in the deferred container
    And I should see the empty message in the deferred container

  @selenium
  Scenario: Deleting a predecessor will activate successors
    Given I have a context called "@pc"
    And I have a project "dependencies" that has the following todos
      | description | context |
      | test 1      | @pc     |
      | test 2      | @pc     |
      | test 3      | @pc     |
    And "test 2" depends on "test 1"
    When I go to the "dependencies" project
    Then I should see "test 2" in the deferred container
    And I should see "test 1" in the action container
    When I delete the action "test 1"
    And I should see "test 2" in the action container
    And I should not see "test 2" in the deferred container
    And I should see the empty message in the deferred container

  Scenario: Deleting a successor will update predecessor
    Given this is a pending scenario

  @selenium
  Scenario: Dragging an action to a completed action will not add it as a dependency
    Given I have a context called "@pc"
    And I have a project "dependencies" that has the following todos
      | description | context | completed |
      | test 1      | @pc     | no        |
      | test 2      | @pc     | no        |
      | test 3      | @pc     | yes       |
    When I go to the "dependencies" project
    And I drag "test 1" to "test 3"
    Then I should see an error flash message saying "Cannot add this action as a dependency to a completed action!"
    And I should see "test 1" in project container for "dependencies"