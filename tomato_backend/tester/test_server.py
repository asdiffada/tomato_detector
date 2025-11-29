import requests

# Ganti dengan nama file gambar tomat sembarang yang ada di laptopmu untuk tes
GAMBAR_TES = "tester/test_pictures/orange1.jpeg" 
URL = "http://127.0.0.1:5000/predict"

try:
    print(f"Sedang mengirim {GAMBAR_TES} ke server...")
    with open(GAMBAR_TES, 'rb') as f:
        files = {'image': f}
        response = requests.post(URL, files=files)
    
    print("\n--- HASIL DARI SERVER ---")
    print(f"Status Code: {response.status_code}")
    print("Response JSON:")
    print(response.json())

except FileNotFoundError:
    print(f"Error: File gambar '{GAMBAR_TES}' tidak ditemukan. Sediakan 1 gambar untuk tes.")
except Exception as e:
    print(f"Error koneksi: {e}")