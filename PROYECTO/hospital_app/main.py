from flask import Flask, render_template, request , redirect , flash, session
import pyodbc
from datetime import datetime

app = Flask(__name__)
app.secret_key = 'ProyectoDSBT'


# Configuración de la cadena de conexión para autenticación de Windows
server = 'LAPTOP-3KA9U966'  # Reemplaza con tu servidor SQL Server
database = 'ProyectoDBST'  # Reemplaza con el nombre de tu base de datos
driver = '{ODBC Driver 17 for SQL Server}'

# Cadena de conexión completa para autenticación de Windows
connection_string = f'DRIVER={driver};SERVER={server};DATABASE={database};Trusted_Connection=yes;'

try:
    # Intenta establecer la conexión
    connection = pyodbc.connect(connection_string)
    print("Conexión exitosa a la base de datos")
except pyodbc.Error as ex:
    # Si hay un error, imprime el mensaje de error
    print("Error al conectar a la base de datos:", ex)
    connection = None

# Crear un cursor para ejecutar consultas SQL
cursor = connection.cursor()

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


@app.route('/')
def index():
    return render_template('index.html')

@app.route('/paciente')
def paciente():
    return render_template('paciente.html')

@app.route('/paciente_post',methods = ['POST'])
def paciente_post():
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
                return redirect('/consola_paciente')
            else:
                # Si las credenciales son incorrectas, mostrar un mensaje de error
                flash("Credenciales incorrectas. Inténtalo de nuevo.", 'error')
                return redirect('/paciente')

        except pyodbc.Error as ex:
            # Si hay un error, imprimir el mensaje
            print("Error al iniciar sesión del paciente:", ex)

    # Redirigir a la página del paciente en cualquier caso
    return redirect('/paciente')

@app.route('/registro_paciente_post' ,methods = ['POST'])
def registro_paciente_post():
    print(request.form)
    if request.method == 'POST':
        # Obtener los datos del formulario
        nombre = request.form['nombre']
        ap_pat = request.form['ap_pat']
        ap_mat = request.form['ap_mat']
        contacto = request.form['contacto']
        fecha_nac = request.form['fecha_nac']
        sexo = request.form['sexo']
        contraseña = request.form['password']
        TipoTabla="Paciente"

        try:
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

            # Mostrar mensaje flash y redirigir
            flash(f"Registro de paciente exitoso. ID: {id_paciente}", 'success')
            return redirect('/paciente')
            
        except pyodbc.Error as ex:
            # Si hay un error, imprimir el mensaje y hacer rollback
            print("Error al registrar paciente:", ex)
            connection.rollback()
  
@app.route('/registro_paciente')
def registro_paciente():
    return render_template('registro_paciente.html')

@app.route('/consola_paciente')
def consola_paciente():
    # Verificar si el paciente ha iniciado sesión
    if 'id_paciente' not in session:
        flash("Debes iniciar sesión para acceder a la consola del paciente.", 'error')
        return redirect('/paciente')

    return render_template('consola_paciente.html')          
            


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
