//This is version 10
//Original by ShiningFace, edit by turtlechuck

state("sonic2app")
{
	bool runStart       : 0x0134AFFA;
	bool controlActive  : 0x0134AFFE;
	bool timerEnd       : 0x0134AFDA;
	bool levelEnd       : 0x0134B002;

	int frameCount      : 0x0134B038;
	byte timestop       : 0x0134AFF7;
	byte menuMode       : 0x01534BE0;

	byte stageID        : 0x01534B70;

	//Get minutes, seconds, and centiseconds all in one read
	int levelTimer      : 0x015457F8;  //0x019457F8
	int levelTimerClone : 0x0134AFDB;  //0x0174AFDB

	float bossHealth    : 0x019E9604, 0x48;
	
	int currMenu        : 0x0197BB10;
	int currMenuState   : 0x0197BB14;
}

init
{
	refreshRate = 60;
	
	if ((settings["timerPopup"]) && timer.CurrentTimingMethod == TimingMethod.RealTime)
	{        
    	var timingMessage = MessageBox.Show
		(
       		"This game uses Game Time (IGT) as the main timing method.\n"+
    		"LiveSplit is currently set to show Real Time (RTA).\n"+
    		"Would you like to set the timing method to Game Time?",
       		 "Sonic Adventure 2: Battle | LiveSplit",
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
	
	vars.totalTime = 0;      //Time accumulated from level timer, in centiseconds
	vars.timestopFrames = 0; //How many additional frames we added due to timestop
	vars.countFrames = false;
	vars.lastGoodTimerVal = Int32.MaxValue;
	vars.splitDelay = 0;
	vars.setGameTime = false;
	
	settings.Add("storyStart", false, "Only start timer when starting a story");
	settings.Add("timerPopup", true, "Ask to switch to IGT on startup");
	
}

update
{
	vars.splitDelay = Math.Max(0, vars.splitDelay-1);
	
	if (current.stageID == 34 ||
		current.stageID == 35 ||
		current.stageID == 36 ||
		current.stageID == 37 ||
		current.stageID == 38) //Cannons Core
	{
		if (current.timestop == 2) //Count time by frames on timestop
		{
			vars.countFrames = true;
		}
		else
		{
			vars.countFrames = false; //Not timestop? - don't count frames
		}

		if (current.menuMode == 17) //Don't count frames when pause menu open
		{
			vars.countFrames = false;
		}

		if (current.timerEnd) //Pause timer when dying/restarting/finishing level while timestop is active
		{
			vars.countFrames = false;
		}
	}
	else
	{
		//Don't count time by frames anywhere else but cannons core
		vars.countFrames = false;
	}

	//Ensure we have accurate readings of the igt
	if ((current.levelTimer & 0xFFFFFF) == (current.levelTimerClone & 0xFFFFFF))
	{
		int currMinutes =    (current.levelTimer >> 0)  & 0xFF;
		int currSeconds =    (current.levelTimer >> 8)  & 0xFF;
		int currCentis  =    (current.levelTimer >> 16) & 0xFF;

		int oldMinutes  = (vars.lastGoodTimerVal >> 0)  & 0xFF;
		int oldSeconds  = (vars.lastGoodTimerVal >> 8)  & 0xFF;
		int oldCentis   = (vars.lastGoodTimerVal >> 16) & 0xFF;

		currCentis = (int)Math.Ceiling(currCentis*(5.0/3.0));
		oldCentis  =  (int)Math.Ceiling(oldCentis*(5.0/3.0));

		//In game timer converted to centiseconds
		int inGameTime  = (currMinutes*6000) + (currSeconds*100) + (currCentis);
		int oldGameTime =  (oldMinutes*6000) +  (oldSeconds*100) +  (oldCentis);

		//Only add positive time
		int timeToAdd = Math.Max(0, inGameTime-oldGameTime);

		//Don't add time when the timer goes beserk in loading screens
		if (current.controlActive)
		{
			vars.totalTime += timeToAdd;
		}

		vars.lastGoodTimerVal = current.levelTimer;
	}

	if (vars.countFrames)
	{
		int diff = current.frameCount - old.frameCount;
		vars.timestopFrames = vars.timestopFrames+diff;
	}
	
	//Boss stages
	if ((current.stageID == 19 ||
		 current.stageID == 20 ||
		 current.stageID == 29 ||
		 current.stageID == 33 ||
		 current.stageID == 42) && current.bossHealth == 0)
	{
		if (current.timerEnd && !old.timerEnd)
		{
			vars.splitDelay = 3;
		}
	}
	else if (current.stageID == 70) //Route 101/280
	{
		if (current.timerEnd && !old.timerEnd && current.menuMode != 12)
		{
			vars.splitDelay = 3;
		}
	}
	else if (current.levelEnd && !old.levelEnd) //Normal stages
	{
		vars.splitDelay = 3;
	}
}

start
{
	vars.totalTime = 0;
	vars.timestopFrames = 0;
	vars.countFrames = false;
	vars.lastGoodTimerVal = current.levelTimerClone;
	vars.splitDelay = 0;
	if (current.runStart && !old.runStart &&
		(!settings["storyStart"] || current.currMenu == 5))
	{
		return true;
	}
}

reset
{
	// Reset if a file is created or deleted.
	if ((current.currMenu == 9 || current.currMenu == 24) &&
		(current.currMenuState == 12 || current.currMenuState == 15))
		{
			return true;
		}
}

split
{
	return (vars.splitDelay == 1);
}

isLoading
{
	return true;
}

gameTime
{
	return TimeSpan.FromMilliseconds((vars.timestopFrames*1000)/60 + vars.totalTime*10);
}
