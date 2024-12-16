# NetCheckr

NetCheckr is a macOS application designed to monitor your internet connection and provide real-time updates. It displays an icon and menu in the system menu bar, sends notifications when you go offline or come back online, and allows you to manage preferences such as launching at login and enabling notifications.

## Features

- **Internet Connection Monitoring:**  
  Utilizes `NWPathMonitor` to detect changes in your online status. You will know when you lose internet connectivity and when it is restored.

- **Menu Bar Integration:**  
  A simple menu bar icon and status text show if you're "Online" or "Offline." When offline, the app also shows how long you've been disconnected.

- **Real-Time Notifications:**  
  Receive a **"No Internet"** notification when the connection is lost and a **"Back Online"** notification when it's restored.  
  Notifications can be enabled or disabled in the app’s settings.

- **Connection History:**  
  View a history of recent offline/online events from a dedicated history window.

- **Customizable Settings:**  
  - **Launch at Login:** Automatically start NetCheckr when you log in.  
  - **Enable Notifications:** Easily toggle notifications on or off.  
  Changes are saved and restored automatically.

## Installation

1. **Download the App:**  
   Obtain `NetCheckr.app` from the provided source or release.

2. **Move to Applications Folder (Recommended):**  
   Drag and drop `NetCheckr.app` into your `/Applications` folder.

3. **Run the App:**  
   Double-click `NetCheckr.app` to launch. The NetCheckr icon will appear in your menu bar.

4. **Grant Permissions (If Prompted):**  
   When you first run the app, you may be asked to allow notifications. Approve if you want to receive alerts about connection changes.

## Usage

- **Menu Bar Menu:**  
  Click the NetCheckr icon to:
  - Check your current status ("Online"/"Offline").
  - View connection history.
  - Access settings (Launch at Login, Enable Notifications).
  - Quit the application.

- **Settings Window:**  
  Toggle options as desired. Changes apply immediately.

## Requirements

- macOS 10.14+ (Recommended: macOS 10.15+), as `NWPathMonitor` requires modern networking frameworks.
- You can run the provided `.app` directly, or if you have xCode installed, you can download the source code and run the application by opening the project in xCode and pressing **Run**.

## Support

If you encounter any issues or have feedback, please get in touch or open a ticket in the project's repository (if available).
