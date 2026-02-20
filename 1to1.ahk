#NoEnv
#SingleInstance, Force
#Persistent
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen

; ============================================================================
; CONFIGURATION
; ============================================================================
global ClickPoints := []  ; Array to store click points
global ShowOverlay := false ; Toggle overlay visibility
global HotkeyTrigger := true   ; Toggle HotkeyTrigger mode
global ContextWindow := 0 ; hwnd of the window to trigger the hotkey
global SelectedPoint := 0  ; Currently selected point index
global PointRadius := 15   ; Radius of circles

; Define the 12 keys
global Keys := ["q", "w", "e", "r", "a", "s", "d", "f", "z", "x", "c", "v"]

; ============================================================================
; INITIALIZATION
; ============================================================================
InitializePoints()
CreateTrayMenu()
ShowInstructions()

; Create hotkeys for all 12 keys
for index, key in Keys {
    hotkeyString := "~" . key
    Hotkey, %hotkeyString%, PointClick
}

; ============================================================================
; HOTKEYS
; ============================================================================
; Toggle overlay
!o::  ; Alt+O
    ShowOverlay := !ShowOverlay
    if (ShowOverlay){
        SetTimer, DrawOverlay, 50
    }
    else{
        SetTimer, DrawOverlay, Off
        loop, % ClickPoints.length(){
            ToolTip,,,, % A_Index
        }
    }
    return

; Reset all points to default positions
!r::  ; Alt+R
    InitializePoints()
    ToolTip, All points reset to default positions, 500, 500, 13
    SetTimer, RemoveTip, -2000
    return

; Disable/Enable Hotkey Trigger
!h::  ; Alt+H
    HotkeyTrigger := !HotkeyTrigger
    return

; Select the context sensitive window
!w::  ; Alt+W
    ContextWindow := WinExist("A")
    WinGetTitle, wTitle, ahk_id %ContextWindow%
    ToolTip, % "Context Window Selected: " . wTitle, 500, 500, 13
    SetTimer, RemoveTip, -3000
    return

; ============================================================================
; MOUSE CONTROLS
; ============================================================================
~LButton::
        MouseGetPos, x, y
        ; Check if clicking on a point
        SelectedPoint := FindPointAt(x, y)
    return

~LButton Up::
    if (SelectedPoint > 0) {
        ; Update point position
        MouseGetPos, x, y
        ClickPoints[SelectedPoint].X := x
        ClickPoints[SelectedPoint].Y := y
        SelectedPoint := 0
    }
    return

; ============================================================================
; FUNCTIONS
; ============================================================================

InitializePoints() {
    global ClickPoints, Keys
    ClickPoints := []
    
    ; Create 12 points in a grid layout
    cols := 4
    rows := 3
    row := 0
    col := 0
    margin := 150
    spacingX := 30
    spacingY := 30
    
    index := 1
    loop %rows% {
        row++
        loop %cols% {
            col++
            if (index <= 12) {
                x := margin + (col * spacingX)
                y := margin + (row * spacingY)
                
                point := {X: x, Y: y, Key: Keys[index]}
                ClickPoints.Push(point)
                index++
            }
        }
        col := 0
    }
}

FindPointAt(x, y) {
    global ClickPoints, PointRadius
    for index, point in ClickPoints {
        distance := Sqrt((point.X - x)**2 + (point.Y - y)**2)
        if (distance <= PointRadius) {
            return index
        }
    }
    return 0
}

PointClick:
    ; Check if the window is the context window
    if (ContextWindow && ContextWindow != WinExist("A"))
        return

    if (!HotkeyTrigger)
        return
    ; Find which key was pressed
    pressedKey := SubStr(A_ThisHotkey, 2) ; Remove the ~ prefix
    ; Find the point with this key
    for index, point in ClickPoints {
        if (point.Key = pressedKey) {
            ClickPoint(point)
            break
        }
    }
return

ClickPoint(point) {
    MouseMove, point.X, point.Y, 0
    Click
    
    /*  
    ; Visual feedback (flash the circle)
    FlashPoint(point)q
    */
}

FlashPoint(point) {
    ; Quick visual feedback
}

DrawOverlay() {
    global ClickPoints, ShowOverlay
    
    if (!ShowOverlay)
        return
 
    ; Draw all points
    for index, point in ClickPoints {
        ; Draw circle around point

        ; Show key in center
        ToolTip, % point.Key, % point.X-8, % point.Y-12, % index
        
    }
}

RemoveTip() {
    ToolTip,,,, 13
}

ShowInstructions() {
    MsgBox, 64, 12-Point Click Automation, 
    (
    12 FIXED POINTS - KEYS: Q W E R A S D F Z X C V
    ===============================================
    
    USAGE:
    - Press any of the 12 keys to click at its assigned position
    - Click and drag circles to reposition them
    
    CONTROLS:
    Alt+O - Toggle visual overlay on/off
    Alt+R - Reset all points to default positions
    Alt+H - Toggle Hotkey Trigger mode
    Alt+W - Select the context sensitive window

    The circles will always show which key is assigned
    )
}

CreateTrayMenu() {
    Menu, Tray, Add, Show Overlay, ToggleOverlay
    Menu, Tray, Add, Toggle Hotkeys, ToggleHotkeyTrigger
    Menu, Tray, Add, Reset Points, ResetPoints
    Menu, Tray, Add, Reset Context Window, ResetContextWindow
    Menu, Tray, Add  ; Separator
    Menu, Tray, Add, Instructions, ShowInstructions
    Menu, Tray, Default, Instructions
}


ToggleOverlay:
    ShowOverlay := !ShowOverlay
    ; Clear all tooltips
    loop, % ClickPoints.length(){
        ToolTip,,,, % A_Index
    }
return

ToggleHotkeyTrigger:
    HotkeyTrigger := !HotkeyTrigger
return

ResetPoints:
    InitializePoints()
    ToolTip, All points reset, 500, 500, 13
    SetTimer, RemoveTip, -1500
return

ResetContextWindow:
    ContextWindow := 0
return

; ============================================================================
; TIMERS
; ============================================================================
SetTimer, DrawOverlay, 50  ; Update overlay every 50ms

; ============================================================================
; EXIT
; ============================================================================
GuiClose:
ExitApp