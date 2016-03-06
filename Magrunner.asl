state("Magrunner")
{
    bool isLoading : "Magrunner.exe", 0x15394E8;
}
 
start
{
}

reset
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
