
<h1 align="center">
  <br>
<img src="https://github.com/OdyAsh/cf_time_tracker/blob/main/appScreenshots/cf_logo.png" alt="cf_icon" width="200">
  <br>
  problem_tracker
  <br>


<h4 align="center">A Flutter desktop app that saves details about a problem you solved on <a href="https://codeforces.com/" target="_blank">Codeforces</a> or <a href="https://cses.fi/problemset/" target="_blank">CSES</a> to Google Sheets.</h4>

<p align="center">
  <a href="#key-features">Key Features</a> •
  <a href="#how-to-use">How To Use</a> •
  <a href="#download">Download</a> •
  <a href="#credits">Credits</a> •
  <a href="#license">License</a>
</p>

<h1 align="center">
<img src="https://github.com/OdyAsh/cf_time_tracker/blob/main/appScreenshots/8%20checking-google-sheets.gif" alt=""app_demo" width="600">
</h1>

## Key Features

* Multiple stop watchers to track each phase of problem-solving (reading, thinking, etc)
* Automating details like entering a hyperlink to solution code, problem code, and writing today's date in the comment field of google sheets
* Time-saver when solving in a competition (even though the problem will initially be saved as '...')

## How To Use

1. Download and open the installer exe file from [here](https://github.com/OdyAsh/problem_tracker/blob/main/installers/problem_tracker_installer.exe)

2. Install the app:

![screenshot](https://github.com/OdyAsh/problem_tracker/blob/main/appScreenshots/0%20installing.gif)

3. Copy [this training sheet](https://docs.google.com/spreadsheets/d/1waZ8nH1GRXRbM2gXym5W1AGQ0bB73PWXhOi7-ijxCnc/edit?usp=sharing) to your own Google drive (AND DON'T MODIFY THE HEADER ROW (row 1)):

![screenshot](https://github.com/OdyAsh/problem_tracker/blob/main/appScreenshots/1%20copying-training-sheet.gif)


> **Optional:**
> I suggest you check out the "Info" worksheet of the training sheet or watch [this video by Dr. Mostafa](https://www.youtube.com/watch?v=c3lmvYBxgwE) to understand how to use the sheet for worksheets other than "External"

4. Copy the new sheet's ID:

![screenshot](https://github.com/OdyAsh/problem_tracker/blob/main/appScreenshots/2%20copy-sheet-id.png)

5. Watch [this video](https://youtu.be/3UJ6RnWTGIY?t=82) to create a Google service account:

![screenshot](https://github.com/OdyAsh/problem_tracker/blob/main/appScreenshots/3%20see%20video.png)

6. Paste the obtained credentials (step 5), google sheet's id (step 4), the name of the worksheet ("External"), and your CodeForces handle (username) to the app, then choose a problem:

![screenshot](https://github.com/OdyAsh/problem_tracker/blob/main/appScreenshots/4%20paste-info-to-app.gif)

**Note:**

![screenshot](https://github.com/OdyAsh/problem_tracker/blob/main/appScreenshots/5%20info-storage-location.png)

**v2.0 Note:**
You can now choose different worksheets other than "External" when submitting a problem

7. Use the app to track details while solving the problem:

![screenshot](https://github.com/OdyAsh/problem_tracker/blob/main/appScreenshots/6%20app-timers.gif)


![screenshot](https://github.com/OdyAsh/problem_tracker/blob/main/appScreenshots/7%20app-filling-info.gif)

8. Submit and check your Google Sheet's spreadsheet:

![screenshot](https://github.com/OdyAsh/problem_tracker/blob/main/appScreenshots/8%20checking-google-sheets.gif)

9. Don't forget to press 'x' when the problem is added to sheets!!!:

![screenshot](https://github.com/OdyAsh/problem_tracker/blob/main/appScreenshots/9%20press-x-when-finished.gif)

10. Keep tracking different problems and repeating steps 7 to 9 :]

**Implementation note about using web scraping on first submission page only:**
![screenshot](https://github.com/OdyAsh/problem_tracker/blob/main/appScreenshots/10%20note-about-saving-from-submissions.png)

## Download

Follow steps 1 to 3 mentioned above :]

In addition, if you want this app to run on linux or mac, clone the project, and type in the command prompt (in vs code):

``` flutter build linux ```

for Mac:

``` flutter build macos ```

Then you will find the executable file here: ```build/LINUX (or MACOS)/runner/release```

## "To-Do"s
* Be able to add submission link of CSES problem to google sheets 
* Be able to add tutorial link that was present in google sheets as a `=HYPERLINK(...)` instead of just text, and move it to "Resources" column
* Make the app available on Android
* Update readme.md's gifs to match new update (possibly upload a youtube video as a demonstration instead)

## Credits

Amazing resources that helped me:
- [Dr. Mostafa Saad with his training sheet](https://www.youtube.com/c/ArabicCompetitiveProgramming)
- [Johannes Milke](https://www.youtube.com/c/JohannesMilke)
- [How to create Flutter .exe for Windows by Paras Jain](https://retroportalstudio.medium.com/creating-exe-executable-file-for-flutter-desktop-apps-windows-ea7c338465e)

## You may also like...

- [mp3quran_scraper_and_tagEditor](https://github.com/OdyAsh/mp3quran_scraper_and_tagEditor) - A data scraping app that fetches mp3 metadata

## License

MIT

---

> :] 🙌

