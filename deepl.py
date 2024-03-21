import cv2
from flask import Flask, render_template, request, make_response, jsonify
import numpy as np
from PIL import Image
#from predict import Predictor
import base64
import os
import pyocr
import pyocr.builders
from flask_cors import CORS
import requests

app = Flask(__name__)
CORS(app)
api_key = "7cfe0f30-a15d-4acb-ba71-84333cd014ae:fx"
source_lang = 'EN'
target_lang = 'JA'

path_tesseract = "C:/Users/hatot/miniconda3/envs/flask_env/Library/bin/"
if path_tesseract not in os.environ["PATH"].split(os.pathsep):
    os.environ["PATH"] += os.pathsep + path_tesseract

# OCRエンジンの取得
tools = pyocr.get_available_tools()
tool = tools[0]

@app.route("/trimming", methods=['POST'])
def predict():
    if request.is_json:
        data = request.get_json()
        post_img = data['post_img']
        img_base64 = post_img.split(',')[1]
    else:
        data = request.get_data().decode()
        temp = data.split('"')
        img_base64 = temp[3]

    # base64から画像に変換
    img_binary = base64.b64decode(img_base64)
    img_array = np.asarray(bytearray(img_binary), dtype=np.uint8)
    img = cv2.imdecode(img_array, 1)

    # OCR実行
    builder = pyocr.builders.TextBuilder(tesseract_layout=6)
    result = tool.image_to_string(Image.fromarray(cv2.cvtColor(img, cv2.COLOR_BGR2RGB)), lang="eng", builder=builder)

    #response = {'ocr_result': result}

    params = {
        'auth_key':api_key,
        'text':result,
        'source_lang':source_lang,
        'target_lang':target_lang
    }
    deepL_request = requests.post("https://api-free.deepl.com/v2/translate", data=params)
    deepL_result = deepL_request.json()
    translated_text = deepL_result["translations"][0]["text"]

    translated_response = {'ocr_result':translated_text}

    #return make_response(jsonify(response))
    return make_response(jsonify(translated_response))

if __name__ == "__main__":
    app.run(host='127.0.0.1', port=5000, debug=True)