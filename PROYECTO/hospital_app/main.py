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

@app.route('/Paciente/login_paciente')
def login_paciente():
    return render_template('/Paciente/login_paciente.html')

@app.route('/Paciente/login_paciente_post',methods = ['POST'])
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
                return redirect('/Paciente/dashboard_paciente')
            else:
                # Si las credenciales son incorrectas, mostrar un mensaje de error
                flash("Credenciales incorrectas. Inténtalo de nuevo.", 'error')
                return redirect('/Paciente/dashboard_paciente')

        except pyodbc.Error as ex:
            # Si hay un error, imprimir el mensaje
            print("Error al iniciar sesión del paciente:", ex)

    # Redirigir a la página del paciente en cualquier caso
    return redirect('/Paciente/login_paciente')

@app.route('/Paciente/registro_paciente')
def registro_paciente():
    return render_template('/Paciente/registro_paciente.html')

@app.route('/Paciente/registro_paciente_post', methods=['POST'])
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
            return redirect('/Paciente/registro_paciente')

        # Verificar si el correo ya está registrado
        cursor.execute("SELECT ID_Paciente FROM Paciente WHERE Contacto = ?", contacto)
        existing_patient = cursor.fetchone()

        if existing_patient:
            flash("Este correo electrónico ya está registrado. Por favor, utiliza otro.", 'error')
            return redirect('/Paciente/registro_paciente')

        # Validar la contraseña
        if not re.match(r"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$", contraseña):
            flash("La contraseña debe tener al menos 1 mayúscula, 1 minúscula, 1 número, 1 carácter especial y una longitud mínima de 8 caracteres.", 'error')
            return redirect('/Paciente/registro_paciente')

        try:
            # Convertir la fecha a un formato adecuado para tu base de datos
            fecha_nac = datetime.strptime(fecha_nac, '%Y-%m-%d').date()

            # Ejecutar el procedimiento almacenado para insertar datos de paciente
            cursor.execute("EXEC InsertarDatos ?, ?, ?, ?, ?, ?, ?, ?, ?",
                           nombre, ap_pat, ap_mat, contacto, fecha_nac, sexo, contraseña, TipoTabla, 0)

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
            return redirect('/Paciente/login_paciente')

        except pyodbc.Error as ex:
            # Si hay un error, imprimir el mensaje y hacer rollback
            print("Error al registrar paciente:", ex)
            flash("Error al registrar paciente. Inténtalo de nuevo.", 'error')
            connection.rollback()

    # Si el método no es POST o hay un error, redirigir a la página de registro del paciente
    return redirect('/Paciente/registro_paciente')  

@app.route('/Paciente/dashboard_paciente')
def dashboard_paciente():
    # Verificar si el paciente ha iniciado sesión
    if 'id_paciente' not in session:
        flash("Debes iniciar sesión para acceder a la consola del paciente.", 'error')
        return redirect('/Paciente/login_paciente')

    return render_template('/Paciente/dashboard_paciente.html')   

@app.route('/Paciente/agendar_cita')
def agendar_cita():
    def obtener_especialidades():
        try:
            # Ejecutar la consulta SQL para obtener las especialidades
            cursor.execute("SELECT ID_Especialidad, Nombre FROM Especialidad")
            # Obtener los resultados de la consulta
            especialidades = cursor.fetchall()
            # Confirmar la transacción
            connection.commit()

            # Devolver la lista de especialidades
            return especialidades
        except pyodbc.Error as ex:
            # Si hay un error, imprimir el mensaje y hacer rollback
            print("Error al extraer las especialidades", ex)
            connection.rollback()
            # En caso de error, devolver una lista vacía
            return []

    def obtener_servicios():
        try:
            # Ejecutar la consulta SQL para obtener las especialidades
            cursor.execute("SELECT ID_Servicios ,NombreServicio, Costo FROM MenuServicios")
            # Obtener los resultados de la consulta
            servicios = cursor.fetchall()
            # Confirmar la transacción
            connection.commit()

            # Devolver la lista de especialidades
            return servicios
        except pyodbc.Error as ex:
            # Si hay un error, imprimir el mensaje y hacer rollback
            print("Error al extraer los servicios", ex)
            connection.rollback()
            # En caso de error, devolver una lista vacía
            return []
        
    def obtener_doctores():
        try:
            # Ejecutar la consulta SQL para obtener los médicos
            cursor.execute("SELECT ID_Medico, Nombre, Ap_Pat, Ap_Mat FROM Medico")
            # Obtener los resultados de la consulta
            medicos = cursor.fetchall()
            # Confirmar la transacción
            connection.commit()

            # Devolver la lista de médicos
            return medicos
        except pyodbc.Error as ex:
            # Si hay un error, imprimir el mensaje y hacer rollback
            print("Error al extraer los médicos", ex)
            connection.rollback()

            # En caso de error, devolver una lista vacía
            return []
    
    especialidades = obtener_especialidades()
    servicios=obtener_servicios()
    medicos = obtener_doctores()
    fecha_actual = datetime.now().date()
    return render_template('/Paciente/agendar_cita.html',fecha_actual=fecha_actual,especialidades=especialidades,servicios=servicios,medicos=medicos)

@app.route('/Paciente/agendar_cita_post', methods=['POST'])
def agendar_cita_post():
    if request.method == 'POST':
        # Obtener los datos del formulario
        fecha = request.form['fecha']
        hora = request.form['hora']
        id_paciente = session.get('id_paciente')

        try:
            # Obtener datos adicionales del formulario
            id_especialidad = request.form['especialidad']
            id_servicio = request.form['servicio']
            id_medico = request.form['medico']

            # Obtener el precio del servicio
            cursor.execute("SELECT Costo FROM MenuServicios WHERE ID_Servicios = ?", id_servicio)
            costo_servicio = cursor.fetchone()[0]
            print(f"EXEC InsertarCita {fecha} ,{hora} ,Pendiente ,{costo_servicio}, M@STEr ,{id_paciente} ,{id_medico}")

            # Ejecutar la consulta SQL para agregar la cita a la base de datos
            cursor.execute("EXEC InsertarCita ?, ?, ?, ?, ?, ?, ?",
                           fecha, hora, 'Pendiente', costo_servicio, 'M@STEr', id_paciente, id_medico)
            # Confirmar la transacción
            connection.commit()

            # Mostrar mensaje flash y redirigir
            flash("Cita agendada exitosamente.", 'success')
            return redirect('/Paciente/dashboard_paciente')
        except pyodbc.Error as ex:
            # Si hay un error, imprimir el mensaje y hacer rollback
            print("Error al agendar cita:", ex)
            connection.rollback()

    # Si el método no es POST o hay un error, redirigir a la consola del paciente
    return redirect('/Paciente/dashboard_paciente')

@app.route('/Paciente/modificar_paciente')
def modificar_paciente():
    # Obtener el ID del paciente desde la sesión (asegúrate de haberlo almacenado previamente)
    id_paciente = session.get('id_paciente')

    # Consultar la información del paciente desde la base de datos
    cursor.execute("SELECT ID_Paciente, Nombre, Ap_Pat, Ap_Mat, Contacto, FechaNac, Sexo FROM Paciente WHERE ID_Paciente = ?", id_paciente)
    paciente_info = cursor.fetchone()

    fecha_nacimiento_formateada = paciente_info[5].strftime('%Y-%m-%d')


    return render_template('/Paciente/modificar_paciente.html', paciente_info=paciente_info, fecha_nacimiento_formateada=fecha_nacimiento_formateada)



@app.route('/Paciente/modificar_paciente_post', methods=['POST'])
def modificar_paciente_post():
    if request.method == 'POST':
        # Obtener los datos del formulario
        nombre = request.form['nombre']
        ap_pat = request.form['ap_pat']
        ap_mat = request.form['ap_mat']
        contacto = request.form['contacto']
        fecha_nac = request.form['fecha_nac']
        sexo = request.form['sexo']
        contraseña = request.form['password']

        # Validar que el campo de contacto sea un correo electrónico válido

        if not re.match(r"[^@]+@[^@]+\.[^@]+", contacto):
            flash("Por favor, introduce un correo electrónico válido.", 'error')
            return redirect('/Paciente/modificar_paciente')
        
        # Verificar si el correo ya está registrado
        cursor.execute("SELECT ID_Paciente FROM Paciente WHERE Contacto = ?", contacto)
        existing_patient = cursor.fetchone()

        if existing_patient:
            flash("Este correo electrónico ya está registrado. Por favor, utiliza otro.", 'error')
            return redirect('/Paciente/registro_paciente')

        # Validar la contraseña
        if not re.match(r"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$", contraseña):
            flash("La contraseña debe tener al menos 1 mayúscula, 1 minúscula, 1 número, 1 carácter especial y una longitud mínima de 8 caracteres.", 'error')
            return redirect('/Paciente/modificar_paciente')

        try:
            # Convertir la fecha a un formato adecuado para tu base de datos
            fecha_nac = datetime.strptime(fecha_nac, '%Y-%m-%d').date()

            # Obtener el ID del paciente desde la sesión (asegúrate de haberlo almacenado previamente)
            id_paciente = session.get('id_paciente')

            # Ejecutar la consulta SQL para actualizar los datos del paciente
            cursor.execute("UPDATE Paciente SET Nombre = ?, Ap_Pat = ?, Ap_Mat = ?, Contacto = ?, "
                           "FechaNac = ?, Sexo = ?, Contraseña = ? WHERE ID_Paciente = ?",
                           nombre, ap_pat, ap_mat, contacto, fecha_nac, sexo, contraseña, id_paciente)

            # Confirmar la transacción
            connection.commit()

            # Mostrar mensaje flash y redirigir
            flash("Datos de paciente actualizados exitosamente.", 'success')
            return redirect('/Paciente/dashboard_paciente')
        except pyodbc.Error as ex:
            # Si hay un error, imprimir el mensaje y hacer rollback
            print("Error al actualizar datos del paciente:", ex)
            flash("Error al actualizar datos del paciente. Inténtalo de nuevo.", 'error')
            connection.rollback()

    # Si el método no es POST o hay un error, redirigir a la consola del paciente
    return redirect('/Paciente/dashboard_paciente')
            
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
