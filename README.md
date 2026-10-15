<div align="center">

# 🦁 BraveControl

### Debloat de Brave en un clic — desde una GUI con tema oscuro

*Apaga IA, recompensas, VPN, Tor, telemetría y más… sin pelearte con el Editor del Registro.*

<br>

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Brave](https://img.shields.io/badge/Brave-19_interruptores-FB542B?style=for-the-badge&logo=brave&logoColor=white)
[![Licencia MIT](https://img.shields.io/badge/Licencia-MIT-3DA639?style=for-the-badge)](<LICENSE.txt>)

</div>

---

## ⚡ Ejecutar desde cualquier equipo

Abre **PowerShell** y pega:

```powershell
irm https://raw.githubusercontent.com/xdoofy92/BraveControl/main/BraveControl.ps1 | iex
```

Descarga el script de este repositorio, pide permisos de administrador (UAC) y abre la interfaz. No instala nada. Revisa antes el [código](<BraveControl.ps1>) si quieres saber qué ejecutas.

---

## ✨ ¿Qué es?

**BraveControl** es una herramienta gráfica de PowerShell que gestiona las **políticas de empresa de Brave** desde el registro de Windows. En lugar de bucear por `regedit`, te presenta una lista de interruptores: **todo viene encendido** (como en una instalación normal) y tú **apagas lo que quieras desactivar**.

> 💡 **Gratuito y de código abierto**, bajo la [licencia MIT](<LICENSE.txt>). Puedes revisar el [código completo](<BraveControl.ps1>), modificarlo y compartirlo. Desarrollado por [Daniel Rodriguez](https://xdoofy92.com/) · [DProjects](https://dprojects.org/).

---

## 🎛️ Cómo funciona

La app refleja el **estado real** de cada característica con un interruptor estilo switch:

| Estado | Aspecto | Significado |
|:------:|:--------|:------------|
| 🟢 **Encendido** | verde, texto normal | La característica está **activa** (valor por defecto del navegador) |
| ⚪ **Apagado** | gris, texto atenuado | Se **desactivará** al pulsar **Aplicar** (escribe la política en el registro) |

El contador de la cabecera (**`0 / 19 a Desactivar`**) te dice cuántas tienes marcadas para apagar. Al pulsar **Aplicar**, los cambios se guardan en:

```
HKLM:\SOFTWARE\Policies\BraveSoftware\Brave
```

> 🔁 Volver a **encender** un interruptor + **Aplicar** elimina la política → la característica regresa a su estado original.

### 🔘 Botones

| Botón | Acción |
|:------|:-------|
| **Activar todo** | Enciende todos los interruptores (estado por defecto) |
| **Desact. todo** | Los apaga todos → *debloat completo* en un clic |
| **Default** | Elimina las políticas (pide confirmación) → Brave deja de salir *administrado por tu organización*. Si hay políticas que no creó la app, deja elegir entre borrarlas todas o solo las propias |
| **Aplicar** | Guarda los cambios *(reinicia Brave para que surtan efecto)* |

---

## 🧩 Características que puedes desactivar

> 19 interruptores, todos encendidos por defecto.

### 🦁 Funciones propias de Brave

| Característica | Qué apaga | Clave de registro |
|:--------------|:----------|:------------------|
| 🤖 Leo (AI Chat) | Asistente de IA Leo integrado | `BraveAIChatEnabled` |
| 📰 Noticias | Feed de noticias Brave News | `BraveNewsDisabled` |
| 🎵 Reproductor | Función Playlist | `BravePlaylistEnabled` |
| 📖 Speedreader | Modo de lectura rápida (Speedreader) | `BraveSpeedreaderEnabled` |
| 🕰️ Wayback Machine | Integración con Wayback Machine | `BraveWaybackMachineEnabled` |
| 💰 Brave Rewards | Brave Rewards y los anuncios | `BraveRewardsDisabled` |
| 🪙 Wallet + Web3 | Brave Wallet y funciones Web3 | `BraveWalletDisabled` |
| 📹 Videollamada | Brave Talk | `BraveTalkDisabled` |
| 🧅 Tor | Ventanas privadas con Tor | `TorDisabled` |
| 🛡️ VPN | Brave VPN | `BraveVPNDisabled` |

### 📡 Telemetría de Brave

| Característica | Qué apaga | Clave de registro |
|:--------------|:----------|:------------------|
| 📊 P3A (análisis de producto) | Telemetría anónima de producto | `BraveP3AEnabled` |
| 📡 Ping de uso diario | Ping diario de estadísticas de uso | `BraveStatsPingEnabled` |
| 🔎 Web Discovery Project | Envío de datos de Web Discovery | `BraveWebDiscoveryEnabled` |

### 🕵️ Privacidad genérica (políticas Chromium que Brave respeta)

| Característica | Qué apaga | Clave de registro |
|:--------------|:----------|:------------------|
| 🔎 Sugerencias de búsqueda | Sugerencias al escribir (envían datos al buscador) | `SearchSuggestEnabled` |
| 🔑 Gestor de contraseñas | Guardado y autocompletado de contraseñas | `PasswordManagerEnabled` |
| 🏠 Autocompletar direcciones | Autocompletado de direcciones y contacto | `AutofillAddressEnabled` |
| 💳 Autocompletar tarjetas | Guardado y autocompletado de tarjetas | `AutofillCreditCardEnabled` |
| 🌙 Modo en segundo plano | Brave sigue ejecutándose al cerrar la ventana | `BackgroundModeEnabled` |
| 🌐 Predicción de red (prefetch) | Precarga de páginas y resolución DNS anticipada | `NetworkPredictionOptions` |

---

## 🚀 Obtención y uso

### Canales oficiales

Descarga el [script](<BraveControl.ps1>) desde este repositorio o clona el proyecto. El código es visible y puedes revisarlo antes de ejecutarlo. Consulta también el [sitio oficial](https://dprojects.org/) y la web del [autor](https://xdoofy92.com/). No requiere instalador.

```powershell
git clone https://github.com/xdoofy92/BraveControl.git
cd BraveControl
```

### Revisar y ejecutar localmente

Revisa el [script](<BraveControl.ps1>) con un editor de texto. Después abre PowerShell en la carpeta donde lo guardaste y ejecuta:

```powershell
.\BraveControl.ps1
```

La licencia MIT permite usar, modificar y redistribuir el script, conservando el aviso de copyright y la licencia en las copias o partes sustanciales del software.

### Pasos típicos

1. **Apaga** los interruptores de lo que no quieras (o pulsa **Desact. todo**).
2. Pulsa **Aplicar**.
3. **Reinicia Brave** para que los cambios surtan efecto.

<details>
<summary>🛠️ ¿Error de "ejecución de scripts deshabilitada"?</summary>

<br>

Aplica estas opciones únicamente a scripts que hayas revisado y en los que confíes. Respeta las políticas de seguridad de tu organización.

**Permanente (usuario actual):**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Temporal (solo esta vez):**
```powershell
powershell -ExecutionPolicy Bypass -File .\BraveControl.ps1
```

`RemoteSigned` es más segura que `Unrestricted`: permite scripts locales y scripts firmados de internet.

</details>

---

## ⚙️ Bajo el capó

- **Auto-elevación**: solicita privilegios de administrador automáticamente (necesarios para escribir en `HKLM`).
- **Interfaz**: Windows Forms con tema oscuro e interruptores dibujados a mano (anti-aliasing).
- **Tipo de valores**: todas las políticas se aplican como `DWord` (32 bits).
- **Reversible**: volver a encender y aplicar **elimina** la política; cuando no queda ninguna se borra también la clave, sin dejar residuos.
- **Avisos**: pide confirmación antes de **Default**, antes de apagar en bloque las opciones sensibles y al cerrar con cambios sin aplicar.
- **Errores reales**: si una escritura en el registro falla, se cuenta y se muestra en la barra de estado.

---

## 🛡️ Seguridad y privacidad

- Solo toca claves bajo `HKLM\SOFTWARE\Policies\BraveSoftware\Brave`. **No** modifica otros navegadores ni el sistema.
- **Default** no borra a ciegas: si detecta políticas que no creó la app (otra herramienta o tu organización) te deja conservarlas.
- **No** recopila ni transmite ningún dato tuyo.
- ⚠️ La app solicita permisos de **administrador**. Verifica la procedencia y revisa el código de cualquier copia, incluidas las modificadas, antes de ejecutarla.
- Si se ejecuta sin archivo local, la auto-elevación puede descargar el script del repositorio. Prefiere descargarlo, revisarlo y ejecutarlo localmente para saber qué código estás ejecutando.

---

## 🤝 Colaborar

¿Una política nueva, un bug, una mejora de UI? Envía tus sugerencias mediante los canales de [DProjects](https://dprojects.org/) o del [autor](https://xdoofy92.com/).

Puedes abrir una incidencia, crear un fork y proponer cambios mediante un pull request. El código está disponible para estudiar, modificar y redistribuir bajo MIT, sin solicitar autorización adicional. Conserva el aviso de copyright y la licencia en las copias o partes sustanciales del software.

---

## 📄 Licencia y distribución

**Daniel Rodriguez (DProjects)** es el autor. Software **gratuito y de código abierto**, bajo la [licencia MIT](<LICENSE.txt>):

- Puedes usarlo con fines personales, profesionales y comerciales.
- Puedes examinar, copiar, modificar, combinar, publicar, distribuir, sublicenciar y vender copias del software.
- Debes conservar el aviso de copyright y el texto de la licencia en todas las copias o partes sustanciales del software.
- Se proporciona **«tal cual», sin garantías**, según los términos de MIT.
- Estos permisos incluyen el script y su código fuente; no se limitan a un instalador ni exigen distribuirlo sin modificaciones.
- Los componentes y marcas de terceros conservan sus propias licencias y derechos.

---

## 📝 Notas

- 🔄 **Reinicia Brave** tras aplicar para ver los cambios.
- 🔒 Las políticas **persisten** hasta que las elimines (encender + Aplicar, o el botón **Default**).
- 🧪 Los nombres de política pueden variar entre versiones de Brave.

---

<div align="center">

**[Licencia MIT](<LICENSE.txt>)** · Hecho por **[Daniel Rodriguez](https://xdoofy92.com/)** · **[DProjects](https://dprojects.org/)**

🔗 [Políticas de Brave (Group Policy)](https://github.com/brave/brave-browser/wiki/Group-Policy) · [Repo de Brave](https://github.com/brave/brave-browser)

⭐ *Si te resulta útil, deja una estrella en el repositorio* ⭐

</div>
