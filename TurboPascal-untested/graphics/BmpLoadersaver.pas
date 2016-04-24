(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0257.PAS
  Description: BMP Loader/Saver
  Author: ELTETO EDMOND
  Date: 05-30-97  18:17
*)


> Can anyone send me source of BMP Loader/Saver.
> If you help me, I would be thankful to you.
>
> Mohammad Reza Nikrou
> nikrou@kadous.gu.ac.ir
>


Hi,
  i send you a loader BMP, if you are interested try this :

To ENCODE (and decode) GIF files
two programs :

gifpasse.zip : ftp.usask.ca /pub/dos/prog/gifpasse.zip
endegif.zip  : ftp.uni-mainz.de/pub/pc/local/dos/programm/pascal/endegif.zip
               ftp.ku-eichstaett.de/pub/dos/graphics/gifutils/endegif.zip
               ftp.uni-koeln.de/msdos/graphics/gifutils/endegif.zip
         ftp.informatik.hu-berlin.de/pub/pc/msdos/graphics/gifutils/endegif.zip

  Edmond

{X,Y - screen coordinates, if x <0 bmp file will be centered on the
screen

file_name - name and path of the bmp file

erro - will return a error condition (0 no error)
if error <0 it's a bmp problem
if error >0 it's a disk error ( dos error codes)

Carlos Rondao
Universidade Catolica Portuguesa
Lisboa
Portugal

Send me a note if you have any comments or problems ...}


uses dos,graph;
var
  grDriver : Integer;
  grMode   : Integer;
  ErrCode  : Integer;
  erro : integer;
const filename = 'c:\download\picture1.bmp';{put filename and path here}
Procedure GetEgaPal(cor :byte ;var pal:byte);assembler;
  asm
   mov bl,cor
   mov ah,$10
   mov al,$07
   int $10
   les DI,pal
   mov ES:[DI],BH
  end;

Procedure SetEgaPal(cor :byte ;pal:byte);assembler;
  asm
   mov bl,cor
   mov bh,pal
   mov ah,$10
   mov al,$00
   int $10
  end;

Procedure SetPal16(Cor,r,g,b : byte);assembler;
 asm
  mov AH,$10
  mov AL,$10
  xor BH,BH
  mov BL,cor
  mov DH,r
  mov CH,g
  mov CL,b
  int $10
 end;
{===================================================}
Procedure GetPal16(Cor:byte;Var r,g,b : byte);assembler;
 asm
  mov AH,$10
  mov AL,$15
  xor BH,BH
  mov BL,cor
  int $10
  les DI,r
  mov ES:[DI],DH
  les DI,g
  mov ES:[DI],CH
  les DI,b
  mov ES:[DI],CL
 end;
Procedure SetAllPal16(var pal ;cor,n:integer);assembler;
 asm
  mov AH,$10
  mov AL,$12
  mov BX,cor
  mov CX,n
  les DX,pal
  int $10
 end;

Procedure EgaDefault;
var i,reg : byte;
    r,g,b : byte;
begin
 for i:=0 to 15 do
  begin
   GetEgaPal(i,reg);
   SetEgaPal(i,i);
   GetPal16(reg,r,g,b);
   SetPal16(i,r,g,b);
  end;
End;


procedure Load_BMP(X,Y:integer;file_name : pathstr;var erro :
integer);
 VAR
   header : array [1..27] of word;
   rgb_struct : array[0..255] of record
                                  b,g,r,cor : byte;
                                 end;
   rgb_triple : array[0..255] of record
                                  b,g,r : byte;
                                 end absolute rgb_struct;
   pal : array[0..255] of record
                            red,green,blue : byte;
                           end;
      F : File;
    i,j : integer;
  locer : integer;
   Xp,Yp,lido,larg,larg1,alt,cores,bufsize,desloc,reloc,grupo :
word;
    buf : array[1..10000] of byte;
    pic_point_1,pic_point_2 : byte;
    sign : array[1..2] of char absolute header;
    maxX,maxY : word;
  Begin
   maxX := GetmaxX;
   maxY := GetMaxY;
   assign(f,file_name);
   {$I-}
   reset(f,1);
   {$I+}
   erro := IoResult;
   if erro<>0 THEN exit;
   {$I-}
   blockread(f,header,18,lido);
   erro := IoResult;
   if erro = 0 then
    if sign<>'BM' THEN
       erro := -100;
   IF erro = 0 THEN
    BEGIN
     desloc := header[8]-4;
     if desloc >36 then desloc := 36;
     blockread(f,header[10],desloc,lido);
     erro := IoResult;
    END;
   if erro = 0 THEN
    begin
     reloc := ord(desloc<>8);
     larg := header[10];
     alt := header[11+reloc];
     cores := 1 shl header[13+2*reloc];
     if (alt > maxY) OR (larg>maxX) then
        erro := -101;
    end;
   If erro = 0 THEN
    BEGIN
     if (X<0) OR (Y<0) THEN
       Begin
        X := (maxX-larg) DIV 2;
        Y := (maxY-alt) DIV 2;
       End;
     blockread(f,rgb_struct,header[6]-18-desloc,lido);
     erro := IoResult;
    END;
    IF erro = 0 THEN
     BEGIN
         if cores = 16 THEN
          begin
           larg1 := 8*(larg DIV 8) + 8*ord(larg MOD 8<>0);
           LARG1 := LARG1 div 2;
          end
         else
          begin
           larg1 := 4*(larg DIV 4) + 4*ord(larg MOD 4<>0);
          end;
         if reloc = 1 THEN
          for i := 0 to cores-1 do
           Begin
            pal[i].red := rgb_struct[i].r DIV 4;
            pal[i].green := rgb_struct[i].g DIV 4;
            pal[i].blue := rgb_struct[i].b DIV 4  ;
           end
         else
          for i := 0 to cores-1 do
           Begin
            pal[i].red := rgb_triple[i].r DIV 4;
            pal[i].green := rgb_triple[i].g DIV 4;
            pal[i].blue := rgb_triple[i].b DIV 4  ;
           end;
         EgaDefault;
         setallpal16(Pal,0,cores);
         bufsize := larg1*(10000 DIV larg1);
         lido := bufsize;
         While (lido=bufsize) AND (erro=0) do
          begin
           blockread(f,buf,bufsize,lido);
           erro := IoResult;
           if erro= 0 Then
            IF Cores = 16 THEN
             For j := 1 to lido DIV larg1 do
              For i:=0 to larg-1 do
               Begin
                XP := X+i;
                YP := Y+alt-j;
                pic_point_1 := buf[(j-1)*larg1+ 1 + i DIV 2];
                pic_point_2:=(pic_point_1 SHR 4)*((i+1) MOD 2) +
                 (pic_point_1 AND 15)*((i+2) MOD 2) ;
                putpixel(XP,YP,pic_point_2)
              End
            ELSE
             For j := 1 to lido DIV larg1 do
              For i:=1 to larg do
               Begin
                XP := X+(i-1);
                YP := Y+alt-j;
                pic_point_1 := buf[(j-1)*larg1+i];
                putpixel(XP,YP,pic_point_1);
               end;
           Y := Y - lido DIV larg1;
         end; { while }
    END; { erro = 0 }
    close(f);
    {$I+}
    locer := Ioresult;
    If erro = 0 THEN erro := locer;
 END;
begin
  grDriver := Detect;
  InitGraph(grDriver,grMode,'c:\tp\bgi');
  ErrCode := GraphResult;
  if ErrCode = grOk then
    begin
      Load_BMP(-1,0,filename,erro);
      readln;
      CloseGraph;
    end
  else
    WriteLn('Graphics error:',
            GraphErrorMsg(ErrCode));

end.


