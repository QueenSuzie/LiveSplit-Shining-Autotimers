state("sonic2app")
{
	byte minutes : "sonic2app.exe", 0x134AFDB;
	byte seconds : "sonic2app.exe", 0x134AFDC;
	byte centiseconds : "sonic2app.exe", 0x134AFDD;

	byte raceSec : "sonic2app.exe", 0x1994421;
	byte raceCenti : "sonic2app.exe", 0x1994422;
	byte map : "sonic2app.exe", 0x1534B70;
}

start
{
	int inGameTime = (current.minutes*60000) + (current.seconds*1000) + (int)Math.Ceiling((current.centiseconds*(5.0/3.0)))*10;
	current.timeBuffer = -inGameTime;
}

split
{
}

isLoading
{
	return true;
}

gameTime
{
	int inGameTime = (current.minutes*60000) + (current.seconds*1000) + (int)Math.Ceiling((current.centiseconds*(5.0/3.0)))*10;
	int oldGameTime = (old.minutes*60000) + (old.seconds*1000) + (int)Math.Ceiling((old.centiseconds*(5.0/3.0)))*10;
	int raceTime = (current.raceSec*1000) + (current.raceCenti*10);
	int oldRaceTime = (old.raceSec*1000) + (old.raceCenti*10);

	if (oldGameTime > inGameTime)
	{
		current.timeBuffer += oldGameTime - inGameTime;
	}
	//if (raceTime != oldRaceTime && inGameTime == 0)
	//{
	//	if (raceTime - oldRaceTime > 0)
	//	{
	//		current.timeBuffer += raceTime - oldRaceTime;
	//	}
	//}
	//if (old.map != 70 && current.map == 70)
	//{
	//	current.timeBuffer -= 870;
	//}
	if (oldGameTime == 0 && inGameTime > 100)
	{
		current.timeBuffer -= inGameTime;
	}


 return TimeSpan.FromMilliseconds(inGameTime + current.timeBuffer + 6);
}
