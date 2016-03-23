/*
Maps button to other button so that pressing the former triggers the latter in rapid succesion.
Created with the help of UCR author EvilC:
http://mwomercs.com/forums/topic/220657-should-i-buy-throttle-or-rudder-pedals/page__view__findpost__p__5080027
*/
class RapidFire extends _Plugin {
	Type := "Remapper (Rapid Fire)"
	Description := "Pushing first button rapid fires the second button."

	Init() {
		this.SpamButtonFn := this.SpamButton.Bind(this)
	    Gui, Add, Text, xm y+10, % "Press"
	    this.AddInputButton("IB1", 0, this.InputChangedState.Bind(this, "IB1"), "x+5 yp-2 w150")
	    Gui, Add, Text, x+5 yp+2, % "to hold"
	    this.AddOutputButton("OB1", 0, "x+5 yp-2 w150")
		Gui, Add, Text, x+5 yp+2, % "down for"
		this.AddControl("HoldDownTime", 0, "Edit", "x+5 yp w30", "250")
		Gui, Add, Text, x+5 yp+2, % "ms. Fire every"
		; MWO likes 50ms between down and up events!
	    this.AddControl("FireRate", 0, "Edit", "x+5 yp w30", "50")
	    Gui, Add, Text, x+5 yp+2, % "ms"
	}


	SpamButton() {
		SetKeyDelay, 0, 0					; Remove all delays before or after sending key events
		this.OutputButtons.OB1.SetState(1)	; Press button
		Sleep % this.GuiControls.HoldDownTime.value
		this.OutputButtons.OB1.SetState(0)	; Release button
	}

	InputChangedState(Name, e) {
		fn := this.SpamButtonFn
		if (e) {
			Settimer, % fn, % this.GuiControls.FireRate.value
			fn.Call()
		} else {
			Settimer, % fn, Off
		}
	}
}
