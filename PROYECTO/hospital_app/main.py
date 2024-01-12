from flask import Flask, render_template, request , redirect , flash, session , jsonify
import pyodbc
from datetime import datetime, timedelta
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

@app.route('/logout')
def logout():
    # Limpiar la sesión
    session.clear()
    flash("Has cerrado sesión exitosamente.", 'success')
    # Redirigir al usuario a la página de inicio de sesión o al inicio
    return redirect('/')
#---------------------------- Paciente ----------------------------------------------------

@app.route('/Paciente/login_paciente')
def login_paciente():
    print(session)
    return render_template('/Paciente/login_paciente.html')

@app.route('/Paciente/login_paciente_post',methods = ['POST'])
def login_paciente_post():
    if request.method == 'POST':
        # Obtener los datos del formulario de inicio de sesión
        id_paciente = request.form['id_paciente']
        contraseña = request.form['contrasena']

        try:
            # Verificar las credenciales en la base de datos
            cursor.execute("SELECT ID_Paciente FROM Paciente WHERE ID_Paciente = ? AND Contrasena = ?", id_paciente, contraseña)
            result = cursor.fetchone()

            if result:
                # Si las credenciales son correctas, almacenar el ID en la variable de sesión
                session['id_paciente'] = id_paciente

                # Redirigir a la página del paciente
                return redirect('/Paciente/dashboard_paciente')
            else:
                # Si las credenciales son incorrectas, mostrar un mensaje de error
                flash("Credenciales incorrectas. Inténtalo de nuevo.", 'error')
                return redirect('/Paciente/login_paciente')

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
            cursor.execute("EXEC SP_AgregarPaciente ?, ?, ?, ?, ?, ?, ?",
                           nombre, ap_pat, ap_mat, contacto, fecha_nac, sexo, contraseña)

            # Confirmar la transacción
            connection.commit()

            # Obtener el ID del nuevo usuario
            cursor.execute("SELECT ID_Paciente FROM Paciente WHERE Contacto = ? ",
                           contacto)
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

    if 'id_paciente' not in session:
        flash("Debes iniciar sesión para acceder a la consola del paciente.", 'error')
        return redirect('/Paciente/login_paciente')
    
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
            cursor.execute("SELECT ID_Servicios ,Nombre, Costo FROM Consultas_Servicios")
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
            cursor.execute("SELECT ID_Doctor, Nombre, Ap_Pat, Ap_Mat FROM Doctor")
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
    max_fecha = fecha_actual + timedelta(days=90)
    return render_template('/Paciente/agendar_cita.html',fecha_actual=fecha_actual,max_fecha=max_fecha,especialidades=especialidades,servicios=servicios,medicos=medicos)

@app.route('/Paciente/agendar_cita_post', methods=['POST'])
def agendar_cita_post():
    if 'id_paciente' not in session:
        flash("Debes iniciar sesión para acceder a la consola del paciente.", 'error')
        return redirect('/Paciente/login_paciente')
    
    if request.method == 'POST':
        # Obtener los datos del formulario
        try:
            id_paciente = session.get('id_paciente')
            id_medico = request.form['medico']
            fecha = request.form['fecha']
            hora = request.form['hora']
            servicio=request.form['servicio']

            cursor.execute(f"Select Nombre from Consultas_Servicios Where ID_Servicios = '{servicio}'")
            desc_servicio = cursor.fetchone()[0]
            connection.commit()

            cursor.execute(f"Select Costo from Consultas_Servicios Where ID_Servicios = '{servicio}'")
            costo = cursor.fetchone()[0]
            connection.commit()
            
            fecha_cita = datetime.strptime(fecha, '%Y-%m-%d').date()
            hora_cita = datetime.strptime(hora, '%H:%M').time()

            if fecha_cita < datetime.now().date() or (fecha_cita == datetime.now().date() and hora_cita < datetime.now().time()):
                flash("La fecha y hora deben ser futuras", "error")
                return redirect('/Paciente/agendar_cita')
            

            cursor.execute("SELECT * FROM VistaDetalleCita WHERE FechaAtencion = ? AND HoraAtencion = ? AND ID_Doctor = ?", fecha,hora, id_medico)
            citas_doctor = cursor.fetchone()
            connection.commit()

            if citas_doctor:
                print("El doctor ya tiene una cita en esta fecha y hora", "error")
                return redirect('/Paciente/agendar_cita')



            # Obtener el precio del servicio
            sp_query = "EXEC SP_AgregarCita ?, ?, ?, ?, ?, ?, ?, ?"
            cursor.execute(sp_query, id_paciente, id_medico, 'ADMIN20230', fecha, hora, 'S', costo, desc_servicio)
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

@app.route('/cargar_servicios_doctores/<int:id_especialidad>')
def cargar_servicios_doctores(id_especialidad):
    servicios = obtener_servicios_por_especialidad(id_especialidad)
    doctores = obtener_doctores_por_especialidad(id_especialidad)
    return jsonify({'servicios': servicios, 'doctores': doctores})

def obtener_servicios_por_especialidad(id_especialidad):
    cursor.execute("SELECT * FROM Consultas_Servicios WHERE ID_Especialidad = ?", id_especialidad)
    servicios = cursor.fetchall()
    return [dict(ID_Servicios=servicio[0], Nombre=servicio[2], precio=servicio[3]) for servicio in servicios]

def obtener_doctores_por_especialidad(id_especialidad):
    cursor.execute("SELECT * FROM Doctor WHERE ID_Especialidad = ?", id_especialidad)
    doctores = cursor.fetchall()
    return [dict(ID_Doctor=doctor[0], Nombre=doctor[1], Ap_Pat=doctor[2], Ap_Mat=doctor[3]) for doctor in doctores]

@app.route('/Paciente/citas_paciente')
def citas_paciente():
    if 'id_paciente' not in session:
        print("si entre")
        flash("Debes iniciar sesión para acceder a la consola del paciente.", 'error')
        return redirect('/Paciente/login_paciente')
    id_paciente = session.get('id_paciente')
    cursor.execute("SELECT * from VistaDetalleCita Where ID_Paciente= ?", id_paciente)
    citas = cursor.fetchall()

    return render_template('/Paciente/citas_paciente.html',citas=citas)  


@app.route('/modificar_cita/<id_cita>', methods=['GET'])
def modificar_cita(id_cita):

    cursor.execute("SELECT * FROM VistaDetalleCita WHERE ID_Cita = ?", id_cita)
    detalles_cita = cursor.fetchone()
    connection.commit()
    fecha_actual = datetime.now().date()
    max_fecha = fecha_actual + timedelta(days=90)
    hora_cita_formato = detalles_cita.HoraAtencion.strftime('%H:%M')


    return render_template('/Paciente/modificar_cita.html', cita=detalles_cita,fecha_actual=fecha_actual,hora_cita_formato=hora_cita_formato,max_fecha=max_fecha)

@app.route('/modificar_cita_post/', methods=['POST'])
def modificar_cita_post():
    if request.method == 'POST':
        folio=request.form.get('folio')
        fecha = request.form.get('fecha')
        hora = request.form.get('hora')
        # Otros campos como sea necesario

        try:
            fecha_cita = datetime.strptime(fecha, '%Y-%m-%d').date()
            hora_cita = datetime.strptime(hora, '%H:%M').time()

            if fecha_cita < datetime.now().date() or (fecha_cita == datetime.now().date() and hora_cita < datetime.now().time()):
                flash("La fecha y hora deben ser futuras", "error")
                return redirect('/modificar_cita')
            
            cursor.execute("SELECT * FROM VistaDetalleCita WHERE ID_Cita = ?", folio)
            detalles_cita = cursor.fetchone()
            connection.commit()

            cursor.execute("SELECT * FROM VistaDetalleCita WHERE FechaAtencion = ? AND HoraAtencion = ? AND ID_Doctor = ?", fecha,hora, detalles_cita.ID_Doctor)
            citas_doctor = cursor.fetchone()
            connection.commit()

            if citas_doctor:
                print("El doctor ya tiene una cita en esta fecha y hora", "error")
                return redirect('/Paciente/citas_paciente')
            
            cursor.execute("UPDATE Cita SET FechaAtencion = ?, HoraAtencion = ? WHERE ID_Cita = ?", (fecha_cita, hora_cita, folio))
            connection.commit()

            print("Cita modificada con éxito", "success")
            return redirect('/Paciente/citas_paciente')
        except Exception as e:

            flash("Error al modificar la cita: " + str(e), "error")

    return render_template('/Paciente/citas_paciente')


@app.route('/eliminar_cita/<id_cita>', methods=['POST'])
def eliminar_cita(id_cita):
    try:
        cursor.execute("SELECT FechaAtencion, HoraAtencion FROM Cita WHERE ID_Cita = ?", (id_cita))
        cita = cursor.fetchone()
        connection.commit()

        # Combinar fecha y hora de la cita y convertirlas a objeto datetime
        fecha_hora_cita = datetime.combine(cita.FechaAtencion, cita.HoraAtencion)

        # Verificar si la cita está al menos a 24 horas de distancia
        if (fecha_hora_cita - datetime.now()) < timedelta(hours=24):
            flash("No se puede cancelar la cita con menos de 24 horas de anticipación.", "error")
            return redirect('/Paciente/citas_paciente')

        cursor.execute("DELETE FROM Cita WHERE ID_Cita = ?", (id_cita))
        connection.commit()

        flash("Cita eliminada con éxito.", "success")
    except Exception as e:
        flash("No se pudo eliminar la cita: " + str(e), "error")

    # Redireccionar al usuario de vuelta a la página de citas
    return redirect('/Paciente/citas_paciente')








@app.route('/Paciente/modificar_paciente')
def modificar_paciente():

    if 'id_paciente' not in session:
        flash("Debes iniciar sesión para acceder a la consola del paciente.", 'error')
        return redirect('/Paciente/login_paciente')
    # Obtener el ID del paciente desde la sesión (asegúrate de haberlo almacenado previamente)
    id_paciente = session.get('id_paciente')

    # Consultar la información del paciente desde la base de datos
    cursor.execute("SELECT ID_Paciente, Nombre, Ap_Pat, Ap_Mat, Contacto, FechaNac, Sexo FROM Paciente WHERE ID_Paciente = ?", id_paciente)
    paciente_info = cursor.fetchone()

    fecha_nacimiento_formateada = paciente_info[5].strftime('%Y-%m-%d')


    return render_template('/Paciente/modificar_paciente.html', paciente_info=paciente_info, fecha_nacimiento_formateada=fecha_nacimiento_formateada)

@app.route('/Paciente/modificar_paciente_post', methods=['POST'])
def modificar_paciente_post():
    if 'id_paciente' not in session:
        flash("Debes iniciar sesión para acceder a la consola del paciente.", 'error')
        return redirect('/Paciente/login_paciente')
    
    # Obtener el ID del paciente desde la sesión (asegúrate de haberlo almacenado previamente)
    id_paciente = session.get('id_paciente')

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
        cursor.execute("SELECT Contacto FROM Paciente WHERE ID_Paciente = ?", id_paciente)

        existing_patient = cursor.fetchone()

        if existing_patient[0]==contacto:
            pass
        else:
            cursor.execute("SELECT ID_Paciente FROM Paciente WHERE Contacto = ?", contacto)
            existing_patient_contact = cursor.fetchone()
            if existing_patient_contact:
                flash("Este correo electrónico ya está registrado. Por favor, utiliza otro.", 'error')
                return redirect('/Paciente/modificar_paciente')

        # Validar la contraseña
        if not re.match(r"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$", contraseña):
            flash("La contraseña debe tener al menos 1 mayúscula, 1 minúscula, 1 número, 1 carácter especial y una longitud mínima de 8 caracteres.", 'error')
            return redirect('/Paciente/modificar_paciente')

        try:
            # Convertir la fecha a un formato adecuado para tu base de datos
            fecha_nac = datetime.strptime(fecha_nac, '%Y-%m-%d').date()

            # Ejecutar la consulta SQL para actualizar los datos del paciente
            cursor.execute("UPDATE Paciente SET Nombre = ?, Ap_Pat = ?, Ap_Mat = ?, Contacto = ?, "
                           "FechaNac = ?, Sexo = ?, Contrasena = ? WHERE ID_Paciente = ?",
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
