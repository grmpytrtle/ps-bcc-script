# **Browser Cache and Cookies Cleaner Script**

### Overview

This PowerShell script is designed to manage browser data for all user profiles on a Windows system. It provides functionality for backing up browsing history and clearing cache, cookies, and temporary files for popular browsers, including Mozilla Firefox, Google Chrome, and Internet Explorer/Microsoft Edge.

<br/>

## Features

### 1. User Profile Management

- Automatically gathers a list of user profiles from the C:\Users directory.
- Exports the user list to a CSV file (bcc-users.csv) for batch processing.

### 2. Backup Browsing History

- Creates backups of browsing history for:
   - Mozilla Firefox
   - Google Chrome
   - Microsoft Edge
- Stores backups in a centralized directory: C:\Support\BrowserHistoryBackup.

### 3. Clear Browser Data

Deletes cache, cookies, and temporary files for each user on the system:
   - Firefox: Clears cache, cookies, thumbnails, and SQLite storage files.
   - Chrome: Clears cache, cookies, media cache, and session files.
   - Edge/Internet Explorer: Clears temporary internet files, error reporting data, temp directories, Windows temp files, and recycle bin contents.

### 4. Error Handling and Logging

- Provides detailed output for each operation, including successful deletions and errors encountered during execution.

### 5. Modular Design

- The script processes data for all user profiles, making it suitable for systems with multiple users.

<br/>

## Prerequisites

  PowerShell 5.1
  Administrator privileges
  Write permissions for C:\Support or the specified backup directory.

<br/>

## How to Use

-  Clone or download the script.
-  Open PowerShell with Administrator privileges.
-  Run the script:
~~~
    .\ps-bcc-script-5.1.ps1
~~~
4.  Review the output to ensure all tasks are completed successfully.

<br/>

## Example Output

~~~
#######################################################
Powershell script to delete cache & cookies in Firefox, Chrome & IE browsers
#######################################################
SECTION 1: Getting the list of users
Exporting the list of users to C:\Support\bcc-users.csv
SECTION 2: Beginning Script...
SECTION 3: Backing Up Mozilla Firefox Browsing History
Firefox history backed up for user JohnDoe
No Firefox history found for user JaneDoe
...
SECTION 6: Clearing Mozilla Firefox Caches
Successfully removed: C:\Users\JohnDoe\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache\...
~~~

<br/>

## Customization

- Change the backup directory by modifying the $backupDir variable.
- Add or remove paths for cache clearing as needed within the respective sections for each browser.

<br/>

## Notes

 - Ensure all browsers are closed before running the script to avoid conflicts.
 - Backups are stored securely in the designated directory for manual restoration if needed.

<br/>

Feel free to contribute or raise issues in the repository! 😊
