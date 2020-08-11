//Version 5 by ShiningFace
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

	if ((settings["timerPopup"]) && timer.CurrentTimingMethod == TimingMethod.RealTime)
	{        
		var timingMessage = MessageBox.Show
		("This game uses Loadless (Game Time) as the main timing method.\n"+
		"LiveSplit is currently set to show RTA (Real Time).\n"+
		"Would you like to set the timing method to Game Time?",
		"Prey (2017) | LiveSplit",
		MessageBoxButtons.YesNo,MessageBoxIcon.Question);
	
		if (timingMessage == DialogResult.Yes) 
		{
			timer.CurrentTimingMethod = TimingMethod.GameTime;
		}
	}
	
	if ((settings["splitPopup"]) && timer.Run.CategoryName != "Any%")
	{	
		var timingMessage = MessageBox.Show
		("Auto Splitting fuctionality is currently only available for Any%.\n"+
		"Another category is selected, therefore splitting must be performed manually.",
		"Prey (2017) | LiveSplit",
		MessageBoxButtons.OK);
	}
}

startup
{
	vars.setGameTime = false;
	vars.stopwatch = new Stopwatch();
	vars.splitCounter = 0;
	vars.splitDelay = 0;
	vars.cutsceneStartup = 0;
	settings.Add("timerPopup", true, "Prompt to use Loadless on startup");
	settings.Add("splitPopup", true, "Inform that Auto Splitting does not work outside of Any%");
}


start
{
	vars.splitCounter = 0;
	vars.splitDelay = 0;
	vars.cutsceneStartup = 0;
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
	
	//Only Auto Split if the current category is set to Any% or Default in LiveSplit
	if (timer.Run.CategoryName == "Any%")
	{
		if (current.isLoading && current.isLoadingMain && !old.isLoadingMain && current.menuMode != 3)
		{
			vars.splitCounter += 1;
		}
		
		if (current.isLoading && current.isLoadingMain && !old.isLoadingMain && current.menuMode != 3)
		{
			vars.splitDelay = 1;
		}
			else if (vars.cutsceneStartup == 1)
			{
				vars.splitDelay = 1;
			}
			
		if (vars.splitCounter == 10 && current.isInCutscene == 1)
		{
			vars.cutsceneStartup += 1;
		}
			else if (vars.splitCounter != 10)
			{
				vars.cutsceneStartup = 0;
			}
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
