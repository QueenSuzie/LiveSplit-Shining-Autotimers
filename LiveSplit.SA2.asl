//Original code for IGT and autosplitting made by Shining_Face
//Now also counts frames in Cannons Core when time is stopped. (Made by Jellyfishswimmer aka. TurtleChuck)

state("sonic2app")
{
    bool runStart : 0x134AFFA;
    bool controlActive : 0x134AFFE;
    bool timerEnd : 0x134AFDA;
    bool levelEnd : 0x134B002;
 
	int frameCount : 0x0134B038;
	byte timestop : 0x134aff7;
	byte menuMode : 0x01534BE0;
	
    byte minutes : 0x134AFDB;
    byte seconds : 0x134AFDC;
    byte centiseconds : 0x134AFDD;
    byte map : 0x1534B70;
	
    float bossHealth : 0x019e9604, 0x48;
}
 
init
{
    vars.timeBuffer = new TimeSpan(0); //now in units of 0.0001 milliseconds (0.1 microseconds) (100 nanoseconds)
    vars.prevPhase = timer.CurrentPhase;
	vars.countFrames = false;
}

update
{
    if(timer.CurrentPhase == TimerPhase.Running && vars.prevPhase == TimerPhase.NotRunning)
    {
        vars.timeBuffer = new TimeSpan((-current.minutes*600000000L) - (current.seconds*10000000L) - ((int)Math.Ceiling(current.centiseconds*(5.0/3.0))*100000L));
    }
    vars.prevPhase = timer.CurrentPhase;
	
	if(current.map == 34 || current.map == 35 || current.map == 36 || current.map == 37 || current.map == 38) //Cannons Core
    {
		if(current.timestop == 2) //Count time by frames on timestop
		{
			vars.countFrames = true;
		}
		else 
		{
			vars.countFrames = false;
		}
		
		if(current.menuMode == 17) //Pause timer when pause menu open
		{
			vars.countFrames = false;
		}
		
		if(current.timerEnd) //Pause timer when dying/restarting/finishing level while timestop is active
		{
			vars.countFrames = false;
		}
    }
	else 
	{
		//Don't count time by frames anywhere else but cannons core
		vars.countFrames = false;
	}
}

start
{
    return current.runStart && !old.runStart;
}
 
split
{
    if((current.map == 19 || current.map == 20 || current.map == 29 || current.map == 33 || current.map == 42) && current.bossHealth == 0)
    {
        return current.timerEnd && !old.timerEnd;
    }
	if(current.map == 70)
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
    long inGameTime = (current.minutes*600000000L) + (current.seconds*10000000L) + ((int)Math.Ceiling(current.centiseconds*(5.0/3.0))*100000L);
    long oldGameTime = (old.minutes*600000000L) + (old.seconds*10000000L) + ((int)Math.Ceiling(old.centiseconds*(5.0/3.0))*100000L);
	
	if(vars.countFrames)
	{
		long diff = current.frameCount - old.frameCount;
		vars.timeBuffer = vars.timeBuffer.Add(TimeSpan.FromTicks(diff*166666L)); //16.6666 milliseconds ~ one frame
	}
    else if((oldGameTime > inGameTime) && !current.controlActive) //Adds time to total if player dies
    {
		vars.timeBuffer = vars.timeBuffer.Add(TimeSpan.FromTicks(oldGameTime - inGameTime));
    }
    else if((oldGameTime == 0 && inGameTime > 0) && !current.controlActive)
    {
		vars.timeBuffer = vars.timeBuffer.Subtract(TimeSpan.FromTicks(inGameTime));
    }
	
	//Make the IGT centiseconds never end in a 1, 3, 6, or 8 (round up)
	long roundedTicks = ((long)(((inGameTime + vars.timeBuffer.Ticks)/100000.0)))*100000L;
	int lastDigit = (int)((long)((roundedTicks/100000.0)) % 10);
	bool addOne = (lastDigit % 2 == 1 && lastDigit < 5 ||
				   lastDigit % 2 == 0 && lastDigit > 5);
				   
    return TimeSpan.FromTicks(roundedTicks+(addOne ? 100000 : 0));
}
