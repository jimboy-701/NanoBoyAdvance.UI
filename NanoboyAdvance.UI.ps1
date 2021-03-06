## Load required assemblies
#
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
Add-Type -AssemblyName System.Windows.Forms

## Hide the PowerShell window: https://stackoverflow.com/a/27992426/1069307
#
$t = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);'
add-type -name win -member $t -namespace native
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0)

[xml]$xaml = @'
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"

        Title="NanoboyAdvance.UI" Height="183" Width="359" WindowStartupLocation="CenterScreen">

    <Grid ShowGridLines="True">
        <!-- <Label Content="Screen Size" HorizontalAlignment="Left" Margin="18,75,0,0" VerticalAlignment="Top" Width="130" FontSize="14" Height="85"/> -->
        <ComboBox x:Name="ScreenSize" HorizontalAlignment="Left" Margin="15,60,0,0" VerticalAlignment="Top" Width="120" Height="21">
            <ComboBoxItem Content="--fullscreen" HorizontalAlignment="Left" Width="118"/>
            <ComboBoxItem Content="--scale 3" HorizontalAlignment="Left" Width="118"/>
            <ComboBoxItem Content="--scale 4" HorizontalAlignment="Left" Width="118"/>
            <ComboBoxItem Content="--scale 5" HorizontalAlignment="Left" Width="118"/>
            <ComboBoxItem Content="--scale 6" HorizontalAlignment="Left" Width="118"/>
        </ComboBox>

        <Button x:Name="OpenRom" Content="Open Rom" HorizontalAlignment="Left" Margin="15.143,33.048,0,0" VerticalAlignment="Top" Width="75"/>
        <Button x:Name="AboutInfo" Content="About" HorizontalAlignment="Left" Margin="254,86.08,0,0" VerticalAlignment="Top" Width="75"/>
        <Button x:Name="HelpInfo" Content="Help" HorizontalAlignment="Left" Margin="254,111.04,0,0" VerticalAlignment="Top" Width="75"/>
        <Button x:Name="EditConfig" Content="Edit Config" HorizontalAlignment="Left" Margin="174,111.04,0,0" VerticalAlignment="Top" Width="75"/>
        <CheckBox x:Name="SyncAudio" Content="[Sync Audio]" HorizontalAlignment="Left" Margin="114.571,33.048,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.182,-0.993"/>

        <GroupBox Header="A simple launcher for NanoboyAdvance Emulator" HorizontalAlignment="Left" Height="142" VerticalAlignment="Top" Width="336.143" FontSize="14" Margin="4,0,0,0"></GroupBox>

    </Grid>
</Window>
'@

## Read XAML
#
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try { $Form = [Windows.Markup.XamlReader]::Load( $reader ) }
catch { Write-Host "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; exit }

<#
function NullRom {
 [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
 [Microsoft.VisualBasic.Interaction]::MsgBox("Please select a GBA rom file first",'OKOnly,Information',"DGEN Error")
 }
#>

$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    InitialDirectory = [Environment]::GetFolderPath('Desktop')
    Filter           = 'Gameboy Advance (*.gba)|*.gba|All Files (*.*)|*.*'
    Title            = 'Select GBA rom to play:'
}

## XAML objects and controls
#
$screen = $Form.FindName("ScreenSize")
$browse = $Form.FindName("OpenRom")
$about = $Form.FindName("AboutInfo")
$help = $Form.FindName("HelpInfo")
$config = $Form.FindName("EditConfig")
$checkbox = $Form.FindName("SyncAudio")

## Click Actions
#
$browse.Add_Click(
    {
        [void]$FileBrowser.ShowDialog()
        $filePath = '"' + $FileBrowser.FileName + '"'

        $arguments = $screen.SelectedItem.Content

        if ($checkbox.IsChecked -eq "True")
            {$syncaudio = ' --sync-to-audio yes'; $arguments2 = $arguments + $syncaudio}
            else {
                $arguments2 = $arguments
            }

        if ($filePath -ne '"' + '"')
            {Start-Process -Wait NanoboyAdvance.exe -ArgumentList $arguments2, $filePath}
        ## [System.Windows.MessageBox]::Show($arguments2)

        # [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
        # [Microsoft.VisualBasic.Interaction]::MsgBox("Please select a GBA rom file first",'OKOnly,Information',"NanoboyAdvance.UI Error")

    })

$about.Add_Click(
    {
        $version = HOSTNAME.EXE
        # Write-Host "$version"
        [System.Windows.MessageBox]::Show($version)
    })

$help.Add_Click(
    {
        Start-Process notepad.exe .\log.txt
    })

$config.Add_Click(
    {
        Start-Process notepad.exe .\config.toml
    })

[void]$Form.ShowDialog()
