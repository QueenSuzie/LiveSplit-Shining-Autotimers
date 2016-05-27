state("sonic2app")
{
	bool runStart : "sonic2app.exe", 0x134AFFA;
	bool controlActive : "sonic2app.exe", 0x134AFFE;
	bool timerEnd : "sonic2app.exe", 0x134AFDA;
	bool levelEnd : "sonic2app.exe", 0x134B002;
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
}

gameTime
{
}
