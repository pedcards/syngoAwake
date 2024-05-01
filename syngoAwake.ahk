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

winStats := {}																			; map array of window
winStats.strings := {epicTitle:"Hyperspace – Production"
					,syngoTitle:"syngo Dynamics"}

SetTimer(epicWinStatus,1000)

ExitApp

; Check Epic window status. Returns TRUE if logged in.
epicWinStatus()
{
	global winStats

	if !WinExist(winStats.strings.epicTitle) {											; no Hyperspace Production window
		return false
	}
	winEpicTitle := WinGetTitle(winStats.strings.epicTitle)
	titleSplit := StrSplit(winEpicTitle," – ")
	if (titleSplit[5]="Childrens") {													; 5th string means is logged in
		return true
	}

	return false
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

