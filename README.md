# BraveOrigins

![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue?logo=powershell)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey)

Herramienta gráfica de PowerShell para gestionar políticas del navegador Brave a través del registro de Windows. Permite deshabilitar características no deseadas de Brave de forma sencilla y permanente.

## 🎯 Características

- **Interfaz gráfica intuitiva** con tema oscuro moderno
- **14 políticas disponibles** para deshabilitar características de Brave
- **Selección rápida** con opción "Seleccionar todo"
- **Ejecución automática como administrador** cuando es necesario
- **Feedback visual** con barra de estado
- **Ejecución directa desde GitHub** sin necesidad de descargar

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

### Configurar Política de Ejecución

Si obtienes un error de "ejecución de scripts deshabilitada", tienes dos opciones:

**Opción 1 - Cambiar política de ejecución (permanente para el usuario actual):**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Opción 2 - Ejecución temporal con Bypass:**
```powershell
powershell -ExecutionPolicy Bypass -File .\BraveOrigins.ps1
```

> **⚠️ Nota**: La política `RemoteSigned` permite ejecutar scripts locales y scripts descargados de internet que estén firmados. Es más segura que `Unrestricted`.

### Pasos de Instalación

**Opción 1 - Clonar el repositorio:**
```powershell
git clone https://github.com/xdoofy92/BraveOrigins.git
cd BraveOrigins
```

Luego ejecuta el script:
```powershell
.\BraveOrigins.ps1
```

**Opción 2 - Ejecución directa desde GitHub (sin clonar):**
```powershell
irm https://raw.githubusercontent.com/xdoofy92/BraveOrigins/main/BraveOrigins.ps1 | iex
```

> **⚠️ Nota**: Al ejecutar desde GitHub, el script se descargará y ejecutará automáticamente. Asegúrate de confiar en el código antes de ejecutarlo de esta manera.

> **⚠️ Importante**: Debes usar `.\` antes del nombre del script. PowerShell no ejecuta scripts del directorio actual por defecto por seguridad. Si solo escribes `BraveOrigins.ps1` obtendrás un error de "comando no reconocido".

El script solicitará elevación a administrador si no se está ejecutando con esos privilegios.

## 📖 Uso

### Aplicar Políticas

1. Selecciona las características que deseas deshabilitar marcando las casillas
2. Haz clic en el botón **"Aplicar"**
3. Reinicia el navegador Brave para que los cambios surtan efecto

### Reactivar Características

1. Desmarca las casillas de las características que deseas reactivar
2. Haz clic en el botón **"Aplicar"**
3. Reinicia el navegador Brave para que los cambios surtan efecto

### Seleccionar Todo

1. Haz clic en el botón **"Sel. todo"** para marcar todas las casillas rápidamente
2. Luego haz clic en **"Aplicar"** para desactivar todas las características

### Actualizar Estado

1. Haz clic en el botón **"Actualizar"** para refrescar el estado actual de las políticas según el registro

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
- **Gestión de políticas**: Funciones para aplicar y eliminar políticas del registro
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
