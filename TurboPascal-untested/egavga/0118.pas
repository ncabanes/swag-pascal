Unit FadeUnit;          { called FadeUnit.Pas }

{ This unit does fading for text/graph modes }

interface

procedure InitCol; { gets the current palette and saves it }
procedure FadeOut(Duration : byte);   { lowers/increases the brightness, }
procedure FadeIn(Duration : byte);    { duration determines the time it takes}
procedure SetBrightness(Brightness : byte); { sets the brightness to brightnes}

implementation

uses Crt; { use Delay procedure from there }

const
PelIdxR  = $3C7; { Port to read from }
PelIdxW  = $3C8; { Port to write to }
PelData  = $3C9; { Dataport }
Maxreg   = 63;   { Set to 255 for graphmode }
MaxInten = 63;

type
TRGB = record R, G, B : byte end;

var
Col : array[0..MaxReg] of TRGB;
I : byte;

Procedure GetCol(ColNr : byte; var R, G, B : byte); assembler;
Asm
MOV DX,PelIdxR
MOV AL,ColNr
OUT DX,AL
MOV DX,PelData
LES SI,R
IN AL,DX
MOV BYTE PTR [ES:SI],AL
LES SI,G
IN AL,DX
MOV BYTE PTR [ES:SI],AL
LES SI,B
IN AL,DX
MOV BYTE PTR [ES:SI],AL
End; { GetCol }

Procedure SetCol(ColNr, R, G, B : byte); assembler; { Change just one color }
Asm
MOV DX,PelIdxW
MOV AL,ColNr
OUT DX,AL
MOV DX,PelData
MOV AL,R
OUT DX,AL
MOV AL,G
OUT DX,AL
MOV AL,B
OUT DX,AL
End; { SetCol }

Procedure InitCol; { Save initial palette }
Begin
for I := 0 to MaxReg do GetCol(I, Col[I].R, Col[I].G, Col[I].B)
End; { InitCol }

Procedure SetBrightness;
Begin
for I := 0 to MaxReg do
SetCol(I,
Col[I].R * Brightness div MaxInten,
Col[I].G * Brightness div MaxInten,
Col[I].B * Brightness div MaxInten)
End; { SetBrightness }

Procedure FadeOut;
var I : byte;
Begin
for I := MaxInten downto 0 do
begin
SetBrightness(I);
Delay(Duration)
end
End; { FadeOut }

Procedure FadeIn;
var I : byte;
Begin
for I := 0 to MaxInten do
begin
SetBrightness(I);
Delay(Duration)
end
End; { FadeIn }

End. { FADEUNIT.PAS }
