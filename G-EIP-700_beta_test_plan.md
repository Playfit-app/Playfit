### **BETA TEST PLAN – Playfit**

## **1. Core Functionalities for Beta Version**

| **Feature Name**  | **Description** | **Priority (High/Medium/Low)** | **Changes Since Tech3** |
|-------------------|-----------------|--------------------------------|-------------------------|
| Movement tracking for exercices | Users can choose the difficulty of the list of exercices and can do the exercice being tracked | High | - |
| Leveling and progression | Users can see their level and progress through the exercices | Medium | - |
| Algorithm | Users can see a mascott that suggests exercices to do | Low | New feature |
| Profile and Avatar | Users can view their profile and custom their avatar | High | - |
| Data visualisation | Users can view their progress through graphs and charts | Low | - |
| Profile details | Users can view their profile details | Medium | New feature |
| Social interaction | Users interact with other users: search for an user, follow an user, view the profile of an user | High | New feature |
| Performance sharing | Users can share their performance with other users | High | New feature |
| Reactions to posts | Users can like and comment the posts of other users | High | New feature |
| Settings | Users can change the settings of the app | Medium | - |


## **2. Beta Testing Scenarios**
### **2.1 User Roles**
[Define the different user roles that will be involved in testing, e.g., Admin, Regular User, Guest, External Partner.]

| **Role Name**  | **Description** |
| User           | Access to the exercices, can check the profile and track progress. |

### **2.2 Test Scenarios**
For each core functionality, provide detailed test scenarios.

#### **Scenario 1: Movement tracking for exercices**
- **Role Involved:** User
- **Objective:** Selecting a list of exercices and do the exercice being tracked
- **Preconditions:** Being logged
- **Test Steps:**
  1. Go to the home page
  2. Select the diffulcty of the list of exercices (easy, medium, hard)
  3. Do the exercices in the orden given, the user can see the exercice being done
  4. Each repetition is tracked and counted
- **Expected Outcome:** When the exercice is finished, the user can see the number of repetitions done and the time taken to do the exercice as recap.

#### **Scenario 2: Leveling of the user**
- **Role Involved:** User
- **Objective:** View the level and progress of the user
- **Preconditions:** Being logged, selected an exercice (see Scenario 1)
- **Test Steps:**
 1. Finish the exercice selected
 2. An animation appears and the user can see his avatar climb a new hill, the objective is to reach the monument
 3. (Optional) The user can see the fun facts about the landmarks if he arrived at the monument
 4. The avatar of the go to the next checkpoint in the home page as well
- **Expected Outcome:** The user can see the animation and the fun facts about the landmarks. The user can also see his progression in the home page.

#### **Scenario 3: Algorithm**
- **Role Involved:** User
- **Objective:** Increase the difficulty of the exercices following the user’s performance
- **Preconditions:** Being logged, having done at least one exercice (see Scenario 1)
- **Test Steps:**
 1. Go to the home page
 2. A mascott appears and asks the user to do an exercice, increasing the difficulty of the exercice suggested
- **Expected Outcome:** The user can see the mascott and the exercice suggested. The user can also see the difficulty of the exercice suggested.


#### **Scenario 4: Profile and avatar**
- **Role Involved:** User
- **Objective:** Customise the avatar and view the profile
- **Preconditions:** Being logged
- **Test Steps:**
  1. Go to the profile page
  2. Click on avatar picture profile to go to the avatar page
  3. Select a one of the clothes weared by the avatar on avatar page
  4. (Optional) Select a new avatar by clicking on the "Change avatar" button
  5. Change the clothe and save the changes
  6. Go back to the profile page
- **Expected Outcome:** The user can see the new clothe on the avatar picture profile.

#### **Scenario 5: Data visualisation**
- **Role Involved:** User
- **Objective:** View data related to the exercices
- **Preconditions:** Being logged, having done at least one exercice (see Scenario 1)
- **Test Steps:**
  1. Go to the profile page
  2. Select the charts to view the data
  3. Select the data to view (day, week, month)
- **Expected Outcome:** The user can see the data visualisation of the exercices done each day.

#### **Scenario 6: Profile details**
- **Role Involved:** User
- **Objective:** View the profile details of the user
- **Preconditions:** Being logged
- **Test Steps:**
  1. Go to the profile page
  2. Select the profile details
  3. View the success details
  4. View the level details
  5. View the followers / following
  6. View the data visualisation (see Scenario 5)
  7. View the customisation of the profile (see Scenario 4)
- **Expected Outcome:** The user can see the profile details of the user and the data visualisation of the exercices done each day.

#### **Scenario 7: Social interaction**
- **Role Involved:** User
- **Objective:** Interact with other users
- **Preconditions:** Being logged
- **Test Steps:**
  1. Go to the search page
  2. Search for an user, the user can search by username
  3. Select the user from the list
  4. View the profile of the user
  5. Follow the user
- **Expected Outcome:** The user can see the profile of the user and the posts of the user. The user can also follow the user.


#### **Scenario 8: Performance sharing**
- **Role Involved:** User
- **Objective:** Share the performance with other users
- **Preconditions:** Being logged, having done at least one exercice (see Scenario 1)
- **Test Steps:**
  1. After doing an exercice, the user can see a button to share the performance
  2. Click on the button to share the performance
  3. Post the message
- **Expected Outcome:** The user can see the post on the wall of the user. The user can also see the post on the wall of the user’s followers.

#### **Scenario 9: Reactions to posts**
- **Role Involved:** User
- **Objective:** Interact with the posts of other users
- **Preconditions:** Being logged, having done at least one exercice (see Scenario 1), follow the user who posted his performance
- **Test Steps:**
  1. Go to the post's page
  2. Select the post of the user
  3. Like the post
  4. Comment the post
- **Expected Outcome:** The user can see the post of the user and can like and comment the post. The user can also see the number of likes and comments on the post.

#### **Scenario 10: Settings**
- **Role Involved:** User
- **Objective:** Change the settings of the app
- **Preconditions:** Being logged
- **Test Steps:**
  1. Go to the settings page
  2. Change the language of the app
  3. Change the theme of the app
  4. Activate / Deactivate the notifications
  5. Customize the overlays (bottom / left / right)
  6. Change user’s data (username, name, etc...)
  7. Read the terms and conditions
  8. Read the privacy policy
- **Expected Outcome:** The user can see the changes made in the app.

## **3. Success Criteria**
Each scenario will be considered successful if the expected outcome is achieved. we expect to have at least 80% of the scenarios passing without any issues. The beta test will be considered successful if the following criteria are met:
- 80% of the scenarios pass without any issues.
- No critical bugs are found that prevent the application from functioning.
- The application performs well on a variety of devices.
- The user experience is smooth and intuitive.

## **4. Known Issues & Limitations**

| **Issue** | **Description** | **Impact** | **Planned Fix? (Yes/No)** |
|-----------|-----------------|---==-------|---------------------------|
| User's distance to the camera | The user needs to be at a correct distance | Highest | Yes |
| False positive during camera setup | A repetition could be counted when the user is setting up the camera's position | High | Yes |
| iOS device | The app is not working on ios devices | Highest | Yes |

## **5. Conclusion**

The team expects to achieve a successful beta test of the core functionalities of the application. The feedback from the beta testers will be crucial in identifying any issues and improving the overall user experience before the final release. The team expects to gather valuable insights from the beta testers and make necessary adjustments to ensure a smooth launch.