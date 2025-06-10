<p align="center">
<img src="flashcard/assets/app_logo4.png" height="110">
<h1 align="center">Handover Documentation</h1>
<h3 align="center">xd23197, ar23931, nv22173, rw22740, nv23870</h3>

<!--Use the code above as a header for all MedicRecall pages.-->

### Contents
1. [Project structure](##Project-structure)
1. [How to run the project](###How-to-run-the-project)
    1. Prerequisites
    1. Instructions
2. [Dependencies](###Screens)
2. [Screens](###Screens)
2. [Where are assets such as the logo kept?](###Where-are-assets-such-as-the-logo-kept?)
2. [Study Schedule Explanation](##Study-schedule-explanation)
2. [Streaks Explanation](##Streaks-explanation)
2. [Contact](##Contact)
2. [List of screens](####Comprehensive-list-of-screens)
2. [List of widgets](####Comprehensive-list-of-widgets)

## Project structure
```
2024-MEDICRECALL1  
└── HANDOVER.md  
└── LICENSE  
└── README.md  
└── build  
└── docs  
└── flashcard
```

### How to run the project

#### Prerequisites
1. You need an IDE:  
    - Visual Studio Code is our preferred IDE:  
    [Download VS Code here](https://docs.flutter.dev/get-started/install)  
    - Alternatively, Android Studio is popular among flutter developers:  
    [Download Android Studio here](https://developer.android.com/studio?gad_source=1&gclid=Cj0KCQjwkN--BhDkARIsAD_mnIophAFNbqu-EUHHKscH53anOTHta_SbeI436j3LbbYuBKJh3d3r39QaAkODEALw_wcB&gclsrc=aw.ds)
2. You'll need to download and install flutter.
    - [Download Flutter here](https://docs.flutter.dev/get-started/install)  
    - Ensure you download the Dart SDK during the flutter installation process.
3. If you're using VS Code, you can install the VS Code flutter extension instead: it's a quicker process. This is what we personally recommend: 
    1. Open VS Code
    2. Click on the 'Extensions' icon or press "CTLR + SHIFT + X" on Windows, "CMD + SHIFT + X" on Mac
    3. Search for Flutter
    4. Install
#### Instructions
1. Firstly, clone the github to have your own copy of the code by typing in  
`git clone 'https://github.com/spe-uob/2024-MedicRecall1.git'`
1. Using VSCode, open the `2024-MEDICRECALL1` folder.  
This is done by pressing `CTLR + O` on Windows or `CMD + O` on a Mac.
2. The project root is `/flashcard` and it should be ran from here.  
    Do this by typing `cd /flashcard` in the terminal.  
3. Retrieve all neccessary dependencies by typing `flutter pub get` in the terminal.  
    The 'pubspec.yaml' file (which is located in the /flashcard directory) contains information about all dependencies that are required to run the program: this command instructs your machine to look at this file and install all neccessary dependencies.
4. Type `flutter run` into the terminal.
5. Type the number corresponding to Chrome. The terminal will instruct, for example `[2]: Chrome (chrome)` means that you should type 2.
6. The program should now run on a seperate Chrome window.  
To terminate program execution, type `q` into the terminal.

 
To look at the dependencies, look at the **pubspec.yaml** file; this file also tells you other information such as the version of flutter that the program requires.

#### Notable *unique* dependencies
- `flip_card` for animated card flipping
- `swiping_card_deck` for the swiping card deck UI

There are also dependencies for the following purposes:  
1. Core flutter dependencies
2. Firebase (our database of choice) and authentication
3. UI and theming
4. Network and storage
5. Testing and code generation

### Screen
#### Location of screens
To access the various pages of the project:
```
2024-MEDICRECALL  
└── flashcard  
    └──lib  
        └──screens
```

Each page on the app has a seperate file - the naming scheme is snake 🐍 case.

### Widgets
#### Location of widgets
```
2024-MEDICRECALL  
└── flashcard  
    └──lib  
        └──widgets
```

### Particularly Notable widgets
- `app_bar_title.dart`
    - The App Bar is widget that is at the top of every page that contains our new MedicRecall logo  
- `drawer_widget.dart`
    - The drawer contains buttons that let the user navigate around the page: if you're adding quotes, 
- `embedded_form.dart`
    - The widget for the Google form located in the Feedback page

### Where are assets such as the logo kept?
```
2024-MEDICRECALL  
└── flashcard  
    └──assets
```
- Our new MedicRecall logo is located here and it's under the name 'newlogo.png'.
- This directory also contains other .png files that are used in the app. 

## Study schedule explanation
The study schedule uses our spaced repition algorithm.
#### Why is spaced repition important in this context?
Spaced repition is important because having time gaps between the study of each topic lets the user retain more information with less revision time.
#### How does the study schedule help manage the workload?
The study schedule is designed so that there are a maximum of two topics to revise per day. This is crucial for our users, junior doctors, as they have to manage many other responsibilities alongside preparing for the MSRA exam.

## Streaks explanation
The streaks feature uses gamification to encourage users to spend more time on the MedicRecall platform and enjoy their revision.

#### How does the platform judge whether a day is marked as a streak or not?
Simply logging into the platform is enough for a user to complete their daily streak. This was chosen as there are many different actions that can be performed on the platform: flipping through flashcards, taking a mock exam, creating a new flashcard, and more. We wanted to reward any type of revision

#### Other streak actions
Other streak actions are self explanatory. For example, when the user checks how many flashcard decks that they've revised, the platform just tells them that.

## Contact
If you need help understanding the codebase, you can contact the team:

|First name| Email address|
|-|-|
|Alex|xd23197@bristol.ac.uk|
|Onett|ar23931@bristol.ac.uk|
|Jiahao|nv22173@bristol.ac.uk|
|Omar|rw22740@bristol.ac.uk|
|Suliman|nv23870@bristol.ac.uk|
## Lists

#### Comprehensive list of screens
The list of screens have been renamed so their function should be easy to understand based on their names.
```
1. Add Flashcard screen 
2. Calendar screen
3. Comment screen
4. Dash screen
5. Dashboard screen
6. Exam declaration screen
7. Exam guide screen
8. Explanation screen
9. FAQ screen
10. Feed screen
11. Feedback Screen
12. Flag overview screen
13. Flashcard editor screen
14. Mark Scheme
15. Mark Scheme Comments
16. Mark Scheme Questions
17. Mark Scheme Single
18. Multiple Choice Screen
19. Quiz choice screen
20. Reset password screen
21. Resources screen
22. Settings screen
23. Sign up screen
24. Streaks page screen
25. Subtopics Choice screen
26. Topic Folder screen
27. User details screen
28. Verify email screen
```

#### Comprehensive list of widgets
Widgets have also been renamed so their function should be easy to understand based on their names.

```
1. app_bar_title.dart
2. calendar_column.dart
3. design_main.dart
4. drawer_widget.dart
5. embedded_form.dart
6. event.dart
7. google_sign_in_button.dart
8. indicator.dart
9. login_form.dart
10. question_page.dart
11. registration_form.dart
12. title_bar.dart
```