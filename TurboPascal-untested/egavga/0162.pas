{
With this program you can view monocrome pcx files, smaller than 60KB. It
will only work on VGA cards.

A Program to view monocrome PCX files

A MacSoft production in 1994 by Andreas Oestlund
}
Type
    TPCX_Header = Record
                        Manufacturer   : Byte;                {always A0h }
                        Version        : Byte;                {version }
                        Encoding       : Byte;                {always 1}
                        Bits_Per_Pixel : Byte;                {color bits}
                        XMin,YMin      : Word;                {image origin}
                        XMax,YMax      : Word;                {dimensions}
                        HRes           : Word;                {resolution val}
                        VRes           : Word;                {}
                        Palette        : Array[1..48] Of Byte;{palette}
                        Reserved       : Byte;                {}
                        Color_Planes   : Byte;                {color planes}
                        Bytes_Per_Line : Word;                {line buffer
size}                        Palette_Type   : Word;                {gray or
color pal}                        Filler         : Array[1..58] Of Byte;{}
                  End;

    TPCXData    = Array[1..60000] Of Byte;

Procedure SetMode (m : Byte); Assembler;
     Asm
          Mov  AH, 0
          Mov  AL, m
          Int  10h
     End;

Var
   Header     : TPCX_Header;
   F          : File;
   B,C        : Byte;
   Line_Table : Array[0..479] Of Word;
   PcxData    : ^TPcxData;

   Width,
   Height,
   Bytes_Per_Line : Word;

   NuRead         : Word;

Procedure Decode_PCX_Line (l : Word);
Var
   i,j      : Word;

Const
     Data_NDX : Word = 0;

     Begin
          i := 0;
          While i < Bytes_Per_Line Do
              Begin
                   Inc (Data_NDX);
                   B := PcxData^[Data_NDX];

                   If (B And $C0) = $C0 Then
                    Begin
                         B := B And $3F;

                         Inc (Data_NDX);
                         C := PcxData^[Data_NDX];
                         For j := 1 To B Do
                           Begin
                                Mem[$A000:Line_Table[l]+i] := C;
                                Inc (i);
                           End;
                    End
                   Else
                       Begin
                            Mem[$A000:Line_Table[l]+i] := B;
                            Inc (i);
                       End;
              End;
     End;

Var
   i : Word;
   Mem2Get : Word;

Begin
     If Paramcount = 0 then HALT;
     Assign (F,ParamStr(1));
     Reset (F,1);

     BlockRead (F,Header,SizeOf(TPCX_Header));
     Width  := (Header.XMax - Header.XMax)+1;
     Height := (Header.YMax - Header.YMin)+1;
     Bytes_Per_Line := Header.Bytes_Per_Line;
     For i := 0 To 479 Do Line_Table[i] := i*80;

     Mem2Get := FileSize(F) - FilePos(F);
     GetMem (PcxData,Mem2Get);
     BlockRead (F,PcxData^,60000,NuRead);

     SetMode ($12);

     For i := 0 To (Height-1) Do Decode_PCX_Line (i);

     Readln;

     FreeMem (PcxData,Mem2Get);
     SetMode (3);
     Close (F);
End.
