(*
  Category: SWAG Title: TEXT WINDOWING ROUTINES
  Original name: 0001.PAS
  Description: Execute DOS in a Window
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  14:08
*)

{$A+,B-,D+,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X+,Y-}
{$M   16384,0,655360}
Unit  ExecWin;
Interface
Var   SaveInt10 : Pointer;

Procedure ExecWindow(X1,Y1,X2,Y2,
                     Attr         : Byte;
                     Path,CmdLine : String);

Implementation
Uses
  Crt,Dos;
Type
  PageType  = Array [1..50,1..80] of Word;
Var
  Window    : Record
    X1,Y1,X2,Y2,
    Attr         : Byte;
    CurX,CurY    : Byte;
  end;
  Regs      : Registers;
  Cleared   : Boolean;
  Screen    : ^PageType;
  ActPage,
  VideoMode : ^Byte;
  {$ifOPT D+}
  Fnc,
  OldFnc    : Byte;
  {$endif}

{$ifOPT D+}
Function FStr(Num : LongInt) : String;
Var
  Dummy : String;
begin
  Str(Num,Dummy);
  FStr := Dummy;
end;

Procedure WriteXY(X,Y,Attr : Byte;TextStr : String);
Var
  Loop : Byte;
begin
  if Length(TextStr)>0 then
  begin
    Loop := 0;
    Repeat
      Inc(Loop);
      Screen^[Y,X+(Loop-1)] := ord(TextStr[Loop])+Word(Attr SHL 8);
    Until Loop=Length(TextStr);
  end;
end;
{$endif}

Procedure ScrollUp(X1,Y1,X2,Y2,Attr : Byte); Assembler;
Asm
  mov   ah,$06
  mov   al,$01
  mov   bh,Attr
  mov   ch,Y1
  mov   cl,X1
  mov   dh,Y2
  mov   dl,X2
  dec   ch
  dec   cl
  dec   dh
  dec   dl
  int   $10
end;

Procedure ClearXY(X1,Y1,X2,Y2,Attr : Byte); Assembler;
Asm
  mov   ah,$06
  mov   al,$00
  mov   bh,Attr
  mov   ch,Y1
  mov   cl,X1
  mov   dh,Y2
  mov   dl,X2
  dec   ch
  dec   cl
  dec   dh
  dec   dl
  int   $10
end;

{$ifOPT D+}
Procedure Beep(Freq,Delay1,Delay2 : Word);
begin
  Sound(Freq);
  Delay(Delay1);
  NoSound;
  Delay(Delay2);
end;
{$endif}

{$F+}
Procedure NewInt10(Flags,CS,IP,AX,BX,CX,
                   DX,SI,DI,DS,ES,BP : Word); Interrupt;
Var
  X, Y, X1,
  Y1, X2, Y2   : Byte;
  Loop, DummyW : Word;
begin
  SetIntVec($10,SaveInt10);
  {$ifOPT D+}
  Fnc := Hi(AX);
  if Fnc<>OldFnc then
  begin
    WriteXY(1,1,14,'Coordinates:');
    WriteXY(20,1,14,'Register:');
    WriteXY(20,2,14,'AH: '+FStr(Hi(AX))+'  ');
    WriteXY(20,3,14,'AL: '+FStr(Lo(AX))+'  ');
    WriteXY(20,4,14,'BH: '+FStr(Hi(BX))+'  ');
    WriteXY(20,5,14,'BL: '+FStr(Lo(BX))+'  ');
    WriteXY(30,2,14,'CH: '+FStr(Hi(CX))+'  ');
    WriteXY(30,3,14,'CL: '+FStr(Lo(CX))+'  ');
    WriteXY(30,4,14,'DH: '+FStr(Hi(DX))+'  ');
    WriteXY(30,5,14,'DL: '+FStr(Lo(DX))+'  ');
    Case Fnc of
      $0 : WriteXY(40,1,14,'Set video mode.                        ');
      $1 : WriteXY(40,1,14,'Set cursor shape.                      ');
      $2 : WriteXY(40,1,14,'Set cursor position.                   ');
      $3 : WriteXY(40,1,14,'Get cursor position.                   ');
      $4 : WriteXY(40,1,14,'Get lightpen position.                 ');
      $5 : WriteXY(40,1,14,'Set active page.                       ');
      $6 : WriteXY(40,1,14,'Scroll up lines.                       ');
      $7 : WriteXY(40,1,14,'Scroll down lines.                     ');
      $8 : WriteXY(40,1,14,'Get Character/attribute.               ');
      $9 : WriteXY(40,1,14,'Write Character/attribute.             ');
      $A : WriteXY(40,1,14,'Write Character.                       ');
      $D : WriteXY(40,1,14,'Get pixel in Graphic mode.             ');
      $E : WriteXY(40,1,14,'Write Character.                       ');
      $F : WriteXY(40,1,14,'Get video mode.                        ');
      else WriteXY(40,1,14,'(unknown/ignored Function)             ');
    end;
    Case Hi(AX) of
      $0..$E : Beep(Hi(AX)*100,2,5);
          else begin
                 Beep(1000,50,0);
                 Repeat Until ReadKey<>#0;
               end;
    end;
  end;
  {$endif}
  Case Hi(AX) of
    $00 : begin
            ClearXY(Window.X1,Window.Y1,Window.X2,Window.Y2,Window.Attr);
            GotoXY(Window.X1,Window.Y1);
            Window.CurX := Window.X1;
            Window.CurY := Window.Y1;
          end;
    $01 : begin
            Regs.AH := $01;
            Regs.CX := CX;
            Intr($10,Regs);
          end;
    $02 : begin
            X           := Lo(DX);
            Y           := Hi(DX);
            Window.CurX := X+1;
            if Cleared then
            begin
              Window.CurY := Window.Y1;
              Cleared     := False;
            end
            else Window.CurY := Y+1;
            if Window.CurX<=Window.X2 then
            begin
              Regs.AH     := $02;
              Regs.BH     := ActPage^;
              Regs.DL     := X;
              Regs.DH     := Y;
              Intr($10,Regs);
            end;
          end;
    $03 : begin
            Regs.AH     := $03;
            Regs.BH     := ActPage^;
            Intr($10,Regs);
            DX          := (Window.X1-Regs.DL)+((Window.Y1-Regs.DH) SHL 8);
            CX          := Regs.CX;
          end;
    $04 : AX := Lo(AX);
    $06 : begin
            X1      := Window.X1+Lo(CX)-1;
            Y1      := Window.Y1+Hi(CX)-1;
            X2      := Window.X2+Lo(DX)-1;
            Y2      := Window.Y2+Hi(DX)-1;
            if Lo(AX)=0 then
            begin
              ClearXY(Window.X1,Window.Y1,
                      Window.X2,Window.Y2,Window.Attr);
              GotoXY(Window.X1,Window.Y1);
              Window.CurX := Window.X1;
              Window.CurY := Window.Y1;
              Cleared     := True;
            end
            else
            begin
              if X2>Window.X2 then X2 := Window.X2;
              if Y2>Window.Y2 then Y2 := Window.Y2;
              Regs.AH := $06;
              Regs.AL := Lo(AX);
              Regs.CL := X1;
              Regs.CH := Y1;
              Regs.DL := X2;
              Regs.DH := Y2;
              Regs.BH := Window.Attr;
              Intr($10,Regs);
            end;
          end;
    $07 : begin
            X1      := Window.X1+Lo(CX)-1;
            Y1      := Window.Y1+Hi(CX)-1;
            X2      := Window.X2+Lo(DX)-1;
            Y2      := Window.Y2+Hi(DX)-1;
            if X2>Window.X2 then
              X2 := Window.X2;
            if Y2>Window.Y2 then
              Y2 := Window.Y2;
            Regs.AH := $07;
            Regs.AL := Lo(AX);
            Regs.CL := X1;
            Regs.CH := Y1;
            Regs.DL := X2;
            Regs.DH := Y2;
            Regs.BH := Window.Attr;
            Intr($10,Regs);
          end;
    $08 : begin
            Regs.AH := $08;
            Regs.BH := ActPage^;
            Intr($10,Regs);
            AX      := Regs.AX;
          end;
    $09,
    $0A : begin
            Regs.AH := $09;
            Regs.BH := ActPage^;
            Regs.CX := CX;
            Regs.AL := Lo(AX);
            Regs.BL := Window.Attr;
            Intr($10,Regs);
          end;
    $0D : AX := Hi(AX) SHL 8;
    $0D : AX := Hi(AX) SHL 8;
    $0E : begin
            Case Lo(AX) of
               7 : Write(#7);
              13 : begin
                     Window.CurX := Window.X1-1;
                     if Window.CurY>=Window.Y2 then
                     begin
                       Window.CurY := Window.Y2-1;
                       ScrollUp(Window.X1,Window.Y1,
                                Window.X2,Window.Y2,Window.Attr);
                     end;
                   end;
              else
                begin
                  Regs.AH := $0E;
                  Regs.AL := Lo(AX);
                  Regs.BL := Window.Attr;
                  Intr($10,Regs);
                end;
            end;
            Inc(Window.CurX);
            GotoXY(Window.CurX,Window.CurY);
          end;
    $0F : begin
            AX := $03+(80 SHL 8);
            BX := Lo(BX);
          end;
     else
       begin
         Regs.AX    := AX;
         Regs.BX    := BX;
         Regs.CX    := CX;
         Regs.DX    := DX;
         Regs.SI    := SI;
         Regs.DI    := DI;
         Regs.DS    := DS;
         Regs.ES    := ES;
         Regs.BP    := BP;
         Regs.Flags := Flags;
         Intr($10,Regs);
         AX         := Regs.AX;
         BX         := Regs.BX;
         CX         := Regs.CX;
         DX         := Regs.DX;
         SI         := Regs.SI;
         DI         := Regs.DI;
         DS         := Regs.DS;
         ES         := Regs.ES;
         BP         := Regs.BP;
         Flags      := Regs.Flags;
       end;
  end;
  {$ifOPT D+}
  if Fnc<>OldFnc then
  begin
    WriteXY(1,2,14,FStr(Window.CurX)+':'+FStr(Window.CurY)+'  ');
    WriteXY(1,3,14,FStr(Window.CurX-Window.X1+1)+':'+
                   FStr(Window.CurY-Window.Y1+1)+'  ');
    WriteXY(40,2,14,'AH: '+FStr(Hi(AX))+'  ');
    WriteXY(40,3,14,'AL: '+FStr(Lo(AX))+'  ');
    WriteXY(40,4,14,'BH: '+FStr(Hi(BX))+'  ');
    WriteXY(40,5,14,'BL: '+FStr(Lo(BX))+'  ');
    WriteXY(50,2,14,'CH: '+FStr(Hi(CX))+'  ');
    WriteXY(50,3,14,'CL: '+FStr(Lo(CX))+'  ');
    WriteXY(50,4,14,'DH: '+FStr(Hi(DX))+'  ');
    WriteXY(50,5,14,'DL: '+FStr(Lo(DX))+'  ');
    OldFnc := Fnc;
  end;
  {$endif}
  SetIntVec($10,@NewInt10);
end;
{$F-}

Procedure ExecWindow;
begin
  Window.X1   := X1;
  Window.Y1   := Y1;
  Window.X2   := X2;
  Window.Y2   := Y2;
  Window.Attr := Attr;
  {$ifOPT D+}
  Fnc         := 255;
  OldFnc      := 255;
  {$endif}
  ClearXY(Window.X1,Window.Y1,
          Window.X2,Window.Y2,Window.Attr);
  GotoXY(Window.X1,Window.Y1);
  Window.CurX := Window.X1;
  Window.CurY := Window.Y1;
  SwapVectors;
  GetIntVec($10,SaveInt10);
  SetIntVec($10,@NewInt10);
  Exec(Path,CmdLine);
  SetIntVec($10,SaveInt10);
  SwapVectors;
end;

begin
  Window.X1   := Lo(WindMin);
  Window.Y1   := Hi(WindMin);
  Window.X2   := Lo(WindMax);
  Window.Y2   := Hi(WindMax);
  Window.Attr := TextAttr;
  Window.CurX := WhereX;
  Window.CurY := WhereY;
  Cleared     := False;
  ActPage     := Ptr(Seg0040,$0062);
  VideoMode   := Ptr(Seg0040,$0049);
  if VideoMode^=7 then
    Screen := Ptr(SegB000,$0000)
  else
    Screen := Ptr(SegB800,$0000);
end.

