//Version 3 by ShiningFace
state("Prey", "v1.0.0.0")
{
	bool isLoading : 0x2433B13;
	bool isLoadingMain : 0x28CBDD0;
	byte isLoadingTextures : 0x24C08F6;
	byte isInCutscene : "bink2w64.dll", 0x57580;
	byte menuMode : 0x241C8A8, 0x1E60, 0x258;
}

init
{
	int moduleSize = modules.First().ModuleMemorySize;
	print("Main Module Size: "+moduleSize.ToString());
	
	if (moduleSize == 171769856)
	{
		version = "v1.0.0.0 Steam";
	}
	if (moduleSize == 174698496)
	{
		version = "v1.0.1.0 Steam";
	}
	
	if ((settings["timerPopup"]) && timer.CurrentTimingMethod == TimingMethod.RealTime)
	{        
    		var timingMessage = MessageBox.Show
			(
       			"This game uses Loadless (Game Time) as the main timing method.\n"+
    			"LiveSplit is currently set to show RTA (Real Time).\n"+
    			"Would you like to set the timing method to Game Time?",
       		 	"Prey | LiveSplit",
       			MessageBoxButtons.YesNo,MessageBoxIcon.Question
       		);
		
        	if (timingMessage == DialogResult.Yes) 
			{
				timer.CurrentTimingMethod = TimingMethod.GameTime;
        	}
	}
}

startup
{
	vars.setGameTime = false;
	vars.stopwatch = new Stopwatch();
	vars.splitNumber = 0;
	vars.splitDelay = 0;
	settings.Add("timerPopup", true, "Ask to switch to Loadless on startup");
}


start
{
	vars.splitNumber = 0;
	vars.splitDelay = 0;
	if (current.menuMode == 1 && old.menuMode == 2)
	{
		return true;
	}
}

update
{
	vars.splitDelay = Math.Max(0, vars.splitDelay-1);
	if (current.isLoading && !old.isLoading)
	{
		vars.stopwatch.Restart();
	}
	if (current.isLoading && current.isLoadingMain && !old.isLoadingMain && current.menuMode != 3)
	{
		vars.splitNumber += 1;
	}
	if (current.isLoading && current.isLoadingMain && !old.isLoadingMain && current.menuMode != 3)
	{
		vars.splitDelay = 1;
	}
	else if (vars.splitNumber == 10 && current.isInCutscene == 1)
	{
		vars.splitDelay = 1;
	}
}

split
{
	return (vars.splitDelay == 1);
}

isLoading
{
	return ((current.isLoading && vars.stopwatch.ElapsedMilliseconds < 2500) || current.isLoadingMain || current.isLoadingTextures == 1 || current.menuMode == 2);
}
