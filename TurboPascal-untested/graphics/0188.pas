{
Hello Folks!

Here is some 3D-Roation stuff.

Tell me, what you think of it, please!

---------------------------------------------------------------------
}

Uses Crt,dos;

(*******************************************************************
 * Displaying a 3D-Cube of point from any difference in any angle. *
 * THIS CODE IS PUBLIC DOMAIN!                                     *
 *                                                                 *
 * Writen by Axel Plinge                                           *
 *   Fido Net:  Axel Plinge @ 2:2448/327.11                        *
 *   InterNet:  axel.plinge@tca-os.ruhr.de                         *
 *******************************************************************)

Type Mat33               = Array[1..3,1..3] of longint;
     Point2D             = Record X,Y : LongInt End;
     Point3D             = Record X,Y,Z : LongInt End;

const CharLength      = 8;
      CharSetNr       = 3;

Type  OneChar = Array [0..CharLength-1] of Byte;

TYPE  ZDEF = ARRAY[#0..#255] OF onechar;
      ZPtr = ^ZDEF;

CONST BIOS_Font : ZPtr = NIL;
const RS = 40;

VAR vio_seg : Word;
    page    : Byte;
    Ofstab  : ARRAY[0..399] OF Word;

PROCEDURE Init;ASSEMBLER;
ASM
    MOV  AX,0EH
    INT  10h

    MOV  DX,3d4h
    MOV  AL,9
    OUT  DX,AL
    INC  DX
    IN   AL,DX
    AND  AL,01110000b
    OUT  DX,AL

    MOV  vio_seg,0a000h
    MOV  page,0

    XOR  AX,AX
    MOV  DI,offset Ofstab
    PUSH DS
    POP  ES
    MOV  CX,400
 @L:
    STOSW
    ADD  AX,80
    LOOP @L
END;

PROCEDURE flip;ASSEMBLER;
ASM
    XOR  BX,BX
    CMP  page,0
    JE   @s0
    MOV  BX, 7d0h
  @s0:
    ADD  BX,0a000h
    MOV  vio_seg,BX
    XOR  BX,BX
    CMP  page,1
    JE   @s1
    MOV  BX, 7d00h
    MOV  page,1
    jmp  @w
  @s1:
    MOV  page,0
  @w:
    MOV  DX, 3d4h
    MOV  AL, 0DH
    CLI
    OUT  DX, AL
    INC  DX
    MOV  AL, BL
    OUT  DX, AL
    DEC  DX
    MOV  AL, 0CH
    OUT  DX, AL
    INC  DX
    MOV  AL, BH
    OUT  DX, AL
    STI
END;


VAR Color:Byte;

PROCEDURE SetzPixel(X,y:Word);ASSEMBLER;
ASM
    MOV  BX,y
    ADD  BX,BX
    MOV  AX,[offset Ofstab+BX]
    MOV  BX,X
    MOV  CL,BL
    shr  BX,3
    ADD  BX,AX
    AND  CL,7
    XOR  CL,7
    MOV  AH,1
    shl  AH,CL
    MOV  DX,3ceh
    MOV  AL,8
    OUT  DX,AX
    MOV  AX,(02h shl 8) + 5
    OUT  DX,AX
    MOV  AX,vio_seg
    MOV  ES,AX
    MOV  AL,ES:[BX]
    MOV  AL,color
    MOV  ES:[BX],AL
END;

PROCEDURE PutLine(X,y:Word;L:byte);ASSEMBLER;
ASM
    MOV   BX,y
    ADD   BX,BX
    MOV   AX,[offset Ofstab+BX]
    MOV   BX,X
    ADD   BX,AX
    MOV   AH,L
    MOV   DX,3ceh
    MOV   AL,8
    OUT   DX,AX
    MOV   AX,(02h SHL 8) + 5
    OUT   DX,AX
    MOV   AX,vio_seg
    MOV   ES,AX
    MOV   AL,ES:[BX]
    MOV   AL,Color
    MOV   ES:[BX],AL
END;

PROCEDURE cls;assembler;
ASM
    MOV   DX,3ceh
    mov ah,0ffh
    MOV   AL,8
    OUT   DX,AX
    MOV   AX,(02h SHL 8) + 5
    OUT   DX,AX
    MOV   AX,vio_seg
    MOV   ES,AX
    xor   bx,bx
    MOV   cx,640*400/16
    @l:
    MOV   Ax,ES:[BX]
    xor   Ax,ax
    MOV   ES:[BX],Ax
    inc bx
    inc bx
    dec cx
    jnz @l
END;

PROCEDURE Retrace;assembler;
asm
  MOV DX, 3dah
  @WaitNotVSyncLoop:
    in   al, dx
    and  al, 8
    jnz  @WaitNotVSyncLoop
  @WaitVSyncLoop:
    in   al, dx
    and  al, 8
    jz   @WaitVSyncLoop
end;


Procedure GetChars;
VAR Regs:Registers;
BEGIN
 Regs.AH:=$11;
 Regs.AL:=$30;
 Regs.BH:=  CharSetNr;
 Intr($10,Regs);
 BIOS_Font:=Ptr(Regs.ES,Regs.BP);
END;

PROCEDURE WriteChr(X,Y:Integer;Z:Char);
var I,c,Maske : Byte;
BEGIN
 FOR i:=0 TO charLength-1 DO BEGIN
  PutLine(X SHR 3,y+i,BIOS_Font^[Z,I]);
 END;
END;

PROCEDURE WriteStr(X,Y:Integer;S:String);
VAR I:Byte;

BEGIN
 FOR I:=1 TO Length(S) DO BEGIN
  WriteChr(X,Y,S[I]);
  Inc(X,8);
 END;
END;

PROCEDURE WriteNr(X,Y:Integer;L:Longint);
VAR I:Byte;
    S:String[8];
BEGIN
 Str(L:3,S);
 FOR I:=1 TO Length(S) DO BEGIN
  WriteChr(X,Y,S[I]);
  Inc(X,8);
 END;
END;


Var x, y, z                 : Real;
    i,j,k                   : INTEGER;
    tz                      : longint;
    Mat                     : Mat33;
    Dist_X, Dist_Y, Dist_Z  : Integer;
    Ang_X,  Ang_Y,  Ang_Z   : word;
    Ende                    : Boolean;
    Point                   : Point3d;
    px,py                   : integer;

BEGIN
 GetChars;
 Init;
 Dist_X:=0; Dist_Y:=0; Dist_Z:=1;
 Ang_X:=0;  Ang_Y:=0;  Ang_Z:=0;
 Ende:=False;
 Repeat
  { Tastaturbehandlung }
  If KeyPressed then Begin
    case ReadKey of
      '+' : IF Dist_Z>  1 THEN DEC(Dist_Z);
      '-' : IF Dist_Z< 70 THEN Inc(Dist_Z);
      '4' : IF Dist_X>-99 THEN DEC(Dist_X);
      '6' : IF Dist_X< 99 THEN Inc(Dist_X);
      '8' : IF Dist_Y>-99 THEN DEC(Dist_Y);
      '2' : IF Dist_Y< 99 THEN Inc(Dist_Y);
      #27 : Ende:=true;
      #0  : CASE readkey of
             #77 : Ang_Y:=Ang_Y + 1;
             #75 : if (Ang_Y > 0) then
                    Ang_Y:=Ang_Y - 1
                   else if Ang_Y=0 THEN Ang_Y:=359;

             #80 : Ang_X:=Ang_X + 1;
             #72 : if (Ang_X > 0) then
                      Ang_X:=Ang_X - 1
                   else if Ang_X=0 THEN Ang_X:=359;

             #81 : Ang_Z:=Ang_Z + 1;
             #73 : if (Ang_Z > 0) then
                      Ang_Z:=Ang_Z - 1
                   else if Ang_Z=0 THEN Ang_Z:=359;
             end;
     end
   End;
   IF ang_x>=360 THEN ang_x:=ang_x-360;
   IF ang_y>=360 THEN ang_y:=ang_y-360;
   IF ang_z>=360 THEN ang_z:=ang_z-360;
   x:=ang_x * Pi / 180;
   y:=ang_y * Pi / 180;
   z:=ang_z * Pi / 180;
   {
    ┌                                                                      ┐
    │     cosZ*cosY                      -cosY*sinZ                 sinY   │
    │ cosX*sinZ-sinY*cosZ*sinX      cosZ*cosX+sinX*sinZ*sinY     cosY*sinX │
    │-sinX*sinZ-sinY*cosZ*cosX     -cosZ*sinX+sinZ*sinY*cosX     cosX*cosY │
    └                                                                      ┘
   }
   Mat[1][1]:=round(cos(z)*cos(y)*(1 SHL 12));
   Mat[1][2]:=round(-sin(z)*cos(y)*(1 SHL 12));
   Mat[1][3]:=round(sin(y)*(1 SHL 12));
   Mat[2][1]:=round((cos(x)*sin(z)-sin(y)*cos(z)*sin(x))*(1 SHL 12));
   Mat[2][2]:=round((cos(z)*cos(x)+sin(x)*sin(z)*sin(y))*(1 SHL 12));
   Mat[2][3]:=round((cos(y)*sin(x))*(1 SHL 12));
   Mat[3][1]:=round((-sin(x)*sin(z)-sin(y)*cos(z)*cos(x))*(1 SHL 12));
   Mat[3][2]:=round((-cos(z)*sin(x)+sin(z)*sin(y)*cos(x))*(1 SHL 12));
   Mat[3][3]:=round(cos(x)*cos(y)*(1 SHL 12));
   { Z-Divisor }
   tz:=abs(Dist_Z) + 1;
   flip;
   retrace;
   cls;
   { show Data }
   Color:=white;
   WriteStr(10,10,'X');
   WriteNr( 20,10, Dist_X);
   WriteNr( 50,10,  Ang_X);
   WriteStr(74,10,'°');
   WriteStr(10,20,'Y');
   WriteNr( 20,20, Dist_Y);
   WriteNr( 50,20,  Ang_Y);
   WriteStr(74,20,'°');
   WriteStr(10,30,'Z');
   WriteNr( 20,30, Dist_Z);
   WriteNr( 50,30,  Ang_Z);
   WriteStr(74,30,'°');
    { Raster }
   color:=white;
   FOR k:=-5 TO 5  DO
   FOR j:=-5 TO 5 DO
   FOR i:=-5 TO 5 DO BEGIN
     Point.X:=RS*I-Dist_X;
     Point.Y:=RS*J-Dist_Y;
     Point.Z:=RS*K-Dist_z;
     { Rotation through Matrix Multiplication }
     Point.X:=(Point.X*MAT[1][1] + Point.Y*MAT[1][2] + Point.Z*MAT[1][3]) div
(1 shl 12);     Point.Y:=(Point.X*MAT[2][1] + Point.Y*MAT[2][2] +
Point.Z*MAT[2][3]) div (1 shl 12);     Point.Z:=(Point.X*MAT[3][1] +
Point.Y*MAT[3][2] + Point.Z*MAT[3][3]) div (1 shl 12);     { 3D -> 2D }
     Point.x:= point.x div tz;
     Point.y:= point.y div tz;
     IF (abs(Point.x)<320) AND (abs(point.y)<200) THEN BEGIN
     { Did I mention this was not optimized ??  ;-) }
      Point.X:=Point.X+320;
      Point.Y:=Point.Y+200;
      SetzPixel(Point.x,point.y);
    END;
   END;
 Until Ende;
 textmode(lastmode);
END.


--------------------------------------------------------------------------

Greetings


Axel

--- CrossPoint v3.02 R
 * Origin: Pascal is nice, but ASM is fast! (2:2448/327.11)
SEEN-BY: 270/101 280/1 396/1 3615/50 51
PATH: 2448/327 3000 4000 10 69 2426/2011 2001 2449/600 2433/1200
PATH: 242/42 2452/110 105/42 103 270/101 396/1 3615/50
