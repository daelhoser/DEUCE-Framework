# DEUCE – Messaging Feature

## Conversations List - BDD Specs

### Narrative 1

```
As an online customer
I want the app to automatically load the conversations the user has participated on
```

#### Scenarios (Acceptance criteria)

```
Given the customer has connectivity
When the customer requests to see their conversations
Then the app should display the latest conversations from remote
```

```
Given the customer has connectivity
    And has conversations loaded
When the user receives a new message from a user from the list
Then the app shall update the list by updating the conversation content 
    And moving the conversation to the top of the list
```

```
Given the customer has connectivity
    And has conversations loaded
When the user receives a new message from a user not from the list
Then the app shall update the list by adding the conversation to the top of the list
```

### Narrative #2

```
As an offline user
I want the app to notify user that the app is offline and remain app in current state
```
#### Scenarios (Acceptance criteria)

```
Given the customer doesn't have connectivity
When the customer requests to see the conversations
Then the app will notify the user of connectivity issue
    and wait for connectivity.
```
