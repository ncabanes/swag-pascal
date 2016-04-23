{
ROBERT ROTHENBURG

>I have created a Menu Bar, Now I think key #77 is left and key #77 is
>assigned to "M" or one of them. But anyway so when someone pushes the
>"M" key the menu bar moves. So how can I stop this, I only want it to
>use the arrow keys and a few letters but not "M".

You guessed it: USE BIOS CALLS!
}

Program ShowCodes; {* This Program will output the keyboard
                   {* scan codes.  Use the Function "ScanCode"
                   {* in your Program once you know the codes
                   {* For each keypress *}
Uses
  Crt, Dos;

Function Byte2Hex(numb : Byte): String;       { Converts Byte to hex String }
Const
  HexChars : Array[0..15] of Char = '0123456789ABCDEF';
begin
  Byte2Hex[0] := #2;
  Byte2Hex[1] := HexChars[numb shr  4];
  Byte2Hex[2] := HexChars[numb and 15];
end; { Byte2Hex }

Function Numb2Hex(numb : Word): String;        { Converts Word to hex String.}
begin
  Numb2Hex := Byte2Hex(hi(numb)) + Byte2Hex(lo(numb));
end; { Numb2Hex }

Function ScanCode : Word;
Var
  reg : Registers;    {* You need the Dos Unit For this! *}
begin
  reg.AH := $10;      {* This should WAIT For a keystroke.  If
                      {* you'd like to POLL For a keystroke and
                      {* have your Program do other stuff While
                      {* "waiting" For a key-stroke change to
                      {* reg.AH:=$11 instead... *}
  intr($16, reg);
  ScanCode := reg.AX  {* The high-Byte is the "scan code" *}
end;                  {* The low-Byte is the ASCII Character *}

begin
  Repeat
    Writeln(Numb2Hex(ScanCode) : 6)
  Until False;        {* You'll have to reboot after running this <g>*}
end.

{
I "think" the arrow-key scan codes are:

   $4800 = Up Arrow
   $5000 = Down Arrow
   $4B00 = Left Arrow
   $4D00 = Right Arrow
}
