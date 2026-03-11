# SAM - Security Assistance Mobile (Remastered)

**SAM** es una aplicación de seguridad inteligente diseñada para la prevención de accidentes y asistencia vial. Este proyecto es una reingeniería completa enfocada en la experiencia de usuario (UX), arquitectura limpia y optimización de recursos.

## Características Implementadas (UI/UX)
* **Onboarding Interactivo:** Sistema de bienvenida con animaciones suaves (`AnimatedSwitcher`) y temporizador automático para guiar al usuario.
* **Autenticación Robusta:** Módulos de **Login y Registro** con validación de formularios en tiempo real y gestión segura de controladores (`dispose`).
* **Dashboard Moderno:** Panel de control principal con diseño de **Bottom Sheet** deslizante y navegación por pestañas para acceso rápido.
* **Gestión de Emergencia:** Interfaz para el registro de datos médicos críticos (tipo de sangre, alergias) y contactos de confianza.

## Tecnologías y Optimización
* **Flutter & Dart:** Framework principal.
* **Google Fonts:** Tipografía profesional (Montserrat y Roboto) para mejor legibilidad.
* **Gestión de Memoria:** Uso de `const` widgets y liberación de recursos en el ciclo de vida de la app.
* **Diseño Responsivo:** Interfaces adaptables a diferentes tamaños de pantalla.

## Roadmap (Próximos pasos)
Actualmente se está trabajando en la integración de la lógica de sensores IoT (Acelerómetro/Giroscopio) migrada de la versión prototipo anterior para la detección automática de caídas.

---
*Proyecto desarrollado por Alan Paul Santiago Flores.*