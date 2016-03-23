class OneSwitchTimer extends _Plugin {
	Type := "OneSwitch Timer"
	Description := "Will exit to a specified profile if no inputs are used on this profile within a set time"
	
	TimerState := 0
	
	Init(){
		this.ExitFn := this.ExitProfile.Bind(this)
		this.AddControl("Profile", this.MyEditChanged.Bind(this), "Edit", "w300")
		this.ParentProfile.SubscribeToStateChange(this, this.InputChangedState.Bind(this))
	}
	
	SetTimerState(state){
		this.TimerState := state
		fn := this.ExitFn
		if (state){
			Settimer, % fn, -3000
		} else {
			Settimer, % fn, Off
		}
	}

	; The plugin became active (changed to plugin's profile)
	OnActive(){
		this.SetTimerState(1)
	}
	
	; The plugin became inactive
	OnInactive(){
		this.SetTimerState(0)
	}
	
	; One of the Inputs on this profile changed state
	InputChangedState(ipt, state){
		; Reset the timer
		this.SetTimerState(1)
	}
	
	ExitProfile(){
		if (!UCR.ChangeProfile(this.GuiControls.Profile.value)){
			SoundBeep
		}
	}
}