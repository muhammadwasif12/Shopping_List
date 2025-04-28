🛒 Shopping List App
A Flutter based mobile application to manage your grocery shopping in an organized and intuitive way.
The app is connected to Firebase Realtime Database to provide real-time storage and synchronization of your shopping list.

📱 Features
➕ Add Items:
Add new grocery items with name, quantity, and category.

📋 View Items:
Automatically fetch and display your shopping list from Firebase.

🗑️ Swipe to Delete with Confirmation:
Swipe an item to the left to delete it. A confirmation dialog appears to avoid accidental deletion.

↩️ Undo Delete (Snackbar):
After deletion, a Snackbar shows up with an UNDO option. You can restore the deleted item instantly.

🔄 Real-Time Firebase Integration:
Changes made (Add/Delete/Undo) are reflected immediately in the Firebase Realtime Database.

🚀 Smooth Navigation with Animation:
Animated transitions between the main list and the "Add Item" screen for a better user experience.

🌐 Internet Permission:
Required to access the Firebase database remotely.

⚡ Error Handling:
Displays user-friendly error messages if network fails or data fetching is unsuccessful.

💬 Loading Indicators:
Shows loading spinners while the app fetches data from the backend.

🛠️ Tech Stack
Frontend: Flutter (Dart)

Backend: Firebase Realtime Database

State Management: setState (for now — lightweight and simple)

HTTP Requests: http Flutter package

🚀 Getting Started
Prerequisites
Flutter SDK installed

Firebase Realtime Database setup

Internet Permission added in AndroidManifest.xml
xml
<uses-permission android:name="android.permission.INTERNET" />

How to Run
Clone the repository:

git clone https://github.com/your-username/shopping_list_flutter.git


Navigate to the project folder:

cd shopping_list_flutter

Install dependencies:

flutter pub get

Run the app:

flutter run

Home Screen	Add Item Screen	Delete Confirmation
		
🤝 Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

📄 License
This project is licensed under the MIT License.

