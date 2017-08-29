function Initialize-RawUI($fgColor, $bgColor)
{
    $script:ui=(get-host).ui
    $script:rui=$script:ui.rawui
    $script:rui.BackgroundColor=$bgColor
    $script:rui.ForegroundColor=$fgColor
    $script:cursor = new-object System.Management.Automation.Host.Coordinates
    Clear-Host
}

function Write-Direct($x, $y, $text, $fgColor, $bgColor)
{
    $script:cursor.x = $x
    $script:cursor.y = $y
    $script:rui.cursorposition = $script:cursor
    write-host -foregroundcolor $fgColor -backgroundcolor $bgColor -nonewline $text
}

function Get-X($x)
{
    if($x -eq 0){ $xaxis = 0}
    if($x -eq 1){ $xaxis = 4}
    if($x -eq 2){ $xaxis = 8}
    return $xaxis
}

function Get-Y($y)
{
    if($y -eq 0){ $yaxis = 0}
    if($y -eq 1){ $yaxis = 4}
    if($y -eq 2){ $yaxis = 8}
    return $yaxis
}

function Draw-X($xblock, $yblock, $selected)
{
    $c1 = "yellow"
    $c2 = "black"
    $x = Get-X $xblock
    $y = Get-Y $yblock
    if($selected){$c2 = "darkgray"}
    Write-Direct $x $y "\ /" $c1 $c2;
    Write-Direct $x ($y+1) " x " $c1 $c2;
    Write-Direct $x ($y+2) "/ \" $c1 $c2;
}

function Draw-O($xblock, $yblock, $selected)
{
    $c1 = "green"
    $c2 = "black"
    if($selected){$c2 = "darkgray"}
    $x = Get-X $xblock
    $y = Get-Y $yblock
    Write-Direct $x $y "/-\" $c1 $c2;
    Write-Direct $x ($y+1) "| |" $c1 $c2;
    Write-Direct $x ($y+2) "\_/" $c1 $c2;
}

function Draw-SelectedNull($xblock, $yblock)
{
    $c1 = "white"
    $c2 = "darkgray"
    $x = Get-X $xblock
    $y = Get-Y $yblock
    Write-Direct $x $y "+-+" $c1 $c2;
    Write-Direct $x ($y+1) "| |" $c1 $c2;
    Write-Direct $x ($y+2) "+-+" $c1 $c2;
}

function Draw-Board()
{
    $c1 = "blue"
    $c2 = "black"
    $x = 0
    while ($x -lt 11) {
        Write-Direct $x 3 "-" $c1 $c2
        Write-Direct $x 7 "-" $c1 $c2
        $x++
    }
    $y=0
    while ($y -lt 11) {
        Write-Direct 3 $y "|" $c1 $c2
        Write-Direct 7 $y "|" $c1 $c2
        $y++
    }
}

function Draw-Game($gamemap)
{
    Draw-Board
    $x=0;
    while($x -lt 3) {
        $y=0;
        while($y -lt 3) {
            $sym = $gamemap[$x][$y][0]
            $sel = $gamemap[$x][$y][1]
            if($sel -eq 1) {
                if($sym -eq 0){Draw-SelectedNull $x $y}
                if($sym -eq 1){Draw-X $x $y $true}
                if($sym -eq 2){Draw-O $x $y $true}
            }
            elseif ($sel -eq 0) {
                if($sym -eq 1){Draw-X $x $y $false}
                if($sym -eq 2){Draw-O $x $y $false}
            }
            $y++
        }
        $x++
    }
}

function Move-Selected($move,$gamemap)
{
    $x = 0;
    $y = 0;
    for ($i = 0; $i -lt $gamemap.Count; $i++) {
        for ($j=0; $j -lt $gamemap[$i].Count; $j++) {
            if ($gamemap[$i][$j][1] -eq 1) {
                $x = $i;
                $y = $j;
                $gamemap[$i][$j][1] = 0;
            }
        }
    }
    if($move -eq "a") {
        #move left
        if($x -eq 0) {
            if($y -eq 0) {
                $x = 2
                $y = 2
            } else {
                $y--
                $x = 2
            }
        } else {
            $x--
        }
    } elseif($move -eq "d") {
        #move right
        if($x -eq 2) {
            if($y -eq 2) {
                $x = 0
                $y = 0
            } else {
                $y++
                $x = 0
            }
        } else {
            $x++
        }
    }
    $gamemap[$x][$y][1] = 1;
    return $gamemap
}

function Set-Sym($sym,$gamemap)
{
    $x = 0
    $y = 0
    for ($i = 0; $i -lt $gamemap.Count; $i++) {
        for ($j=0; $j -lt $gamemap[$i].Count; $j++) {
            if ($gamemap[$i][$j][1] -eq 1) {
                $x = $i;
                $y = $j;
            }
        }
    }
    if($gamemap[$x][$y][0] -eq 0) { $gamemap[$x][$y][0] = $sym }
    return $gamemap
}

function Has-GameWon($gm)
{
    $sym = 0;
    #logic to check whether game has been won or not
    if(($gm[0][0][0] -eq $gm[0][1][0]) -and ($gm[0][0][0] -eq $gm[0][2][0]) -and ($gm[0][0][0] -ne 0)) { $sym = $gm[0][0][0] }
    elseif(($gm[1][0][0] -eq $gm[1][1][0]) -and ($gm[1][0][0] -eq $gm[1][2][0]) -and ($gm[1][0][0] -ne 0)) { $sym = $gm[1][0][0] }
    elseif(($gm[2][0][0] -eq $gm[2][1][0]) -and ($gm[2][0][0] -eq $gm[2][2][0]) -and ($gm[2][0][0] -ne 0)) { $sym = $gm[2][0][0] }
    elseif(($gm[0][0][0] -eq $gm[1][0][0]) -and ($gm[0][0][0] -eq $gm[2][0][0]) -and ($gm[0][0][0] -ne 0)) { $sym = $gm[0][0][0] }
    elseif(($gm[0][1][0] -eq $gm[1][1][0]) -and ($gm[0][1][0] -eq $gm[2][1][0]) -and ($gm[0][1][0] -ne 0)) { $sym = $gm[0][1][0] }
    elseif(($gm[0][2][0] -eq $gm[1][2][0]) -and ($gm[0][2][0] -eq $gm[2][2][0]) -and ($gm[0][2][0] -ne 0)) { $sym = $gm[0][2][0] }
    elseif(($gm[0][0][0] -eq $gm[1][1][0]) -and ($gm[0][0][0] -eq $gm[2][2][0]) -and ($gm[0][0][0] -ne 0)) { $sym = $gm[0][0][0] }
    elseif(($gm[0][2][0] -eq $gm[1][1][0]) -and ($gm[0][2][0] -eq $gm[2][0][0]) -and ($gm[0][2][0] -ne 0)) { $sym = $gm[0][2][0] }
    else {
        $isEmpty = $false
        for ($i = 0; $i -lt $gm.Count; $i++) {
            for ($j=0; $j -lt $gm[$i].Count; $j++) {
                if ($gm[$i][$j][0] -eq 0) { $isEmpty = $true }
            }
        } if(!$isEmpty){$sym=3}
    }
    if($sym -eq 1) {
        $c1 = "red"
        $c2 = "black"
        Write-Direct 0 12 "Game Over: X Has Won" $c1 $c2
        Write-Direct 0 13 "" $c1 $c2
        exit
    } elseif($sym -eq 2) {
        $c1 = "red"
        $c2 = "black"
        Write-Direct 0 12 "Game Over: O Has Won" $c1 $c2
        Write-Direct 0 13 "" $c1 $c2
        exit
    } elseif($sym -eq 3) {
        $c1 = "red"
        $c2 = "black"
        Write-Direct 0 12 "Game Over: Alas Its a Draw" $c1 $c2
        Write-Direct 0 13 "" $c1 $c2
        exit
    }
}

# Main Program Starts here
if ($host.name -ne "ConsoleHost")  {
  write-host "This script should only be run in a ConsoleHost window (outside of the ISE)"
  exit
  $done=$true
}
Initialize-RawUI "white" "black"
$gamemap = @(((0,1),(0,0),(0,0)),((0,0),(0,0),(0,0)),((0,0),(0,0),(0,0)))
Draw-Game $gamemap
$done = $false
$isX = $true
while (!$done) {
    if ($script:rui.KeyAvailable) {
        $key = $script:rui.ReadKey()
        if ($key.keydown) {
            if ($key.virtualkeycode -eq 81) {
                $done=$true
                Clear-Host
            }
            # Draw X
            if ($key.virtualkeycode -eq 88) {
                if($isX) {
                    $gamemap = Set-Sym 1 $gamemap
                    $isX = $false
                }
                Initialize-RawUI "white" "black"
                Draw-Game $gamemap
                Has-GameWon $gamemap
            }
            # Draw O
            if ($key.virtualkeycode -eq 79) {
                if(!$isX) {
                    $gamemap = Set-Sym 2 $gamemap
                    $isX = $true
                }
                Initialize-RawUI "white" "black"
                Draw-Game $gamemap
                Has-GameWon $gamemap
            }
            # Left
            if ($key.virtualkeycode -eq 37) {
                $gamemap = Move-Selected "a" $gamemap
                Initialize-RawUI "white" "black"
                Draw-Game $gamemap
            }   
            # Right
            if ($key.virtualkeycode -eq 39) {
                $gamemap = Move-Selected "d" $gamemap
                Initialize-RawUI "white" "black"
                Draw-Game $gamemap
            }
        }
    }
}