from flask import Flask, render_template, request , redirect , flash, session
import pyodbc
from datetime import datetime
import re
from config.utilities import db_connect,send_registration_email

app = Flask(__name__)
app.secret_key = 'ProyectoDSBT'
connection=db_connect()
cursor = connection.cursor()

#---------------------------- Index ------------------------------------------------------
@app.route('/')
def index():
    return render_template('index.html')

#---------------------------- Paciente ----------------------------------------------------

@app.route('/login_paciente')
def login_paciente():
    return render_template('login_paciente.html')

@app.route('/login_paciente_post',methods = ['POST'])
def login_paciente_post():
    if request.method == 'POST':
        # Obtener los datos del formulario de inicio de sesión
        id_paciente = request.form['id_paciente']
        contraseña = request.form['contrasena']

        try:
            # Verificar las credenciales en la base de datos
            cursor.execute("SELECT ID_Paciente FROM Paciente WHERE ID_Paciente = ? AND Contraseña = ?", id_paciente, contraseña)
            result = cursor.fetchone()

            if result:
                # Si las credenciales son correctas, almacenar el ID en la variable de sesión
                session['id_paciente'] = id_paciente

                # Redirigir a la página del paciente
                return redirect('/dashboard_paciente')
            else:
                # Si las credenciales son incorrectas, mostrar un mensaje de error
                flash("Credenciales incorrectas. Inténtalo de nuevo.", 'error')
                return redirect('/dashboard_paciente')

        except pyodbc.Error as ex:
            # Si hay un error, imprimir el mensaje
            print("Error al iniciar sesión del paciente:", ex)

    # Redirigir a la página del paciente en cualquier caso
    return redirect('/login_paciente')

@app.route('/registro_paciente')
def registro_paciente():
    return render_template('registro_paciente.html')

@app.route('/registro_paciente_post', methods=['POST'])
def registro_paciente_post():
    if request.method == 'POST':
        # Obtener los datos del formulario
        nombre = request.form['nombre']
        ap_pat = request.form['ap_pat']
        ap_mat = request.form['ap_mat']
        contacto = request.form['contacto']
        fecha_nac = request.form['fecha_nac']
        sexo = request.form['sexo']
        contraseña = request.form['password']
        TipoTabla = "Paciente"

        # Validar que el campo de contacto sea un correo electrónico válido
        if not re.match(r"[^@]+@[^@]+\.[^@]+", contacto):
            flash("Por favor, introduce un correo electrónico válido.", 'error')
            return redirect('/registro_paciente')

        # Verificar si el correo ya está registrado
        cursor.execute("SELECT ID_Paciente FROM Paciente WHERE Contacto = ?", contacto)
        existing_patient = cursor.fetchone()

        if existing_patient:
            flash("Este correo electrónico ya está registrado. Por favor, utiliza otro.", 'error')
            return redirect('/registro_paciente')

        # Validar la contraseña
        if not re.match(r"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$", contraseña):
            flash("La contraseña debe tener al menos 1 mayúscula, 1 minúscula, 1 número, 1 carácter especial y una longitud mínima de 8 caracteres.", 'error')
            return redirect('/registro_paciente')

        try:
            # Convertir la fecha a un formato adecuado para tu base de datos
            fecha_nac = datetime.strptime(fecha_nac, '%Y-%m-%d').date()

            # Ejecutar el procedimiento almacenado para insertar datos de paciente
            cursor.execute("EXEC InsertarDatos ?, ?, ?, ?, ?, ?, ?, ?",
                           nombre, ap_pat, ap_mat, contacto, fecha_nac, sexo, contraseña, TipoTabla)

            # Confirmar la transacción
            connection.commit()

            # Obtener el ID del nuevo usuario
            cursor.execute("SELECT ID_Paciente FROM Paciente WHERE Nombre = ? AND Ap_Pat = ? AND Ap_Mat = ?",
                           nombre, ap_pat, ap_mat)
            id_paciente = cursor.fetchone()[0]

            # Almacenar el ID en la variable de sesión
            session['id_paciente'] = id_paciente

            send_registration_email(nombre, ap_pat, ap_mat, contacto,id_paciente)

            # Mostrar mensaje flash y redirigir
            flash(f"Registro de paciente exitoso. ID: {id_paciente}", 'success')
            return redirect('/login_paciente')

        except pyodbc.Error as ex:
            # Si hay un error, imprimir el mensaje y hacer rollback
            print("Error al registrar paciente:", ex)
            flash("Error al registrar paciente. Inténtalo de nuevo.", 'error')
            connection.rollback()

    # Si el método no es POST o hay un error, redirigir a la página de registro del paciente
    return redirect('/registro_paciente')  
@app.route('/dashboard_paciente')


def dashboard_paciente():
    # Verificar si el paciente ha iniciado sesión
    if 'id_paciente' not in session:
        flash("Debes iniciar sesión para acceder a la consola del paciente.", 'error')
        return redirect('/login_paciente')

    return render_template('dashboard_paciente.html')   


@app.route('/agendar_cita_post', methods=['POST'])
def agendar_cita_post():
    if request.method == 'POST':
        # Obtener los datos del formulario
        fecha = request.form['fecha']
        hora = request.form['hora']

        # Obtener el ID del paciente desde la sesión (asegúrate de haberlo almacenado previamente)
        id_paciente = session.get('id_paciente')
        print(id_paciente)

        try:
            # Ejecutar la consulta SQL para agregar la cita a la base de datos
            cursor.execute("EXEC InsertarCita ?, ?, ?, ?, ?, ?, ?",
                           fecha, hora, 'Pendiente', 0, None, id_paciente, None)
            # Confirmar la transacción
            connection.commit()
            
            # Mostrar mensaje flash y redirigir
            flash("Cita agendada exitosamente.", 'success')
            return redirect('/consola_paciente')
        except pyodbc.Error as ex:
            # Si hay un error, imprimir el mensaje y hacer rollback
            print("Error al agendar cita:", ex)
            connection.rollback()

    # Si el método no es POST o hay un error, redirigir a la consola del paciente
    return redirect('/consola_paciente')


@app.route('/agendar_cita')
def agendar_cita():
    return render_template('agendar_cita.html')



       
            
#---------------------------- Medico ----------------------------------------------------
#---------------------------- Farmacia ----------------------------------------------------
#---------------------------- Recepcion ----------------------------------------------------







@app.route('/recepcion')
def recepcion():
    return render_template('recepcion.html')

@app.route('/medico')
def medico():
    return render_template('medico.html')

@app.route('/farmacia')
def farmacia():
    return render_template('farmacia.html')



if __name__ == '__main__':
    app.run(debug=True)
