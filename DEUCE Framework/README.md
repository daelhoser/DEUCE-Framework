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

## Start new conversation with another user - BDD Specs

### Narrative 1

```
As an online user
I want the app to automatically load the users i can start/continue a conversation with.
```

#### Scenarios (Acceptance criteria)

```
Given the customer has connectivity
When the customer requests to see the users they can message
Then the app should display the users from remote
```

```
Given the customer has connectivity
    And has requested users displayed
When the customer selects a user from the list 
Then the app navigates to the 'Conversation' screen to begin/continue conversation
```

### Narrative 2

```
As an offline user
I want the app to notify the user that the app is offline and remian in the current state
```

#### Scenarios (Acceptance criteria)

```
Given the customer doesn't have connectivity
When the customer requests to see the users
Then the app will notify the user of connectivity issue
and wait for connectivity.
```

## Message in a conversation with another user - BDD Specs

### Narrative 1

```
As an online user
I want the app to be able to send & receive messages from the other user
```

#### Scenarios (Acceptance criteria)

```
Given the customer has connectivity
When the user requests to see the conversation with a selected user
Then the app displays the previous messages sent/received between this user
```

```
Given the customer has connectivity
    And previous messages sent/received from the other user are displayed
When a new message is received from or sent to the other user (image, text)
Then the app displays the message at the bottom of the list with a timestamp and name of the user from the message
```

```
Given the customer does not have connectivty
When the user tries to send a message 
Then an error message appears notifying the user of internet connectivity
```

```
Given the customer has connectivity
And previous messages sent/received from the other user are displayed
When a new message sent fails 
Then the app displays an icon to allow the user to try again or delete the message.
```
