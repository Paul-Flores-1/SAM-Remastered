import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

class SAMBackgroundService {
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'sam_service_channel',
      'SAM24 - Servicio de Protección',
      description: 'Mantiene activa la detección de accidentes.',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false, 
        isForegroundMode: true,
        notificationChannelId: 'sam_service_channel',
        initialNotificationTitle: 'SAM Protegiéndote',
        initialNotificationContent: 'Detección de accidentes activa',
        // CORRECCIÓN DEFINITIVA: Usamos la lista de tipos para máxima compatibilidad
        foregroundServiceTypes: [AndroidForegroundType.location], 
      ),
      iosConfiguration: IosConfiguration(),
    );
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 10), (timer) async {
    if (service is AndroidServiceInstance) {
      if (!(await service.isForegroundService())) return;

      // Obtener ubicación con la configuración moderna
      try {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );

        service.setForegroundNotificationInfo(
          title: "SAM - Protegiéndote",
          content: "Ubicación: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}",
        );
      } catch (e) {
        debugPrint("Error obteniendo GPS en segundo plano: $e");
      }
    }
    
    debugPrint("Servicio SAM corriendo...");
  });
}