state("sonic2app")
{
	bool runStart : "sonic2app.exe", 0x134AFFA;
	bool controlActive : "sonic2app.exe", 0x134AFFE;
	bool timerEnd : "sonic2app.exe", 0x134AFDA;
	bool levelEnd : "sonic2app.exe", 0x134B002;

	byte minutes : "sonic2app.exe", 0x134AFDB;
	byte seconds : "sonic2app.exe", 0x134AFDC;
	byte centiseconds : "sonic2app.exe", 0x134AFDD;
	byte map : "sonic2app.exe", 0x1534B70;
}

start
{
	return current.runStart && !old.runStart;
}

reset
{
}

split
{
	if ((current.map == 19 || current.map == 20 || current.map == 29 || current.map == 33 || current.map == 42 || current.map == 70) && current.controlActive)
	{
		return current.timerEnd && !old.timerEnd;
	}
	return current.levelEnd && !old.levelEnd;
}

isLoading
{
	return true;
}

gameTime
{
	int inGameTime = (current.minutes*60000) + (current.seconds*1000) + (current.centiseconds*(5.0/3.0))*10;
	int oldGameTime = (old.minutes*60000) + (old.seconds*1000) + (old.centiseconds*(5.0/3.0))*10;
	
	if (oldGameTime > inGameTime)
	{
		current.timeBuffer += oldGameTime - inGameTime;
	}
	if (oldGameTime == 0 && inGameTime > 0)
	{
		current.timeBuffer -= inGameTime;
	}

    return TimeSpan.FromMilliseconds(inGameTime + current.timeBuffer + 6);
}
