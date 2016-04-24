(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0195.PAS
  Description: Progress Bar for TechnoJock Toolkit
  Author: SERGEY PEREVOZNIK
  Date: 11-29-96  08:17
*)


{
 Since I received the request I post the following TOT (TechnoJock)  snippet.
 The  object in the code below is a window with progress bar.
 The object is very simple so I didn't comment the source.
 I did include an example.

 Here we go :
}

 {==========================================================================}
 {= Unit name      : TotPro                                                =}
 {= Version        : 1.0                                                   =}
 {= Public Objects : ProcessOBJ                                            =}
 {===--------------------------------------------------------------------===}
 {= Programmer     : Sergey Perevoznik                                     =}
 {                   root@pcb.chernigov.ua                                  }
 {= Language       : Borland Pascal 7.0                                    =}
 {===--------------------------------------------------------------------===}

Unit TotPro;

Interface

Uses
TotStr,
TotFast,
TotWin;

Type
       ProcessOBJ = object
          vWinPtr        : WinPtr;
          ScaleSym       : char;
          DoneSym        : char;
          ScaleCol       : byte;
          DoneCol        : byte;
          OneStep        : real;
          CountCycle     : longint;
          ScaleLen       : byte;
          OldX           : byte;
          InitVal,
          DoneVal        : longInt;
          Currentpercent : byte;

          Constructor Init(InitValue, EndValue : longint;
                           Title : string);
          Procedure   SetScale(ScaleSymbol,
                               DoneSymbol : char;
                               ScaleColor,
                               DoneColor   : byte);
          Procedure  Run;
          Procedure  UpDate;
          Destructor Done;
       end;

Implementation


Function  FillCh(Sym:Char;L:Byte):String;  Assembler;
ASM
 PUSH DS
 LES   DI,@Result
 XOR  CX,CX
 MOV   CL,L
 CMP   CL,0
 MOV AL,CL
 STOSB
 MOV CL,AL
 JE  @@1
 MOV   AL,SYM
 CLD
 REP   STOSB
@@1:
 POP DS
end;


 Constructor ProcessOBJ.Init(InitValue, EndValue : longint;
                           Title : string);
  begin
     New(vWinPtr,Init);
     vWinPtr^.SetTitle(Title);
     vWinPtr^.SetSize(15,8,65,12,2);
     vWinPtr^.SetColors($70,$70,$70,$70);
     ScaleSym := '░';
     DoneSym  := '█';
     ScaleCol := $07;
     DoneCol  := $70;
     OldX     := 2;
     initVal  := InitValue;
     DoneVal  := EndValue;
     CurrentPercent := 0;
     CountCycle := 0;
  end;


  Procedure ProcessOBJ.SetScale(ScaleSymbol,
                     DoneSymbol : char;
                     ScaleColor,
                     DoneColor   : byte);
  begin
    ScaleSym := ScaleSymbol;
    DoneSym  := DoneSymbol;
    ScaleCol := ScaleColor;
    DoneCol  := DoneColor;
  end;


  Procedure ProcessOBJ.Run;
    begin

       vWinPtr^.Draw;
       ScaleLen := vWinPtr^.vBorder.X2 - vWinPtr^.vBorder.X1 - 8;
       Screen.WriteAT(2,2,ScaleCol,FillCh(ScaleSym,ScaleLen));
       OneStep := (DoneVal - Initval) / 100;
    end;

  Procedure ProcessOBJ.Update;
    var
    Cp1 : byte;
    begin
       Inc(CountCycle);
       Cp1 := Round(CountCycle/OneStep);
       if Cp1 > CurrentPercent then CurrentPercent := Cp1;
       Screen.WriteAT(2,2,DoneCol,FillCH(DoneSym,trunc(CurrentPercent*ScaleLen/100)));
       Screen.WriteAT(vWinPtr^.vBorder.X2 - vWinPtr^.vBorder.X1- 5,2,
       DoneCol,intTostr(CurrentPercent) + '%');
    end;

  Destructor ProcessOBJ.Done;
    begin
      Dispose(vWinPtr,done);
    end;
end.

{
Program Example;

Uses TotPro,
     TotFast,
     CRT;

Var
   Process : ProcessOBJ;
   I       : integer;
begin
  ClrScr;
  Screen.CursOFF;
  Process.Init(0,80,'TOT Process Example');
  Process.Run;
  For I := 1 to 80 do
    begin
      Process.Update;
      Delay(30);
    end;
  Process.Done;
  Screen.CursON;
end.

}


