# BraveControl v0.1

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# Elevacion a administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    if (-not $PSCommandPath) {
        # Ejecucion remota: descargar y ejecutar como admin
        $url = "https://raw.githubusercontent.com/xdoofy92/BraveControl/main/BraveControl.ps1"
        $scriptContent = Invoke-RestMethod -Uri $url
        $tempFile = [System.IO.Path]::GetTempFileName() + ".ps1"
        $scriptContent | Out-File $tempFile -Encoding UTF8
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempFile`""
        exit
    } else {
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        exit
    }
}

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# Constantes

$REG_PATH  = "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave"
$APP_TITLE = "BraveControl - dprojects.org"

$DARK  = [Drawing.Color]::FromArgb(18, 18, 18)
$PANEL = [Drawing.Color]::FromArgb(28, 28, 28)
$BORDER= [Drawing.Color]::FromArgb(48, 48, 48)
$FG    = [Drawing.Color]::FromArgb(220, 220, 220)
$MUTED = [Drawing.Color]::FromArgb(130, 130, 130)
$ACCENT= [Drawing.Color]::FromArgb(255, 120, 80)

$FONT_BODY  = [Drawing.Font]::new("Segoe UI", 9)
$FONT_LABEL = [Drawing.Font]::new("Segoe UI", 8, [Drawing.FontStyle]::Bold)

if (-not (Test-Path $REG_PATH)) { New-Item $REG_PATH -Force | Out-Null }

# Policies

$POLICIES = [ordered]@{
    "Leo (AI Chat)"              = @{ Key = "BraveAIChatEnabled";         Val = 0; Opp = 1; T = "DWord" }
    "Noticias"                   = @{ Key = "BraveNewsDisabled";          Val = 1; Opp = 0; T = "DWord" }
    "Lista de reproduccion"      = @{ Key = "BravePlaylistEnabled";       Val = 0; Opp = 1; T = "DWord" }
    "Recompensas + Brave Ads"    = @{ Key = "BraveRewardsDisabled";       Val = 1; Opp = 0; T = "DWord" }
    "Lector rapido"              = @{ Key = "BraveSpeedreaderEnabled";    Val = 0; Opp = 1; T = "DWord" }
    "P3A (analisis de producto)" = @{ Key = "BraveP3AEnabled";            Val = 0; Opp = 1; T = "DWord" }
    "Ping de uso diario"         = @{ Key = "BraveStatsPingEnabled";      Val = 0; Opp = 1; T = "DWord" }
    "Hablar (Talk)"              = @{ Key = "BraveTalkDisabled";          Val = 1; Opp = 0; T = "DWord" }
    "Tor"                        = @{ Key = "TorDisabled";                Val = 1; Opp = 0; T = "DWord" }
    "VPN"                        = @{ Key = "BraveVPNDisabled";           Val = 1; Opp = 0; T = "DWord" }
    "Monedero + Web3"            = @{ Key = "BraveWalletDisabled";        Val = 1; Opp = 0; T = "DWord" }
    "Wayback Machine"            = @{ Key = "BraveWaybackMachineEnabled"; Val = 0; Opp = 1; T = "DWord" }
    "Web Discovery"              = @{ Key = "BraveWebDiscoveryEnabled";   Val = 0; Opp = 1; T = "DWord" }
    "Alias de correo (Nightly)"  = @{ Key = "BraveEmailAliasesEnabled";   Val = 0; Opp = 1; T = "DWord" }
}

# Helpers

function New-FlatButton {
    param([string]$Text, [Drawing.Point]$Pos, [Drawing.Size]$Size, [Drawing.Color]$Fg)
    $btn = [Windows.Forms.Button]::new()
    $btn.Text        = $Text
    $btn.Location    = $Pos
    $btn.Size        = $Size
    $btn.Font        = $FONT_BODY
    $btn.FlatStyle   = "Flat"
    $btn.ForeColor   = $Fg
    $btn.BackColor   = [Drawing.Color]::FromArgb(38, 38, 38)
    $btn.FlatAppearance.BorderColor = $BORDER
    $btn.FlatAppearance.BorderSize  = 1
    $btn.FlatAppearance.MouseOverBackColor  = [Drawing.Color]::FromArgb(52, 52, 52)
    $btn.FlatAppearance.MouseDownBackColor  = [Drawing.Color]::FromArgb(22, 22, 22)
    $btn.Cursor = [Windows.Forms.Cursors]::Hand
    return $btn
}

function Get-ActivePolicies {
    return $script:checks.Keys | Where-Object { $script:checks[$_].Checked }
}

function Get-PolicyState {
    param([string]$Key)
    try {
        $value = Get-ItemProperty -Path $REG_PATH -Name $Key -ErrorAction SilentlyContinue
        if ($value) {
            return $value.$Key
        }
    } catch {
        return $null
    }
    return $null
}

function Update-CurrentState {
    foreach ($name in $POLICIES.Keys) {
        $p = $POLICIES[$name]
        $currentValue = Get-PolicyState -Key $p.Key
        if ($currentValue -eq $p.Val) {
            $script:checks[$name].Checked = $true
            $script:labels[$name].ForeColor = [Drawing.Color]::FromArgb(120,220,120)
        } elseif ($null -eq $currentValue) {
            $script:checks[$name].Checked = $false
            $script:labels[$name].ForeColor = $FG
        } else {
            $script:checks[$name].Checked = $false
            $script:labels[$name].ForeColor = [Drawing.Color]::FromArgb(255,100,100)
        }
    }
}

function Set-Policies {
    $ok = 0; $fail = 0; $removed = 0
    foreach ($name in $POLICIES.Keys) {
        $p = $POLICIES[$name]
        $isChecked = $script:checks[$name].Checked
        $currentValue = Get-PolicyState -Key $p.Key

        if ($isChecked) {
            # Activar política
            try {
                Set-ItemProperty -Path $REG_PATH -Name $p.Key -Value $p.Val -Type $p.T -Force
                $ok++
            } catch { $fail++ }
        } elseif ($currentValue -eq $p.Val) {
            # Desactivar política (eliminar del registro)
            try {
                Remove-ItemProperty -Path $REG_PATH -Name $p.Key -Force -ErrorAction Stop
                $removed++
            } catch { $fail++ }
        }
    }
    return $ok, $fail, $removed
}

# UI

$form = [Windows.Forms.Form]::new()
$form.Text            = $APP_TITLE
$form.Size            = [Drawing.Size]::new(420, 600)
$form.StartPosition   = "CenterScreen"
$form.BackColor       = $DARK
$form.ForeColor       = $FG
$form.Font            = $FONT_BODY
$form.MaximizeBox     = $false
$form.FormBorderStyle = "FixedDialog"

# Header
$header = [Windows.Forms.Panel]::new()
$header.Size      = [Drawing.Size]::new(420, 48)
$header.Location  = [Drawing.Point]::new(0, 0)
$header.BackColor = $PANEL
$form.Controls.Add($header)

$lblTitle = [Windows.Forms.Label]::new()
$lblTitle.Text      = "BraveControl"
$lblTitle.Font      = [Drawing.Font]::new("Segoe UI", 13, [Drawing.FontStyle]::Bold)
$lblTitle.ForeColor = $ACCENT
$lblTitle.Location  = [Drawing.Point]::new(20, 12)
$lblTitle.AutoSize  = $true
$header.Controls.Add($lblTitle)

$lblSub = [Windows.Forms.Label]::new()
$lblSub.Text      = "Politicas de Brave via registro"
$lblSub.Font      = [Drawing.Font]::new("Segoe UI", 8)
$lblSub.ForeColor = $MUTED
$lblSub.Location  = [Drawing.Point]::new(145, 18)
$lblSub.AutoSize  = $true
$header.Controls.Add($lblSub)

# Panel de checks con scroll
$scroll = [Windows.Forms.Panel]::new()
$scroll.Location    = [Drawing.Point]::new(16, 60)
$scroll.Size        = [Drawing.Size]::new(386, 420)
$scroll.BackColor   = $PANEL
$scroll.AutoScroll  = $false
$scroll.BorderStyle = "None"
$form.Controls.Add($scroll)

# Separador visual arriba del scroll panel
$sep = [Windows.Forms.Panel]::new()
$sep.Location  = [Drawing.Point]::new(16, 58)
$sep.Size      = [Drawing.Size]::new(386, 1)
$sep.BackColor = $BORDER
$form.Controls.Add($sep)

# Label de secciÃ³n dentro del panel
$secLabel = [Windows.Forms.Label]::new()
$secLabel.Text      = "CARACTERISTICAS A DESHABILITAR"
$secLabel.Font      = $FONT_LABEL
$secLabel.ForeColor = $ACCENT
$secLabel.Location  = [Drawing.Point]::new(12, 10)
$secLabel.AutoSize  = $true
$scroll.Controls.Add($secLabel)

$script:checks = [ordered]@{}
$script:labels = [ordered]@{}
$y = 34

foreach ($name in $POLICIES.Keys) {
    $cb = [Windows.Forms.CheckBox]::new()
    $cb.Text      = ""
    $cb.Location  = [Drawing.Point]::new(12, $y)
    $cb.Size      = [Drawing.Size]::new(20, 22)
    $cb.FlatStyle = "Flat"
    $cb.Cursor    = [Windows.Forms.Cursors]::Hand
    $cb.Add_CheckedChanged({
        $currentName = $this.Tag
        if ($this.Checked) {
            $script:labels[$currentName].ForeColor = [Drawing.Color]::FromArgb(120,220,120)
        } else {
            $script:labels[$currentName].ForeColor = $FG
        }
    }.GetNewClosure())
    $cb.Tag = $name
    $scroll.Controls.Add($cb)
    $script:checks[$name] = $cb

    $lbl = [Windows.Forms.Label]::new()
    $lbl.Text      = $name
    $lbl.Location  = [Drawing.Point]::new(38, $y + 2)
    $lbl.Size      = [Drawing.Size]::new(340, 20)
    $lbl.ForeColor = $FG
    $lbl.Font      = $FONT_BODY
    $lbl.Cursor    = [Windows.Forms.Cursors]::Hand
    $lbl.Tag = $name
    $lbl.Add_Click({
        $currentName = $this.Tag
        $script:checks[$currentName].Checked = !$script:checks[$currentName].Checked
    }.GetNewClosure())
    $scroll.Controls.Add($lbl)
    $script:labels[$name] = $lbl

    $y += 26
}

# Botones
$btnSelectAll = New-FlatButton "Sel. todo"   ([Drawing.Point]::new(60,  500)) ([Drawing.Size]::new(100, 30)) ([Drawing.Color]::FromArgb(100,100,100))
$btnApply = New-FlatButton "Aplicar"   ([Drawing.Point]::new(170,  500)) ([Drawing.Size]::new(100, 30)) ([Drawing.Color]::FromArgb(120,220,120))
$btnUpdate = New-FlatButton "Actualizar"  ([Drawing.Point]::new(280, 500)) ([Drawing.Size]::new(100, 30)) ([Drawing.Color]::FromArgb(120,180,255))

$form.Controls.AddRange(@($btnSelectAll, $btnApply, $btnUpdate))

# Barra de estado
$script:status = [Windows.Forms.Label]::new()
$script:status.Location  = [Drawing.Point]::new(16, 540)
$script:status.Size      = [Drawing.Size]::new(386, 16)
$script:status.ForeColor = $MUTED
$script:status.Font      = [Drawing.Font]::new("Segoe UI", 7.5)
$script:status.Text      = "Listo."
$form.Controls.Add($script:status)

# Cargar estado actual al iniciar
Update-CurrentState

# Eventos

$btnSelectAll.Add_Click({
    foreach ($cb in $script:checks.Values) {
        $cb.Checked = $true
    }
    $script:status.ForeColor = $MUTED
    $script:status.Text = "Todas las politicas seleccionadas."
})

$btnApply.Add_Click({
    $count = 0
    foreach ($name in $POLICIES.Keys) {
        $p = $POLICIES[$name]
        if ($script:checks[$name].Checked) {
            try {
                Set-ItemProperty -Path $REG_PATH -Name $p.Key -Value $p.Val -Type $p.T -Force
                $count++
            } catch { }
        } else {
            try {
                Remove-ItemProperty -Path $REG_PATH -Name $p.Key -Force -ErrorAction SilentlyContinue
            } catch { }
        }
    }
    Update-CurrentState
    $script:status.ForeColor = [Drawing.Color]::FromArgb(120,220,120)
    $script:status.Text = "Aplicadas $count politicas. Reinicia Brave."
})

$btnUpdate.Add_Click({
    Update-CurrentState
    $script:status.ForeColor = $MUTED
    $script:status.Text = "Estado actualizado."
})

[void]$form.ShowDialog()
