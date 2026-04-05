# --- SIMULADOR DE ALGORITMO SAM ---
NOMBRE_ARCHIVO = 'serial_20260405_131624.txt' 

# Parámetros acordados
GRAVEDAD = 9.81
LIMITE_XY_MS2 = 6.0 * GRAVEDAD  # Aprox 58.86 m/s^2
LIMITE_Z_MS2 = 8.0 * GRAVEDAD   # Aprox 78.48 m/s^2

falsos_positivos_evitados = 0
accidentes_detectados = 0
linea_actual = 0

print("Iniciando simulador SAM con datos de campo...")
print(f"Límite X/Y: {LIMITE_XY_MS2:.2f} m/s^2")
print(f"Límite Z:   {LIMITE_Z_MS2:.2f} m/s^2\n")

try:
    with open(NOMBRE_ARCHIVO, 'r') as archivo:
        for linea in archivo:
            linea_actual += 1
            partes = linea.strip().split(' ') 
            
            if len(partes) >= 2:
                datos = partes[1].split(',')
                if len(datos) == 6:
                    try:
                        ax = abs(float(datos[0]))
                        ay = abs(float(datos[1]))
                        az = abs(float(datos[2]))
                        
                        # --- NUEVA LÓGICA SAM SEPARADA POR EJES ---
                        choque_frontal = ax >= LIMITE_XY_MS2 or ay >= LIMITE_XY_MS2
                        impacto_vertical = az >= LIMITE_Z_MS2
                        
                        if choque_frontal or impacto_vertical:
                            accidentes_detectados += 1
                            print(f"[ALERTA] ¡Posible accidente en la lectura {linea_actual}!")
                            print(f"Valores -> X:{ax:.2f}, Y:{ay:.2f}, Z:{az:.2f}")
                            
                        # Curiosidad: Ver cuántos baches habrían activado la alarma vieja (usando 6G para todo)
                        elif az >= LIMITE_XY_MS2:
                            falsos_positivos_evitados += 1
                            
                    except ValueError:
                        pass 

    print("\n--- RESULTADOS DE LA SIMULACIÓN ---")
    if accidentes_detectados == 0:
        print("PRUEBA EXITOSA: No se detonaron falsas alarmas durante el viaje.")
    else:
        print(f"PELIGRO: Se detectaron {accidentes_detectados} eventos que superaron los umbrales.")
        
    print(f" El nuevo umbral de 8G en el eje Z evitó {falsos_positivos_evitados} falsos positivos por topes/baches.")

except FileNotFoundError:
    print("Error: Archivo no encontrado.")