state("AliceMadnessReturns") 
{
	bool isLoading : 0x1107798;
}

init
{
}

start
{
}

split
{
}

isLoading
{
	return current.isLoading;
}

gameTime
{
}
