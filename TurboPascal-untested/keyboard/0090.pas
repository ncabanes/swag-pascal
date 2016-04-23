{
 BD> I have a loop that goes something like this:

 BD>         uses crt;
 BD>         var c: char;
 BD>             i: integer;
 <skipped>

 BD>   The problem is, if they press anything, the program needs to simulate
 BD> F10 being pressed.  Obviously, if the user hits F10, the loop ends just
 BD> like anything else.  And, if I don't put the c := readkey at the end, I
 BD> get an extra keystroke.

 BD> So...

 BD> can anyone tell me how to put F10 in the keyboard buffer?

Sure, no problem. Here is the routine:
}

Procedure StuffKey(Key : word); assembler;
{$IFNDEF BP70} const Seg0040 = $0040; {$ENDIF}
Asm
  cli
  mov es,Seg0040
  mov di,001Ch
  mov ax,Key
  xchg ah,al
  mov bx,[es:di]
  mov [es:bx],ax
  add byte ptr [es:di],2
  cmp byte ptr [es:di],60
  jle @@1
  mov byte ptr [es:di],30
@@1:
  sti
End; { StuffKey }

{ and here are the values to pass to StuffKey: }

const

  { standard (non-extended) key codes }

  keyNull          = $0000;
  keyBell          = $0700;
  keyEscape        = $1B00;
  keyTab           = $0900;
  keyBackspace     = $0800;
  keySpace         = $2000;
  keyEnter         = $0D00;
  keyCtrlEnter     = $0A00;
  keyCtrlY         = $1900;
  keyA             = $4100;
  keyZ             = $5A00;

  { extended key codes }

  keyUp            = $0048;
  keyDown          = $0050;
  keyLeft          = $004B;
  keyRight         = $004D;
  keyCtrlLeft      = $0073;
  keyCtrlRight     = $0074;
  keyPageUp        = $0049;
  keyPageDown      = $0051;
  keyHome          = $0047;
  keyEnd           = $004F;
  keyDelete        = $0053;
  keyInsert        = $0052;
  keyF1            = $003B;
  keyF2            = $003C;
  keyF3            = $003D;
  keyF4            = $003E;
  keyF5            = $003F;
  keyF6            = $0040;
  keyF7            = $0041;
  keyF8            = $0042;
  keyF9            = $0043;
  keyF10           = $0044;
  keyShiftF1       = $0054;
  keyShiftF2       = $0055;
  keyShiftF3       = $0056;
  keyShiftF4       = $0057;
  keyShiftF5       = $0058;
  keyShiftF6       = $0059;
  keyShiftF7       = $005A;
  keyShiftF8       = $005B;
  keyShiftF9       = $005C;
  keyShiftF10      = $005D;
  keyCtrlF1        = $005E;
  keyCtrlF2        = $005F;
  keyCtrlF3        = $0060;
  keyCtrlF4        = $0061;
  keyCtrlF5        = $0062;
  keyCtrlF6        = $0063;
  keyCtrlF7        = $0064;
  keyCtrlF8        = $0065;
  keyCtrlF9        = $0066;
  keyCtrlF10       = $0067;
  keyAltF1         = $0068;
  keyAltF2         = $0069;
  keyAltF3         = $006A;
  keyAltF4         = $006B;
  keyAltF5         = $006C;
  keyAltF6         = $006D;
  keyAltF7         = $006E;
  keyAltF8         = $006F;
  keyAltF9         = $0070;
  keyAltF10        = $0071;
  keyAltA          = $001E;
  keyAltB          = $0030;
  keyAltC          = $002E;
  keyAltD          = $0020;
  keyAltE          = $0012;
  keyAltF          = $0021;
  keyAltG          = $0022;
  keyAltH          = $0023;
  keyAltI          = $0017;
  keyAltJ          = $0024;
  keyAltK          = $0025;
  keyAltL          = $0026;
  keyAltM          = $0032;
  keyAltN          = $0031;
  keyAltO          = $0018;
  keyAltP          = $0019;
  keyAltQ          = $0010;
  keyAltR          = $0013;
  keyAltS          = $001F;
  keyAltT          = $0014;
  keyAltU          = $0016;
  keyAltV          = $002F;
  keyAltW          = $0011;
  keyAltX          = $002D;
  keyAltY          = $0015;
  keyAltZ          = $002C;


Example:

StuffKey(keyF10);  { will fortunately do the job for ya }

{
 BP> Could someone please give me some source code to stuff a key into the
 BP> keyboard buffer? :)

Here is for you and for SWAG:

{ The following are ASCII and extended key codes that consist of:

  ASCII code:
   hi byte: ASCII key code
   lo byte: zero

  Extended code:
   hi byte: zero
   lo byte: Extended key code
}

const
  { ASCII key codes }

  { standard (non-extended) key codes }

  keyNull          = $0000;
  keyBell          = $0700;
  keyEscape        = $1B00;
  keyTab           = $0900;
  keyBackspace     = $0800;
  keySpace         = $2000;
  keyEnter         = $0D00;
  keyCtrlEnter     = $0A00;
  keyCtrlY         = $1900;
  keyA             = $4100;
  keyZ             = $5A00;

  { extended key codes }

  keyUp            = $0048;
  keyDown          = $0050;
  keyLeft          = $004B;
  keyRight         = $004D;
  keyCtrlLeft      = $0073;
  keyCtrlRight     = $0074;
  keyPageUp        = $0049;
  keyPageDown      = $0051;
  keyHome          = $0047;
  keyEnd           = $004F;
  keyDelete        = $0053;
  keyInsert        = $0052;
  keyF1            = $003B;
  keyF2            = $003C;
  keyF3            = $003D;
  keyF4            = $003E;
  keyF5            = $003F;
  keyF6            = $0040;
  keyF7            = $0041;
  keyF8            = $0042;
  keyF9            = $0043;
  keyF10           = $0044;
  keyShiftF1       = $0054;
  keyShiftF2       = $0055;
  keyShiftF3       = $0056;
  keyShiftF4       = $0057;
  keyShiftF5       = $0058;
  keyShiftF6       = $0059;
  keyShiftF7       = $005A;
  keyShiftF8       = $005B;
  keyShiftF9       = $005C;
  keyShiftF10      = $005D;
  keyCtrlF1        = $005E;
  keyCtrlF2        = $005F;
  keyCtrlF3        = $0060;
  keyCtrlF4        = $0061;
  keyCtrlF5        = $0062;
  keyCtrlF6        = $0063;
  keyCtrlF7        = $0064;
  keyCtrlF8        = $0065;
  keyCtrlF9        = $0066;
  keyCtrlF10       = $0067;
  keyAltF1         = $0068;
  keyAltF2         = $0069;
  keyAltF3         = $006A;
  keyAltF4         = $006B;
  keyAltF5         = $006C;
  keyAltF6         = $006D;
  keyAltF7         = $006E;
  keyAltF8         = $006F;
  keyAltF9         = $0070;
  keyAltF10        = $0071;
  keyAltA          = $001E;
  keyAltB          = $0030;
  keyAltC          = $002E;
  keyAltD          = $0020;
  keyAltE          = $0012;
  keyAltF          = $0021;
  keyAltG          = $0022;
  keyAltH          = $0023;
  keyAltI          = $0017;
  keyAltJ          = $0024;
  keyAltK          = $0025;
  keyAltL          = $0026;
  keyAltM          = $0032;
  keyAltN          = $0031;
  keyAltO          = $0018;
  keyAltP          = $0019;
  keyAltQ          = $0010;
  keyAltR          = $0013;
  keyAltS          = $001F;
  keyAltT          = $0014;
  keyAltU          = $0016;
  keyAltV          = $002F;
  keyAltW          = $0011;
  keyAltX          = $002D;
  keyAltY          = $0015;
  keyAltZ          = $002C;

Procedure StuffKey(Key : word); assembler;
Asm
  cli
  mov es,Seg0040
  mov di,001Ch
  mov ax,Key
  xchg ah,al
  mov bx,es:[di]
  mov es:[bx],ax
  add byte ptr es:[di],2
  cmp byte ptr es:[di],60
  jle @@1
  mov byte ptr [es:di],30
@@1:
  sti
End; { StuffKey }

The above function is BIOS-independant and thus should work on most of the
PC compatibles.

Example:

var S : string;

Function MakeWord(Hi, Lo : byte) : word; assembler;
Asm
  mov ah,Hi
  mov al,Lo
End; { MakeWord }

Begin
  Write('Enter a string: ');
  StuffKey(MakeWord(Ord('H'), 0));
  StuffKey(MakeWord(Ord('e'), 0));
  StuffKey(MakeWord(Ord('l'), 0));
  StuffKey(MakeWord(Ord('l'), 0));
  StuffKey(MakeWord(Ord('o'), 0));
  StuffKey(MakeWord(Ord('!'), 0));
  StuffKey(keyEnter);
  ReadLn(S);
  WriteLn('Oh, you have already typed your string? :O Hmm, smart guy...')
End.

