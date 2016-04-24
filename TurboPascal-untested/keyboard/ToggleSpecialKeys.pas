(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0110.PAS
  Description: Toggle Special Keys
  Author: VARIOUS
  Date: 02-21-96  21:04
*)

{
 JR> Does anyone have the code (probably ASM) to turn the CapsLock key of
 JR> _and_ on as well?  Thanks in advance if you can help.
}

Procedure TogLed (Lock: Integer);

Const
     Num=1;
     Caps=2;
     Scroll=3;
     AllOff=0;
     AllOn=4;

Type
    BitMapByte=Array[0..7] OF Boolean;


Var
  OldStatByte,
  StatByte:  Byte;
  StatMap:  BitMapByte;
  OldTimerVec:  Pointer;

Label
     Start,GetOne,Quit;

{****************************************************************}
Procedure BitMap(ToConvert:  Byte;
                 Var Converted:  BitMapByte);

Var Count:  Integer;
    Temp:  Word;

Begin {Procedure BitMap}
      For Count:=7 DownTo 0 DO
          Begin {FOR Count}
          Temp:=PowerX(2,Count);
          If ToConvert>=Temp
             Then
             Begin {If ToConvert>=Temp}
                 Converted[Count]:=True;
                 ToConvert:=ToConvert-Temp
             End   {If ToConvert>=Temp}
             Else
             Converted[Count]:=False
          End {FOR Count}
End;{Procedure BitMap}
{****************************************************************}
Procedure MapToByte(ToConvert:  BitMapByte;
                    Var Converted:  Byte);

Var
   Count:  Byte;

Begin {Procedure MapToByte}
     Converted:=0;
     For Count:=0 TO 7 Do
         If ToConvert[Count]
            Then
            Converted:=Converted+PowerX(2,Count);
End;  {Procedure MapToByte}
{****************************************************************************}
Begin {Procedure TogLed}
     StatByte:=Mem[0:$417];
     BitMap(StatByte,StatMap);
     Case Lock Of
          0: Begin
                  StatMap[4]:=False;
                  StatMap[5]:=False;
                  StatMap[6]:=False
             End;
          1: Begin
                  If StatMap[5]=True
                     Then
                     StatMap[5]:=False
                     Else
                     StatMap[5]:=True
             End;
          2: Begin
                  If StatMap[6]=True
                     Then
                     StatMap[6]:=False
                     Else
                     StatMap[6]:=True
             End;
          3: Begin
                  If StatMap[4]=True
                     Then
                     StatMap[4]:=False
                     Else
                     StatMap[4]:=True
             End;
          4: Begin
                  StatMap[4]:=True;
                  StatMap[5]:=True;
                  StatMap[6]:=True
             End;
     End;
     Asm
        Start:
        MOV AH,$05
        MOV CH,$00
        MOV CL,$00
        INT $16
        CMP AL,$1
        JE  GetOne
        JMP Quit
        GetOne:
        MOV AH,$00
        INT $16
        JMP Start
        Quit:
     End;
     MapTOByte(StatMap,StatByte);
     Mem[0:$417]:=StatByte;
     Asm
        MOV AH,$00
        INT $16
     End;
End;  {Procedure TogLed}


                 / -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- \
                 | Steve_Schwarz@f1244.n141.z1.fidonet.org |
                 |        SysOp: The RoadHouse BBS         |
                 |  (203) 263-5922  -=Home of the blues=-  |
                 \ -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- /

{ ---------------------------------------------------------------- }

USES DOS,CRT;

Type

   Toggles      = (RShift, LShift, Ctrl, Alt,
                   ScrollLock, NumLock, CapsLock, Insert);
   Status       = Set of Toggles;

Const
   ToggleStr   : Array[Toggles] OF String[10] = (
                 'RShift','LShift','Ctrl','Alt',
                 'Scroll','Num','Caps','Insert');

Var
   KeyStatus   : Status Absolute $40:$17;
   OldStatus   : Status;
   Flip        : BOOLEAN;
   T           : Toggles;


   PROCEDURE RandomRoutine;
   VAR
        R,C : BYTE;
   BEGIN
   R := Random(24) + 1;
   C := Random(79) + 1;
   GoToXY(C,R);Write(ToggleStr[T]);
   END;


   PROCEDURE StatusFlasher ( D : BYTE);
   BEGIN
   WHILE NOT Keypressed DO
      BEGIN
        IF Flip THEN KeyStatus := KeyStatus + [T] ELSE
                     KeyStatus := KeyStatus - [T];

        {  Call another routine here if you like }
        RandomRoutine;


        DEC(T);              { get the next toggle }
        DELAY(D);            { delay this long }
        Flip := NOT Flip;    { flip the on/off state }

        IF T = ALT THEN T := CapsLock;  { limit the list to just the three }

      END;
   END;


BEGIN
CLRSCR;
T         := Capslock;   { staring toggle          }
OldStatus := KeyStatus;  { save the current Status }
Flip      := TRUE;       { used to flip it off/on  }

StatusFlasher( 100 );           { the main procedure to make lights flash }

KeyStatus := OldStatus;  { restore original status }

END.

Martin Woods
martin@nisa.net

