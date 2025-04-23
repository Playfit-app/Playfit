### **BETA TEST PLAN – Playfit**

## **1. Core Functionalities for Beta Version**

| **Feature Name**  | **Description** | **Priority (High/Medium/Low)** | **Changes Since Tech3** |
|-------------------|-----------------|--------------------------------|-------------------------|
| Movement tracking for exercices | Users can choose an exercice and can do the exercice being tracked | High | - |
| Social interaction | Users interact with other users: search for an user, follow an user, view the profile of an user | Medium | New feature |
| Profile and settings | Users can view their profile and custom their avatar | High | - |
| Data visualisation | Users can view their progress through graphs and charts | Low | - |

## **2. Beta Testing Scenarios**
### **2.1 User Roles**
[Define the different user roles that will be involved in testing, e.g., Admin, Regular User, Guest, External Partner.]

| **Role Name**  | **Description** |
| User           | Access to the exercices, can check the profile and track progress. |

### **2.2 Test Scenarios**
For each core functionality, provide detailed test scenarios.

#### **Scenario 1: Movement tracking for exercices**
- **Role Involved:** User
- **Objective:** Doing an exercice
- **Preconditions:** Being logged
- **Test Steps:**
  1. Select an exercice from the list
  2. Do the exercice choosen, the user can see the exercice being done
  3. Each repetition is tracked and counted
- **Expected Outcome:** When the exercice is finished, the user can see the number of repetitions done and the time taken to do the exercice as recap.


#### **Scenario 2: Social interaction**
- **Role Involved:** User
- **Objective:** Interact with other users
- **Preconditions:** Being logged
- **Test Steps:**
  1. Go to the search page
  2. Search for an user, the user can search by name or by username
  3. Select the user from the list
  4. View the profile of the user
  5. Follow the user
- **Expected Outcome:** The user can see the profile of the user and the posts of the user. The user can also follow the user.

#### **Scenario 3: Profile and avatar**
- **Role Involved:** User
- **Objective:** Customise the profile
- **Preconditions:** Being logged
- **Test Steps:**
  1. Go to the profile page
  2. Click on avatar picture profile to go to the avatar page
  3. Select a one of the clothes weared by the avatar on avatar page
  4. Change the clothe and save the changes
  5. Go back to the profile page
- **Expected Outcome:** The user can see the new clothe on the avatar picture profile.

#### **Scenario : Data visualisation**
- **Role Involved:** User
- **Objective:** View data related to the exercices
- **Preconditions:** Being logged, having done at least one exercice (see Scenario 1)
- **Test Steps:**
  1. Go to the profile page
  2. Select the charts to view the data
- **Expected Outcome:** The user can see the data visualisation of the exercices done each day.

## **3. Success Criteria**


## **4. Known Issues & Limitations**

| **Issue** | **Description** | **Impact** | **Planned Fix? (Yes/No)** |
|-----------|-----------------|---==-------|---------------------------|
| User's distance to the camera | The user needs to be at a correct distance | Highest | Yes |
| False positive during camera setup | A repetition could be counted when the user is setting up the camera's position | High | Yes |
| Jumping jack exercice | The detection of jumping jack accuracy is low | High | Yes |

## **5. Conclusion**

The team expects to achieve a successful beta test of the core functionalities of the application. The feedback from the beta testers will be crucial in identifying any issues and improving the overall user experience before the final release. The team expects to gather valuable insights from the beta testers and make necessary adjustments to ensure a smooth launch.