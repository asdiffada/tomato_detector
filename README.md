# Tomato Maturity Detection App (Hybrid AI + Hue Rules)
A mobile application based on Flutter integrated with a Python (Flask) backend to detect the maturity level of tomatoes. This system employs a Hybrid approach combining Artificial Intelligence (TFLite) with Digital Image Processing rules (Hue Thresholding) for accurate results.

## Key Features
- Real-time Detection: Distinguishes between Unripe, Turning, and Ripe tomatoes.
- Hybrid Logic: Uses AI for feature extraction and Hue Value for final decision rules.
- Dual Mode: Supports image input directly from the Camera or from the Gallery.
- Informative Dashboard: Provides educational information regarding the characteristics of each tomato maturity phase.
- Separate Backend: Lightweight and modular Python Flask server.

## Project Structure
tomato_apk/
├── tomato_backend/          # Server Side (Python)
│   ├── assets/              # TFLite Model & Scaler JSON
│   ├── venv/                # Virtual Environment
│   ├── app.py               # Main Flask Server Code
│   └── requirements.txt     # Python Libraries List
│
├── tomato_frontend/         # App Side (Flutter)
│   ├── lib/
│   │   ├── api_service.dart # IP Config & HTTP Requests
│   │   ├── dashboard_page.dart # Main Page
│   │   ├── camera_page.dart # Camera Page Logic
│   │   ├── gallery_page.dart # Gallery Page Logic
│   │   ├── widgets.dart     # UI Components (Sidebar, Result)
│   │   └── main.dart        # App Entry Point
│   └── pubspec.yaml         # Flutter Dependencies
│
└── README.md                # Project Documentation

## Installation & Run Guide (Backend)
The backend is responsible for processing images using Python.
1. Environment Setup
Ensure you have Python 3.10 - 3.12 installed.
cd tomato_backend
Create Virtual Environment
python -m venv venv
Activate Venv (Windows)
venv\Scripts\activate
Activate Venv (Mac/Linux)
source venv/bin/activate

2. Install Libraries
pip install -r requirements.txt
Note: If using Python 3.12, ensure setuptools is installed.

3. Run Server
python app.py
If successful, the terminal will display:
    Running on http://0.0.0.0:5000

## Installation & Run Guide (Frontend)
The frontend is the mobile application installed on the Android device.
1. Flutter Setup
Ensure Flutter SDK is installed and detected (flutter doctor).
2. IP Address Configuration (IMPORTANT!)
For the phone to connect to the Laptop, you must configure the server IP Address.
Check your Laptop IP:
Windows: Open CMD, type ipconfig. Look for "IPv4 Address" on the Wi-Fi adapter (e.g., 192.168.1.13).
Open the file tomato_frontend/lib/api_service.dart.
Update the SERVER_URL variable:
final String SERVER_URL = "[http://192.168.1.13:5000/predict](http://192.168.1.13:5000/predict)";
3. Install Dependencies
cd tomato_frontend
flutter pub get
4. Run Application
Connect your Android phone via USB (enable USB Debugging) and ensure both the Phone & Laptop are connected to the same Wi-Fi.
flutter run

## Technologies Used
Frontend: Flutter (Dart), HTTP, Image Picker.
Backend: Python, Flask.
AI/ML: TensorFlow Lite, NumPy.
Computer Vision: OpenCV (for BGR/RGB/HSV color conversion).

## Common Troubleshooting
- Error: Connection Timed Out / Connection Failed
- Ensure the Python Server (app.py) is running.
- Ensure the Phone and Laptop are on the same Wi-Fi network.
- Check if the IP in api_service.dart is correct.
- Temporarily disable Windows Firewall if it blocks the connection.
- Error: ModuleNotFoundError 'distutils' (Python 3.12)
- Ensure the setuptools library is installed: pip install setuptools.

Created for Final Project purposes.