state("sonic2app")
{
    bool runStart : 0x134AFFA;
    bool controlActive : 0x134AFFE;
    bool timerEnd : 0x134AFDA;
    bool levelEnd : 0x134B002;
 
    byte minutes : 0x134AFDB;
    byte seconds : 0x134AFDC;
    byte centiseconds : 0x134AFDD;
	
    byte map : 0x1534B70;
	
}
 
init
{
    vars.timeBuffer = 0;
    vars.prevPhase = timer.CurrentPhase;
}

update
{
    if (timer.CurrentPhase == TimerPhase.Running && vars.prevPhase == TimerPhase.NotRunning)
    {
        vars.timeBuffer = (-current.minutes*60000) - (current.seconds*1000) - ((int)Math.Ceiling(current.centiseconds*(5.0/3.0))*10);
    }
    vars.prevPhase = timer.CurrentPhase;
}

start
{
    return current.runStart && !old.runStart;
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
    int inGameTime = (current.minutes*60000) + (current.seconds*1000) + ((int)Math.Ceiling(current.centiseconds*(5.0/3.0))*10);
    int oldGameTime = (old.minutes*60000) + (old.seconds*1000) + ((int)Math.Ceiling(old.centiseconds*(5.0/3.0))*10);
	
    if (oldGameTime > inGameTime + 1000)
    {
        vars.timeBuffer += oldGameTime - inGameTime;
    }
    if (oldGameTime == 0 && inGameTime > 100)
    {
        vars.timeBuffer -= inGameTime;
    }
	
	//Work On Timer Resetting If Less Than 1 second IGT
	
    return TimeSpan.FromMilliseconds(inGameTime + vars.timeBuffer);
}
