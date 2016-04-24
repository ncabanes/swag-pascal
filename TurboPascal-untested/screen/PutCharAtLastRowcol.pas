(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0022.PAS
  Description: Put Char at LAST Row/Col
  Author: MIKE BURNS
  Date: 07-16-93  06:07
*)

===========================================================================
 BBS: Canada Remote Systems
Date: 06-24-93 (15:09)             Number: 27660
From: MIKE BURNS                   Refer#: NONE
  To: CHRIS PORTMAN                 Recvd: NO  
Subj: Re: Putting A Character R      Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
 -=> Quoting Chris Portman to All <=-

 CP> I was wondering if anyone knows how to put a character at the last
 CP> row and the last column at the screen - every time I attempt that, the
 CP> computer scrolls down to the next line.

 CP> Is there an assembler routine someone could write fast?

 CP> Thanks

 CP> PS - An example of a program that does that is Novell's SYSCON for its
 CP> background fill.

Try this Chris;

Procedure DVWRITE(X,Y:word;S:String;Back,Fore,BLNK:byte);
Var
I,I2:integer;
begin
   If (X>80) or (Y>25) or (X<1) or (Y<1) then Exit;
   If X+Length(S)>81 then Exit;
   DEC(X);
   DEC(Y);
   I2:=0;
   For I:= 0 to Length(S)-1 do
     begin
       Mem[$B800: (160 * y)+(x*2)+I2]:=Ord(S[I+1]);
       Mem[$B800: (160 * y)+(x*2)+I2+1]:=BLNK+(Back SHL 4)+Fore;
       INC(I2,2);
     end;
End;

This is a direct video write, and can not scroll the screen.
  Valid range X = 1..80  Y= 1..25
If you like take out the DEC(X&Y) and you can use 0..79 0..24

Should do the trick for you.

.\\ike Burns



... Security, confine Ensign Portman to the brig.
--- Blue Wave/Max v2.12 [NR]
 * Origin: Basic'ly Computers: Mooo-ing Right Along. (1:153/9.0)

