import serial
import time

PUERTO_COM = 'COM3'  
BAUD_RATE = 115200
NOMBRE_ARCHIVO = 'prueba_rodada.txt' # Tu archivo de Acapulco

try:
    print(f"Conectando a SAM en {PUERTO_COM}...")
    esp32 = serial.Serial(PUERTO_COM, BAUD_RATE, timeout=0.1)
    time.sleep(2) 
    
    print("Iniciando simulación en TIEMPO REAL (10ms por lectura)...")
    print("Esto tomará el mismo tiempo que duró el viaje real.\n")
    
    lineas = 0
    with open(NOMBRE_ARCHIVO, 'r') as archivo:
        for linea in archivo:
            partes = linea.strip().split(' ')
            if len(partes) >= 2:
                # Enviamos los datos
                esp32.write((partes[1] + '\n').encode('utf-8'))
                
                # Leemos respuesta si la hay
                if esp32.in_waiting:
                    resp = esp32.readline().decode('utf-8', errors='ignore').strip()
                    if resp: print(f"SAM: {resp}")
                
                # RETRASO DE TIEMPO REAL: 0.01s = 10ms = 100Hz
                time.sleep(0.01)
                
                lineas += 1
                if lineas % 1000 == 0:
                    minutos_simulados = round((lineas * 0.01) / 60, 1)
                    print(f"--- Progreso: {minutos_simulados} min simulados ---")

    print("\nSimulación finalizada.")
    esp32.close()

except Exception as e:
    print(f"Error: {e}")