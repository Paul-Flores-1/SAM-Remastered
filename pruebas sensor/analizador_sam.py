import matplotlib.pyplot as plt

# --- CONFIGURACIÓN ---
# Cambia esto por el nombre exacto de tu archivo
NOMBRE_ARCHIVO = 'prueba_rodada.txt' 

lecturas_z = []
lecturas_y = []

print("Procesando archivo de telemetría...")

try:
    with open(NOMBRE_ARCHIVO, 'r') as archivo:
        for linea in archivo:
            # Separar la hora (ej. 21:42:10) de los datos (9.8,1.5,0.9...)
            partes = linea.strip().split(' ') 
            
            # Si la línea tiene el formato correcto (Hora + Datos)
            if len(partes) >= 2:
                datos = partes[1].split(',')
                # Asegurarnos de que tenga los 6 valores del sensor
                if len(datos) == 6:
                    try:
                        # Extraer el eje Y (Frenado/Aceleración) y Z (Baches/Topes)
                        ay = float(datos[1])
                        az = float(datos[2])
                        
                        lecturas_y.append(ay)
                        lecturas_z.append(az)
                    except ValueError:
                        pass # Ignorar líneas con texto corrupto

    print(f"¡Éxito! Se analizaron {len(lecturas_z)} lecturas del sensor.")
    
    # --- CREAR LA GRÁFICA ---
    plt.figure(figsize=(12, 6))
    
    # Graficar el eje Z (Vertical) en azul
    plt.plot(lecturas_z, label='Eje Z (Topes/Baches/Gravedad)', color='blue', alpha=0.7)
    
    # Graficar el eje Y (Frontal) en rojo
    plt.plot(lecturas_y, label='Eje Y (Aceleración/Frenado)', color='red', alpha=0.7)
    
    plt.title('Telemetría SAM - Rodada de 18 Minutos')
    plt.xlabel('Tiempo (Número de Lectura)')
    plt.ylabel('Aceleración (m/s²)')
    plt.legend()
    plt.grid(True)
    
    print("Mostrando gráfica... Cierra la ventana de la gráfica para terminar.")
    plt.show()

except FileNotFoundError:
    print(f"Error: No se encontró el archivo '{NOMBRE_ARCHIVO}'. Revisa el nombre.")