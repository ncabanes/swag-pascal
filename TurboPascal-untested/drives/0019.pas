{
>Who can give me the source code in TP 6.0 which reads a HardDisks Volume
>Serial Number ?

Starting With Dos 4 this inFormation can be GET/SET using inT 21h func 69h
   Entry  AH =69h
            Al = 00h    Get Serial number and Label
            Al = 01h    Set Serial number
            BL = drive number 0=default, 1=A: .....)
            DS:DX Pointer to a 24 Bytes  Buffer (see below)
   Return
         Cf set on error
             AX = error code  (same as Int 21h AH = 59 )
         CF Clear if Ok
             if AL was 0 then Buffer is filled with
                offset   size   Contents:
                0         Word     0
                2         DWord    the disk Serial number
                6         11 Bytes= volume Label or "NO NAME"
                16        8 Bytes = 'FAT12' or 'FAT16'

 The buffer is actually a copy of ByteS $27 to $3D of the Sector 0 of the disk
 So With previous versions of Dos one should be able to do an Absolute read
 of sector 0 from the disk and extract the Info from a buffer. I did not dare
 doing it....

 Last Thought: With Dos earlier than 4 , there was no disk serial number
               so what the point looking For one .... !!!!
               Although this info can be used to set one ???
               (not by me... I need too badly my hard disk to
               experiment With Int 13h ..... )

  Here is a Program that Get these Infos...
  I did not dare trying the Set Function (AL=1...) see above...
}
Program GetSerial;
Uses
  Dos;
Var
  Buffer : Array[0..23] of Byte;
  R      : Registers;
  Serial : LongInt;
  VLabel : String[11];
  Fat    : String[8];
begin
  R.AH := $69;
  R.AL := 0;
  R.BL := 3;            { C: Drive }
  R.DS := Seg(Buffer);
  R.DX := ofs(Buffer);
  Intr($21,R);
  if (R.Flags and Fcarry = 0) then
  begin
    Move(Buffer[2], Serial, Sizeof(LongInt));
    Move(Buffer[6], VLabel[1], 11);
    VLabel[0] := Char(11);
    Move(Buffer[16], Fat[1], 8);
    Fat[0] := Char(8);
  end;
  Writeln(VLabel);
  Writeln(Fat);
  readln;
end.
