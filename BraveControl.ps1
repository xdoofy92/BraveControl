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

# ─── Scrollbar negro y minimalista (tema nativo DarkMode_Explorer) ────────────
if (-not ("Native.Theme" -as [type])) {
Add-Type -Namespace Native -Name Theme -MemberDefinition @'
[System.Runtime.InteropServices.DllImport("uxtheme.dll", CharSet = System.Runtime.InteropServices.CharSet.Unicode)]
public static extern int SetWindowTheme(System.IntPtr hWnd, string pszSubAppName, string pszSubIdList);
'@
}

function Set-DarkScroll {
    param($ctrl)
    try {
        if ($ctrl.IsHandleCreated) {
            [Native.Theme]::SetWindowTheme($ctrl.Handle, "DarkMode_Explorer", $null) | Out-Null
        }
    } catch {}
}

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
    "Lista de reproduccion"      = @{ Key = "BravePlaylistEnabled";       Val = 0; Opp = 1; T = "DWord"; Desc = "Funcion Playlist" }
    "Lector rapido"              = @{ Key = "BraveSpeedreaderEnabled";    Val = 0; Opp = 1; T = "DWord"; Desc = "Modo de lectura rapida (Speedreader)" }
    "Wayback Machine"            = @{ Key = "BraveWaybackMachineEnabled"; Val = 0; Opp = 1; T = "DWord"; Desc = "Integracion con Wayback Machine" }
    "P3A (analisis de producto)" = @{ Key = "BraveP3AEnabled";           Val = 0; Opp = 1; T = "DWord"; Desc = "Telemetria anonima de producto (P3A)" }
    "Ping de uso diario"         = @{ Key = "BraveStatsPingEnabled";     Val = 0; Opp = 1; T = "DWord"; Desc = "Ping diario de estadisticas de uso" }
    "Web Discovery"              = @{ Key = "BraveWebDiscoveryEnabled";  Val = 0; Opp = 1; T = "DWord"; Desc = "Envio de datos de Web Discovery" }
    "Recompensas + Brave Ads"    = @{ Key = "BraveRewardsDisabled";      Val = 1; Opp = 0; T = "DWord"; Desc = "Brave Rewards y los anuncios" }
    "Monedero + Web3"            = @{ Key = "BraveWalletDisabled";       Val = 1; Opp = 0; T = "DWord"; Desc = "Brave Wallet y las funciones Web3" }
    "Videollamada"               = @{ Key = "BraveTalkDisabled";         Val = 1; Opp = 0; T = "DWord"; Desc = "Brave Talk (videollamadas)" }
    "Tor"                        = @{ Key = "TorDisabled";               Val = 1; Opp = 0; T = "DWord"; Desc = "Ventanas privadas con Tor" }
    "VPN"                        = @{ Key = "BraveVPNDisabled";          Val = 1; Opp = 0; T = "DWord"; Desc = "Brave VPN" }
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

$accentBar = [Windows.Forms.Panel]::new()
$accentBar.Size      = [Drawing.Size]::new(4, 34)
$accentBar.Location  = [Drawing.Point]::new(16, 14)
$accentBar.BackColor = $ACCENT
$header.Controls.Add($accentBar)

$lblTitle = [Windows.Forms.Label]::new()
$lblTitle.Text      = $APP_NAME
$lblTitle.Font      = $FONT_TITLE
$lblTitle.ForeColor = $FG
$lblTitle.Location  = [Drawing.Point]::new(28, 8)
$lblTitle.AutoSize  = $true
$header.Controls.Add($lblTitle)

$lblSub = [Windows.Forms.Label]::new()
$lblSub.Text      = $APP_SUB
$lblSub.Font      = $FONT_SUB
$lblSub.ForeColor = $MUTED
$lblSub.Location  = [Drawing.Point]::new(30, 39)
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

# ── Panel scrollable ──
$scrollPanel = [Windows.Forms.Panel]::new()
$scrollPanel.Location   = [Drawing.Point]::new(16, 74)
$scrollPanel.Size       = [Drawing.Size]::new($W_PANEL, 474)
$scrollPanel.BackColor  = $CARD
$scrollPanel.AutoScroll = $true
$form.Controls.Add($scrollPanel)

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

# Aplicar el scrollbar oscuro al panel una vez creado su handle
$form.Add_Shown({ Set-DarkScroll $scrollPanel })

[void]$form.ShowDialog()
