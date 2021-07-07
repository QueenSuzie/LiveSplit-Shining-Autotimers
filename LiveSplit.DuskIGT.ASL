//Version 2 (ShiningFace, TwanJones)

state("Dusk", "Steam") 
{
	byte Level: "UnityPlayer.dll", 0x1519458, 0x130, 0xE0, 0x38, 0x80, 0xA8, 0x60, 0xE4;
	float currSeconds: "UnityPlayer.dll", 0x01519458, 0x128, 0x80, 0xC0, 0x60, 0x104;
	float currMinutes: "UnityPlayer.dll", 0x01519458, 0x128, 0x80, 0x40, 0x60, 0x100;
	float StatsScreenTimeSeconds: "UnityPlayer.dll", 0x1519458, 0x130, 0x48, 0x120, 0xD0, 0x100, 0x28, 0xB0;
	float StatsScreenTimeMinutes: "UnityPlayer.dll", 0x1519458, 0x130, 0x20, 0x0, 0x60, 0x10, 0x118, 0xAC;
}

startup 
{
	refreshRate = 60;
}

init 
{
	version = "Steam";
	vars.IGT = 0;
	vars.intRound = 0;
}

update 
{
	vars.intRound = (int)Math.Floor(current.currSeconds*100);
	
	current.IGT = (current.currMinutes*6000.0) + (vars.intRound);
	
	double timeToAdd = Math.Max(0, current.IGT - old.IGT);
	vars.IGT += timeToAdd;
}

start 
{
	vars.IGT = 0;
	vars.intRound = 0;
	
	if (current.Level == 3 && current.IGT == 0 && old.IGT != 0) 
	{
		return true;
	}
	else if (current.Level == 3 && old.Level == 21) 
	{
		return true;
	}
	else if (current.Level == 22 && old.Level == 33) 
	{
		return true;
	}
	else if (current.Level == 37 && old.Level == 48) 
	{
		return true;
	}
}

split 
{
	if ((current.Level == old.Level + 1) || (current.Level == 35 && old.Level == 31)) 
	{
		if (current.Level != 21 && current.Level != 33 && current.Level != 48 && old.Level != 13 && old.Level != 35 && old.Level != 47)
		{
			return true;
		}
	} 
	else if ((current.Level == 5 && old.Level == 14) || (current.Level == 26 && old.Level == 32) || (current.Level == 41 && old.Level == 47)) 
	{
		return true;
	} 
	else if ((current.Level == 14 && old.Level == 4) || (current.Level == 32 && old.Level == 25) || (current.Level == 47 && old.Level == 40)) 
	{
		return true;
	}
}

reset 
{
	if (current.Level == 3 && current.IGT == 0 && old.IGT != 0)
	{
		return true;
	}
	else if (current.Level != old.Level) 
	{
		if (current.Level == 21 && old.Level != 13 && old.Level != 35 && old.Level != 47) 
		{
			return true;
		} 
		else if (current.Level == 33 && old.Level != 13 && old.Level != 35 && old.Level != 47) 
		{
			return true;
		} 
		else if (current.Level == 48 && old.Level != 13 && old.Level != 35 && old.Level != 47) 
		{
			return true;
		}
	}
}

gameTime 
{
	return TimeSpan.FromMilliseconds(vars.IGT*10.0);
}

isLoading 
{
	return true;
}
