import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// --- 1. EL MODELO DE DATOS ---
// Esta clase convierte los datos de Firebase en objetos de Dart y viceversa.
class ContactoEmergencia {
  String nombre;
  String telefono;

  ContactoEmergencia({required this.nombre, required this.telefono});

  // Convierte el objeto a un formato que Firestore entiende (Map)
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'telefono': telefono,
    };
  }

  // Crea un objeto a partir de los datos leídos de Firestore
  factory ContactoEmergencia.fromMap(Map<String, dynamic> map) {
    return ContactoEmergencia(
      nombre: map['nombre'] ?? '',
      telefono: map['telefono'] ?? '',
    );
  }
}

// --- 2. CONTROLADOR / SERVICIO CRUD ---
class ContactosService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // AGREGAR / EDITAR: Como es un documento existente, usamos update()
  // Sirve tanto para crear uno nuevo por primera vez, como para modificarlo.
  Future<bool> guardarContacto({required ContactoEmergencia contacto, required bool esPrincipal}) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      // Determinamos a qué campo de la BD le vamos a pegar
      String campoDestino = esPrincipal ? 'contactoPrincipal' : 'contactoSecundario';

      // Actualizamos solo esa parte del documento del usuario
      await _db.collection('usuarios').doc(user.uid).update({
        campoDestino: contacto.toMap(),
      });
      
      debugPrint("Contacto guardado exitosamente");
      return true;
    } catch (e) {
      debugPrint("Error al guardar contacto: $e");
      return false;
    }
  }

  // ELIMINAR: Borra la información del contacto dejándolo vacío o eliminando el campo
  Future<bool> eliminarContacto({required bool esPrincipal}) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      String campoDestino = esPrincipal ? 'contactoPrincipal' : 'contactoSecundario';

      // FieldValue.delete() elimina ese campo específico dentro del documento sin borrar al usuario
      await _db.collection('usuarios').doc(user.uid).update({
        campoDestino: FieldValue.delete(),
      });

      debugPrint("Contacto eliminado exitosamente");
      return true;
    } catch (e) {
      debugPrint("Error al eliminar contacto: $e");
      return false;
    }
  }
}