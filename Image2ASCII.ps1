# Image to ascii art converter
#

param(
  [string]$path = $(throw "Supply an image path"),
  [int]$maxwidth,
  [string]$palette="ascii",
  [float]$ratio = 1.5
  )

$path=(resolve-path -erroraction "stop" $path).path

$palettes = @{
  "ascii" = " .,:;=|iI+hHOE#`$"
  "shade" = " " + [char]0x2591 + [char]0x2592 + [char]0x2593 + [char]0x2588
  "bw"    = " " + [char]0x2588
}
$c = $palettes[$palette]
if (-not $c) {
  write-warning "palette should be one of:  $($palettes.keys.GetEnumerator())"
  write-warning "defaulting to ascii"
  $c = $palettes.ascii
}
[char[]]$charpalette = $c.ToCharArray()

# we need the drawing assembly
#$dllpath=(get-command "system.drawing.dll").definition #fixed with next two lines
$drawfile= Get-ChildItem -Path "$((Get-ChildItem Env:\windir).Value)\assembly" -Filter *drawing.dll -Recurse
$dllpath=(Get-Command $($drawfile.Fullname)).definition
[Reflection.Assembly]::LoadFrom($dllpath) | out-null
# load the image
$image = [Drawing.Image]::FromFile($path)
if ($maxwidth -le 0) { [int]$maxwidth = $host.ui.rawui.WindowSize.Width - 1}
[int]$imgwidth = $image.Width
[int]$maxheight = $image.Height / ($imgwidth / $maxwidth) / $ratio
$bitmap = new-object Drawing.Bitmap ($image,$maxwidth,$maxheight)
[int]$bwidth = $bitmap.Width; [int]$bheight = $bitmap.Height
# draw it!
$cplen = $charpalette.count
for ([int]$y=0; $y -lt $bheight; $y++) {
  $line = ""
  for ([int]$x=0; $x -lt $bwidth; $x++) {
    $colour = $bitmap.GetPixel($x,$y)
    $bright = $colour.GetBrightness()
    [int]$offset = [Math]::Floor($bright*$cplen)
    $ch = $charpalette[$offset]
    if (-not $ch) { $ch = $charpalette[-1] } #overflow
    $line += $ch
  }
  $line
}

