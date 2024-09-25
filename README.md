<p align="center">
<img src="flashcard/assets/newlogo.png" height="150">
<h1 align="center">2023-MedicRecall</h1>

# Table of Contents

* [What do we need to deliver?](#what-do-we-need-to-deliver)
* [About our client:](#About-our-client)
* [About Recall:](#About-Recall)
* [About MSRA:](#About-MSRA)
* [Existing problems:](#Existing-problems)
* [Previous Year’s GitHub (2022):](#previous-years-github-2022)
* [Setting Up:](#Setting-Up)
* [Running the App：](#Running-the-App)
* [User Stories：](#User-Stories)
* [About Firebase:](#About-Firebase)
* [CI/CD:](#CI/CD)
* [Ethics](#ethics)
* [Gantt Chart](#Gantt-Chart)



# What do we need to deliver?
<br>
1. Webapp to deliver premade flashcards.<br>
<br>
2. Allow people to rate flashcards based on knowledge.<br>
<br>
3. Area for peer discussion and collaboration.<br>
<br>
4. Test taking functionality with automatic grading.
<br>
<br>

# About our client：
<br>
- Most trainee doctors are not studying effectively.<br>
<br>
- Use active recall, spaced repetition and concept mapping to improve how doctors study.<br>
<br>
- PowerPoint that he has - notes.<br>
<br>
- He’s a medic with a bit of software dev knowledge.<br>
<br>
- “Evidence based revision for medical trainees”.<br>
<br>
- Time taken for studying exams is too long.<br>
<br>
- Develop a portfolio as a doctor etc.<br>
<br>
- There’s a lot to worry about as a medic.<br>
<br>
<br>
<br>

# About Recall：
<br>
i.	Over time, you retain less and less information.<br>
<br>

ii.	Targeting the MSRA - Multi Specialty Recruitment Assessment<br>
<br>

iii.	It’s a very important exam! Determines the course of your medical future.<br>
<br>

iv.	Two parts: Situational Judgement - clinical scenario, ethical dilemma/teamwork/managing situation, then you rank a group of some options from most to least appropriate or choose the three most appropriate options. (People aren’t used to revising for it)<br>
<br>


# About MSRA：
<br>
i.	Clinical knowledge, similar to medical school exams. Tests knowledge in 12 specialty areas. Multiple choice.<br>
<br>

ii.	There are resources for the Professional dilemmas paper, the GMC has released practice papers. There are GMC booklets too, NOT VERY USEFUL, as too broad.<br>
<br>

iii.	Clinical problem-solving paper: revise using question banks<br>
<br>

iv.	What already exists: Question bank and mock exam, £60 ，Courses for £100<br>
<br>

v.	Solution - evidence based revision. Idea is to remind oneself periodically<br>
<br>

vi.	We need to complete the pivot from the SJT to the MSRA.<br>
<br>

# Existing problems：
<br>
i.	Flashcard system could do with some tweaking<br>
<br>

ii.	Complete the change from SJT to MSRA.  

iii.	Flashcards don’t auto update to green after finishing a set, you have to manually reload the page.   

iv.	Don’t let the user just flick straight through.   

v.	Notifications when things are due.  

And more...
  
  

# Previous Year’s GitHub (2022):
<br>
[GitHub Repo](https://github.com/spe-uob/2022-MedicRecall)
<br>
<br>
<br>

# Overview:
<br>

  The project proposal is called MedicRecall and is a continuation of one of last year's projects. The brief is to expand on the work they have already done to create a comprehensive revision platform that will welcome and host users this academic year. Continue with our **own idea**  <br>
<br>



# Stakeholders:
<br>
- Medical students<br>
<br>
- Doctors<br>
<br>
- Lecturers<br>
<br>

# Setting Up:
<br>

## Requirements:
<br>
 - If you wish to build MedicRecall yourself, you will need the following components/tools:<br>  
 <br>
 
●	Android Studio (available to download here)<br>
<br>
●	An emulator capable of running<br>
<br>
●	Android 6.0 or above or<br>
<br>
●	iOS 11 or above<br>
<br>
●	Flutter Development packages<br>
<br>


## Compiling:
i.	After you have downloaded the repo, ensure that you are in the root folder: ` /flashcard `<br>
<br>
ii.	To build the app in android, use the command: ` flutter build apk `<br>
<br>
iii.	To build the app in iOS, use the command: ` flutter build ios --release --no-codesign ` <br>
<br>
iv.	To build the app in macOS, use the command: ` flutter create --platforms=macos `  followed by: ` flutter build macos `   <br> 
<br>



## Running the App:
<br>
  Although this app is still under development and not yet available on the Google Play Store or the iOS App Store, you can access the source code and perform more testing and debugging by following these steps:<br>

1. Clone the repo: ` git clone https://github.com/spe-uob/2022-MedicRecall.git `

2. Download the Flutter editor plugins for Android Studio, IntelliJ IDEA, or Visual Studio Code.

3. Run: ` flutter pub get `    from the project root.<br>

4. Prepare a device or use a web browser.

5. Run: ` flutter run ` 

<br>

## Run the web app directly：
<br>
<br>

The app is being hosted on Google Firebase at the following link:<br>
<br>
https://flashcard-6edc2.web.app<br>
<br>

When you click it, be sure to allow some time for the app to start up!<br>
<br>



# User Stories:
| **Name** | **User Story** | **Feature required** |
|----------|------------|------------------|
| Doctor | As a doctor, I want it to help me recall some disease. | Recall Memory |
| Busy student | As a medical student, I hope it reduces the review time. | Instant Feedback |
| General student | As a medical student, I need it to test my understanding of knowledge. | Help Review |
<br>

# About Firebase:
<br>
Firebase is a platform that integrates many functions. It can help us build and test our project. It's also a platform with a large number of open-source packages, which will greatly reduce the difficulty of developing the project. The completed part of this project uses Dart language, so we will continue to develop using Dart language.
<br>

# CI/CD:
i.	When a pull request is opened, a GitHub action creates an associated preview channel on Firebase, to which the changes from each commit are automatically deployed, and adds a comment to the pull request with the preview URL. Once a pull request has been created, any changes from new commits are automatically deployed to its preview channel without change to the preview URL. This allows the proposed changes to be easily viewed and tested by each reviewer.<br>
<br>
ii.	Before a pull request can be merged into the main branch, it must pass the GitHub actions which ensure that the proposed changes do not prevent the app from passing all tests and compiling for Android, IOS and the web.<br>
<br>
iii.	The app is automatically deployed to the live channel on Firebase when a pull request has been merged into the main branch and passed the integration tests. This is achieved by adding the service account's key to the repository as a secret.<br>
<br>

# Ethics:
i.	Handling of user data is our top ethical concern. The pertinent legislation must be followed.

ii.	When they are learning, we must give our users the most recent and correct information.

iii.	We must exercise caution to prevent unintentionally breaking users' devices for instance, don't remove any files that are unrelated to MedicRecall or don't write any more files to a mobile device.

# Gantt Chart:

[Gantt Chart](https://uob-my.sharepoint.com/:x:/g/personal/uk21548_bristol_ac_uk/EdxNOLQdN6dNuAkYmCxvvpwB3U1XXNDYE3MUtbqgKRjwMw?e=awz8AG)

