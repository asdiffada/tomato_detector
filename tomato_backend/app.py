import flask
from flask import request, jsonify
import numpy as np
import cv2
import joblib 
import os
import logging
import math

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("TomatoServer")

app = flask.Flask(__name__)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, 'assets', 'model_jst.pkl')
SCALER_PATH = os.path.join(BASE_DIR, 'assets', 'scaler_jst.pkl')

PIXELS_PER_METRIC = 0.73

model = None
scaler = None

try:
    if os.path.exists(MODEL_PATH) and os.path.exists(SCALER_PATH):
        model = joblib.load(MODEL_PATH)
        scaler = joblib.load(SCALER_PATH)
        logger.info("✅ Model JST (Binary: Mentah/Matang) & Scaler berhasil dimuat!")
    else:
        logger.error("❌ Model tidak ditemukan. Pastikan file .pkl ada di folder assets.")
except Exception as e:
    logger.error(f"❌ Error loading model: {e}")

def calculate_metrics(image):
    """
    Menghitung kualitas fisik tomat:
    1. Shape (Circularity)
    2. Texture (FFT Analysis)
    3. Size (Diameter mm - Fixed Distance)
    """

    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    blur = cv2.GaussianBlur(gray, (7, 7), 0)
    
    edged = cv2.Canny(blur, 50, 100)
    edges = cv2.dilate(edged, None, iterations=1)
    edges = cv2.erode(edges, None, iterations=1)
    
    contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    valid_contours = [c for c in contours if cv2.contourArea(c) > 1000]
    
    shape_score = 0
    diameter_mm = 0
    
    if valid_contours:
        c = max(valid_contours, key=cv2.contourArea)
        area = cv2.contourArea(c)
        perimeter = cv2.arcLength(c, True)
        
        if perimeter > 0:
            circularity = (4 * math.pi * area) / (perimeter ** 2)
            shape_score = min(circularity * 100 + 10, 100)

        ((x, y), radius) = cv2.minEnclosingCircle(c)
        diameter_pixels = radius * 2
        
        diameter_mm = diameter_pixels / PIXELS_PER_METRIC

    h, w = gray.shape
    center_h, center_w = h // 2, w // 2
    crop_size = min(h, w) // 6 
    
    crop_img = gray[center_h-crop_size:center_h+crop_size, center_w-crop_size:center_w+crop_size]
    
    texture_score = 0
    
    if crop_img.size > 0:
        f = np.fft.fft2(crop_img)
        fshift = np.fft.fftshift(f)
        magnitude_spectrum = 20 * np.log(np.abs(fshift) + 1)
        mean_magnitude = np.mean(magnitude_spectrum)
        
        min_mag = 130.0
        max_mag = 180.0
        
        raw_score = 100 - ((mean_magnitude - min_mag) * 100 / (max_mag - min_mag))
        texture_score = max(0, min(100, int(raw_score)))
        
        print(f"DEBUG FFT -> Mean Mag: {mean_magnitude:.2f} | Score: {texture_score}")

    return int(shape_score), int(texture_score), int(diameter_mm)

def calculate_overall_quality(shape, texture, confidence):
    score = (0.4 * texture) + (0.4 * shape) + (0.2 * confidence)
    
    if score >= 90: return "Sangat Baik"
    if score >= 70: return "Baik"
    if score >= 40: return "Sedang"
    return "Buruk"

@app.route('/', methods=['GET'])
def index():
    return jsonify({
        "status": "online",
        "method": "Binary JST (Mentah/Matang) + FFT",
        "message": "Server Siap"
    })

@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({"error": "Tidak ada file gambar"}), 400
    
    if model is None:
        return jsonify({"error": "Model JST belum siap"}), 500

    try:
        file = request.files['image']
        img_bytes = np.frombuffer(file.read(), np.uint8)
        img_bgr = cv2.imdecode(img_bytes, cv2.IMREAD_COLOR)

        if img_bgr is None:
            return jsonify({"error": "File rusak"}), 400

        img_resized = cv2.resize(img_bgr, (100, 100))
        mean_bgr = np.mean(img_resized, axis=(0, 1))
        
        b, g, r = mean_bgr[0], mean_bgr[1], mean_bgr[2]
        total_color = r + g + b
        if total_color == 0: total_color = 1 
        
        norm_r = r / total_color
        norm_g = g / total_color
        norm_b = b / total_color
        
        input_features = np.array([[norm_r, norm_g, norm_b]])
        input_scaled = scaler.transform(input_features)
        
        probabilities = model.predict_proba(input_scaled)[0]
        pred_idx = np.argmax(probabilities)
        confidence = probabilities[pred_idx] * 100

        labels = ["UNRIPE", "RIPE"]
        colors = ["green", "red"]
        
        final_label = labels[pred_idx]
        final_color = colors[pred_idx]
        
        prob_unripe = probabilities[0]
        prob_ripe = probabilities[1]

        shape_score, texture_score, size_mm = calculate_metrics(img_bgr)

        quality_label = calculate_overall_quality(shape_score, texture_score, confidence)

        conf_str = f"{int(confidence)}%"
        rgb_info = f"R:{norm_r:.2f} G:{norm_g:.2f} B:{norm_b:.2f}"

        response = {
            "label": final_label,
            "color_status": final_color,
            "confidence": conf_str,
            "details": {
                "color_score": int(confidence),
                "shape_score": shape_score,
                "texture_score": texture_score,
                "size_mm": size_mm,
                "quality": quality_label
            },
            "debug_info": (
                f"RGB: {rgb_info} | Tex: {texture_score} | "
                f"JST Probs: M:{prob_ripe:.2f} S:0.00 U:{prob_unripe:.2f}"
            )
        }
        
        logger.info(f"Hasil: {final_label} ({conf_str}) | Size: {size_mm}mm | Qual: {quality_label}")
        return jsonify(response)

    except Exception as e:
        logger.error(f"Error Processing: {e}")
        return jsonify({"error": str(e), "label": "ERROR", "color_status": "purple"}), 500

if __name__ == '__main__':
    print("\n--- SERVER TOMAT JST (BINARY) SIAP ---")
    app.run(host='0.0.0.0', port=5000, debug=True)