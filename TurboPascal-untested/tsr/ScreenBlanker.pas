(*
  Category: SWAG Title: TSR UTILITIES AND ROUTINES
  Original name: 0030.PAS
  Description: Screen Blanker
  Author: MAYNARD PHILBROOK
  Date: 11-26-94  05:03
*)

{
Screen Blanker , Tsr Example only, By Maynard Philbrook ,VGA Type
From: Maynard.Philbrook@trisoft.com (Maynard Philbrook)
}
{$F+,S-,D-,I-,V-,R-}
 {$M 1024, 0,0} { Reduce Memory to the minimum }
Uses DOs;
Var
 OLDINT09, OLDINT08:pointer;
 IsScreenOn :Boolean;
 DownCounter :Word;
procedure NewKeyBoardHandler; Interrupt;
Begin
 ASm    PushF;
       Call OldInt09;
       Cmp IsScreenOn, True;
        Je     @Done;
        Mov DX, $03C4;  { Tell VGA Card Which Reg we want "Index Reg"}
        Mov AL, 01;
        Out DX,AL;     { Make sure we are in the correct Regs }
        Inc DX;         { Move to the Data Reg now }
        IN  AL, DX;     { get the curent  value of the CLocking Mode 
Reg}
        And AL ,($FF-$20); { Turn off Blanker Bit }
        Out DX, AL;    { Send New Value to Port, WRite it Back }
        mov IsScreenOn, True;
@Done:
       Mov DownCounter, 50; { Set for 50 Ticks for Now }
 end;
end;
procedure NewTimerHandler; Interrupt;
begin
 ASm
    PushF;
    Call Oldint08;
    Mov BX, DownCounter;
    Cmp BX, 0;
    Je  @Done;
    Dec        BX;
    Jnz  @Done;
    Mov DX, $03C4;  { Tell VGA Card Which Reg we want "Index Reg"}
    Mov AL, 01;
    Out DX,AL; { Make sure we are in the correct Regs }
    Inc DX;         { Move to the Data Reg now }
    IN  AL, DX;     { get the curent  value of the CLocking Mode Reg}
    Or  AL ,$20; { Turn off Blanker Bit }
    Out DX, AL;         { Send New Value to Port, WRite it Back }
    Mov IsScreenOn, False;
@Done:
    Mov DownCounter, BX;
   End;
End;
Begin
 GetINtVec($09, OLDINT09);
 GetIntVec($08, OLDINT08);
 SetIntVec($09, @NewKeyBoardHandler);
 SetIntVec($08, @NewTimerHandler);
 IsScreenOn := True;
   { The Following is a Test }
 Readln;
 SetIntVec($09, OldINt09); { Restore Vectors after test }
 SetIntVec($08, OldINt08);
 { End of Test}
 { To used as a TSR Exit the program With out restoring Vectors Like
So}
 { KEEP(0) }
End.

