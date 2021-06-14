# Load required assemblies
Add-Type -AssemblyName System.Windows.Forms
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')

# Hide the powershell window: https://stackoverflow.com/a/27992426/1069307
$t = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);'
add-type -name win -member $t -namespace native
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0)

[xml]$XAML = @'
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"

        Title="NanoboyAdvance.UI" Height="183" Width="359" WindowStartupLocation = "CenterScreen">

    <Grid>
        <ComboBox HorizontalAlignment="Left" Margin="29.665,112.237,0,0" VerticalAlignment="Top" Width="135" Height="25">
            <ComboBoxItem Content="Default" HorizontalAlignment="Left" Width="118"/>
            <ComboBoxItem Content="Full Screen" HorizontalAlignment="Left" Width="118"/>
            <ComboBoxItem Content="800x600" HorizontalAlignment="Left" Width="118"/>
            <ComboBoxItem Content="1024x768" HorizontalAlignment="Left" Width="148"/>
        </ComboBox>
        <Button x:Name="openRom" Content="Open Rom" HorizontalAlignment="Left" Margin="15.143,33.048,0,0" VerticalAlignment="Top" Width="75"/>
        <Button x:Name="aboutInfo" Content="About" HorizontalAlignment="Left" Margin="254,86.08,0,0" VerticalAlignment="Top" Width="75"/>
        <Button x:Name="helpInfo" Content="Help" HorizontalAlignment="Left" Margin="254,111.04,0,0" VerticalAlignment="Top" Width="75"/>
        <Button x:Name="editConfig" Content="Edit Config" HorizontalAlignment="Left" Margin="174,111.04,0,0" VerticalAlignment="Top" Width="75"/>
        <CheckBox Content="Fullscreen" HorizontalAlignment="Left" Margin="114.571,33.048,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.182,-0.993"/>
       
        <GroupBox Header="A simple launcher for NanoboyAdvance Emulator" HorizontalAlignment="Left" Height="142" VerticalAlignment="Top" Width="336.143" FontSize="14" Margin="4,0,0,0">
        
        </GroupBox>

    </Grid>
</Window>
'@

# Read XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try { $Form = [Windows.Markup.XamlReader]::Load( $reader ) }
catch { Write-Host "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; exit }

$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    InitialDirectory = [Environment]::GetFolderPath('Desktop')
    Filter           = 'Gameboy Advance (*.gba)|*.gba|All Files (*.*)|*.*'
    Title            = 'Select GBA rom to play:'

}

## XAML objects and controls
$browse = $Form.FindName("openRom")
$about = $Form.FindName("aboutInfo")
$help = $Form.FindName("helpInfo")
$config = $Form.FindName("editConfig")

# Click Actions
$browse.Add_Click(
    {
        
        [void]$FileBrowser.ShowDialog()
        $filePath = '"' + $FileBrowser.FileName + '"'
        $arguments = '-f'
        Start-Process -Wait dgen.exe -ArgumentList $arguments, $filePath

        # Uncomment Below for debugging
        # [System.Windows.MessageBox]::Show($filePath)
        # Write-Host "$dgenemu" "$arguments" "$filePath"

    })

$about.Add_Click(
    { 
        $version = .\dgen.exe -v
        # Write-Host "$version"
        [System.Windows.MessageBox]::Show($version)
    
    })

$help.Add_Click(
    {
        Start-Process notepad.exe .\dgen.1.txt
    })

$config.Add_Click(
    {
        Start-Process notepad.exe .\dgen.cfg
    })

[void]$Form.ShowDialog()
