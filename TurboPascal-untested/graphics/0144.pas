{
> I need help programming in Mode 12h.  That's 640x480x16.  I need help
> changing the bit planes, and also I need help with an explanation of the
> bit plane arrangement.  Any help would be appreciated.  I don't mind (if
> you write a routine for me ) if its in Assembler or Pascal. Thanks!

I was fiddling with this this afternoon, origonally from Mr Michael Field, in
NZ_LOWLEVEL, I got the following (now pascal) routines:
}

Procedure SetWriteMode; {Called once at start of program.}
Begin
 Port[$3CE]:=5;
 Port[$3CF]:=Port[$3CF] And $FC;
End;

Procedure Plot(X,Y:Word; C:Byte);
Var
 B:Byte;
Begin
 PortW[$3CE]:=(C Mod 16)*256;
 PortW[$3CE]:=$0F01;
 Port[$3CE]:=8;
 Port[$3CF]:=128 Shr (X And 7);
 B:=Mem[$A000:(X Shr 3)+80*Y];   {This is important. Dont ask me why.}
 Mem[$A000:(X Shr 3)+80*Y]:=$FF;
End;
