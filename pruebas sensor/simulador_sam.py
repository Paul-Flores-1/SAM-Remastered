import serial
import time
import random

# Configuración del puerto
PUERTO = 'COM3'
BAUDIOS = 115200

def escuchar_respuesta_sam(sam_serial, duracion_segundos=1.5):
    """Función auxiliar para leer e imprimir todo lo que responda el ESP32"""
    tiempo_inicio = time.time()
    while time.time() - tiempo_inicio < duracion_segundos:
        if sam_serial.in_waiting > 0:
            respuesta = sam_serial.readline().decode('utf-8', errors='ignore').strip()
            if respuesta:
                print(f"   SAM -> {respuesta}")

try:
    print(f"==================================================")
    print(f"  INICIANDO SUITE DE PRUEBAS AUTOMATIZADA DE SAM")
    print(f"==================================================")
    print(f"Conectando al puerto {PUERTO}...")
    
    sam_serial = serial.Serial(PUERTO, BAUDIOS, timeout=1)
    time.sleep(2) # Pausa obligatoria para que el ESP32 se reinicie tras la conexión serial
    
    print("Conexión exitosa. Comenzando en 3 segundos...\n")
    time.sleep(3)

    # ---------------------------------------------------------
    # PRUEBA 1: BACHE SEVERO
    # ---------------------------------------------------------
    print(">>> PRUEBA 1: Bache o tope severo (Impacto vertical puro de ~4G)")
    print("    Esperado: Detección de bache, SIN alerta SMS.")
    # Trama: Sin aceleración frontal/lateral, 39.24 m/s2 en el eje Z vertical
    trama_bache = "0.0,0.0,39.24,0.0,0.0,0.0\n"
    sam_serial.write(trama_bache.encode('utf-8'))
    escuchar_respuesta_sam(sam_serial)
    time.sleep(1)


    # ---------------------------------------------------------
    # PRUEBA 2: FRENADO DE EMERGENCIA
    # ---------------------------------------------------------
    print("\n>>> PRUEBA 2: Frenado de Pánico (Desaceleración frontal de ~2G)")
    print("    Esperado: Detección de frenado, SIN alerta SMS.")
    # Trama: Desaceleración en el eje Y (19.62 m/s2), gravedad normal en Z
    trama_freno = "0.0,19.62,9.81,0.0,0.0,0.0\n"
    sam_serial.write(trama_freno.encode('utf-8'))
    escuchar_respuesta_sam(sam_serial)
    time.sleep(1)


    # ---------------------------------------------------------
    # PRUEBA 3: VUELCO / CAÍDA (Moto parada)
    # ---------------------------------------------------------
    print("\n>>> PRUEBA 3: Moto derribada estando estacionada (Inclinación de 90 grados)")
    print("    Esperado: Detección de inclinación crítica, SIN alerta de impacto masivo.")
    # Trama: Cero aceleración dinámica. La gravedad (9.81) recae en el eje lateral (Y)
    trama_vuelco = "0.0,9.81,0.0,0.0,0.0,0.0\n"
    sam_serial.write(trama_vuelco.encode('utf-8'))
    escuchar_respuesta_sam(sam_serial)
    time.sleep(1)


    # ---------------------------------------------------------
    # PRUEBA 4: CHOQUE FRONTAL
    # ---------------------------------------------------------
    print("\n>>> PRUEBA 4: Colisión Frontal contra objeto rígido a 50 km/h (~17.7G)")
    print("    Esperado: Alerta CATASTRÓFICA detonada. Protocolo de emergencia activo.")
    # Trama: Impacto masivo en eje X (173.6 m/s2), gravedad en Z
    trama_choque = "173.6,0.0,9.81,0.0,0.0,0.0\n"
    sam_serial.write(trama_choque.encode('utf-8'))
    escuchar_respuesta_sam(sam_serial, duracion_segundos=2.5)
    
    print("\n==================================================")
    print("  SUITE DE PRUEBAS COMPLETADA")
    print("==================================================")

except Exception as e:
    
    print(f"\n[ERROR] No se pudo ejecutar la simulación: {e}")
    print("Revisa que el Monitor Serie de Arduino esté cerrado.")
finally:
    if 'sam_serial' in locals() and sam_serial.is_open:
        sam_serial.close()