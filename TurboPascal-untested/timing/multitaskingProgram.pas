(*
  Category: SWAG Title: TIMER/RESOLUTION ROUTINES
  Original name: 0020.PAS
  Description: multitasking program
  Author: PETE ROCCA
  Date: 08-24-94  13:44
*)

{
YC> Does anyone got any unit/code on giving up time slice under DV or OS/2?
Here they are for DOS, Windows, OS/2, DV and DoubleDos.  You will need
to detect the enviroment first (although none should make the system
hang if it's the wrong enviroment, just be ignored)  The key to good
idle release is finding the right spots to put them.  I have gotten my
door making unit that I created to about 97% idle during pauses and 93%
idle while waiting for keyboard input (with no delay in response - much
better than the typical 12% idle pauses and 8% idle keyboard waits)
Here is how... }

Procedure Sleep(Seconds: Word);
Var
  H,M,S,T,Last: Word;
Begin
  If Seconds = 0 Then Exit;
  If Seconds > 999 Then Seconds := Seconds DIV 1000;
  {incase of caller is thinking milliseconds}

  GetTime(H,M,Last,T);
  Repeat
    Repeat
      GetTime(H,M,S,T);
      TimerSlice;
      TimerSlice;
    Until S <> Last;
    Last := S;
    Dec(Seconds);
  Until Seconds = 0;
End;

Function GetChar: Char;
Var
  Counter, Span: Byte;
  Done: Boolean;
Begin
  Span := 0;
  Done := False;
  Repeat
    Inc(Counter);
    If Counter > Span Then
      Begin
        Counter := 0;
        If IsChar Then Done := True
        Else If Span < 50 Then Inc(Span);
      End
    Else TimerSlice;
  Until Done;
  If KeyPressedExtended Then GetChar := Readkey
  Else GetChar := RxChar;
End;

Procedure TimerSlice;
Begin
  Case SystemEnviroment Of
    DOS4:;
    DOS5,
    WINDOWS,
    OS2: Asm
           MOV AX,$1680
           INT $2F
         End;
    DV: Asm
          MOV AX,$1000
          INT $15
        End;
    DOUBLEDOS: Asm
                 MOV AX,$EE01
                 INT $21
               End;
  End;
End;

This is released as public domain, however if you are using it, I'd
appreciate a PRIVATE NETMAIL message to me at 1:2401/123 letting me
know.

Thanks

Pete Rocca
Multiboard Communications Centre @ 1:2401/123

