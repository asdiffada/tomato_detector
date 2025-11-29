import flask
from flask import request, jsonify
import numpy as np
import cv2
import tensorflow as tf
import json
import os
import logging

# --- SETUP LOGGING ---
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("TomatoServer")

app = flask.Flask(__name__)

# --- KONFIGURASI PATH (DISESUAIKAN DENGAN STRUKTUR FOLDER ANDA) ---
# Menggunakan os.path.join agar kompatibel dengan Windows/Linux
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, 'assets', 'tomato_model_2output.tflite')
SCALER_PATH = os.path.join(BASE_DIR, 'assets', 'scaler_params.json')

# --- 1. LOAD MODEL TFLITE ---
logger.info(f"Mencoba memuat model dari: {MODEL_PATH}")
try:
    if not os.path.exists(MODEL_PATH):
        raise FileNotFoundError(f"File model tidak ditemukan di {MODEL_PATH}")

    interpreter = tf.lite.Interpreter(model_path=MODEL_PATH)
    interpreter.allocate_tensors()
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    logger.info("✅ Model berhasil dimuat!")
except Exception as e:
    logger.error(f"❌ GAGAL MEMUAT MODEL: {e}")
    exit() # Matikan server jika model vital tidak ada

# --- 2. LOAD SCALER ---
logger.info(f"Mencoba memuat scaler dari: {SCALER_PATH}")
scaler_mean = [0]*6
scaler_scale = [1]*6

if os.path.exists(SCALER_PATH):
    try:
        with open(SCALER_PATH, 'r') as f:
            data = json.load(f)
            scaler_mean = data.get('mean', [0]*6)
            scaler_scale = data.get('scale', [1]*6)
        logger.info("✅ Scaler berhasil dimuat.")
    except Exception as e:
        logger.warning(f"⚠️ Gagal baca scaler json: {e}, menggunakan default.")
else:
    logger.warning("⚠️ File scaler_params.json tidak ditemukan! Menggunakan default (0,1).")

@app.route('/', methods=['GET'])
def index():
    return jsonify({
        "status": "online",
        "message": "Server Tomat Siap",
        "structure": "Assets Folder Mode"
    })

@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({"error": "Tidak ada file gambar yang diupload"}), 400

    try:
        # --- A. BACA GAMBAR (OpenCV default BGR) ---
        file = request.files['image']
        img_bytes = np.frombuffer(file.read(), np.uint8)
        img_bgr = cv2.imdecode(img_bytes, cv2.IMREAD_COLOR)

        if img_bgr is None:
            return jsonify({"error": "File rusak atau bukan gambar"}), 400

        # --- B. PREPROCESSING ---
        # 1. Resize
        img_resized_bgr = cv2.resize(img_bgr, (128, 128))
        
        # ### PERUBAHAN PENTING: KONVERSI KE RGB UNTUK AI ###
        # AI butuh RGB, tapi Hue butuh BGR. Jadi kita buat variabel terpisah.
        img_resized_rgb = cv2.cvtColor(img_resized_bgr, cv2.COLOR_BGR2RGB)
        
        # 2. Normalisasi Gambar [-1, 1] (Gunakan yang RGB!)
        img_norm = (img_resized_rgb.astype(np.float32) / 127.5) - 1.0
        input_img = np.expand_dims(img_norm, axis=0) # [1, 128, 128, 3]

        # 3. Ekstraksi Fitur Numerik (Gunakan RGB agar tidak tertukar)
        # Di array numpy RGB: Channel 0=R, 1=G, 2=B
        mean_r = np.mean(img_resized_rgb[:,:,0])
        mean_g = np.mean(img_resized_rgb[:,:,1])
        mean_b = np.mean(img_resized_rgb[:,:,2])
        
        features = [mean_r, mean_g, mean_b, 15.0, 120.0, 11304.0]
        
        # 4. Scaling Fitur Numerik
        scaled_features = []
        for i, val in enumerate(features):
            scale = scaler_scale[i] if scaler_scale[i] != 0 else 1.0
            scaled_features.append((val - scaler_mean[i]) / scale)
        
        input_num = np.array([scaled_features], dtype=np.float32)

        # --- C. INFERENCE MODEL ---
        for detail in input_details:
            shape = detail['shape']
            if shape[-1] == 6:
                interpreter.set_tensor(detail['index'], input_num)
            elif len(shape) == 4:
                interpreter.set_tensor(detail['index'], input_img)

        interpreter.invoke()

        # --- D. HASIL AI ---
        probs = interpreter.get_tensor(output_details[0]['index'])[0]
        prob_ripe = float(probs[0])
        prob_turn = float(probs[1])
        prob_unr = float(probs[2])

        # --- E. LOGIKA HUE (TETAP PAKAI BGR) ---
        # OpenCV butuh BGR untuk convert ke HSV dengan benar
        hsv = cv2.cvtColor(img_resized_bgr, cv2.COLOR_BGR2HSV)
        mean_hue = np.mean(hsv[:,:,0]) 

        label = "UNKNOWN"
        color_code = "grey"

        # Aturan Hue
        if mean_hue < 17.0:
            label = "UNRIPE"
            color_code = "green"
        elif 17.0 <= mean_hue <= 27.0:
            label = "TURNING"
            color_code = "orange"
        else:
            label = "RIPE"
            color_code = "red"

        # --- F. RESPONSE ---
        response = {
            "label": label,
            "color_status": color_code,
            "confidence": "Hue Rules", 
            "debug_info": (
                f"Hue: {mean_hue:.1f} | "
                f"AI: R{prob_ripe:.2f} T{prob_turn:.2f} U{prob_unr:.2f}"
            )
        }
        
        logger.info(f"Sukses Deteksi: {label} (Hue: {mean_hue:.1f})")
        return jsonify(response)

    except Exception as e:
        logger.error(f"Error Processing: {e}")
        return jsonify({"error": str(e), "label": "ERROR", "color_status": "purple"}), 500

if __name__ == '__main__':
    # Menjalankan Server
    print("\n--- SERVER SIAP ---")
    print("Menunggu request dari Flutter...")
    app.run(host='0.0.0.0', port=5000, debug=True)