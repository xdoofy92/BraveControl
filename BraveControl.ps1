# BraveControl - Gestor grafico de politicas de Brave via registro de Windows
# Autor: xdoofy92 | https://github.com/xdoofy92

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
$FONT_GRP   = [Drawing.Font]::new("Segoe UI", 8, [Drawing.FontStyle]::Bold)
$FONT_BTN   = [Drawing.Font]::new("Segoe UI Semibold", 9)
$FONT_CNT   = [Drawing.Font]::new("Segoe UI", 9, [Drawing.FontStyle]::Bold)
$FONT_STAT  = [Drawing.Font]::new("Segoe UI", 7.75)

# ─── Geometria ───────────────────────────────────────────────────────────────
$W_FORM = 462; $H_FORM = 678
$W_PANEL = 418
$W_ROW = 392; $X_ROW = 6; $H_ROW = 46
$H_GRP = 28
$TOG_W = 40; $TOG_H = 22
$X_TOG = $W_ROW - $TOG_W - 12
$X_TXT = 14
$W_TXT = $X_TOG - $X_TXT - 10

if (-not (Test-Path $REG_PATH)) { New-Item $REG_PATH -Force | Out-Null }

# ─── Politicas por categoria ─────────────────────────────────────────────────
# Formato: Nombre = @{ Key; Val=valor desactivado; Opp=valor activado; T=tipo; Desc }
$GROUPS = [ordered]@{

    "IA y contenido" = [ordered]@{
        "Leo (AI Chat)"             = @{ Key = "BraveAIChatEnabled";         Val = 0; Opp = 1; T = "DWord"; Desc = "Desactiva el asistente de IA Leo integrado" }
        "Noticias"                  = @{ Key = "BraveNewsDisabled";          Val = 1; Opp = 0; T = "DWord"; Desc = "Desactiva el feed de noticias Brave News" }
        "Lista de reproduccion"     = @{ Key = "BravePlaylistEnabled";       Val = 0; Opp = 1; T = "DWord"; Desc = "Desactiva la funcion Playlist" }
        "Lector rapido"             = @{ Key = "BraveSpeedreaderEnabled";    Val = 0; Opp = 1; T = "DWord"; Desc = "Desactiva el modo de lectura rapida (Speedreader)" }
        "Wayback Machine"           = @{ Key = "BraveWaybackMachineEnabled"; Val = 0; Opp = 1; T = "DWord"; Desc = "Desactiva la integracion con Wayback Machine" }
    }

    "Privacidad y telemetria" = [ordered]@{
        "P3A (analisis de producto)" = @{ Key = "BraveP3AEnabled";           Val = 0; Opp = 1; T = "DWord"; Desc = "Desactiva la telemetria anonima de producto (P3A)" }
        "Ping de uso diario"         = @{ Key = "BraveStatsPingEnabled";     Val = 0; Opp = 1; T = "DWord"; Desc = "Desactiva el ping diario de estadisticas de uso" }
        "Web Discovery"              = @{ Key = "BraveWebDiscoveryEnabled";  Val = 0; Opp = 1; T = "DWord"; Desc = "Desactiva el envio de datos de Web Discovery" }
    }

    "Recompensas y Web3" = [ordered]@{
        "Recompensas + Brave Ads"   = @{ Key = "BraveRewardsDisabled";       Val = 1; Opp = 0; T = "DWord"; Desc = "Desactiva Brave Rewards y los anuncios" }
        "Monedero + Web3"           = @{ Key = "BraveWalletDisabled";        Val = 1; Opp = 0; T = "DWord"; Desc = "Desactiva Brave Wallet y las funciones Web3" }
    }

    "Funciones extra" = [ordered]@{
        "Videollamada"              = @{ Key = "BraveTalkDisabled";          Val = 1; Opp = 0; T = "DWord"; Desc = "Desactiva Brave Talk (videollamadas)" }
        "Tor"                       = @{ Key = "TorDisabled";                Val = 1; Opp = 0; T = "DWord"; Desc = "Desactiva las ventanas privadas con Tor" }
        "VPN"                       = @{ Key = "BraveVPNDisabled";           Val = 1; Opp = 0; T = "DWord"; Desc = "Desactiva Brave VPN" }
        "Alias de correo"           = @{ Key = "BraveEmailAliasesEnabled";   Val = 0; Opp = 1; T = "DWord"; Desc = "Desactiva los alias de correo" }
    }
}

# ─── Estado en memoria ───────────────────────────────────────────────────────
$script:state   = [ordered]@{}
$script:labels  = [ordered]@{}
$script:toggles = [ordered]@{}
$script:total   = 0
foreach ($g in $GROUPS.Keys) { $script:total += $GROUPS[$g].Count }

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
    $n = ($script:state.Values | Where-Object { $_ }).Count
    $script:counter.Text = "$n / $script:total activas"
    $script:counter.ForeColor = if ($n -gt 0) { $GREEN } else { $MUTED }
}

function Update-CurrentState {
    foreach ($group in $GROUPS.Keys) {
        foreach ($name in $GROUPS[$group].Keys) {
            $p = $GROUPS[$group][$name]
            $cur = Get-PolicyState -Key $p.Key
            if ($cur -eq $p.Val) {
                $script:state[$name] = $true
                $script:labels[$name].ForeColor = $GREEN
            } elseif ($null -eq $cur) {
                $script:state[$name] = $false
                $script:labels[$name].ForeColor = $FG
            } else {
                $script:state[$name] = $false
                $script:labels[$name].ForeColor = $RED
            }
            $script:toggles[$name].Invalidate()
        }
    }
    Update-Counter
}

function Invoke-PolicyToggle {
    param([string]$Name)
    $script:state[$Name] = -not $script:state[$Name]
    $script:labels[$Name].ForeColor = if ($script:state[$Name]) { $GREEN } else { $FG }
    $script:toggles[$Name].Invalidate()
    Update-Counter
}

function Set-Policies {
    $ok = 0; $fail = 0; $removed = 0
    foreach ($group in $GROUPS.Keys) {
        foreach ($name in $GROUPS[$group].Keys) {
            $p = $GROUPS[$group][$name]
            $cur = Get-PolicyState -Key $p.Key
            if ($script:state[$name]) {
                try { Set-ItemProperty -Path $REG_PATH -Name $p.Key -Value $p.Val -Type $p.T -Force; $ok++ }
                catch { $fail++ }
            } elseif ($cur -eq $p.Val) {
                try { Remove-ItemProperty -Path $REG_PATH -Name $p.Key -Force -ErrorAction Stop; $removed++ }
                catch { $fail++ }
            }
        }
    }
    return $ok, $fail, $removed
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
$script:counter.Size      = [Drawing.Size]::new(150, 24)
$script:counter.Location  = [Drawing.Point]::new($W_FORM - 166, 19)
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

# ── Banner de instruccion ──
$banner = [Windows.Forms.Panel]::new()
$banner.Size      = [Drawing.Size]::new($W_ROW, 44)
$banner.Location  = [Drawing.Point]::new($X_ROW, $yGlobal)
$banner.BackColor = $GRPBG
$scrollPanel.Controls.Add($banner)

$bannerLine = [Windows.Forms.Panel]::new()
$bannerLine.Size      = [Drawing.Size]::new(3, 44)
$bannerLine.Location  = [Drawing.Point]::new(0, 0)
$bannerLine.BackColor = $ACCENT
$banner.Controls.Add($bannerLine)

$bannerTitle = [Windows.Forms.Label]::new()
$bannerTitle.Text      = "Marca las caracteristicas que quieres DESHABILITAR"
$bannerTitle.Font      = $FONT_BTN
$bannerTitle.ForeColor = $FG
$bannerTitle.Location  = [Drawing.Point]::new(13, 7)
$bannerTitle.AutoSize  = $true
$banner.Controls.Add($bannerTitle)

$bannerSub = [Windows.Forms.Label]::new()
$bannerSub.Text      = "Aplicar desactiva lo marcado; desmarcar y Aplicar lo reactiva"
$bannerSub.Font      = $FONT_DESC
$bannerSub.ForeColor = $MUTED
$bannerSub.Location  = [Drawing.Point]::new(13, 25)
$bannerSub.AutoSize  = $true
$banner.Controls.Add($bannerSub)

$yGlobal += 44 + 8

foreach ($group in $GROUPS.Keys) {

    # Cabecera de grupo
    $groupPanel = [Windows.Forms.Panel]::new()
    $groupPanel.Size      = [Drawing.Size]::new($W_ROW, $H_GRP)
    $groupPanel.Location  = [Drawing.Point]::new($X_ROW, $yGlobal)
    $groupPanel.BackColor = $GRPBG
    $scrollPanel.Controls.Add($groupPanel)

    $grpLine = [Windows.Forms.Panel]::new()
    $grpLine.Size      = [Drawing.Size]::new(3, $H_GRP)
    $grpLine.Location  = [Drawing.Point]::new(0, 0)
    $grpLine.BackColor = $ACCENT
    $groupPanel.Controls.Add($grpLine)

    $grpLabel = [Windows.Forms.Label]::new()
    $grpLabel.Text      = $group.ToUpper()
    $grpLabel.Font      = $FONT_GRP
    $grpLabel.ForeColor = $ACCENT
    $grpLabel.Location  = [Drawing.Point]::new(13, 6)
    $grpLabel.AutoSize  = $true
    $groupPanel.Controls.Add($grpLabel)

    $yGlobal += $H_GRP + 4

    $i = 0
    foreach ($name in $GROUPS[$group].Keys) {
        $p = $GROUPS[$group][$name]
        $rowBg = if (($i % 2) -eq 0) { $CARD } else { $CARD2 }
        $i++

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
    $yGlobal += 8
}

# ── Botonera ──
$btnY = 560; $btnH = 36
$btnRefresh  = New-Button "Actualizar"  16  $btnY 92  $btnH
$btnSelectAll= New-Button "Sel. todo"   116 $btnY 92  $btnH
$btnClear    = New-Button "Limpiar"     216 $btnY 92  $btnH
$btnApply    = New-Button "Aplicar"     316 $btnY 118 $btnH -Primary
$form.Controls.AddRange(@($btnRefresh, $btnSelectAll, $btnClear, $btnApply))

# ── Barra de estado ──
$script:status = [Windows.Forms.Label]::new()
$script:status.Location  = [Drawing.Point]::new(16, 616)
$script:status.Size      = [Drawing.Size]::new($W_PANEL, 18)
$script:status.ForeColor = $MUTED
$script:status.Font      = $FONT_STAT
$script:status.Text      = ""
$form.Controls.Add($script:status)

# ── Estado inicial ──
Update-CurrentState

# ── Eventos ──
$btnSelectAll.Add_Click({
    foreach ($n in $script:state.Keys) {
        $script:state[$n] = $true
        $script:labels[$n].ForeColor = $GREEN
        $script:toggles[$n].Invalidate()
    }
    Update-Counter
    $script:status.ForeColor = $MUTED
    $script:status.Text = "Todas las politicas seleccionadas."
})

$btnClear.Add_Click({
    foreach ($n in $script:state.Keys) {
        $script:state[$n] = $false
        $script:labels[$n].ForeColor = $FG
        $script:toggles[$n].Invalidate()
    }
    Update-Counter
    $script:status.ForeColor = $MUTED
    $script:status.Text = "Seleccion limpiada."
})

$btnRefresh.Add_Click({
    Update-CurrentState
    $script:status.ForeColor = $MUTED
    $script:status.Text = "Estado actualizado desde el registro."
})

$btnApply.Add_Click({
    $ok, $fail, $removed = Set-Policies
    Update-CurrentState
    $msg = "Aplicadas $ok politicas"
    if ($removed -gt 0) { $msg += ", eliminadas $removed" }
    if ($fail -gt 0)    { $msg += ", $fail errores" }
    $msg += ". Reinicia $BROWSER para que surtan efecto."
    $script:status.ForeColor = if ($fail -gt 0) { $RED } else { $GREEN }
    $script:status.Text = $msg
})

[void]$form.ShowDialog()
