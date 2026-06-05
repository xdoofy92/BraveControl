# BraveOrigins

![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue?logo=powershell)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey)

Herramienta gráfica de PowerShell para gestionar políticas del navegador Brave a través del registro de Windows. Permite deshabilitar características no deseadas de Brave de forma sencilla y permanente.

## 🎯 Características

- **Interfaz gráfica intuitiva** con tema oscuro moderno
- **14 políticas disponibles** para deshabilitar características de Brave
- **Exportar/Importar configuraciones** en formato JSON
- **Selección rápida** con opción "Seleccionar todo"
- **Reset completo** de todas las políticas aplicadas
- **Ejecución automática como administrador** cuando es necesario
- **Feedback visual** con barra de estado

## 📋 Políticas Disponibles

| Política | Descripción |
|----------|-------------|
| Leo (AI Chat) | Deshabilita el asistente de IA integrado |
| Noticias | Deshabilita el feed de noticias de Brave |
| Lista de reproducción | Deshabilita la función de playlist |
| Recompensas + Brave Ads | Deshabilita Brave Rewards y anuncios |
| Lector rápido | Deshabilita el modo lectura |
| P3A (análisis de producto) | Deshabilita la telemetría de producto |
| Ping de uso diario | Deshabilita los pings de estadísticas |
| Hablar (Talk) | Deshabilita Brave Talk |
| Tor | Deshabilita el modo Tor |
| VPN | Deshabilita Brave VPN |
| Monedero + Web3 | Deshabilita Brave Wallet y funciones Web3 |
| Wayback Machine | Deshabilita la integración con Wayback Machine |
| Web Discovery | Deshabilita Web Discovery |
| Alias de correo (Nightly) | Deshabilita los alias de correo (versión Nightly) |

## 🚀 Instalación

### Requisitos Previos

- Windows 10 o superior
- PowerShell 5.1 o superior
- Privilegios de administrador
- Navegador Brave instalado

### Pasos de Instalación

1. Clona el repositorio:
```powershell
git clone https://github.com/xdoofy92/BraveOrigins.git
cd BraveOrigins
```

2. Ejecuta el script:
```powershell
.\BraveOrigins.ps1
```

El script solicitará elevación a administrador si no se está ejecutando con esos privilegios.

## 📖 Uso

### Aplicar Políticas

1. Selecciona las características que deseas deshabilitar marcando las casillas
2. Haz clic en el botón **"Aplicar"**
3. Reinicia el navegador Brave para que los cambios surtan efecto

### Exportar Configuración

1. Configura las políticas deseadas
2. Haz clic en **"Exportar"**
3. Guarda el archivo JSON en tu ubicación preferida

### Importar Configuración

1. Haz clic en **"Importar"**
2. Selecciona un archivo JSON previamente exportado
3. Las casillas se actualizarán automáticamente

### Resetear Políticas

1. Haz clic en **"Resetear"**
2. Confirma la acción en el diálogo de advertencia
3. Todas las políticas serán eliminadas del registro

## ⚙️ Detalles Técnicos

### Registro de Windows

El script modifica las políticas de Brave en la siguiente ruta del registro:

```
HKLM:\SOFTWARE\Policies\BraveSoftware\Brave
```

### Tipos de Políticas

Todas las políticas se aplican como valores `DWord` (32-bit) en el registro de Windows.

### Estructura del Script

- **Auto-elevación**: Solicita privilegios de administrador automáticamente
- **Interfaz gráfica**: Utiliza Windows Forms con tema oscuro personalizado
- **Gestión de políticas**: Funciones para aplicar, exportar, importar y resetear
- **Validación**: Manejo de errores y feedback al usuario

## 🛡️ Seguridad

- El script solo modifica claves de registro específicas de Brave
- No realiza cambios en otros navegadores o aplicaciones
- Requiere confirmación para acciones destructivas (reset)
- No recopila ni transmite datos personales

## 🤝 Contribuir

Las contribuciones son bienvenidas. Puedes:

1. Fork el repositorio
2. Crear una rama para tu feature (`git checkout -b feature/NuevaCaracteristica`)
3. Commit tus cambios (`git commit -m 'Agrega nueva característica'`)
4. Push a la rama (`git push origin feature/NuevaCaracteristica`)
5. Abrir un Pull Request

## 📝 Notas Importantes

- **Reinicio requerido**: Brave debe reiniciarse después de aplicar políticas
- **Permanencia**: Las políticas persisten hasta que se eliminen manualmente
- **Compatibilidad**: Las políticas pueden variar entre versiones de Brave
- **Backup**: Se recomienda exportar la configuración antes de hacer cambios

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más detalles.

## 🔗 Enlaces

- [Repositorio de Brave](https://github.com/brave/brave-browser)
- [Documentación de políticas de Brave](https://github.com/brave/brave-browser/wiki/Group-Policy)

## 👤 Autor

**xdoofy92** - [GitHub](https://github.com/xdoofy92)

## ⭐ Si te gusta este proyecto

Considera darle una estrella ⭐ al repositorio para apoyar su desarrollo.
