# YouTube Music Desktop - Art Mode Widget (Version 27 - PIXEL PERFECT)
# -------------------------------------------------------------------------

# 0. Completely Hide the PowerShell Terminal
Add-Type -Name Window -Namespace Win2 -MemberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);'
[Win2.Window]::ShowWindow((Get-Process -Id $PID).MainWindowHandle, 0)

if ([System.Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA') {
    powershell -NoProfile -ExecutionPolicy Bypass -Sta -File $PSCommandPath
    return
}

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# --- UI Setup ---
$window = New-Object System.Windows.Window
$window.Title = "YTM Art Mode"
$window.Height = 450
$window.Width = 450
$window.WindowStyle = "None"
$window.AllowsTransparency = $true
$window.Background = "Transparent"
$window.Topmost = $true
$window.ResizeMode = "NoResize" # THE FIX: Remove the "Permanent" native grip dots
$window.WindowStartupLocation = "CenterScreen"

# --- THE ASPECT RATIO FIX ---
$window.Add_SizeChanged({
    $size = [Math]::Max($window.ActualWidth, $window.ActualHeight)
    if ($window.ActualWidth -ne $window.ActualHeight) {
        $window.Width = $size
        $window.Height = $size
    }
})

# --- Main Layout ---
$outerBorder = New-Object System.Windows.Controls.Border
$outerBorder.Padding = "20"
$window.Content = $outerBorder

# 1. Shadow Effect
$shadow = New-Object System.Windows.Media.Effects.DropShadowEffect
$shadow.BlurRadius = 25
$shadow.ShadowDepth = 0
$shadow.Opacity = 0.8
$shadow.Color = [System.Windows.Media.Colors]::Black
$outerBorder.Effect = $shadow

# 2. The Base Card
$cardGrid = New-Object System.Windows.Controls.Grid
$outerBorder.Child = $cardGrid

# 3. The Album Art
$artImage = New-Object System.Windows.Controls.Image
$artImage.Stretch = "Uniform" 
$cardGrid.Children.Add($artImage)

# --- THE CLIPPING FIX ---
$updateClip = {
    $radius = 35
    $rect = New-Object System.Windows.Rect(0, 0, $artImage.ActualWidth, $artImage.ActualHeight)
    $artImage.Clip = New-Object System.Windows.Media.RectangleGeometry($rect, $radius, $radius)
}
$artImage.Add_SizeChanged($updateClip)

# 4. Pill-Shaped Info Tag
$pillBorder = New-Object System.Windows.Controls.Border
$pillBorder.CornerRadius = "15"
$pillBorder.Background = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromArgb(200, 10, 10, 10))
$pillBorder.HorizontalAlignment = "Left"
$pillBorder.VerticalAlignment = "Bottom"
$pillBorder.Margin = "25,0,0,35"
$pillBorder.Padding = "12,6,12,6"
$cardGrid.Children.Add($pillBorder)

$infoStack = New-Object System.Windows.Controls.StackPanel
$pillBorder.Child = $infoStack

$titleText = New-Object System.Windows.Controls.TextBlock
$titleText.Foreground = [System.Windows.Media.Brushes]::White
$titleText.FontSize = 11
$titleText.FontFamily = "Consolas"
$titleText.Text = "connecting..."
$infoStack.Children.Add($titleText)

$artistText = New-Object System.Windows.Controls.TextBlock
$artistText.Foreground = [System.Windows.Media.Brushes]::DarkGray
$artistText.FontSize = 9
$artistText.FontFamily = "Consolas"
$artistText.Text = ""
$infoStack.Children.Add($artistText)

# 5. Lofi Custom Progress Bar
$progressContainer = New-Object System.Windows.Controls.Canvas
$progressContainer.Height = 6
$progressContainer.VerticalAlignment = "Bottom"
$progressContainer.Margin = "40,0,40,20"
$cardGrid.Children.Add($progressContainer)

$progressBg = New-Object System.Windows.Shapes.Rectangle
$progressBg.Height = 4
$progressBg.Fill = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromArgb(80, 255, 255, 255))
$window.Add_SizeChanged({ $progressBg.Width = $progressContainer.ActualWidth })
$progressContainer.Children.Add($progressBg)

$progressFill = New-Object System.Windows.Shapes.Rectangle
$progressFill.Height = 4
$progressFill.Fill = [System.Windows.Media.Brushes]::White
$progressContainer.Children.Add($progressFill)

# 6. Close Button (X)
$closeButton = New-Object System.Windows.Controls.Button
$closeButton.Content = "X"
$closeButton.FontSize = 16
$closeButton.FontWeight = "Bold"
$closeButton.Foreground = [System.Windows.Media.Brushes]::White
$closeButton.Background = [System.Windows.Media.Brushes]::Transparent
$closeButton.BorderThickness = 0
$closeButton.Width = 35
$closeButton.Height = 35
$closeButton.HorizontalAlignment = "Right"
$closeButton.VerticalAlignment = "Top"
$closeButton.Margin = "10"
$closeButton.Opacity = 0
$closeButton.Cursor = [System.Windows.Input.Cursors]::Hand
$cardGrid.Children.Add($closeButton)

# 7. --- CUSTOM RESIZE GRIP (The Hover-Only dots) ---
$resizeGrip = New-Object System.Windows.Controls.Primitives.ResizeGrip
$resizeGrip.Width = 15
$resizeGrip.Height = 15
$resizeGrip.HorizontalAlignment = "Right"
$resizeGrip.VerticalAlignment = "Bottom"
$resizeGrip.Opacity = 0 # Hidden by default
$resizeGrip.Margin = "0,0,5,5"
$cardGrid.Children.Add($resizeGrip)

# THE REAL RESIZE LOGIC: Since we turned off native resize, we must use the grip to trigger it
$resizeGrip.Add_MouseLeftButtonDown({
    # We turn native resize back on ONLY while dragging
    $window.ResizeMode = "CanResizeWithGrip"
})
$resizeGrip.Add_MouseLeftButtonUp({
    $window.ResizeMode = "NoResize" # Turn it back off when done
})

# HOVER LOGIC for UI Elements
$window.Add_MouseEnter({ 
    $closeButton.Opacity = 0.8
    $resizeGrip.Opacity = 0.8
})
$window.Add_MouseLeave({ 
    $closeButton.Opacity = 0
    $resizeGrip.Opacity = 0
})
$closeButton.Add_Click({ $window.Close() })

# --- Configuration ---
$script:token = ""
$script:currentArtUrl = ""
$appId = "ytm-art-widget-lofi-final"
$tokenFile = "$env:TEMP\ytm-token-final.txt"
$baseUrl = "http://localhost:9863/api/v1"

function Get-YTMToken {
    if (Test-Path $tokenFile) { 
        $t = Get-Content $tokenFile
        if ($t -and $t.Length -gt 10) { return $t }
    }
    try {
        $body = @{ appId = $appId; appName = "ArtWidget"; appVersion = "2.7.0" } | ConvertTo-Json
        $auth = Invoke-RestMethod -Method Post -Uri "$baseUrl/auth/requestcode" -Body $body -ContentType "application/json"
        $code = $auth.code
        while ($true) {
            try {
                $tokenBody = @{ appId = $appId; code = $code } | ConvertTo-Json
                $tokenResp = Invoke-RestMethod -Method Post -Uri "$baseUrl/auth/request" -Body $tokenBody -ContentType "application/json"
                if ($tokenResp.token) {
                    $tokenResp.token | Out-File $tokenFile
                    return $tokenResp.token
                }
            } catch { }
            Start-Sleep -Seconds 3
        }
    } catch { return $null }
}

$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds(2)

$timer.Add_Tick({
    if (-not $script:token) { 
        $script:token = Get-YTMToken
        if (-not $script:token) { return }
    }

    try {
        $headers = @{ "Authorization" = "$($script:token)" }
        $state = Invoke-RestMethod -Method Get -Uri "$baseUrl/state" -Headers $headers -ErrorAction Stop -TimeoutSec 3
        
        if ($state.video.title) {
            $titleText.Text = $state.video.title.ToLower()
            $artistText.Text = $state.video.author.ToLower()
        }

        if ($state.player.videoProgress -and $state.video.durationSeconds) {
            $ratio = $state.player.videoProgress / $state.video.durationSeconds
            $progressFill.Width = $progressContainer.ActualWidth * $ratio
        }

        $url = ""
        if ($state.video.thumbnails) { $url = $state.video.thumbnails[-1].url }
        if ($url -and ($url -ne $script:currentArtUrl)) {
            $script:currentArtUrl = $url
            $highResUrl = $url -replace "=w\d+-h\d+", "=w1024-h1024"
            $bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
            $bitmap.BeginInit()
            $bitmap.UriSource = [Uri]$highResUrl
            $bitmap.CacheOption = "OnLoad"
            $bitmap.EndInit()
            
            $artImage.Source = $bitmap
            $window.Dispatcher.Invoke($updateClip)
        }
    } catch {
        if ($_.Exception.Message -like "*UNAUTHORIZED*") {
            Remove-Item $tokenFile -ErrorAction SilentlyContinue
            $script:token = ""
        }
    }
})

$window.Add_MouseLeftButtonDown({ $window.DragMove() })

$timer.Start()
$window.ShowDialog() | Out-Null
