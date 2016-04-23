{
> I need help with a scroller for the textmode (25x80)...I ran into some
> trouble..:(.. The major problem is that it has to quite fast, so my choise
> was to make the scroller using Mem [VidSeg....] and Move but I just don't
> seem to get it right... So if anybody out there has got a scroller for the
> textmode please post it... Nevermind if it's not so fast, it might help
> anyway

I tested the single line scroller, and it worked. (Delayed 50 instead of 10)
(make the constant a string to compile it).

Now a simple scroll command for the entire screen (up)
}
Move(Mem[Vidseg,160],Mem[Vidseg,0],3840);     or just writeln
{
entire screen(down)
}
Move(Mem[Vidseg,0],Mem[Vidseg,160],3840);
{
entire screen(left)
}
Move(Mem[Vidseg,2],Mem[Vidseg,0],3998);
{
then write all characters that are new in the right column

entire screen(right)
}
Move(Mem[VidSeg,0],Mem[VidSeg,2],3998);
{
then write all characters in new left column
}
