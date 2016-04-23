{
> Oh, btw Hunking is the conversion of three binary bytes to four ascii
> bytes! Thought you should know that :)

Hmmm... so that's 3*8 bits=24 bits, into 4 ascii bytes=6 significant bits, is
2^6, =64 different ascii characters needed. I think I can manage that...
}
Const
 HunkChars:String[64]=
  'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890:;';
  {         1111111111222222222233333333334444444444555555555566666}
  {1234567890123456789012345678901234567890123456789012345678901234}

Function Bin2Hunk(Bin1,Bin2,Bin3: Byte): String;
Var
 Working:LongInt;
 Loop:Byte;
 S:String;
Begin
 Working:=Byte1+Byte2*256+Byte3*65536;
 S:='';
 For Loop:=1 To 4 Do
  Begin
   S:=S+HunkChars[(Working Mod 64)+1];
   Working:=Working Div 64;
  End;
 Bin2Hunk:=S;
End;

Procedure Hunk2Bin(Hunk:String; Bin1,Bin2,Bin3:Byte);
Var
 Working:LongInt;
Begin
 Working:=(Pos(Hunk[1],HunkChars)-1)+
          (Pos(Hunk[2],HunkChars)-1)*64+
          (Pos(Hunk[3],HunkChars)-1)*4096+
          (Pos(Hunk[4],HunkChars)-1)*262144;
 Bin1:=Working Mod 256;
 Bin2:=(Working Div 256) Mod 256;
 Bin3:=(Working Div 65536) Mod 256;
End;

{
> Those of *course* are not the real outputs, so don't bother trying to
> "un-hunk" them. But if anyone has such functions, thanx before hand!

HunkChars must be at least 64 letters long, each being unique. These will be
the characters in the hunk. The result of the function will be the hunk string.
In the un-hunker, the hunk MUST be at least 4 characters long; and only consist
of characters in HunkChars. no checking is done.
}