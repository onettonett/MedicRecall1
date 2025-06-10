<p align="center">
<img src="flashcard/assets/app_logo4.png" height="110">
<h1 align="center">2024-MedicRecall</h1>
<h4 align="center">xd23197, ar23931, nv22173, rw22740, nv23870</h5>

<!--Use the code above as a header for all MedicRecall pages.-->

## Brief Project Description
The project’s aim is to provide an all-encompassing platform to help medical students study for the Multi-Speciality Recruitment Assessment (MSRA). By using evidence-based studying principles, such as active recall and spaced repetition, students should expect to spend less time achieving a higher score.

### Contents
This is a thorough README document so use this to skip to your desired section:
1. [Brief Project Description](##Brief-Project-Description)
2. [Why is this important?](###Why-is-this-important?)  
3. [Stakeholders](##Stakeholders)  
4. [User stories](##User-stories)
5. [Ethics Analysis](##Ethics-analysis)  
6. [User instructions](##User-instructions)  
6. [Database Diagram](##Database-Diagram)  
7. [Architecture Diagram](##Architecture-Diagram)  
8. [Developer Instructions](#Developer-Instructions)  
9. [Why Firebase?](##Why-Firebase?)  
10. [Contributors](##Contributors)

### Why is this important?
The MSRA is crucial for trainees as it decides their speciality and is used to apply for placement: placements are increasingly competitive with only one in four applications being successful. Preparing for this exam is done in parallel with medical students’ other responsibilities: a full-time demanding job, maintaining a competitive portfolio (including research papers), and other exams such as the MRCP. This, combined with the importance of the exam, leads to four in ten doctors reporting burnout.

## Stakeholders
#### Primary users of the platform
**_Junior doctors_** are the primary users of the platform.
MedicRecall helps them score highly on the MSRA, which helps them secure highly competitive work placements. Trained doctors may also use the platform to reacquaint themselves with the material. 

#### Other stakeholders
- NHS
    - MedicRecall trains doctors for the NHS so we must ensure junior doctors are equipped with a comprehensive and in-depth understanding of necessary topics for their work
    - Teaching false information has detrimental effects so all information that is taught on the platform must be accurate and up to date
- Legislators (GDPR)
    - Students’ data is collected so corresponding data and privacy laws must be adhered to:
        - The use of data should be transparent to customers
        - Data must not be sent to countries without equivalent data protection laws.
        - Only necessary data should be stored and shouldn’t be kept for longer than required
- App Store (Apple App Store, Google Play Store)
    - Rules of the app store must be adhered to

## User stories

### Sophia
> "I don't want to waste time thinking about exactly when I should study for the MSRA. The platform should automatically schedule tests for me so I don't have to worry about planning my revision."
#### How did we address this?
We added a **study planner feature**. A spaced repitition algorithm automatically decides which topics Sophia should study each day for optimal long term memory, ensuring a maximum of two topics per day. Clicking on the topics in the calendar lets Sophia revise only the most relevant topics easily.

### Liam
> "I want a variety of question formats, not just flashcards. I believe exam-style questions are an important revision tool."
#### How did we address this?
- We added **full-size mock exams**
- We added **multiple choice questions**
- We added the **ability to create your own flashcards**
    - For instance, Liam might want to articulate a piece of knowledge differently.
### Noah
> "I want the platform to feel responsive and fast. The user interface is especially important to me: it should look minimal and it should feel intuitive. I don't want to spend time learning how to use the app, it should be designed such that the way to use it is obvious."
#### How did we address this?
- We've completely overhauled the UI of every page in the app, this includes the following:
    - Dashboard page
    - Topic selector page
    - Flashcard review page
    - Mark scheme page
    - Mock exam page
    - Settings page
    - Sidebar
    - Loading screen UI
    - Explanation pages (inc. How does the platform work?, FAQ, Feedback)
    - **_and more..._**
- Fixed theming issues and theming inconsistency
- We've made changes to the poorly designed, inefficient database that we inherited
- Added a light and dark theme
- Added a font size selector

## Ethics Analysis

#### Publically accessible data
The majority of the data used in MedicRecall is learning material, exam-style questions and past exam papers. This information is publically available and impersonal so there's no consequence to people trying to webscrape for the data as it's not intellectual property of MedicRecall: there's also no incentive as doing this is harder than finding the same data elsewhere.

However, it's notable that if MedicRecall does decide to make it's own practise questions - in addition to publically available questions - then protecting against web scraping becomes more of a priority. 

#### Personal User Data
The only identifiable data will be progress on the exam questions, names of the users, and emails. Preventing names and emails from being leaked is crucial.

#### Database safety considerations
Currently, we are working with a live site and live database (with active users).

## User Instructions
There is plenty of help on the app, in the form of tooltips and help pages, so a junior doctor should be able to quickly discover how to use the app.

#### How to revise flashcards
- First, select the **flashcard tutor** page: you can select it from the sidebar or by clicking "Start now" on the "Next Flashcard Deck for review" widget on the homepage. 
- **Select topics** or refine your learning by selecting individual subtopics - you can pick as many subtopics or topics as you desire. Then, click revise.
- The timer at the top is the countdown until you are allowed to flip the flashcard. Click to flip the flashcard, then press on the green tick or red cross depending on whether you already knew the answer to the flashcard.encouraging

#### How to use the study schedule
Our spaced repition algorithm calculates when you should revise certain topics based on the previous days that you revised them. It assigns dates to topics of revision based on when you last revised them, ensuring no more than two topics are assigned to any given day. Click on the topics to revise them.

#### How to use streaks
We added streaks as a form of gamification. It automatically compiles data about your studying performance and expresses it to you in a way that's encouraging and quick to view.

#### How to use mock exams
Select the appropriate amount of responses, as specified in the question, submit the question. Do this for each question. It's recommended that for any given question, if it's something that you want to revisit, click the 'flag question' button to highlight it for later.

#### How to use create flashcards
Since the flashcards on MedicRecall are pre-written, some students may want to create their own and add them to existing study sets: it can be helpful to word compilated topics differently - so that it's written in a way that you understand and remember better. Use the create flashcards tool to do this and add them to the appropriate deck.

#### How to get help
Find all relevant information and instructions by pressing one of the three help buttons on the dashboard or in settings. There are also tooltips across the app to find help.

# Developer Instructions

### Database Diagram
![database drawio](https://github.com/user-attachments/assets/21d1992d-aeea-4868-83b9-9211308dcfb6)

### Architecture Diagram
![Screenshot 2025-02-25 093238](https://github.com/user-attachments/assets/5e7d439b-dff7-4f1a-94af-92711e4b435c)

## System Requirements
To build MedicRecall, you'll need the following:
- An IDE of choice: Visual Studio Code (Our prefererence), Android Studio or IntelliJ IDEA

## Compilation
1. Download the Flutter editor plugin for your IDE (Android Studio, IntelliJ IDEA or VSCode)
1. Open the repo with Android Studio or VSCode
2. Ensure you're in the root folder (called flashcard):
    - This can be done with `cd /flashcard`

#### To run the web app
3. Retrieve all dependencies
    - Dependencies can be retrieved and installed with the following command: `flutter pub get`
4. Run the program
    - `flutter run`
    - If there are multiple running options, type the number corresponding to the number to run it on Chrome - this number will be displayed in the terminal surrounded in square brackets like this: `[2]: Chrome (chrome)`

## Why Firebase?
We inherited Firebase from last year's project. 

There's a lot of functionality included in Firebase: there's a real-time database which syncs data across all clients; authentication is made easy as users can sign in with their Google account (in addition to signing in with their email address); analytics track how users interact with the app; and there's built-in crash reporting.

## Contributors
### Team members
| Alex Gray | Onett Perera | Jiahao Dong | Omar Elekiaby | Suliman Alsami |
| ---------------- | ---------------- | ---------------- | ---------------- | ---------------- |
| alexgray-314 | onettonett | jhd7755 | oekiaby0 | sulaimans12 |
#### Mentor
Thomas Parr
#### Client
Dr William Harris

