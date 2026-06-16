# BraveControl - Gestor grafico de politicas de Brave via registro de Windows
# Autor: Daniel Rodriguez | https://xdoofy92.com

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# ─── Auto-elevacion a administrador ──────────────────────────────────────────
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    if (-not $PSCommandPath) {
        # Ejecucion remota (irm | iex): descargar y relanzar como admin
        $url = "https://raw.githubusercontent.com/xdoofy92/BraveControl/main/BraveControl.ps1"
        $scriptContent = Invoke-RestMethod -Uri $url
        $tempFile = Join-Path $env:TEMP "BraveControl_$([guid]::NewGuid().ToString('N')).ps1"
        $scriptContent | Out-File $tempFile -Encoding UTF8
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempFile`""
        exit
    } else {
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        exit
    }
}

Add-Type -AssemblyName System.Windows.Forms, System.Drawing
[Windows.Forms.Application]::EnableVisualStyles()

# ─── Identidad de la app ─────────────────────────────────────────────────────
$REG_PATH  = "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave"
$APP_TITLE = "BraveControl - dprojects.org"
$APP_NAME  = "BraveControl"
$APP_SUB   = "Politicas de Brave via registro"
$BROWSER   = "Brave"

# ─── Paleta (compartida con EdgeControl, solo cambia el acento) ───────────────
$BG       = [Drawing.Color]::FromArgb(17, 17, 20)
$CARD     = [Drawing.Color]::FromArgb(26, 26, 30)
$CARD2    = [Drawing.Color]::FromArgb(32, 32, 37)
$HOVER    = [Drawing.Color]::FromArgb(40, 40, 46)
$GRPBG    = [Drawing.Color]::FromArgb(22, 22, 26)
$BORDER   = [Drawing.Color]::FromArgb(46, 46, 54)
$FG       = [Drawing.Color]::FromArgb(232, 232, 236)
$MUTED    = [Drawing.Color]::FromArgb(140, 140, 150)
$GREEN    = [Drawing.Color]::FromArgb(86, 196, 138)
$RED      = [Drawing.Color]::FromArgb(232, 100, 100)
$TOG_OFF  = [Drawing.Color]::FromArgb(62, 62, 72)
$ACCENT   = [Drawing.Color]::FromArgb(251, 84, 43)     # Naranja Brave
$ACC_HOV  = [Drawing.Color]::FromArgb(255, 104, 63)
$ACC_DWN  = [Drawing.Color]::FromArgb(214, 66, 30)

# ─── Tipografias ─────────────────────────────────────────────────────────────
$FONT_TITLE = [Drawing.Font]::new("Segoe UI", 15, [Drawing.FontStyle]::Bold)
$FONT_SUB   = [Drawing.Font]::new("Segoe UI Semibold", 8.5)
$FONT_BODY  = [Drawing.Font]::new("Segoe UI", 9.5)
$FONT_DESC  = [Drawing.Font]::new("Segoe UI", 7.75)
$FONT_BTN   = [Drawing.Font]::new("Segoe UI Semibold", 9)
$FONT_CNT   = [Drawing.Font]::new("Segoe UI", 9, [Drawing.FontStyle]::Bold)
$FONT_STAT  = [Drawing.Font]::new("Segoe UI", 7.75)

# ─── Geometria ───────────────────────────────────────────────────────────────
$W_FORM = 462; $H_FORM = 632
$W_PANEL = 418
$W_ROW = 392; $X_ROW = 6; $H_ROW = 46
$TOG_W = 40; $TOG_H = 22
$X_TOG = $W_ROW - $TOG_W - 12
$X_TXT = 14
$W_TXT = $X_TOG - $X_TXT - 10

# Nota: NO creamos $REG_PATH al arrancar. La clave se crea solo cuando se aplica
# alguna politica (ver Set-Policies). Asi, tras pulsar "Default" la clave queda
# realmente eliminada y Brave no muestra "Administrado por su organizacion".

# ─── Caracteristicas (listado unico) ─────────────────────────────────────────
# Logica: el toggle refleja el estado de la caracteristica.
#   ON  (verde) = activada (estado normal)        Off = valor "activado" / no configurada
#   OFF (gris)  = se desactivara al pulsar Aplicar  -> escribe Val en el registro
# Formato: Nombre = @{ Key; Val=valor desactivado; Opp=valor activado; T=tipo; Desc }
$POLICIES = [ordered]@{
    "Leo (AI Chat)"              = @{ Key = "BraveAIChatEnabled";         Val = 0; Opp = 1; T = "DWord"; Desc = "Asistente de IA Leo integrado" }
    "Noticias"                   = @{ Key = "BraveNewsDisabled";          Val = 1; Opp = 0; T = "DWord"; Desc = "Feed de noticias Brave News" }
    "Reproductor"                = @{ Key = "BravePlaylistEnabled";       Val = 0; Opp = 1; T = "DWord"; Desc = "Funcion Playlist" }
    "Speedreader"                = @{ Key = "BraveSpeedreaderEnabled";    Val = 0; Opp = 1; T = "DWord"; Desc = "Modo de lectura rapida (Speedreader)" }
    "Wayback Machine"            = @{ Key = "BraveWaybackMachineEnabled"; Val = 0; Opp = 1; T = "DWord"; Desc = "Integracion con Wayback Machine" }
    "P3A (analisis de producto)" = @{ Key = "BraveP3AEnabled";           Val = 0; Opp = 1; T = "DWord"; Desc = "Telemetria anonima de producto (P3A)" }
    "Ping de uso diario"         = @{ Key = "BraveStatsPingEnabled";     Val = 0; Opp = 1; T = "DWord"; Desc = "Ping diario de estadisticas de uso" }
    "Web Discovery Project"      = @{ Key = "BraveWebDiscoveryEnabled";  Val = 0; Opp = 1; T = "DWord"; Desc = "Envio de datos de Web Discovery" }
    "Brave Rewards"              = @{ Key = "BraveRewardsDisabled";      Val = 1; Opp = 0; T = "DWord"; Desc = "Brave Rewards y los anuncios" }
    "Wallet + Web3"              = @{ Key = "BraveWalletDisabled";       Val = 1; Opp = 0; T = "DWord"; Desc = "Brave Wallet y las funciones Web3" }
    "Videollamada"               = @{ Key = "BraveTalkDisabled";         Val = 1; Opp = 0; T = "DWord"; Desc = "Brave Talk (videollamadas)" }
    "Tor"                        = @{ Key = "TorDisabled";               Val = 1; Opp = 0; T = "DWord"; Desc = "Ventanas privadas con Tor" }
    "VPN"                        = @{ Key = "BraveVPNDisabled";          Val = 1; Opp = 0; T = "DWord"; Desc = "Brave VPN" }
    # ── Privacidad generica (politicas Chromium que Brave respeta) ──
    "Sugerencias de busqueda"    = @{ Key = "SearchSuggestEnabled";       Val = 0; Opp = 1; T = "DWord"; Desc = "Sugerencias al escribir (envian datos al buscador)" }
    "Gestor de contrasenas"      = @{ Key = "PasswordManagerEnabled";     Val = 0; Opp = 1; T = "DWord"; Desc = "Guardado y autocompletado de contrasenas" }
    "Autocompletar direcciones"  = @{ Key = "AutofillAddressEnabled";     Val = 0; Opp = 1; T = "DWord"; Desc = "Autocompletado de direcciones y contacto" }
    "Autocompletar tarjetas"     = @{ Key = "AutofillCreditCardEnabled";  Val = 0; Opp = 1; T = "DWord"; Desc = "Guardado y autocompletado de tarjetas" }
    "Modo en segundo plano"      = @{ Key = "BackgroundModeEnabled";      Val = 0; Opp = 1; T = "DWord"; Desc = "Brave sigue ejecutandose al cerrar la ventana" }
    "Prediccion de red (prefetch)" = @{ Key = "NetworkPredictionOptions"; Val = 2; Opp = 0; T = "DWord"; Desc = "Precarga de paginas y resolucion DNS anticipada" }
}

# ─── Estado en memoria ───────────────────────────────────────────────────────
$script:state   = [ordered]@{}   # $true = caracteristica activada (toggle ON)
$script:labels  = [ordered]@{}
$script:toggles = [ordered]@{}
$script:total   = $POLICIES.Count

# ─── Helpers de registro ─────────────────────────────────────────────────────
function Get-PolicyState {
    param([string]$Key)
    try {
        $value = Get-ItemProperty -Path $REG_PATH -Name $Key -ErrorAction SilentlyContinue
        if ($null -ne $value) { return $value.$Key }
    } catch {}
    return $null
}

function Update-Counter {
    $off = ($script:state.Values | Where-Object { -not $_ }).Count
    $script:counter.Text = "$off / $script:total a Desactivar"
    $script:counter.ForeColor = if ($off -gt 0) { $ACCENT } else { $MUTED }
}

function Update-CurrentState {
    foreach ($name in $POLICIES.Keys) {
        $p = $POLICIES[$name]
        $cur = Get-PolicyState -Key $p.Key
        if ($cur -eq $p.Val) {
            # Ya esta desactivada en el registro -> toggle OFF
            $script:state[$name] = $false
            $script:labels[$name].ForeColor = $MUTED
        } else {
            # Activada (no configurada o valor activado) -> toggle ON
            $script:state[$name] = $true
            $script:labels[$name].ForeColor = $FG
        }
        $script:toggles[$name].Invalidate()
    }
    Update-Counter
}

function Invoke-PolicyToggle {
    param([string]$Name)
    $script:state[$Name] = -not $script:state[$Name]
    $script:labels[$Name].ForeColor = if ($script:state[$Name]) { $FG } else { $MUTED }
    $script:toggles[$Name].Invalidate()
    Update-Counter
}

function Set-Policies {
    $disabled = 0; $fail = 0; $reenabled = 0
    foreach ($name in $POLICIES.Keys) {
        $p = $POLICIES[$name]
        $cur = Get-PolicyState -Key $p.Key
        if (-not $script:state[$name]) {
            # Toggle OFF -> desactivar caracteristica
            if (-not (Test-Path $REG_PATH)) { New-Item $REG_PATH -Force | Out-Null }
            try { Set-ItemProperty -Path $REG_PATH -Name $p.Key -Value $p.Val -Type $p.T -Force; $disabled++ }
            catch { $fail++ }
        } elseif ($cur -eq $p.Val) {
            # Toggle ON y estaba desactivada -> reactivar (quitar la politica)
            try { Remove-ItemProperty -Path $REG_PATH -Name $p.Key -Force -ErrorAction Stop; $reenabled++ }
            catch { $fail++ }
        }
    }
    return $disabled, $fail, $reenabled
}

# ─── Helpers de UI ───────────────────────────────────────────────────────────
function New-Toggle {
    param([string]$Name, [int]$X, [int]$Y, [Drawing.Color]$BaseBg)
    $t = [Windows.Forms.Panel]::new()
    $t.Size     = [Drawing.Size]::new($TOG_W, $TOG_H)
    $t.Location = [Drawing.Point]::new($X, $Y)
    $t.BackColor = $BaseBg
    $t.Tag      = $Name
    $t.Cursor   = [Windows.Forms.Cursors]::Hand
    $t.Add_Paint({
        param($s, $e)
        $g = $e.Graphics
        $g.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $on = [bool]$script:state[$s.Tag]
        $w = $s.Width; $h = $s.Height
        $col = if ($on) { $GREEN } else { $TOG_OFF }
        $path = New-Object Drawing.Drawing2D.GraphicsPath
        $path.AddArc(0, 0, $h, $h, 90, 180)
        $path.AddArc($w - $h, 0, $h, $h, 270, 180)
        $path.CloseFigure()
        $b = New-Object Drawing.SolidBrush($col)
        $g.FillPath($b, $path)
        $kd = $h - 6
        $kx = if ($on) { $w - $h + 3 } else { 3 }
        $wb = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(245, 245, 245))
        $g.FillEllipse($wb, $kx, 3, $kd, $kd)
        $b.Dispose(); $wb.Dispose(); $path.Dispose()
    })
    return $t
}

function New-Button {
    param([string]$Text, [int]$X, [int]$Y, [int]$W, [int]$H, [switch]$Primary)
    $b = [Windows.Forms.Button]::new()
    $b.Text      = $Text
    $b.Location  = [Drawing.Point]::new($X, $Y)
    $b.Size      = [Drawing.Size]::new($W, $H)
    $b.Font      = $FONT_BTN
    $b.FlatStyle = "Flat"
    $b.Cursor    = [Windows.Forms.Cursors]::Hand
    if ($Primary) {
        $b.BackColor = $ACCENT
        $b.ForeColor = [Drawing.Color]::White
        $b.FlatAppearance.BorderSize = 0
        $b.FlatAppearance.MouseOverBackColor = $ACC_HOV
        $b.FlatAppearance.MouseDownBackColor = $ACC_DWN
    } else {
        $b.BackColor = $CARD2
        $b.ForeColor = $FG
        $b.FlatAppearance.BorderSize  = 1
        $b.FlatAppearance.BorderColor = $BORDER
        $b.FlatAppearance.MouseOverBackColor = $HOVER
        $b.FlatAppearance.MouseDownBackColor = $CARD
    }
    return $b
}

# ─── Ventana ─────────────────────────────────────────────────────────────────
$form = [Windows.Forms.Form]::new()
$form.Text            = $APP_TITLE
$form.ClientSize      = [Drawing.Size]::new($W_FORM, $H_FORM)
$form.StartPosition   = "CenterScreen"
$form.BackColor       = $BG
$form.ForeColor       = $FG
$form.Font            = $FONT_BODY
$form.MaximizeBox     = $false
$form.FormBorderStyle = "FixedDialog"

# ── Cabecera ──
$header = [Windows.Forms.Panel]::new()
$header.Size      = [Drawing.Size]::new($W_FORM, 62)
$header.Location  = [Drawing.Point]::new(0, 0)
$header.BackColor = $CARD
$form.Controls.Add($header)

# -- Logo oficial de Brave (PNG oficial de Wikimedia Commons embebido en Base64 -> PictureBox) --
$LOGO_B64 = "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"
$logo = [Windows.Forms.PictureBox]::new()
$logo.Size      = [Drawing.Size]::new(36, 36)
$logo.Location  = [Drawing.Point]::new(16, 13)
$logo.BackColor = $CARD
$logo.SizeMode  = [Windows.Forms.PictureBoxSizeMode]::Zoom
$logo.Image     = [Drawing.Image]::FromStream([IO.MemoryStream]::new([Convert]::FromBase64String($LOGO_B64)))
$header.Controls.Add($logo)

$lblTitle = [Windows.Forms.Label]::new()
$lblTitle.Text      = $APP_NAME
$lblTitle.Font      = $FONT_TITLE
$lblTitle.ForeColor = $FG
$lblTitle.Location  = [Drawing.Point]::new(60, 8)
$lblTitle.AutoSize  = $true
$header.Controls.Add($lblTitle)

$lblSub = [Windows.Forms.Label]::new()
$lblSub.Text      = $APP_SUB
$lblSub.Font      = $FONT_SUB
$lblSub.ForeColor = $MUTED
$lblSub.Location  = [Drawing.Point]::new(62, 39)
$lblSub.AutoSize  = $true
$header.Controls.Add($lblSub)

$script:counter = [Windows.Forms.Label]::new()
$script:counter.Size      = [Drawing.Size]::new(180, 24)
$script:counter.Location  = [Drawing.Point]::new($W_FORM - 196, 19)
$script:counter.Font      = $FONT_CNT
$script:counter.ForeColor = $MUTED
$script:counter.TextAlign = "MiddleRight"
$header.Controls.Add($script:counter)

# Franja de acento bajo la cabecera
$accentStrip = [Windows.Forms.Panel]::new()
$accentStrip.Size      = [Drawing.Size]::new($W_FORM, 2)
$accentStrip.Location  = [Drawing.Point]::new(0, 62)
$accentStrip.BackColor = $ACCENT
$form.Controls.Add($accentStrip)

# ── Panel scrollable con scrollbar oscuro personalizado (todo negro) ──
$SBW       = [Windows.Forms.SystemInformation]::VerticalScrollBarWidth  # ancho del scrollbar nativo (se oculta)
$VBAR_W    = 8                                                          # ancho de nuestro scrollbar
$TRACK_COL = $BG                                                        # pista/fondo: negro
$THUMB_COL = [Drawing.Color]::FromArgb(64, 64, 72)                      # pulgar en reposo
$THUMB_HOV = [Drawing.Color]::FromArgb(98, 98, 110)                     # pulgar en hover/arrastre

# Contenedor que recorta el scrollbar nativo del panel
$scrollHost = [Windows.Forms.Panel]::new()
$scrollHost.Location  = [Drawing.Point]::new(16, 74)
$scrollHost.Size      = [Drawing.Size]::new($W_PANEL, 474)
$scrollHost.BackColor = $CARD
$form.Controls.Add($scrollHost)

# Panel real con AutoScroll; más ancho para que su scrollbar nativo quede fuera (recortado por el host)
$scrollPanel = [Windows.Forms.Panel]::new()
$scrollPanel.Location   = [Drawing.Point]::new(0, 0)
$scrollPanel.Size       = [Drawing.Size]::new($W_PANEL + $SBW, 474)
$scrollPanel.BackColor  = $CARD
$scrollPanel.AutoScroll = $true
$scrollHost.Controls.Add($scrollPanel)

# Pista del scrollbar (negra) y pulgar (gris oscuro)
$vbar = [Windows.Forms.Panel]::new()
$vbar.Size      = [Drawing.Size]::new($VBAR_W, 474)
$vbar.Location  = [Drawing.Point]::new($W_PANEL - $VBAR_W, 0)
$vbar.BackColor = $TRACK_COL
$scrollHost.Controls.Add($vbar)
$vbar.BringToFront()

$vthumb = [Windows.Forms.Panel]::new()
$vthumb.Size      = [Drawing.Size]::new($VBAR_W, 40)
$vthumb.Location  = [Drawing.Point]::new(0, 0)
$vthumb.BackColor = $THUMB_COL
$vthumb.Cursor    = [Windows.Forms.Cursors]::Hand
$vbar.Controls.Add($vthumb)

$script:vDrag = $false
$script:vDragStartY = 0
$script:vDragStartScrolled = 0

function Update-VScroll {
    $view    = $scrollPanel.ClientSize.Height
    $content = $scrollPanel.DisplayRectangle.Height
    if ($view -le 0 -or $content -le $view) { $vbar.Visible = $false; return }
    $vbar.Visible = $true
    $trackH = $vbar.Height
    $thumbH = [int][math]::Max(28, [math]::Round($trackH * $view / $content))
    if ($thumbH -gt $trackH) { $thumbH = $trackH }
    $maxScroll = $content - $view
    $scrolled  = - $scrollPanel.AutoScrollPosition.Y
    if ($scrolled -lt 0) { $scrolled = 0 } elseif ($scrolled -gt $maxScroll) { $scrolled = $maxScroll }
    $thumbY = if ($maxScroll -gt 0) { [int][math]::Round(($trackH - $thumbH) * $scrolled / $maxScroll) } else { 0 }
    if ($vthumb.Height -ne $thumbH) { $vthumb.Height = $thumbH }
    if ($vthumb.Top    -ne $thumbY) { $vthumb.Top    = $thumbY }
}

$vthumb.Add_MouseEnter({ if (-not $script:vDrag) { $vthumb.BackColor = $THUMB_HOV } })
$vthumb.Add_MouseLeave({ if (-not $script:vDrag) { $vthumb.BackColor = $THUMB_COL } })
$vthumb.Add_MouseDown({
    $script:vDrag = $true
    $script:vDragStartY = [Windows.Forms.Cursor]::Position.Y
    $script:vDragStartScrolled = - $scrollPanel.AutoScrollPosition.Y
    $vthumb.BackColor = $THUMB_HOV
})
$vthumb.Add_MouseUp({
    $script:vDrag = $false
    $vthumb.BackColor = $THUMB_COL
})
$vthumb.Add_MouseMove({
    if (-not $script:vDrag) { return }
    $view    = $scrollPanel.ClientSize.Height
    $content = $scrollPanel.DisplayRectangle.Height
    $maxScroll = $content - $view
    if ($maxScroll -le 0) { return }
    $denom = $vbar.Height - $vthumb.Height
    if ($denom -le 0) { return }
    $dy = [Windows.Forms.Cursor]::Position.Y - $script:vDragStartY
    $newScrolled = $script:vDragStartScrolled + [int][math]::Round($dy * $maxScroll / $denom)
    if ($newScrolled -lt 0) { $newScrolled = 0 } elseif ($newScrolled -gt $maxScroll) { $newScrolled = $maxScroll }
    $scrollPanel.AutoScrollPosition = [Drawing.Point]::new(0, $newScrolled)
    Update-VScroll
})

# El thumb se sincroniza con la rueda y el arrastre nativo via timer + evento Scroll
$scrollPanel.Add_Scroll({ Update-VScroll })
$vtimer = [Windows.Forms.Timer]::new()
$vtimer.Interval = 60
$vtimer.Add_Tick({ Update-VScroll })
$vtimer.Start()
$form.Add_FormClosed({ $vtimer.Stop(); $vtimer.Dispose() })

$yGlobal = 8

# ── Filas de caracteristicas (listado unico) ──
$i = 0
foreach ($name in $POLICIES.Keys) {
    $p = $POLICIES[$name]
    $rowBg = if (($i % 2) -eq 0) { $CARD } else { $CARD2 }
    $i++
    $script:state[$name] = $true   # por defecto activada (ON)

    $row = [Windows.Forms.Panel]::new()
    $row.Size      = [Drawing.Size]::new($W_ROW, $H_ROW)
    $row.Location  = [Drawing.Point]::new($X_ROW, $yGlobal)
    $row.BackColor = $rowBg
    $row.Cursor    = [Windows.Forms.Cursors]::Hand
    $scrollPanel.Controls.Add($row)

    $lbl = [Windows.Forms.Label]::new()
    $lbl.Text      = $name
    $lbl.Location  = [Drawing.Point]::new($X_TXT, 7)
    $lbl.Size      = [Drawing.Size]::new($W_TXT, 17)
    $lbl.ForeColor = $FG
    $lbl.Font      = $FONT_BODY
    $lbl.BackColor = [Drawing.Color]::Transparent
    $lbl.Cursor    = [Windows.Forms.Cursors]::Hand
    $row.Controls.Add($lbl)
    $script:labels[$name] = $lbl

    $desc = [Windows.Forms.Label]::new()
    $desc.Text      = $p.Desc
    $desc.Location  = [Drawing.Point]::new($X_TXT, 25)
    $desc.Size      = [Drawing.Size]::new($W_TXT, 14)
    $desc.ForeColor = $MUTED
    $desc.Font      = $FONT_DESC
    $desc.BackColor = [Drawing.Color]::Transparent
    $desc.Cursor    = [Windows.Forms.Cursors]::Hand
    $row.Controls.Add($desc)

    $tog = New-Toggle $name $X_TOG ([int](($H_ROW - $TOG_H) / 2)) $rowBg
    $row.Controls.Add($tog)
    $script:toggles[$name] = $tog

    $tt = [Windows.Forms.ToolTip]::new()
    $tt.SetToolTip($lbl,  "Clave: $($p.Key)")
    $tt.SetToolTip($desc, "Clave: $($p.Key)")

    # Click -> alternar
    $capture = $name
    $onClick = { Invoke-PolicyToggle $capture }.GetNewClosure()
    $row.Add_Click($onClick)
    $lbl.Add_Click($onClick)
    $desc.Add_Click($onClick)
    $tog.Add_Click($onClick)

    # Hover de fila
    $baseBg = $rowBg
    $onEnter = {
        $row.BackColor = $HOVER
        $tog.BackColor = $HOVER
        $tog.Invalidate()
    }.GetNewClosure()
    $onLeave = {
        $pt = $row.PointToClient([Windows.Forms.Cursor]::Position)
        if (-not $row.ClientRectangle.Contains($pt)) {
            $row.BackColor = $baseBg
            $tog.BackColor = $baseBg
            $tog.Invalidate()
        }
    }.GetNewClosure()
    $row.Add_MouseEnter($onEnter);  $row.Add_MouseLeave($onLeave)
    $lbl.Add_MouseEnter($onEnter);  $lbl.Add_MouseLeave($onLeave)
    $desc.Add_MouseEnter($onEnter); $desc.Add_MouseLeave($onLeave)
    $tog.Add_MouseEnter($onEnter);  $tog.Add_MouseLeave($onLeave)

    $yGlobal += $H_ROW + 2
}

# ── Botonera ──
$btnY = 560; $btnH = 36
$btnDefault   = New-Button "Default"      16  $btnY 92  $btnH
$btnEnableAll = New-Button "Activar todo"  116 $btnY 92  $btnH
$btnDisableAll= New-Button "Desact. todo"  216 $btnY 92  $btnH
$btnApply     = New-Button "Aplicar"       316 $btnY 118 $btnH -Primary
$form.Controls.AddRange(@($btnDefault, $btnEnableAll, $btnDisableAll, $btnApply))

# ── Barra de estado ──
$script:status = [Windows.Forms.Label]::new()
$script:status.Location  = [Drawing.Point]::new(16, 606)
$script:status.Size      = [Drawing.Size]::new($W_PANEL, 18)
$script:status.ForeColor = $MUTED
$script:status.Font      = $FONT_STAT
$script:status.Text      = ""
$form.Controls.Add($script:status)

# ── Estado inicial ──
Update-CurrentState

# ── Eventos ──
$btnEnableAll.Add_Click({
    foreach ($n in @($script:state.Keys)) {
        $script:state[$n] = $true
        $script:labels[$n].ForeColor = $FG
        $script:toggles[$n].Invalidate()
    }
    Update-Counter
    $script:status.ForeColor = $MUTED
    $script:status.Text = "Todas las caracteristicas activadas."
})

$btnDisableAll.Add_Click({
    foreach ($n in @($script:state.Keys)) {
        $script:state[$n] = $false
        $script:labels[$n].ForeColor = $MUTED
        $script:toggles[$n].Invalidate()
    }
    Update-Counter
    $script:status.ForeColor = $MUTED
    $script:status.Text = "Todas marcadas para desactivar."
})

$btnDefault.Add_Click({
    # Elimina por completo la clave de politicas de Brave -> vuelve todo a sus
    # valores predeterminados y Brave deja de aparecer "Administrado por su organizacion".
    try {
        if (Test-Path $REG_PATH) { Remove-Item $REG_PATH -Recurse -Force -ErrorAction Stop }
        Update-CurrentState
        $script:status.ForeColor = $GREEN
        $script:status.Text = "Politicas eliminadas. Reinicia $BROWSER; ya no saldra administrado por su organizacion."
    } catch {
        $script:status.ForeColor = $RED
        $script:status.Text = "No se pudieron eliminar las politicas: $($_.Exception.Message)"
    }
})

$btnApply.Add_Click({
    $disabled, $fail, $reenabled = Set-Policies
    Update-CurrentState
    $msg = "$disabled desactivadas"
    if ($reenabled -gt 0) { $msg += ", $reenabled reactivadas" }
    if ($fail -gt 0)      { $msg += ", $fail errores" }
    $msg += ". Reinicia $BROWSER para que surtan efecto."
    $script:status.ForeColor = if ($fail -gt 0) { $RED } else { $GREEN }
    $script:status.Text = $msg
})

# Refresco inicial del scrollbar personalizado una vez mostrado el formulario
$form.Add_Shown({ Update-VScroll })

[void]$form.ShowDialog()
