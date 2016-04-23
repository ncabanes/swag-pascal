===========================================================================
 BBS: Canada Remote Systems
Date: 06-25-93 (17:55)             Number: 27742
From: T.C. DOYLE                   Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: Pascal Code How To Detect      Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
 I found this in the shareware echo...hmm...wrong place:)
 So I decided to forward this message here:



 * Originally By: Mark Shadaram
 * Originally To: All
 * Originally Re: Pascal Code How To Detect Adlib Sound Card
 * Original Area: <FIDO> Shareware Forum
 * Forwarded by : Blue Wave v2.12

{ How to Detect Adlib Sound Card}
{ Coded By Mark Shadaram ( mark.shadaram@oubbs.telecom.uoknor.edu)}
Procedure SetAdlib(Address, Data:Byte);  VAR X,I:Byte;
BEGIN Port[$388]:=Address;
      for I:= 1 to 6 do X:=Port[$388];  {Delay}
      Port[$389]:=Data;
      for I:= 1 to 35 do X:=Port[$388]; {Delay}
END;
Function DetectAdlib:Boolean; VAR X,X2:Byte;
BEGIN SetAdlib($4,$60);                  {Step 1}
      SetAdlib($4,$80);                  {Step 2}
      Delay(10);{Just to make sure!}
      X:=Port[$388];                     {Step 3}
      SetAdlib($2,$ff);                  {Step 4}
      SetAdlib($4,$21);                  {Step 5}
      Delay(10);{Just to make sure!}     {Step 6}
      X2:=Port[$388];                    {Step 7}
      SetAdlib($4,$60);                  {Step 8}
      SetAdlib($4,$80);
      X:= X AND $E0;                     {Step 9}
      X2:= X2 AND $E0;
      IF (X =$0) AND (X2 =$C0) THEN
      DetectAdlib:=TRUE ELSE DetectAdlib:=FALSE;
END;

-!- Tag 2.6e + FMail 0.94
 ! Origin: NightShift / Wichita Falls, TX (817)855-1526 (1:3805/13)

--- GEcho/Telegard
 * Origin: Never mind the bollocks here's TEROX BBS (1:120/324.0)
