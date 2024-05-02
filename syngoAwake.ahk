/*  syngoAwake - keep syngo from ungracefully killing Epic
	When syngoDynamics and Epic are synced (local apps), closing syngo sends a force log off to the linked Epic

	If local Epic window is active (exists and not logged off), prevent Syngo from closing.
	If user tries to close syngo, give fair warning

	Epic logged off "Hyperspace – Production – Childrens"
	Epic login dialog "Hyperspace – Production – {nameF nameL} – Childrens"
	Epic logged on "Hyperspace – Production – {context} – {nameF nameL} – Childrens"
	Syngo window title "syngo Dynamics"
*/
#Requires AutoHotkey v2
#Warn VarUnset, OutputDebug

win := {}																				; map array of window
win.epic :=
	{
		title	: "Hyperspace – Production"
	}
win.syngo :=
	{
		title	: "syngo Dynamics",
		lastActive	: A_Now,
		inactive	: 0
	}
checkDelay := (10) *1000																; (secs) to check

SetTimer(winCheck,checkDelay)

WinWaitClose("Hyperspace")
ExitApp

; Check if Epic window exists, check if Syngo active
winCheck()
{
	if !(epicWinState()) {																; Not logged in, ignore
		win.syngo.lastActive := A_Now		
		win.syngo.inactive := 0
		return
	} else {
		syngoWinState()	 																; Perform Syngo check
	}
}

; Check Epic window state. Returns TRUE if logged in.
epicWinState()
{
	global win

	if !(winEpic := WinExist(win.epic.title)) {											; no Hyperspace Production window
		return false
	}
	fullTitle := WinGetTitle("ahk_id " winEpic)
	titleSplit := StrSplit(fullTitle," – ")
	if (ObjHasValue(titleSplit,"Childrens")=5) {										; 5th string means is logged in
		return true
	}

	return false
}

; Check Syngo window. Send key if not active.
syngoWinState()
{
	global win

	if !(winSyngo := WinExist(win.syngo.title)) {										; No Syngo window
		return
	}
	id := "ahk_id " winSyngo
	if (WinActive(id)) {																; Syngo active, no problem!
		win.syngo.lastActive := A_Now
		win.syngo.inactive := 0
		return
	} else {																			; Syngo inactive, WAKEY WAKEY!
		ControlSend("{Shift}",,id)
		win.syngo.inactive := DateDiff(A_now, win.syngo.lastActive, "Minutes")
	}
	if (win.syngo.inactive > 30) {
		MsgBox("syngoDynamics has been inactive for " win.syngo.inactive " minutes.`n`n"
			. "Please logoff syngoDynamics.`n"
			. "Be sure to save any unsaved work in Epic.")
	}
}

ObjHasValue(aObj, aValue, rx:="") {
	for key, val in aObj
		if (rx="RX") {																	; argument 3 is "RX" 
			if (aValue="") {															; null aValue in "RX" is error
				return false
			}
			if (val ~= aValue) {														; val=text, aValue=RX
				return key
			}
			if (aValue ~= val) {														; aValue=text, val=RX
				return key
			}
		} else {
			if (val = aValue) {															; otherwise just string match
				return key
			}
		}
	return false																		; fails match, return err
}
