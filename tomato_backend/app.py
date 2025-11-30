import flask
from flask import request, jsonify
import numpy as np
import cv2
import joblib 
import os
import logging
import math

# --- SETUP LOGGING ---
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("TomatoServer")

app = flask.Flask(__name__)

# --- CONFIG ---
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, 'assets', 'model_jst.pkl')
SCALER_PATH = os.path.join(BASE_DIR, 'assets', 'scaler_jst.pkl')

model = None
scaler = None

try:
    if os.path.exists(MODEL_PATH) and os.path.exists(SCALER_PATH):
        model = joblib.load(MODEL_PATH)
        scaler = joblib.load(SCALER_PATH)
        logger.info("✅ Model JST (Normalized) Dimuat!")
    else:
        logger.error("❌ Model tidak ditemukan.")
except Exception as e:
    logger.error(f"❌ Error loading: {e}")

# --- FUNGSI METRIK FISIK (Bentuk & Tekstur) ---
# Fungsi ini TETAP ADA untuk menghitung skor detail di frontend
def calculate_metrics(image):
    # 1. Analisis Bentuk (Circularity)
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    blur = cv2.GaussianBlur(gray, (5, 5), 0)
    _, thresh = cv2.threshold(blur, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    shape_score = 85 
    if contours:
        c = max(contours, key=cv2.contourArea)
        area = cv2.contourArea(c)
        perimeter = cv2.arcLength(c, True)
        if perimeter > 0:
            circularity = (4 * math.pi * area) / (perimeter ** 2)
            shape_score = min(circularity * 100 + 10, 100)

    # 2. Analisis Tekstur (Skin Smoothness)
    # Menggunakan standar deviasi warna. Semakin kecil std, semakin mulus.
    (mean, std) = cv2.meanStdDev(image)
    avg_std = np.mean(std)
    # Rumus pendekatan skor tekstur (0-100)
    texture_score = max(0, min(100, 100 - (avg_std * 1.5))) 

    return int(shape_score), int(texture_score)

@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files: return jsonify({"error": "No image"}), 400
    if model is None: return jsonify({"error": "Model not ready"}), 500

    try:
        file = request.files['image']
        img_bytes = np.frombuffer(file.read(), np.uint8)
        img_bgr = cv2.imdecode(img_bytes, cv2.IMREAD_COLOR)

        if img_bgr is None: return jsonify({"error": "File rusak"}), 400

        # --- PREPROCESSING (NORMALISASI) ---
        img_resized = cv2.resize(img_bgr, (100, 100))
        mean_bgr = np.mean(img_resized, axis=(0, 1))
        
        r, g, b = mean_bgr[2], mean_bgr[1], mean_bgr[0]
        total = r + g + b
        if total == 0: total = 1
        
        # Hitung Persentase Warna (Normalized RGB)
        norm_r = r / total
        norm_g = g / total
        norm_b = b / total
        
        # Input ke Model
        input_features = np.array([[norm_r, norm_g, norm_b]])
        input_scaled = scaler.transform(input_features)

        # --- PREDIKSI (FULL AI / JST ONLY) ---
        # Kita HAPUS logika Hue Rules di sini sesuai permintaan
        probabilities = model.predict_proba(input_scaled)[0]
        
        # Ambil kelas dengan probabilitas tertinggi
        pred_idx = np.argmax(probabilities)
        confidence = probabilities[pred_idx] * 100

        labels = ["UNRIPE", "TURNING", "RIPE"]
        colors = ["green", "orange", "red"]
        
        final_label = labels[pred_idx]
        final_color = colors[pred_idx]

        # --- HITUNG METRIK FISIK (BENTUK & TEKSTUR) ---
        shape, texture = calculate_metrics(img_bgr)

        # Response
        debug_str = f"R:{norm_r:.2f} G:{norm_g:.2f} B:{norm_b:.2f}"
        
        response = {
            "label": final_label,
            "color_status": final_color,
            "confidence": f"{int(confidence)}%",
            "details": {
                "color_score": int(confidence), # Keyakinan AI terhadap warna
                "shape_score": shape,           # Hasil perhitungan OpenCV
                "texture_score": texture        # Hasil perhitungan OpenCV
            },
            "debug_info": f"NormRGB: {debug_str} | AI: {final_label}"
        }
        
        logger.info(f"Hasil: {final_label} ({int(confidence)}%) - {debug_str} - Tex: {texture}")
        return jsonify(response)

    except Exception as e:
        logger.error(f"Error: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)