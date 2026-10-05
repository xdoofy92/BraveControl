<div align="center">

# 🦁 BraveControl

### Debloat de Brave en un clic — desde una GUI con tema oscuro

*Apaga IA, recompensas, VPN, Tor, telemetría y más… sin pelearte con el Editor del Registro.*

<br>

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Brave](https://img.shields.io/badge/Brave-19_interruptores-FB542B?style=for-the-badge&logo=brave&logoColor=white)
[![Licencia propietaria](https://img.shields.io/badge/Licencia-Propietaria-3DA639?style=for-the-badge)](<LICENSE.txt>)

</div>

---

## ✨ ¿Qué es?

**BraveControl** es una herramienta gráfica de PowerShell que gestiona las **políticas de empresa de Brave** desde el registro de Windows. En lugar de bucear por `regedit`, te presenta una lista de interruptores: **todo viene encendido** (como en una instalación normal) y tú **apagas lo que quieras desactivar**.

> 💡 Consulta la disponibilidad y las vías de obtención autorizadas en [DProjects](https://dprojects.org/) o contacta con [Daniel Rodriguez](https://xdoofy92.com/). Software propietario, de código cerrado y uso gratuito, también profesional y empresarial, según la [licencia](<LICENSE.txt>).

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
| **Actualizar** | Relee el registro y refresca el estado actual |
| **Aplicar** | Guarda los cambios *(reinicia Brave para que surtan efecto)* |

---

## 🧩 Características que puedes desactivar

> 19 interruptores, todos encendidos por defecto.

### 🦁 Funciones propias de Brave

| Característica | Qué apaga | Clave de registro |
|:--------------|:----------|:------------------|
| 🤖 Leo (AI Chat) | Asistente de IA Leo integrado | `BraveAIChatEnabled` |
| 📰 Noticias | Feed de noticias Brave News | `BraveNewsDisabled` |
| 🎵 Lista de reproducción | Función Playlist | `BravePlaylistEnabled` |
| 📖 Lector rápido | Modo de lectura rápida (Speedreader) | `BraveSpeedreaderEnabled` |
| 🕰️ Wayback Machine | Integración con Wayback Machine | `BraveWaybackMachineEnabled` |
| 💰 Recompensas + Brave Ads | Brave Rewards y los anuncios | `BraveRewardsDisabled` |
| 🪙 Monedero + Web3 | Brave Wallet y funciones Web3 | `BraveWalletDisabled` |
| 📹 Videollamada | Brave Talk | `BraveTalkDisabled` |
| 🧅 Tor | Ventanas privadas con Tor | `TorDisabled` |
| 🛡️ VPN | Brave VPN | `BraveVPNDisabled` |

### 📡 Telemetría de Brave

| Característica | Qué apaga | Clave de registro |
|:--------------|:----------|:------------------|
| 📊 P3A | Telemetría anónima de producto | `BraveP3AEnabled` |
| 📡 Ping de uso diario | Ping diario de estadísticas de uso | `BraveStatsPingEnabled` |
| 🔎 Web Discovery | Envío de datos de Web Discovery | `BraveWebDiscoveryEnabled` |

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

Consulta [DProjects](https://dprojects.org/) para conocer las copias oficiales disponibles y sus instrucciones, o solicita información al [autor](https://xdoofy92.com/). Este repositorio contiene un script, no un instalador; esta documentación no afirma que exista un instalador oficial publicado.

### Uso local — solo con una copia autorizada

Solo si el titular te ha proporcionado o autorizado expresamente una copia local del [script](<BraveControl.ps1>), abre PowerShell en la carpeta donde la guardaste y ejecuta:

```powershell
.\BraveControl.ps1
```

Esta indicación no concede permiso para obtener, modificar ni redistribuir el código. El script no es un instalador y no está incluido en el permiso general de redistribución.

### Pasos típicos

1. **Apaga** los interruptores de lo que no quieras (o pulsa **Desact. todo**).
2. Pulsa **Aplicar**.
3. **Reinicia Brave** para que los cambios surtan efecto.

<details>
<summary>🛠️ ¿Error de "ejecución de scripts deshabilitada"?</summary>

<br>

Las siguientes opciones solo se aplican a la copia local proporcionada o expresamente autorizada por el titular. Respeta las políticas de seguridad de tu organización.

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
- **Reversible**: desmarcar y aplicar **elimina** la clave; no deja residuos.

---

## 🛡️ Seguridad y privacidad

- Solo toca claves bajo `HKLM\SOFTWARE\Policies\BraveSoftware\Brave`. **No** modifica otros navegadores ni el sistema.
- **No** recopila ni transmite ningún dato tuyo.
- ⚠️ Usa únicamente copias proporcionadas o autorizadas por el titular. La app solicita permisos de **administrador**; confirma su procedencia antes de ejecutarla.
- La implementación conserva una ruta de descarga remota para la auto-elevación cuando se ejecuta sin archivo local. No se documenta como vía pública de obtención ni concede permiso para distribuir scripts.

---

## 🤝 Sugerencias y desarrollo autorizado

¿Una política nueva, un bug, una mejora de UI? Envía tus sugerencias mediante los canales de [DProjects](https://dprojects.org/) o del [autor](https://xdoofy92.com/).

El desarrollo y cualquier instrucción técnica para modificar el proyecto se reservan al titular y a colaboradores **expresamente autorizados por escrito**, dentro del alcance de ese permiso. La visibilidad del repositorio no constituye una concesión pública para modificar, copiar para terceros ni redistribuir su código.

---

## 📄 Licencia y distribución

**Daniel Rodriguez (DProjects)** es el titular y desarrollador. Software **propietario y de código cerrado**, bajo la [licencia propietaria de uso gratuito](<LICENSE.txt>):

- Uso gratuito de copias oficiales, también **profesional y empresarial**.
- No se permite **modificar, vender ni revender** el programa sin autorización previa y por escrito del titular. Ajustar preferencias con las funciones de la app no es modificar el programa.
- Cualquiera puede redistribuir **gratis únicamente el instalador oficial publicado por DProjects**, completo e intacto, conservando autoría, licencia y avisos de terceros, indicando [la web oficial](https://dprojects.org/) y cumpliendo las demás condiciones de la licencia. No se permite cobrar ni reempaquetarlo.
- Ese permiso **no incluye scripts sueltos ni código fuente**; requieren autorización previa y por escrito. Siempre puedes compartir el enlace a la web oficial. No se afirma aquí que exista un instalador publicado.
- Los componentes y marcas de terceros conservan sus licencias, avisos y derechos. La licencia no restringe los permisos propios de esos componentes.
- Estos términos se aplican a las versiones distribuidas bajo ellos: **no revocan retroactivamente** derechos concedidos legítimamente sobre versiones anteriores bajo otras licencias.

---

## 📝 Notas

- 🔄 **Reinicia Brave** tras aplicar para ver los cambios.
- 🔒 Las políticas **persisten** hasta que las elimines (encender + Aplicar).
- 🧪 Los nombres de política pueden variar entre versiones de Brave.

---

<div align="center">

**[Licencia propietaria de uso gratuito](<LICENSE.txt>)** · Hecho por **[Daniel Rodriguez](https://xdoofy92.com/)** · **[DProjects](https://dprojects.org/)**

🔗 [Políticas de Brave (Group Policy)](https://github.com/brave/brave-browser/wiki/Group-Policy) · [Repo de Brave](https://github.com/brave/brave-browser)

⭐ *Si te resulta útil, deja una estrella en el repositorio* ⭐

</div>
