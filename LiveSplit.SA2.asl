//Updated 04-30-2023
//By Shining, Jelly, IDGeek, Skewb
state("sonic2app")
{
	bool timerEnd         : 0x0134AFDA;
	bool runStart         : 0x0134AFFA;
	bool controlActive    : 0x0134AFFE;
	bool levelEnd         : 0x0134B002;
	bool inCutscene       : 0x015420F8;
	bool nowLoading       : 0x016557E4;
	bool inAMV            : 0x016EDE28;
	bool inEmblem         : 0x01919BE0;
	
	byte bossRush         : 0x00877DC4;
	byte timestop         : 0x0134AFF7;
	byte ringSaving       : 0x015455DC;
	byte stageID          : 0x01534B70;
	byte charID           : 0x01534B80;
	byte menuMode         : 0x01534BE0;
	byte timesRestarted   : 0x01534BE8;
	byte saveChao         : 0x015F645C;
	byte chaoID           : 0x0165A2CC;
	byte textCutscene     : 0x016EFD44;
	byte raceChao         : 0x019D2784;
	byte twoplayerMenu    : 0x0191B88C;
	byte mainMenu1        : 0x0191BD2C;
	byte mainMenu2        : 0x0197BAE0;
	byte stageSelect      : 0x0191BEAC;
	byte storyRecap       : 0x0191C1AC;
	byte inlevelCutscene  : 0x019D0F9C;
	byte gameplayPause    : 0x021F0014;

	short currEmblems     : 0x01536296;
	short currEvent       : 0x01628AF4;
	//Timing
	int levelTimer        : 0x015457F8;
	int levelTimerClone   : 0x0134AFDB;
	int levelTimer        : 0x015457F8;
	int frameCount        : 0x0134B038;

	float bossHealth      : 0x019E9604, 0x48;
	
	int currMenu          : 0x0197BB10;
	int currMenuState     : 0x0197BB14;
	//Quick Save Reload
	int qsrPointer        : 0x00054884;
	int qsrReloadCount    : 0x00054884, 0x0;
}

init
{
	refreshRate = 120;
}

startup
{
	refreshRate = 120;
	//Variables
	vars.lastGoodTimerVal = Int32.MaxValue;
	vars.totalTime = 0;     //Time accumulated from level timer, in centiseconds
	vars.countedFrames = 0; //How many frames have elapsed
	vars.splitDelay = 0;
	vars.firstLoad = true;
	vars.qsrEnabled = false;
	//Settings
	settings.Add("storyStart", false, "Only start timer when starting a story.");
	settings.Add("NG+", false, "Start timer when selecting first stage of a completed story (NG+).", "storyStart");
	settings.Add("huntingTimer", false, "Allow the use of loadless if category is set improperly.");
	settings.Add("timeIGT", false, "Use legacy IGT timing.");
	settings.Add("combinedHunting", false, "Only add up hunting levels (Combined hunting).");
	settings.Add("no280", false, "Don't count Route 280 as part of Rouge stages.", "combinedHunting");
	settings.Add("fileReset", true, "Restart timer when deleting a file/activating QSR mod.");
	settings.Add("stageExit", false, "Restart timer when manually exiting a stage in stage select.");
	settings.Add("resetIL", false, "Restart timer on restart/death (For use with ILs).");
	settings.Add("stageEntry", false, "Split when entering a stage in stage select.");
	settings.Add("chaoRace", false, "Split when exiting Chao Race.");
	settings.Add("cannonsCore", false, "Only split in Cannon's Core when a mission is completed.");
	settings.Add("bossRush", false, "Only split in Boss Rush when defeating the last boss of a story.");
}

update
{
	//First time in a stage?
	if (current.menuMode == 0 || current.menuMode == 1 || current.menuMode == 16)
	{
		vars.firstLoad = true;
	}
	else if (current.menuMode == 9 || current.menuMode == 13)
	{
		vars.firstLoad = false;
	}
	//Pauses timer when livesplit is paused
	if (timer.CurrentPhase == TimerPhase.Paused)
	{
		vars.countFrames = false;
	}
	//Loading, saving, and cutscenes
	else if (current.inCutscene || current.inEmblem || current.nowLoading || current.saveChao == 1 || (!current.controlActive && (current.menuMode == 1 || current.menuMode == 2 || current.menuMode == 3 || 
	(!current.levelEnd && vars.firstLoad && current.menuMode == 7)) || (!current.levelEnd && (current.menuMode == 8 || current.menuMode == 12))) || 
	((current.levelEnd && old.levelEnd) && (current.ringSaving == 4 || old.ringSaving == 4)) || (current.mainMenu1 == 1 && current.currMenu == 24 && current.currMenuState == 13) || 
	(current.mainMenu1 == 0 && current.mainMenu2 == 0 && current.stageSelect == 0 && current.storyRecap == 0 && current.twoplayerMenu == 0 && current.currMenuState != 2 && !settings["huntingTimer"] && 
	timer.Run.GameName != "Sonic Adventure 2: Hunting Redux" && timer.Run.CategoryName != "Knuckles Centurion" && timer.Run.CategoryName != "Knuckles stages x20" && 
	timer.Run.CategoryName != "Rouge Centurion" && timer.Run.CategoryName != "Rouge stages x25" && ((current.menuMode == 7 && !current.controlActive) || 
	(current.stageID != 66 && current.stageID != 65 && current.inlevelCutscene == 14) || (current.gameplayPause == 117 || current.gameplayPause == 123) && (current.levelTimer == old.levelTimer))))
	{
		vars.countFrames = false;
	}
	//Credits
	else if (current.mainMenu1 == 0 && current.mainMenu2 == 0 && current.stageSelect == 0 && current.storyRecap == 0 && current.twoplayerMenu == 0 && current.stageID == 0 && 
	(current.currEvent == 211 || current.currEvent == 210 || current.currEvent == 208 || current.currEvent == 131 || current.currEvent == 28))
	{
		vars.countFrames = false;
	}
	//Normal stages
	else if (!settings["timeIGT"] && !settings["combinedHunting"] && current.mainMenu2 == 1 && 
	(((current.currMenuState == 2 || current.currMenuState == 3) && !current.runStart) || current.currMenuState == 4 || current.currMenuState == 5 || current.currMenuState == 6 || current.currMenuState == 7))
	{
		vars.countFrames = true;
	}
	else if (current.mainMenu1 == 0 && current.stageSelect == 0 && current.storyRecap == 0 && current.twoplayerMenu == 0 && current.currMenuState != 3 && 
	((current.menuMode == 16 && current.controlActive && !current.levelEnd && !current.timerEnd && current.timestop != 2) || 
	(!settings["huntingTimer"] && timer.Run.GameName != "Sonic Adventure 2: Hunting Redux" && timer.Run.CategoryName != "Knuckles Centurion" && timer.Run.CategoryName != "Knuckles stages x20" && 
	timer.Run.CategoryName != "Rouge Centurion" && timer.Run.CategoryName != "Rouge stages x25" && (current.levelEnd || (current.menuMode == 0 && !current.levelEnd) || (current.stageID == 90 && !current.controlActive && 
	(current.menuMode == 29 || old.menuMode == 29 || current.menuMode == 12 || old.menuMode == 12 || current.menuMode == 8 || old.menuMode == 8 || current.menuMode == 7 || old.menuMode == 7)) ||  
	(current.stageID != 90 && current.menuMode != 0 && current.timerEnd)))))
	{
		vars.countFrames = false;
	}
	else if (!settings["timeIGT"])
	{
		if (!settings["combinedHunting"])
		{
			vars.countFrames = true;
		}
		else if (settings["combinedHunting"])
		{
			if (current.stageID == 5 || current.stageID == 7 || current.stageID == 8 || current.stageID == 16 || current.stageID == 18 || current.stageID == 25 || 
			current.stageID == 26 || current.stageID == 32 || current.stageID == 44 || (!settings["no280"] && current.stageID == 70 && current.charID == 5))
			{
				vars.countFrames = true;
			}
		else vars.countFrames = false;
		}
	}
	else if (settings["timeIGT"] && current.timestop == 2)
	{
		vars.countFrames = true;
	}
	else vars.countFrames = false;
	
	if (vars.countFrames)
	{
		int timeToAdd = Math.Max(0, current.frameCount - old.frameCount);
		vars.countedFrames += timeToAdd;
	}
	//Ensure we have accurate readings of the IGT
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
		
		if (current.controlActive)
		{
			if (settings["combinedHunting"] && (current.stageID == 5 || current.stageID == 7 || current.stageID == 8 || current.stageID == 16 || current.stageID == 18 || current.stageID == 25 || 
			current.stageID == 26 || current.stageID == 32 || current.stageID == 44 || (!settings["no280"] && current.stageID == 70 && current.charID == 5)))
			{
				vars.totalTime += timeToAdd;
			}
			else if (!settings["combinedHunting"])
			{
				vars.totalTime += timeToAdd;
			}
		}
		vars.lastGoodTimerVal = current.levelTimer;
	}
	//Splitting
	vars.splitDelay = Math.Max(0, vars.splitDelay-1);
	//Boss rush
	if (settings["bossRush"] && current.bossRush == 1 && (current.stageID == 67 || current.stageID == 65 || current.stageID == 64 || current.stageID == 63 || current.stageID == 62 || 
	current.stageID == 61 || current.stageID == 60 || current.stageID == 33 || current.stageID == 29 || current.stageID == 20 || current.stageID == 19))
	{
		vars.splitDelay = 0;
	}
	//Boss stages
	else if ((current.stageID == 42 || current.stageID == 33 || current.stageID == 29 || current.stageID == 20 || current.stageID == 19) && current.bossHealth == 0)
	{
		if (current.timerEnd && !old.timerEnd)
		{
			vars.splitDelay = 3;
		}
	}
	//Cannon's Core
	else if (settings["cannonsCore"] && (current.stageID == 38 || current.stageID == 37 || current.stageID == 36 || current.stageID == 35))
	{
		if (current.controlActive && current.menuMode != 8 && current.levelEnd && !old.levelEnd)
		{
			vars.splitDelay = 3;
		}
	}
	//Level End
	else if ((current.stageID != 71 || current.stageID != 70) && current.levelEnd && !old.levelEnd)
	{
		vars.splitDelay = 1;
	}
	//Kart stages
	else if (current.stageID == 71 || current.stageID == 70)
	{
		if (current.timerEnd && !old.timerEnd && current.controlActive && current.menuMode != 12)
		{
			vars.splitDelay = 3;
		}
	}
	//Chao World
	else if ((settings["chaoRace"] && current.stageID == 90 && current.raceChao != 1 && old.raceChao == 1) || (current.stageID == 90 && current.chaoID == 1 && current.inEmblem && !old.inEmblem))
	{
		vars.splitDelay = 3;
	}
	//Split on stage entry
	else if (settings["stageEntry"] && current.mainMenu1 == 0 && current.mainMenu2 == 0 && current.currMenuState == 5 && (current.menuMode == 1 && old.menuMode != 1) && current.runStart)
	{
		vars.splitDelay = 3;
	}
}

start
{
	vars.totalTime = 0;
	vars.countedFrames = 0;
	vars.splitDelay = 0;
	vars.firstLoad = true;
	vars.countFrames = false;
	//QSR Check
	if (current.qsrPointer == 0xCCCCCCCC)
	{
		vars.qsrEnabled = true;
	}
	else vars.qsrEnabled = false;
	//Allow Any% and 2 Player Levels to start where other categories can't
	if ((timer.Run.CategoryName != "Any%" && timer.Run.CategoryName != "2 Player Levels" && 
	current.currMenuState != 4 && current.currMenuState != 5 && current.currMenuState != 7) || 
	current.inEmblem || current.inAMV)
	{
		return false;
	}
	//Only start timer when selecting 2p mode
	else if (timer.Run.CategoryName == "Any%")
	{
		if (current.mainMenu1 != 1 && current.mainMenu2 != 1 && current.stageSelect != 1 && current.twoplayerMenu == 1 && old.twoplayerMenu == 0)
		{
			return true;
		}
	}
	//Only start timer when starting a story or selecting chao garden
	else if (timer.Run.CategoryName == "Chao%")
	{
		if (current.mainMenu1 != 1 && current.mainMenu2 != 1 && current.stageSelect != 1 && 
		((current.stageID == 90 && (current.menuMode == 1 && old.menuMode != 1)) || current.currMenu == 5) && current.runStart)
		{
			return true;
		}
	}
	//2p Levels
	else if (timer.Run.CategoryName == "2 Player Levels")
	{
		if (current.mainMenu1 != 1 && current.mainMenu2 != 1 && current.stageSelect != 1 && current.currMenuState == 11 && (current.runStart && !old.runStart))
		{
			return true;
		}
	}
	//Normal
	else if (current.mainMenu1 != 1 && current.mainMenu2 != 1 && current.stageSelect != 1 && ((current.menuMode == 1 && old.menuMode != 1) || 
	(current.inCutscene && old.inCutscene)) && current.runStart)
	{
		if (settings["storyStart"] && !settings["NG+"])
		{
			if (timer.Run.CategoryName == "Hero Story" || timer.Run.CategoryName == "Dark Story" || timer.Run.CategoryName == "All Stories")
			{
				if (current.currMenu == 5 && ((timer.Run.CategoryName == "Hero Story" && current.currEvent == 0) || (timer.Run.CategoryName == "Dark Story" && current.currEvent == 100) ||
				(timer.Run.CategoryName == "All Stories" && (current.currEvent == 0 || current.currEvent == 100))))
				{
					return true;
				}
			}
			else if (current.currMenu == 5)
			{
				return true;
			}
		}
		else if (settings["NG+"])
		{
			if (timer.Run.CategoryName == "Hero Story" || timer.Run.CategoryName == "Dark Story" || timer.Run.CategoryName == "Last Story" || timer.Run.CategoryName == "All Stories")
			{
				if (current.currMenu == 2 && ((timer.Run.CategoryName == "Hero Story" && current.currEvent == 0) || (timer.Run.CategoryName == "Dark Story" && current.currEvent == 100) || 
				(timer.Run.CategoryName == "Last Story" && current.currEvent == 200) || (timer.Run.CategoryName == "All Stories" && (current.currEvent == 0 || current.currEvent == 100))))
				{
					return true;
				}
			}
			else if (current.currMenu == 2)
			{
				return true;
			}
		}
		else return true;
	}
	//Start timer upon resetting a stage
	if (settings["resetIL"])
	{
		if (!current.levelEnd && !current.controlActive && old.controlActive && current.timerEnd)
		{
			return true;
		}
	}
}

reset
{
	//Reset if a file is created or deleted
	if (settings["fileReset"])
	{
		if ((current.currMenu == 9 || current.currMenu == 24) && (current.currMenuState == 12 || current.currMenuState == 15))
		{
			return true;
		}
		//Reset upon activating quick save reload
		else if (vars.qsrEnabled = true)
		{
			if ((current.qsrReloadCount != 0 && old.qsrReloadCount != -1) && (old.qsrReloadCount != current.qsrReloadCount))
			{
				return true;
			}
		}
	}
	//Reset if manually exiting a stage during stage select
	if (settings["stageExit"])
	{
		if (current.menuMode == 0 && current.stageSelect == 1 && old.stageSelect != 1 && !current.timerEnd)
		{
			return true;
		}
	}
	//Reset if leaving a stage
	if (settings["resetIL"])
	{
		if (!current.levelEnd && !current.controlActive && old.controlActive && current.timerEnd)
		{
			return true;
		}
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
	return TimeSpan.FromMilliseconds(vars.countedFrames*5.0/0.3 + vars.totalTime*10.0);
}
