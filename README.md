# Tomato Detector - Intelligent Ripeness Detection
Tomato Detector is an Artificial Intelligence (AI) based mobile application designed to detect tomato ripeness levels accurately and in real-time.

This system employs a Computer Vision and Artificial Neural Network (ANN) approach using Normalized RGB feature extraction. It is capable of distinguishing tomatoes into three categories: Unripe, Turning, and Ripe, as well as analyzing physical quality metrics such as shape and texture.

## Key Features
Dual Input Mode: Supports detection directly via the camera (Embedded Camera) or by uploading images from the gallery.
Advanced AI Analysis: Utilizes the Multi-Layer Perceptron (MLP) algorithm trained on the Fruit-360 dataset with color normalization techniques for high accuracy across various lighting conditions.
Detailed Analysis: Provides detailed scores regarding Color Confidence, Shape (Circularity), and Skin Texture (Smoothness).
Smart Dashboard: Visualizes daily scanning statistics and ripeness distribution charts.
History & Tracking: Saves a complete scan history with timestamps and analysis results.
Education: A "Discover" feature containing cultivation guides, storage tips, and articles related to tomatoes connected to trusted sources.

## Tech Stack
Frontend (Mobile App)
Framework: Flutter (Dart)
State Management: setState & Service Singleton pattern
Networking: http package
Camera: camera & image_picker plugins
UI/UX: Material Design 3, Custom Painters (Charts), Responsive Layout
Backend (API Server)
Framework: Flask (Python)
Machine Learning: Scikit-Learn (MLPClassifier)
Image Processing: OpenCV (Feature Extraction, Contours, Histograms)
Data Handling: NumPy, Joblib

## Project Structure
ProjectTomat/
├── tomato_backend/          # Server Side (Python AI)
│   ├── assets/              # Stores models (.pkl) and scalers
│   ├── dataset/             # (Optional) Training image data
│   ├── venv/                # Virtual Environment
│   ├── app.py               # Flask server entry point
│   ├── train_jst.py         # ANN model training script
│   └── requirements.txt     # Python Dependencies
│
├── tomato_frontend/         # Application Side (Flutter)
│   ├── lib/
│   │   ├── api_service.dart # HTTP Request Logic
│   │   ├── history_service.dart # Local Data Management
│   │   ├── widgets.dart     # UI Components (Sidebar, etc.)
│   │   ├── *_page.dart      # Pages (Home, Scan, Analysis, etc.)
│   │   └── main.dart        # Application entry point
│   └── pubspec.yaml         # Flutter Dependencies
│
└── README.md                # Project Documentation


## Installation & Setup Guide
Prerequisites
Python (v3.10 or latest)
Flutter SDK (v3.0 or latest)
USB Cable (For debugging on an Android device)

1. Setup Backend (Server)
Navigate to the backend folder
cd tomato_backend
Create Virtual Environment
python -m venv venv
Activate Venv
Windows:
venv\Scripts\activate
Mac/Linux:
source venv/bin/activate
Install Libraries
pip install -r requirements.txt
(Optional) Retrain the JST Model
python train_jst.py
Run Server
python app.py
The server will run at http://0.0.0.0:5000

2. Setup Frontend (Application)
- Configure IP Address:
Check your Laptop's IP (Windows: ipconfig, Mac/Linux: ifconfig).
Open tomato_frontend/lib/api_service.dart.
Update SERVER_URL to match your Laptop's IP:
final String SERVER_URL = "[http://192.168.1.](http://192.168.1.)X:5000/predict";
- Run Application:
Navigate to the frontend folder
cd tomato_frontend
Download dependencies
flutter pub get
Run on Device
flutter run

## AI Methodology (ANN)
This system does not use a conventional Convolutional Neural Network (CNN). Instead, it adopts an Average Color Value Analysis method, which is efficient and aligns with specific literature references:
- Preprocessing: Image is resized to 100x100 pixels.
- Feature Extraction: Calculates the average Red, Green, and Blue values of all pixels.
- Normalization: Converts absolute values into proportions ($R / (R+G+B)$) to handle lighting variations (bright/dark).
- Classification: Normalized data is fed into a Multi-Layer Perceptron (MLP) to determine - class probabilities (Unripe/Turning/Ripe).
- Quality Check: Uses OpenCV to mathematically calculate Circularity and Skin Smoothness (Standard Deviation).

This project is created for Final Project purposes.