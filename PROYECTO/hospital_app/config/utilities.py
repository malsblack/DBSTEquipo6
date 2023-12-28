import json
import pyodbc
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def credentials_db():
    with open('./config/config.json', 'r') as archivo:
        data = json.load(archivo)
        return f"DRIVER={data['Db']['driver']};SERVER={data['Db']['server']};DATABASE={data['Db']['database']};Trusted_Connection=yes;"
    
def credentials_email():
    with open('./config/config.json', 'r') as archivo:
        data = json.load(archivo)
        return data['Email']
    
def db_connect():
    try:
        connection = pyodbc.connect(credentials_db())
        print("Conexión exitosa a la base de datos")
        return connection
    except pyodbc.Error as ex:
        # Si hay un error, imprime el mensaje de error
        print("Error al conectar a la base de datos:", ex)
        return None
    


def send_registration_email(nombre, ap_pat, ap_mat, contacto, nombre_usuario):
    email = credentials_email()

    # Crear el objeto del mensaje
    msg = MIMEMultipart()
    msg['From'] = email['EMAIL_USERNAME']
    msg['To'] = contacto
    msg['Subject'] = '¡Bienvenido a nuestro servicio de salud!'

    # Cuerpo del mensaje con formato HTML
    body = f'''
    <html>
    <head>
        <style>
            body {{
                background-color: #f4f4f4; /* Color de fondo */
                font-family: 'Arial', sans-serif;
            }}
            .container {{
                max-width: 600px;
                margin: 0 auto;
                padding: 20px;
                background-color: #fff;
                border-radius: 8px;
                box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            }}
            h2 {{
                color: #007bff;
            }}
            p {{
                margin-bottom: 15px;
            }}
            .highlight {{
                background-color: #ffff66; /* Color de resaltado */
                font-weight: bold;
            }}
        </style>
    </head>
    <body>
        <div class="container">
            <h2>¡Bienvenido, {nombre} {ap_pat} {ap_mat}!</h2>
            <p>
                Te damos la bienvenida a nuestro servicio de salud. Tu registro ha sido exitoso y ahora eres parte de nuestra comunidad.
                Esperamos que encuentres la información y los servicios que ofrecemos útiles para tu bienestar.
            </p>
            <p>Si tienes alguna pregunta o necesitas asistencia, no dudes en contactarnos.</p>
            <p>Gracias por confiar en nosotros, tu usuario es :</p>
            <span class="highlight">{nombre_usuario}</span>. 
            <p>¡Te deseamos salud y felicidad!</p>
        </div>
    </body>
    </html>
    '''
    msg.attach(MIMEText(body, 'html'))

    # Conectar al servidor SMTP y enviar el correo
    with smtplib.SMTP(email['EMAIL_HOST'], email['EMAIL_PORT']) as server:
        server.starttls()
        server.login(email['EMAIL_USERNAME'], email['EMAIL_PASSWORD'])
        server.sendmail(email['EMAIL_USERNAME'], contacto, msg.as_string())
