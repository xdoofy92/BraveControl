#Requires -Version 5.1

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

param(
    [switch]$Bypass,
    [switch]$Remote
)

# Elevacion a administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    if ($Remote -or -not $PSCommandPath) {
        # Ejecucion remota: descargar y ejecutar como admin
        $url = "https://raw.githubusercontent.com/xdoofy92/BraveOrigins/main/BraveOrigins.ps1"
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

# â”€â”€ Constantes â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

$REG_PATH  = "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave"
$APP_TITLE = "BraveOrigins"

$DARK  = [Drawing.Color]::FromArgb(18, 18, 18)
$PANEL = [Drawing.Color]::FromArgb(28, 28, 28)
$BORDER= [Drawing.Color]::FromArgb(48, 48, 48)
$FG    = [Drawing.Color]::FromArgb(220, 220, 220)
$MUTED = [Drawing.Color]::FromArgb(130, 130, 130)
$ACCENT= [Drawing.Color]::FromArgb(255, 120, 80)

$FONT_BODY  = [Drawing.Font]::new("Segoe UI", 9)
$FONT_LABEL = [Drawing.Font]::new("Segoe UI", 8, [Drawing.FontStyle]::Bold)

if (-not (Test-Path $REG_PATH)) { New-Item $REG_PATH -Force | Out-Null }

# â”€â”€ Policies â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

$POLICIES = [ordered]@{
    "Leo (AI Chat)"              = @{ Key = "BraveAIChatEnabled";         Val = 0; T = "DWord" }
    "Noticias"                   = @{ Key = "BraveNewsDisabled";          Val = 1; T = "DWord" }
    "Lista de reproduccion"      = @{ Key = "BravePlaylistEnabled";       Val = 0; T = "DWord" }
    "Recompensas + Brave Ads"    = @{ Key = "BraveRewardsDisabled";       Val = 1; T = "DWord" }
    "Lector rapido"              = @{ Key = "BraveSpeedreaderEnabled";    Val = 0; T = "DWord" }
    "P3A (analisis de producto)" = @{ Key = "BraveP3AEnabled";            Val = 0; T = "DWord" }
    "Ping de uso diario"         = @{ Key = "BraveStatsPingEnabled";      Val = 0; T = "DWord" }
    "Hablar (Talk)"              = @{ Key = "BraveTalkDisabled";          Val = 1; T = "DWord" }
    "Tor"                        = @{ Key = "TorDisabled";                Val = 1; T = "DWord" }
    "VPN"                        = @{ Key = "BraveVPNDisabled";           Val = 1; T = "DWord" }
    "Monedero + Web3"            = @{ Key = "BraveWalletDisabled";        Val = 1; T = "DWord" }
    "Wayback Machine"            = @{ Key = "BraveWaybackMachineEnabled"; Val = 0; T = "DWord" }
    "Web Discovery"              = @{ Key = "BraveWebDiscoveryEnabled";   Val = 0; T = "DWord" }
    "Alias de correo (Nightly)"  = @{ Key = "BraveEmailAliasesEnabled";   Val = 0; T = "DWord" }
}

# â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

function Set-Policies {
    $ok = 0; $fail = 0
    foreach ($name in Get-ActivePolicies) {
        $p = $POLICIES[$name]
        try {
            Set-ItemProperty -Path $REG_PATH -Name $p.Key -Value $p.Val -Type $p.T -Force
            $ok++
        } catch { $fail++ }
    }
    return $ok, $fail
}

function Reset-Policies {
    $confirm = [Windows.Forms.MessageBox]::Show(
        "Se eliminaran todas las politicas de Brave del registro.`nÂ¿Continuar?",
        $APP_TITLE, "YesNo", "Warning")
    if ($confirm -ne "Yes") { return $false }
    try {
        Remove-Item $REG_PATH -Recurse -Force -ErrorAction Stop
        New-Item $REG_PATH -Force | Out-Null
        return $true
    } catch {
        [Windows.Forms.MessageBox]::Show("Error al resetear: $_", $APP_TITLE, "OK", "Error")
        return $false
    }
}

function Export-Config {
    $dlg = [Windows.Forms.SaveFileDialog]::new()
    $dlg.Title           = "Exportar configuracion"
    $dlg.Filter          = "JSON (*.json)|*.json"
    $dlg.FileName        = "BraveOrigins-config.json"
    $dlg.InitialDirectory= [Environment]::GetFolderPath("MyDocuments")
    if ($dlg.ShowDialog() -ne "OK") { return }
    $data = @{ Active = @(Get-ActivePolicies) } | ConvertTo-Json
    try {
        $data | Out-File $dlg.FileName -Force -Encoding utf8
        [Windows.Forms.MessageBox]::Show("Exportado en:`n$($dlg.FileName)", $APP_TITLE, "OK", "Information")
    } catch {
        [Windows.Forms.MessageBox]::Show("Error al exportar: $_", $APP_TITLE, "OK", "Error")
    }
}

function Import-Config {
    $dlg = [Windows.Forms.OpenFileDialog]::new()
    $dlg.Title           = "Importar configuracion"
    $dlg.Filter          = "JSON (*.json)|*.json"
    $dlg.InitialDirectory= [Environment]::GetFolderPath("MyDocuments")
    if ($dlg.ShowDialog() -ne "OK") { return }
    try {
        $data = Get-Content $dlg.FileName -Raw | ConvertFrom-Json
        foreach ($cb in $script:checks.Values) { $cb.Checked = $false }
        foreach ($name in $data.Active) {
            if ($script:checks.ContainsKey($name)) { $script:checks[$name].Checked = $true }
        }
        [Windows.Forms.MessageBox]::Show("Importado desde:`n$($dlg.FileName)", $APP_TITLE, "OK", "Information")
    } catch {
        [Windows.Forms.MessageBox]::Show("Error al importar: $_", $APP_TITLE, "OK", "Error")
    }
}

# â”€â”€ UI â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

$form = [Windows.Forms.Form]::new()
$form.Text            = $APP_TITLE
$form.Size            = [Drawing.Size]::new(420, 560)
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
$lblTitle.Text      = "BraveOrigins"
$lblTitle.Font      = [Drawing.Font]::new("Segoe UI", 13, [Drawing.FontStyle]::Bold)
$lblTitle.ForeColor = $ACCENT
$lblTitle.Location  = [Drawing.Point]::new(20, 12)
$lblTitle.AutoSize  = $true
$header.Controls.Add($lblTitle)

$lblSub = [Windows.Forms.Label]::new()
$lblSub.Text      = "Politicas de Brave via registry"
$lblSub.Font      = [Drawing.Font]::new("Segoe UI", 8)
$lblSub.ForeColor = $MUTED
$lblSub.Location  = [Drawing.Point]::new(130, 18)
$lblSub.AutoSize  = $true
$header.Controls.Add($lblSub)

# Panel de checks con scroll
$scroll = [Windows.Forms.Panel]::new()
$scroll.Location    = [Drawing.Point]::new(16, 60)
$scroll.Size        = [Drawing.Size]::new(386, 390)
$scroll.BackColor   = $PANEL
$scroll.AutoScroll  = $true
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
$y = 34

foreach ($name in $POLICIES.Keys) {
    $cb = [Windows.Forms.CheckBox]::new()
    $cb.Text      = $name
    $cb.Location  = [Drawing.Point]::new(12, $y)
    $cb.Size      = [Drawing.Size]::new(360, 22)
    $cb.ForeColor = $FG
    $cb.FlatStyle = "Flat"
    $cb.Cursor    = [Windows.Forms.Cursors]::Hand
    $scroll.Controls.Add($cb)
    $script:checks[$name] = $cb
    $y += 26
}

# Seleccionar/deseleccionar todo
$script:chkAll = [Windows.Forms.CheckBox]::new()
$script:chkAll.Text      = "Seleccionar todo"
$script:chkAll.Location  = [Drawing.Point]::new(28, 458)
$script:chkAll.AutoSize  = $true
$script:chkAll.ForeColor = $MUTED
$script:chkAll.FlatStyle = "Flat"
$script:chkAll.Cursor    = [Windows.Forms.Cursors]::Hand
$form.Controls.Add($script:chkAll)

$script:chkAll.Add_CheckedChanged({
    foreach ($cb in $script:checks.Values) { $cb.Checked = $script:chkAll.Checked }
})

# Botones
$btnApply  = New-FlatButton "Aplicar"   ([Drawing.Point]::new(16,  490)) ([Drawing.Size]::new(88, 30)) ([Drawing.Color]::FromArgb(120,220,120))
$btnExport = New-FlatButton "Exportar"  ([Drawing.Point]::new(114, 490)) ([Drawing.Size]::new(88, 30)) ([Drawing.Color]::FromArgb(120,180,255))
$btnImport = New-FlatButton "Importar"  ([Drawing.Point]::new(212, 490)) ([Drawing.Size]::new(88, 30)) ([Drawing.Color]::FromArgb(200,200,200))
$btnReset  = New-FlatButton "Resetear"  ([Drawing.Point]::new(310, 490)) ([Drawing.Size]::new(88, 30)) ([Drawing.Color]::FromArgb(255,110,110))

$form.Controls.AddRange(@($btnApply, $btnExport, $btnImport, $btnReset))

# Barra de estado
$script:status = [Windows.Forms.Label]::new()
$script:status.Location  = [Drawing.Point]::new(16, 526)
$script:status.Size      = [Drawing.Size]::new(386, 16)
$script:status.ForeColor = $MUTED
$script:status.Font      = [Drawing.Font]::new("Segoe UI", 7.5)
$script:status.Text      = "Listo."
$form.Controls.Add($script:status)

# â”€â”€ Eventos â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

$btnApply.Add_Click({
    $active = @(Get-ActivePolicies)
    if ($active.Count -eq 0) {
        $script:status.Text = "Ninguna politica seleccionada."
        return
    }
    $ok, $fail = Set-Policies
    if ($fail -eq 0) {
        $script:status.ForeColor = [Drawing.Color]::FromArgb(120,220,120)
        $script:status.Text = "Aplicadas $ok politicas correctamente. Reinicia Brave."
    } else {
        $script:status.ForeColor = [Drawing.Color]::FromArgb(255,160,80)
        $script:status.Text = "$ok aplicadas, $fail fallaron."
    }
})

$btnExport.Add_Click({ Export-Config })
$btnImport.Add_Click({ Import-Config })

$btnReset.Add_Click({
    if (Reset-Policies) {
        foreach ($cb in $script:checks.Values) { $cb.Checked = $false }
        $script:chkAll.Checked = $false
        $script:status.ForeColor = $MUTED
        $script:status.Text = "Todas las politicas eliminadas del registro."
    }
})

[void]$form.ShowDialog()
