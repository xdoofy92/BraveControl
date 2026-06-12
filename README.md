# BraveControl

![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue?logo=powershell)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey)

Herramienta gráfica de PowerShell para gestionar políticas del navegador Brave a través del registro de Windows. Permite deshabilitar características no deseadas de Brave de forma sencilla y permanente.

## 🎯 Características

- **Interfaz gráfica intuitiva** con tema oscuro moderno
- **13 características** para deshabilitar en Brave
- **Todos los interruptores activados por defecto**: apagas el de lo que quieras desactivar
- **Acciones rápidas**: "Activar todo" y "Desactivar todo"
- **Ejecución automática como administrador** cuando es necesario
- **Feedback visual** con barra de estado
- **Ejecución directa desde GitHub** sin necesidad de descargar

## � Ejecución

### Opción Recomendada - Ejecución Directa desde GitHub (Requiere Administrador)

Esta es la forma más rápida de ejecutar BraveControl. Abre PowerShell como administrador y ejecuta:

```powershell
irm https://raw.githubusercontent.com/xdoofy92/BraveControl/main/BraveControl.ps1 | iex
```

> **📃 Nota**: Al ejecutar desde GitHub, el script se descargará y ejecutará automáticamente.

### Opción Alternativa - Ejecución Local

Si prefieres descargar el script primero:

```powershell
git clone https://github.com/xdoofy92/BraveControl.git
cd BraveControl
.\BraveControl.ps1
```

### Solución de Problemas

Si obtienes un error de "ejecución de scripts deshabilitada", tienes dos opciones:

**Opción 1 - Cambiar política de ejecución (permanente para el usuario actual):**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Opción 2 - Ejecución temporal con Bypass:**
```powershell
powershell -ExecutionPolicy Bypass -File .\BraveControl.ps1
```

> **⚠️ Nota**: La política `RemoteSigned` permite ejecutar scripts locales y scripts descargados de internet que estén firmados. Es más segura que `Unrestricted`.

## 🔐 Políticas Disponibles

| Política | Descripción |
|----------|-------------|
| Leo (AI Chat) | Deshabilita el asistente de IA integrado |
| Noticias | Deshabilita el feed de noticias de Brave |
| Lista de reproducción | Deshabilita la función de playlist |
| Recompensas + Brave Ads | Deshabilita Brave Rewards y anuncios |
| Lector rápido | Deshabilita el modo lectura |
| P3A (análisis de producto) | Deshabilita la telemetría de producto |
| Ping de uso diario | Deshabilita los pings de estadísticas |
| Videollamada | Deshabilita Brave Talk |
| Tor | Deshabilita el modo Tor |
| VPN | Deshabilita Brave VPN |
| Monedero + Web3 | Deshabilita Brave Wallet y funciones Web3 |
| Wayback Machine | Deshabilita la integración con Wayback Machine |
| Web Discovery | Deshabilita Web Discovery |

## 📖 Uso

> Todos los interruptores vienen **activados** (estado por defecto del navegador). Apagas el de lo que quieras desactivar.

### Desactivar características

1. **Apaga** el interruptor de las características que quieras deshabilitar
2. Haz clic en el botón **"Aplicar"**
3. Reinicia el navegador Brave para que los cambios surtan efecto

### Reactivar Características

1. **Enciende** de nuevo el interruptor de lo que quieras volver a activar
2. Haz clic en el botón **"Aplicar"** (elimina la política del registro)
3. Reinicia el navegador Brave para que los cambios surtan efecto

### Activar / Desactivar todo

- **"Activar todo"**: enciende todos los interruptores (estado por defecto)
- **"Desactivar todo"**: los apaga todos (debloat completo); luego pulsa **"Aplicar"**

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
