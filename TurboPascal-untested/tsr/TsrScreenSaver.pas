(*
  Category: SWAG Title: TSR UTILITIES AND ROUTINES
  Original name: 0028.PAS
  Description: TSR Screen Saver
  Author: JUAN JOSE VERGARA
  Date: 08-24-94  13:56
*)

{This is a Screen saver, that passed X time blank screen if no pressed a Key}

{ - TSR.PAS - }

{$M 6000,0,0}
{$R-,S-,I-,D+,F+,V-,B-,N-,L+}

Uses Dos,Crt,Graph,Screen;
{ The code for SCREEN.PAS is in the SCREEN.SWG file }
Const
  KeyBdInt = $09;
  TimerInt = $08;
  ScreenOn:Boolean = True;
  Seconds = 10;    {Time to activate}
  Counter:Word = 0;
Var
  Regs:Registers;
  OldKbdVec,OldTimerVec:Pointer;
  S:ScreenStore;
Procedure STI; Inline($FB);
Procedure CLI; Inline($FA);
Procedure CallOldInt(Sub:Pointer);
  Begin
    Inline($9C/$FF/$5E/$06);
  End;
Procedure KeyBoard(Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP:Word); Interrupt;
    Begin
      Counter:=0;
      If Not(ScreenOn) Then
        Begin
          S.RestoreScreen;
          ScreenOn:=True;
        End;
      CallOldInt(OldKbdVec);
      STI;
    End;
Procedure Timer(Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP:Word); Interrupt;
    Begin
      If ScreenOn Then
        Begin
          Inc(Counter);
          If Counter>(Trunc(18.2*Seconds)) Then
            Begin
              S.StoreScreen;
              ClrScr;
              ScreenOn:=False;
            End;
        End;
      CallOldInt(OldTimerVec);
      STI;
    End;
Begin
S.Init(1,1,178,7);
GetIntVec(KeyBdInt,OldKbdVec);
SetIntVec(KeyBdInt,@KeyBoard);
GetIntVec(TimerInt,OldTimerVec);
SetIntVec(TimerInt,@Timer);
Keep(0);

End.

