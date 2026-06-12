<div align="center">

# 🦁 BraveControl

### Debloat de Brave en un clic — desde una GUI con tema oscuro

*Apaga IA, recompensas, VPN, Tor, telemetría y más… sin pelearte con el Editor del Registro.*

<br>

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Brave](https://img.shields.io/badge/Brave-13_interruptores-FB542B?style=for-the-badge&logo=brave&logoColor=white)
![License](https://img.shields.io/badge/Licencia-MIT-3DA639?style=for-the-badge)

</div>

---

## ✨ ¿Qué es?

**BraveControl** es una herramienta gráfica de PowerShell que gestiona las **políticas de empresa de Brave** desde el registro de Windows. En lugar de bucear por `regedit`, te presenta una lista de interruptores: **todo viene encendido** (como en una instalación normal) y tú **apagas lo que quieras desactivar**.

```powershell
irm https://raw.githubusercontent.com/xdoofy92/BraveControl/main/BraveControl.ps1 | iex
```

> 💡 Pégalo en una terminal **PowerShell como administrador** y listo. Se descarga, pide elevación y abre la ventana.

---

## 🎛️ Cómo funciona

La app refleja el **estado real** de cada característica con un interruptor estilo switch:

| Estado | Aspecto | Significado |
|:------:|:--------|:------------|
| 🟢 **Encendido** | verde, texto normal | La característica está **activa** (valor por defecto del navegador) |
| ⚪ **Apagado** | gris, texto atenuado | Se **desactivará** al pulsar **Aplicar** (escribe la política en el registro) |

El contador de la cabecera (**`0 / 13 a Desactivar`**) te dice cuántas tienes marcadas para apagar. Al pulsar **Aplicar**, los cambios se guardan en:

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

> 13 interruptores, todos encendidos por defecto.

| Característica | Qué apaga | Clave de registro |
|:--------------|:----------|:------------------|
| 🤖 Leo (AI Chat) | Asistente de IA Leo integrado | `BraveAIChatEnabled` |
| 📰 Noticias | Feed de noticias Brave News | `BraveNewsDisabled` |
| 🎵 Lista de reproducción | Función Playlist | `BravePlaylistEnabled` |
| 📖 Lector rápido | Modo de lectura rápida (Speedreader) | `BraveSpeedreaderEnabled` |
| 🕰️ Wayback Machine | Integración con Wayback Machine | `BraveWaybackMachineEnabled` |
| 📊 P3A | Telemetría anónima de producto | `BraveP3AEnabled` |
| 📡 Ping de uso diario | Ping diario de estadísticas de uso | `BraveStatsPingEnabled` |
| 🔎 Web Discovery | Envío de datos de Web Discovery | `BraveWebDiscoveryEnabled` |
| 💰 Recompensas + Brave Ads | Brave Rewards y los anuncios | `BraveRewardsDisabled` |
| 🪙 Monedero + Web3 | Brave Wallet y funciones Web3 | `BraveWalletDisabled` |
| 📹 Videollamada | Brave Talk | `BraveTalkDisabled` |
| 🧅 Tor | Ventanas privadas con Tor | `TorDisabled` |
| 🛡️ VPN | Brave VPN | `BraveVPNDisabled` |

---

## 🚀 Instalación y uso

### Opción A — Directo desde GitHub *(recomendada)*

```powershell
irm https://raw.githubusercontent.com/xdoofy92/BraveControl/main/BraveControl.ps1 | iex
```

### Opción B — Local

```powershell
git clone https://github.com/xdoofy92/BraveControl.git
cd BraveControl
.\BraveControl.ps1
```

### Pasos típicos

1. **Apaga** los interruptores de lo que no quieras (o pulsa **Desact. todo**).
2. Pulsa **Aplicar**.
3. **Reinicia Brave** para que los cambios surtan efecto.

<details>
<summary>🛠️ ¿Error de "ejecución de scripts deshabilitada"?</summary>

<br>

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
- ⚠️ La ejecución `irm … | iex` descarga y ejecuta el script **como administrador**. Si prefieres revisarlo antes, usa la **Opción B** y léelo.

---

## 🤝 Contribuir

¿Una política nueva, un bug, una mejora de UI? ¡Bienvenido!

1. Haz *fork* del repositorio
2. Crea una rama: `git checkout -b feature/mi-mejora`
3. *Commit*: `git commit -m 'Añade mi mejora'`
4. *Push*: `git push origin feature/mi-mejora`
5. Abre un *Pull Request*

---

## 📝 Notas

- 🔄 **Reinicia Brave** tras aplicar para ver los cambios.
- 🔒 Las políticas **persisten** hasta que las elimines (encender + Aplicar).
- 🧪 Los nombres de política pueden variar entre versiones de Brave.

---

<div align="center">

**Licencia MIT** · Hecho por **[xdoofy92](https://github.com/xdoofy92)**

🔗 [Políticas de Brave (Group Policy)](https://github.com/brave/brave-browser/wiki/Group-Policy) · [Repo de Brave](https://github.com/brave/brave-browser)

⭐ *Si te resulta útil, deja una estrella en el repositorio* ⭐

</div>
