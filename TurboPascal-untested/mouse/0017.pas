
                    {MOUSE.PAS creates MOUSE.TPU Unit}
     {From the book "OBJECT ORIENTED PROGRAMMING IN TURBO PASCAL 5.5"}

Unit Mouse;

Interface

Type
    GCursor = record
            ScreenMask,
            CursorMask : array[0..15] of word;
            hotX,hotY  : integer;
            end; {record}


                  {================================}
                  {Graphics Cursors are predefined }
                  {for use with GraphicMouse       }
                  {================================}


Const           {The graphics cursors are defined as constants       }

     HAMMER : GCursor =       {As in the hammer of THOR, my favorite}
            (ScreenMask : ($8003,$0001,$0001,$1831,
                           $1011,$0001,$0001,$8003,
                           $F83F,$F83F,$F83F,$F83F,
                           $F83F,$F83F,$F83F,$F83F);
             CursorMask : ($0000,$3FF8,$4284,$4104,
                           $4284,$4444,$3FF8,$0380,
                           $0380,$0380,$0380,$0380,
                           $0380,$0380,$0380,$0000);
             HotX : $0007;
             HotY : $0003);

     ARROW : GCursor =       {Your run-of-the-mill Graphics Arrow cursor}
           (ScreenMask : ($1FFF,$0FFF,$07FF,$03FF,
                          $01FF,$00FF,$007F,$003F,
                          $001F,$003F,$01FF,$01FF,
                          $E0FF,$F0FF,$F8FF,$F8FF);
            CursorMask : ($0000,$4000,$6000,$7000,
                          $7800,$7C00,$7E00,$7F00,
                          $7F80,$7C00,$4C00,$0600,
                          $0600,$0300,$0400,$0000);
            HotX : $0001;
            HotY : $0001);

     CHECK : GCursor =       {A check-mark cursor}
           (ScreenMask : ($FFF0,$FFE0,$FFC0,$FF81,
                          $FF03,$0607,$000F,$001F,
                          $803F,$C07F,$E0FF,$F1FF,
                          $FFFF,$FFFF,$FFFF,$FFFF);
            CursorMask : ($0000,$0006,$000C,$0018,
                          $0030,$0060,$70C0,$3980,
                          $1F00,$0E00,$0400,$0000,
                          $0000,$0000,$0000,$0000);
            HotX : $0005;
            HotY : $0010);

     CROSS : GCursor =       {A circle with center cross cursor}
           (ScreenMask : ($F01F,$E00F,$C007,$8003,
                          $0441,$0C61,$0381,$0381,
                          $0381,$0C61,$0441,$8003,
                          $C007,$E00F,$F01F,$FFFF);
            CursorMask : ($0000,$07C0,$0920,$1110,
                          $2108,$4004,$4004,$783C,
                          $4004,$4004,$2108,$1110,
                          $0920,$07C0,$0000,$0000);
            HotX : $0007;
            HotY : $0007);

     GLOVE : GCursor =       {The hand with pointing finger cursor}
           (ScreenMask : ($F3FF,$E1FF,$E1FF,$E1FF,
                          $E1FF,$E049,$E000,$8000,
                          $0000,$0000,$07FC,$07F8,
                          $9FF9,$8FF1,$C003,$E007);
            CursorMask : ($0C00,$1200,$1200,$1200,
                          $1200,$13B6,$1249,$7249,
                          $9249,$9001,$9001,$8001,
                          $4002,$4002,$2004,$1FF8);
            HotX : $0004;
            HotY : $0000);

     IBEAM : GCursor =       {Your normal text entering I shaped cursor}
           (ScreenMask : ($F3FF,$E1FF,$E1FF,$E1FF,
                          $E1FF,$E049,$E000,$8000,
                          $0000,$0000,$07FC,$07F8,
                          $9FF9,$8FF1,$C003,$E007);
            CursorMask : ($0C30,$0240,$0180,$0180,
                          $0180,$0180,$0180,$0180,
                          $0180,$0180,$0180,$0180,
                          $0180,$0180,$0240,$0C30);
            HotX : $0007;
            HotY : $0007);

      KKG : GCursor =     {KKG symbol, a little sorority stuff}
        (ScreenMask : ($FFFF,$1040,$1040,$0000,
                       $0000,$0000,$0411,$0411,
                       $0001,$0001,$0001,$1041,
                       $1041,$1041,$FFFF,$FFFF );
         CursorMask : ($0000,$0000,$4517,$4515,
                       $4925,$5144,$6184,$6184,
                       $5144,$4924,$4514,$4514,
                       $4514,$0000,$0000,$0000 );
         HotX : $0007;
         HotY : $0005);

      SMILEY : GCursor =  {a Smiley face for you!}
        (ScreenMask : ($C003,$8001,$07E0,$0000,
                       $0000,$0000,$0000,$0000,
                       $0000,$0000,$0000,$8001,
                       $C003,$C003,$E007,$F81F );
         CursorMask : ($0FF0,$1008,$2004,$4002,
                       $4E72,$4A52,$4E72,$4002,
                       $4992,$581A,$2424,$13C8,
                       $1008,$0C30,$03C0,$0000 );
         HotX : $0007;
         HotY : $0005);

      XOUT : GCursor =    {a BIG X marks the spot}
        (ScreenMask : ($1FF8,$0FF0,$07E0,$03C0,
                       $8181,$C003,$E007,$F00F,
                       $F81F,$F00F,$E007,$C003,
                       $8181,$03C0,$07E0,$0FF0 );
         CursorMask : ($8001,$C003,$6006,$300C,
                       $1818,$0C30,$0660,$03C0,
                       $0180,$03C0,$0660,$0C30,
                       $1818,$300C,$6006,$C003 );
         HotX : $0007;
         HotY : $0008);

      SWORD : GCursor =   {For the D&D buffs...}
        (ScreenMask : ($F83F,$F83F,$F83F,$F83F,
                       $F83F,$F83F,$F83F,$F83F,
                       $8003,$8003,$8003,$8003,
                       $8003,$F83F,$F01F,$F01F );
         CursorMask : ($0100,$0380,$0380,$0380,
                       $0380,$0380,$0380,$0380,
                       $0380,$3398,$3398,$3FF8,
                       $0380,$0380,$0380,$07C0 );
         HotX : $0007;
         HotY : $0000);


Type
    Position = record
             btnStat,
             opCount,
             Xpos,Ypos : integer;
             end; {record}

Const
     ButtonL = 0;
     ButtonR = 1;
     ButtonM = 2;
     Software = 0;
     Hardware = 1;

     
Type
    GenMouse = object
             X,Y : integer;
             Visible : boolean;
             Function TestMouse : boolean;
             Procedure SetAccel(Threshold : integer);
             Procedure Show(Option : boolean);
             Procedure GetPosition(var BtnStatus,Xpos,Ypos : integer);
             Procedure QueryBtnDn(Button : integer;var mouse : position);
             Procedure QueryBtnUp(Button : integer;var mouse : position);
             Procedure ReadMove(var XMove,YMove : integer);
             Procedure Reset(var Status : boolean;var BtnCount : integer);
             Procedure SetRatio(HorPix,VerPix : integer);
             Procedure SetLimits(XPosMin,YPosMin,XPosMax,YPosMax : integer);
             Procedure SetPosition(XPos,YPos : integer);
             end; {object}

    GraphicMouse = object(GenMouse)
                 Procedure Initialize;
                 Procedure ConditionalHide(Left,Top,Right,Bottom : integer);
                 Procedure SetCursor(Cursor : GCursor);
                 end; {object}

    TextMouse = object(GenMouse)
              Procedure Initialize;
              Procedure SetCursor(Ctype,C1,C2 : word);
              end; {object}

    GraphicLightPen = object(GraphicMouse)
                    Procedure LightPen(Option : boolean);
                    end; {object}

    TextLightPen = object(TextMouse)
                 Procedure LightPen(Option : boolean);
                 end; {object}

{=========================================================================}

Implementation

Uses
    Crt,Graph,Dos;
Var
   Regs : registers;

{*************************************************************************}

Function Lower(N1,N2 : integer) : integer;
Begin
     if N1 < N2 then
        Lower := N1
     else
         Lower := N2;
End;

{*************************************************************************}

Function Upper(N1,N2 : integer) : integer;
Begin
     if N1 > N2 then
        Upper := N1
     else
         Upper := N2;
End;

{*************************************************************************}

Function GenMouse.TestMouse : boolean;
Const
     Iret = 207;
Var
   dOff,dSeg : integer;
Begin
     dOff := MemW[0000:0204];
     dSeg := MemW[0000:0206];
     if ((dSeg = 0) or (dOff = 0)) then
        TestMouse := False
     else
         TestMouse := Mem[dSeg:dOff] <> Iret;
End;

{*************************************************************************}

Procedure GenMouse.Reset(var Status : boolean; var BtnCount : integer);
Begin
     Regs.AX := $00;            {Reset to default conditions}
     intr($33,Regs);
     Status := Regs.AX <> 0;    {Mouse Present}
     BtnCount := Regs.BX;       {Button Count}
End;

{*************************************************************************}

Procedure GenMouse.SetAccel(Threshold : integer);
Begin
     Regs.AX := $13;
     Regs.DX := Threshold;
     Intr($33,Regs);
End;

{*************************************************************************}

Procedure GenMouse.Show(Option : boolean);
Begin
     if Option and not Visible then
     begin
          Regs.AX := $01;         {Show mouse cursor}
          Visible := True;
          Intr($33,Regs);
     end
     else
     if Visible and not Option then
     begin
          Regs.AX := $02;           {Hide mouse cursor}
          Visible := False;
          Intr($33,Regs);
     end;
End;

{*************************************************************************}

Procedure GenMouse.GetPosition(var BtnStatus,Xpos,Ypos : integer);
Begin
     Regs.AX := $03;
     Intr($33,Regs);
     BtnStatus := Regs.BX;
     Xpos      := Regs.CX;
     Ypos      := Regs.DX;
End;

{*************************************************************************}

Procedure GenMouse.SetPosition(Xpos,Ypos : integer);
Begin
     Regs.AX := $04;
     Regs.CX := Xpos;
     Regs.DX := Ypos;
     Intr($33,Regs);
End;

{*************************************************************************}

Procedure GenMouse.SetRatio(HorPix,VerPix : integer);
Begin
     Regs.AX := $0F;
     Regs.CX := HorPix;         {horizonal mickeys/pixel}
     Regs.DX := VerPix;         {vertical mickeys/pixel}
     Intr($33,Regs);
End;

{*************************************************************************}

Procedure GenMouse.QueryBtnDn(Button : integer;var Mouse : position);
Begin
     Regs.AX := $05;
     Regs.BX := Button;
     Intr($33,Regs);
     Mouse.BtnStat := Regs.AX;
     Mouse.OpCount := Regs.BX;
     Mouse.Xpos    := Regs.CX;
     Mouse.Ypos    := Regs.DX;
End;

{*************************************************************************}

Procedure GenMouse.QueryBtnUp(Button : integer;var Mouse : position);
Begin
     Regs.AX := $06;
     Regs.BX := Button;
     Intr($33,Regs);
     Mouse.BtnStat := Regs.AX;
     Mouse.OpCount := Regs.BX;
     Mouse.Xpos    := Regs.CX;
     Mouse.Ypos    := Regs.DX;
End;

{*************************************************************************}

Procedure GenMouse.SetLimits(XPosMin,YPosMin,XPosMax,YPosMax : integer);
Begin
     Regs.AX := $07;    {horizonal limits}
     Regs.CX := Lower(XPosMin,XPosMax);
     Regs.DX := Upper(XPosMin,XPosMax);
     Intr($33,Regs);
     Regs.AX := $08;    {vertical limits}
     Regs.CX := Lower(YPosMin,YPosMax);
     Regs.DX := Upper(YPosMin,YPosMax);
     Intr($33,Regs);
End;

{*************************************************************************}

Procedure GenMouse.ReadMove(var XMove,YMove : integer);
Begin
     Regs.AX := $0B;
     Intr($33,Regs);
     XMove := Regs.CX;
     YMove := Regs.DX;
End;

{*************************************************************************}

             {=======================================}
             {Implementation methods for GraphicMouse}
             {=======================================}

Procedure GraphicMouse.SetCursor(Cursor : GCursor);
Begin
     Regs.AX := $09;
     Regs.BX := Cursor.HotX;
     Regs.CX := Cursor.HotY;
     Regs.DX := Ofs(Cursor.ScreenMask);
     Regs.ES := Seg(Cursor.ScreenMask);
     Intr($33,Regs);
End;

{*************************************************************************}

Procedure GraphicMouse.ConditionalHide(Left,Top,Right,Bottom : integer);
Begin
     Regs.AX := $0A;
     Regs.CX := Left;
     Regs.DX := Top;
     Regs.SI := Right;
     Regs.DI := Bottom;
     Intr($33,Regs);
End;

{*************************************************************************}

Procedure GraphicMouse.Initialize;
Begin
     Visible := False;
     SetLimits(0,0,GetMaxX,GetMaxY);
     SetCursor(Arrow);
     SetPosition(GetMaxX div 2,GetMaxY div 2);
     Show(True);
End;

{*************************************************************************}

                    {====================================}
                    {Implementation methods for TextMouse}
                    {====================================}

Procedure TextMouse.Initialize;
Begin
     Visible := False;
     SetLimits(Lo(WindMin)*8,Hi(WindMin)*8,Lo(WindMax)*8,Hi(WindMax)*8);
     SetCursor(Hardware,6,7);
     SetPosition(0,0);
     Show(True);
End;

{*************************************************************************}

Procedure TextMouse.SetCursor(CType,C1,C2 : word);
Begin
     Regs.AX := $0A;            {function 10h}
     Regs.BX := CType;          {0=software,1=hardware}
     Regs.CX := C1;             {screen mask or scan start line}
     Regs.DX := C2;             {screen mask or scan stop line}
     Intr($33,Regs);
End;

{*************************************************************************}

             {===================================}
             {Implementation methods for LightPen}
             {===================================}

Procedure TextLightPen.LightPen(Option : boolean);
Begin
     if Option then
        Regs.AX := $0D
     else
         Regs.AX := $0E;
     Intr($33,Regs);
End;

{*************************************************************************}

Procedure GraphicLightPen.LightPen(Option : boolean);
Begin
     if Option then
        Regs.AX := $0D
     else
         Regs.AX := $0E;
     Intr($33,Regs);
End;

{*************************************************************************}

BEGIN
END.

