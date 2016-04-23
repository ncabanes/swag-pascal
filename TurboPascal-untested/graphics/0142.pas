{
> I've asked this question before, in several message areas, but
> have still to get an answer.. I need to be able to get the size
> and colors from a JPEG/JFIF image file.. Nothing more, nothing
> less... Structures would do, regardless of language (C, Asm,
> Pas, Basic). Anyone?

Here it is (not fully tested, only extracts height and width of the picture!)
}

Procedure GetJpegInfo(FName : String; VAR IsJpeg: Boolean; VAR Height,
                            Width : Word);

{Checks if file FName is a (true) JPEG/JFIF file and extracts
 height and width (in pixels) of the picture}
Const
  JFIFS : String[4] = #$FF + #$D8 + #$FF + #$E0;
          {JFIF marker: $FF SOI $FF App0}

Var F : File;
    ReadS : String;
    ARead : Word;
    Count : Integer;

begin
   Assign(F,FName);
   Reset(F,1);
   Blockread(F, ReadS[1], 255, Aread);
   ReadS[0] := Chr(Aread);
   Close(F);

   IsJpeg := FALSE;

   {Search for JFIF marker in first 255 bytes of the file.
    If NOT found, then you can safely assume the file isn't
    a (real) JPEG/JFIF file}

   if Pos(JFIFS, ReadS) > 0 then
      begin
      If (Copy(ReadS, Pos(JFIFS,ReadS)+Length(JFIFS)+2,5) = 'JFIF'+#0) then
         begin

         {We have a JPEG/JFIF File!}

         IsJpeg := TRUE;

         {Search for SOF marker}

         Count := 0;
         Repeat
          inc(Count);
         Until (Count > length(ReadS)) OR
               (ReadS[Count] in [#192..#207]);
         if Count <= Length(ReadS) then
            begin
           { ReadS[Count] = first SOF marker
             Count + 1 = length high byte  \ length of APP0 data!
             Count + 2 = length low byte   /
             Count + 3 = data precision    - colors (?)
             Count + 4 = height high byte  \ heigth of picture
             Count + 5 = height low byte   /
             Count + 6 = width high byte   \ width of picture
             Count + 7 = width low byte    /
           }
            Height := Word(Ord(ReadS[Count+4])*256) + Ord(ReadS[Count+5]);
            Width  := Word(Ord(ReadS[Count+6])*256) + ord(ReadS[Count+7]);
            end;
         end;
      end;
end;

