(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0081.PAS
  Description: Keyboard Unit
  Author: ALEX GRISCHENKO
  Date: 08-24-94  13:44
*)


{$X+,S-,R-,I-,L-,O-,B-,D-}
{*****************************************}
{*  Keyboard unit for BP 7.0             *}
{*  Direct INT 9h support                *}
{*  Written by Alex Grischenko           *}
{*  Modified by Olaf Bartelt for DPMI    *}
{*  (C) AntSoft Lab , 1994               *}
{*  Version 1.0 30-06-94                 *}
{*****************************************}

Unit  Keyboard;

interface

type
  DoubleKey = object
    Left,Right : boolean;
    function Both : boolean;
    function Any  : boolean;
  end;

  LockKey = record
    Pressed,Locked : boolean;
  end;

  KeyEvent = record
    case Integer of
     0: (KeyCode : Word);
     1: (CharCode: Char; ScanCode: Byte);
  end;


const
  SEG0000  : WORD = $0000;

  k_LShift = $2A00;
  k_RShift = $3600;
  k_LAlt   = $3800;
  k_RAlt   = $3800 or $8000;
  k_LCtrl  = $1D00;
  k_RCtrl  = $1D00 or $8000;

  k_PrtScr     = $F900;
  k_SysReg     = $F800;
  k_Pause      = $F700;
  k_Break      = $F600;
  k_CapsLock   = $3A00;
  k_NumLock    = $4500;
  k_ScrollLock = $4600;

  k_AltCtrlDel = $F200;

  WasKeybEvent : boolean = false;  { Was event from keyboard }
  Pressed  : boolean = false;      { TRUE - key pressed, FALSE - released }

  ESC    : boolean   = false;
  Alt    : DoubleKey = ( Left : false; Right : false );
  Ctrl   : DoubleKey = ( Left : false; Right : false );
  Shift  : DoubleKey = ( Left : false; Right : false );
  PrtScr    : boolean = false;
  CapsLock  : LockKey = ( Pressed : false; Locked : false );
  NumLock   : LockKey = ( Pressed : false; Locked : false );
  ScrollLock: LockKey = ( Pressed : false; Locked : false );
  Pause     : boolean = false;
  CtrlBreak : boolean = false;

  AltCtrlDel: boolean = false;

procedure InitKeyboard;             { Initalize driver }
procedure DoneKeyboard;             { Uninstall driver }
function  ReadKeyboard : byte;      { Read current scancode from keyboard
                                      ( }
function  KeyPressed  : boolean;    { Keys was pressed?             }
function  ReadKey  : char;          { For using instead CRT.ReadKey }
function  ReadChar : char;          { Converts scancode to ASC-key  }
procedure GetKeyEvent(var KEvent : KeyEvent);

procedure NullProc;
{procedure KeybLights(On : boolean; Light : byte);}

const
  AltCtrlDelproc : procedure = NullProc;
  { Alt-Ctrl-Del Handler }

implementation

function DoubleKey.Both : boolean;
begin
  Both:=Right and Left;
end;

function DoubleKey.Any : boolean;
begin
  Any:=Right or Left;
end;

const
  Key : byte = 0;
  KeyboardSet : boolean = false;

  KeyCodes : array [1..$58] of word = (

{******** 85 - key **********}
       {ESC  1  2  3  4  5  6  7  8  9  0  -  =  BkSp}
 27, 49,50,51,52,53,54,55,56,57,48,45,61,    8,

       {TAB  Q  W  E  R  T  Y  U  I  O  P  [  ] Enter}
        9,  81,87,69,82,84,89,85,73,79,80,91,93,   13,

     {LCtrl  A  S  D  F  G  H  J  K  L  ;  '  `}
    k_LCtrl,65,83,68,70,71,72,74,75,76,59,39,96,

    {LShift  \  Z  X  C  V  B  N  M  ,  .  /  RShift}
   k_LShift,92,90,88,67,86,66,78,77,44,46,47, k_RShift,

       { *  LAlt   Space  CapsLock}
 42, k_LAlt,   32, k_CapsLock,

       {F1    F2    F3    F4    F5    F6    F7    F8    F9   F10}
     $3B00,$3C00,$3D00,$3E00,$3f00,$4000,$4100,$4200,$4300,$4400,

    {  NumLock    ScrollLock}
     k_NumLock, k_ScrollLock,

     {Home    Up  PgUp  K  -  Left  K  5 Right  K  +}
     $4700,$4800,$4900,$4A2D,$4b00,$4c00,$4d00,$4e2b,

     { End  Down  PgDn   Ins   Del}
     $4f00,$5000,$5100,$5200,$5300,

{******** 101 - key **********}
    {AltPrtScr          F11     F12}
         $5400, 0, 0, $5700,  $5800);

    ExtCode    : byte    = 0;
    ExtExtCode : byte    = 0;
    Extent     : boolean = false;

var
  oldint9seg,oldint9ofs : word;
  Lights : byte ;
{  Queue : array[0..30] of byte;
}  QHead,QTail : word;


{ - Wait keyboard }
procedure WaitKeyb; near; assembler;
asm
   push ax
@@Wait:
   in   al,64h
   test al,02h
   loopnz @@Wait
   pop  ax
end;

{ - Send byte to keyboard port }
procedure SendIt; near; assembler;
asm
  cli
  call WaitKeyb
  out 64h,al
  sti
end;

procedure SetLights; near; assembler;
asm
(*
  push ax
  mov  al,0EDh
{  call SendIt}
  out  60h,al
  mov  cx,200h
@loop:
  loop @loop
  mov  al,Lights
{  call SendIt }
  out  60h,al
  pop  ax
*)
end;


procedure MyInt9(Flags, CS, IP, AX, BX,
CX, DX, SI, DI, DS, ES, BP: Word); interrupt;
label IntEnd,SendEOI;
begin
  asm
    mov  ax, seg @data
    mov  ds,ax

    mov  al,0adh   { Disable keyboard }
    call sendit
    cli

    call WaitKeyb  { Wait }

    in  al,60h     { Get keycode }
    sti
    mov key,al;

push ax
mov  al,0AEh
call sendit
mov  al,20h
out  20h,al
pop  ax

@@keyEvent:
    mov WasKeybEvent,1    { Set event flag }

    mov ah,al
    and ah,0F0h      { Was extented keystroke ? }

    cmp ah,0E0h
    jne @NormalCode
(*    jne  @CheckAA    { no, check next ext. code AAh }

    cmp ExtCode,0AAh { Was sequence E0 AA E0 ? }
    jne @ExtCode     { No, set as firts extent code }

    mov Extent,0     { yes, clear exten flags }
    mov ExtCode,0
{    mov al,91        { Return as Shift key pressed }
    jmp IntEnd
*)
  @ExtCode:
    mov Extent,1   { yes, set flag and store extented code }
    mov ExtCode,al
    mov WasKeybEvent,0
    jmp IntEnd     { finish interrupt }

  @NormalCode:
    mov ah,al
    and al,7Fh     { mask low 7 bits }

    cmp al,60h
    jb @@IsKey

    cmp al,0A0h
    jb IntEnd

@@IsKey:
    and ah,80h     { check pressing  }
    je @@Pressed

    mov Pressed,0  { if higher bit set to 1, then key released }
    jmp @@1

  @@Pressed:
    mov Pressed,1

  @@1:
    mov key,al     { store key }
    mov ah,Pressed

{------------------------}
    cmp al,1
    jne @PrtScr
    mov ESC,ah
    jmp IntEnd

@PrtScr:
    cmp al,37h
    jne @next0
    cmp ExtCode,0E0h
    jne IntEnd
    mov PrtScr,ah

@next0:
    cmp al,2ah
    jne @next1
    cmp ExtCode,0E0h
    jne @ShiftL
@ExtShift:
    xor ax,ax
    mov WasKeybEvent,al
    mov ExtCode,al
    mov key,al
    jmp IntEnd
@ShiftL:
    mov Shift.Left,ah
    jmp IntEnd

@next1:
    cmp al,36h
    jne @next2
    cmp ExtCode,0E0h
    je  @ExtShift
    mov Shift.Right,ah
    jmp IntEnd

@next2:
    cmp al,38h
    jne @next3
    cmp ExtCode,0E0h
    je  @RAlt
    mov Alt.Left,ah
    jmp IntEnd
  @Ralt:
    mov Alt.Right,ah
    jmp @@ResetExt


@next3:
    cmp al,1Dh
    jne @next4
    cmp ExtCode,0E0h
    je  @RCtrl
    mov Ctrl.Left,ah
    jmp IntEnd
  @RCtrl:
    mov Ctrl.Right,ah
    jmp @@ResetExt

@next4:
    cmp al,3ah
    jne @next5
    mov CapsLock.Pressed,ah
    cmp ah,1
    je  IntEnd
    xor CapsLock.Locked,1
    xor Lights,4
    mov ax,0AEh
{    call SendIt}
    call SetLights
    jmp SendEOI

@next5:
    cmp al,45h
    jne @next6
    mov NumLock.Pressed,ah
    cmp ah,1
    je  IntEnd
    xor NumLock.Locked,1
    xor Lights,2
    mov ax,0AEh
{    call SendIt  }
    call SetLights
    jmp SendEOI

@next6:
    cmp al,46h
    jne @next7
    mov ScrollLock.Pressed,ah
    cmp ah,1
    je  IntEnd
    xor ScrollLock.Locked,1
    xor Lights,1
    mov ax,0AEh
 {   call SendIt}
    call SetLights
    jmp SendEOI

@@ResetExt:
    xor ax,ax
    mov ExtCode,al
    mov Extent,al
    jmp IntEnd

@next7:
    cmp al,53h
    jne IntEnd
  end;

  AltCtrlDel:=pressed and Alt.Any and Ctrl.Any;

  if AltCtrlDel then AltCtrlDelProc;

IntEnd:
asm
{ Interrupt end }{
    mov  al,0aeh
    call sendit   }
SendEOI:           {
    mov  al,20h
    out  20h,al     }
  end;
end;


procedure InitKeyboard; assembler;
asm
   cmp KeyboardSet,0
   jne @@Quit

@ClearBufferLoop:
   mov ah,1
   int 16h
   jz  @NoKeyb
   xor ax,ax
   int 16h
   jmp @ClearBufferLoop

@NoKeyb:
   mov ax,3509h
   int 21h
   mov oldint9seg,es
   mov oldint9ofs,bx

   push ds

   push cs
   pop  ds
   mov  ax,2509h
   mov  dx,offset MyInt9
   int  21h
   pop  ds

   cli
   xor  ax,ax
   mov  QHead,ax
   mov  QTail,ax
   mov  Key,al

   xor  ax,ax
   mov  es,SEG0000
   mov  al,byte ptr es:[417h]
   mov  cl,4
   shr  al,cl
   mov  Lights,al

   mov  KeyboardSet,1
   sti
@@Quit:
end;

procedure DoneKeyboard; assembler;
asm
   cmp  KeyboardSet,0
   je   @@Quit
   xor  ax,ax
   mov  es,SEG0000
   mov  ax,word ptr es:[417h]
   mov  bl,Lights
   mov  cl,4
   shl  bl,cl
   and  al,10001111b  { Set Lights status }
   or   al,bl
   and  ax,111110011110000b
   mov  word ptr es:[417h],ax


   push ds
   mov  dx,oldint9ofs
   mov  ax,oldint9seg
   mov  ds,ax
   mov  ax,2509h
   int  21h
   pop  ds
@@Quit:
end;

function ReadKeyboard : byte; Assembler;
asm
  xor  ax,ax
  mov  al,Key;
  mov  Key,ah;
  mov  WasKeybEvent,ah
end;

function KeyPressed : boolean;
begin
  KeyPressed:=WasKeybEvent and Pressed;
end;

function ReadKey : char;
begin
  if KeyboardSet then
  begin

  end
  else begin
    Writeln(#7'KEYBOARD.TPU Error : use InitKeyboard first!');
    halt;
  end;
end;

function ReadChar : char; assembler;
const
  scancode : char = #0;
asm
  cmp ScanCode,0     { if were extented keystrokes }
  je  @@NoScanCode

  mov al,ScanCode    { then return scan code }
  mov ScanCode,0
  jmp @@Quit

@@NoScanCode:
  mov al,0
  cmp Key,0
  je  @@Quit

  mov bh,al
  mov bl,Key
  dec bl
  shl bx,1
  mov ax,[offset KeyCodes + bx]

  cmp al,0
  jne @@Quit

  mov ScanCode,ah
@@Quit:
  mov key,0
end;

procedure GetKeyEvent( var KEvent : KeyEvent); assembler;
asm
  les di,KEvent
  mov word ptr es:[di],0
  cmp WasKeybEvent,0
  je  @Quit

  xor bx,bx
  mov bl,key
  dec bx
  shl bx,1
  mov ax,[offset KeyCodes + bx]

  cmp al,0
  je  @Store

  mov ah,key
@Store:
  mov word ptr es:[di],ax
  mov WasKeybEvent,0
  mov Key,0
@Quit:
end;

{-------------------------------}
procedure KeybLights(On : boolean; Light : byte);
var L : byte;
begin
  if (Light>7) then exit;
  asm
    mov al,0EDh
    out 60h,al
    mov cx,2000h
  @loop:
    loop @loop
  end;
  if On then L := Lights or  Light
        else L := Lights and not Light;
  port[$60]:=L;
end;

{-------------------------------}
procedure NullProc;
begin
end;

var OldExitProc : pointer;

procedure ExitProcedure; far;
begin
  DoneKeyboard;
  ExitProc:=OldExitProc;
end;

FUNCTION  get_selector(segment : WORD) : WORD;
VAR selector : WORD;
BEGIN
  {$IFDEF DPMI}
  ASM
    MOV AX, $0002
    MOV BX, segment
    INT $31
    JNC @@1
    MOV AX, segment
@@1:
    MOV selector, AX
  END;
  {$ELSE}
  selector := segment;
  {$ENDIF}

  get_selector := selector;
END;

begin
  SEG0000 := get_selector($0000);
  OldExitProc:=ExitProc;
  ExitProc:=@ExitProcedure;
end.

{ ---------------------------  DEMO ------------------------------ }

program KeybDemo;
{ Copyright (c) 1994 by Andrew Eigus   Fidonet: 2:5100/33 }

uses Crt, Keyboard;

const
  Status : array[Boolean] of String[11] = ('Not pressed', 'Pressed    ');
  Lock : array[Boolean] of String[10] = ('Not locked', 'Locked    ');

var
  key : KeyEvent;
  ch : char;
  CursorShape : word;

Procedure SetCursor(CursorOnOff : boolean); assembler;
Asm
  CMP CursorOnOff,True
  JNE @@2
  CMP BYTE PTR [LastMode],Mono
  JE  @@1
  MOV CX,0607h
  JMP @@4
@@1:
  MOV CX,0B0Ch
  JMP @@4
@@2:
  CMP BYTE PTR [LastMode],Mono
  JE  @@3
  MOV CX,2000h
  JMP @@4
@@3:
  XOR CX,CX
@@4:
  MOV AH,01h
  XOR BH,BH
  INT 10h
End; { SetCursor }

procedure AltCtrlDelp; far;
begin
  Writeln(#13#10#10'That was it. Not bad, eh?');
  SetCursor(True);
  Halt(1)
end;

Procedure WriteXY(X, Y : byte; S : string);
Begin
  GotoXY(X, Y);
  Write(S)
End; { WriteXY }

Function Hex(W : Word) : string;
const hexChars: array [0..$F] of Char = '0123456789ABCDEF';
Begin
  Hex[0] := #4;
  Hex[1] := hexChars[Hi(W) shr 4];
  Hex[2] := hexChars[Hi(W) and $F];
  Hex[3] := hexChars[Lo(W) shr 4];
  Hex[4] := hexChars[Lo(W) and $F]
End; { Hex }

Begin
  InitKeyboard;
  AltCtrlDelproc:=AltCtrlDelp;
  SetCursor(False);
  TextAttr := LightGray;
  ClrScr;
  WriteLn('Keyboard unit demo  by Andrew Eigus (c) 1994   Fidonet: 2:5100/33');
  WriteLn('Hit any key to scan or Ctrl-Alt-Del to quit.');
  repeat
    GetKeyEvent(Key);

    WriteXY(1, 5, 'Left Shift state  : ' + Status[Shift.Left]);
    WriteXY(35, 5, 'Right Shift state  : ' + Status[Shift.Right]);
    WriteXY(1, 6, 'Left Alt state    : ' + Status[Alt.Left]);
    WriteXY(35, 6, 'Right Alt state    : ' + Status[Alt.Right]);
    WriteXY(1, 7, 'Left Ctrl state   : ' + Status[Ctrl.Left]);
    WriteXY(35, 7, 'Right Ctrl state   : ' + Status[Ctrl.Right]);
    WriteXY(1, 9, 'Scroll Lock state : ' + Status[ScrollLock.Pressed]);
    WriteXY(35, 9, 'Scroll Lock toggle : ' + Lock[ScrollLock.Locked]);
    WriteXY(1, 10, 'Num Lock state    : ' + Status[NumLock.Pressed]);
    WriteXY(35, 10, 'Num Lock toggle    : ' + Lock[NumLock.Locked]);
    WriteXY(1, 11, 'Caps Lock state   : ' + Status[CapsLock.Pressed]);
    WriteXY(35, 11, 'Caps Lock toggle   : ' + Lock[CapsLock.Locked]);
    WriteXY(1, 13, 'PrtScr key state : ' + Status[PrtScr]);
    if Key.ScanCode and $F0 = $E0 then
      WriteXY(1, 15, 'Key code        : ' + Hex(Key.ScanCode))
    else
    begin
      WriteXY(1, 16, 'Scan code       : ' +
        Hex(Key.ScanCode and $7F) + ',' + Hex(Key.ScanCode and $7F));
      WriteXY(35, 16, 'Key state      : ' + Status[Pressed])
    end;

    WriteXY(1, 17, 'Key ASCII code      : "' +
      Key.CharCode + '",' + Hex(Byte(Key.CharCode)));

    repeat until WasKeybEvent
  until False
End.


