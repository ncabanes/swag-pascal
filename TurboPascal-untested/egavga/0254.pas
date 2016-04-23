{
Date: 06-06-95
From: Zbigniew Szuszkiewicz Kraków POLSKA
Subj: VGA 132 kolumn
}
PROGRAM VGA_132k;
{
  It's best procedure to automatic seeking condensed text mode, where
  horizontal characters in line is constans = 132
  but lines per monitor is unknown; first seek 28 lines !
  Array tryb_video_132x28 contains 4 numbers of "standard" condensed video
  mode. You may change this line or remove with first sequence Repeat .. Until;
  All remarks please write to : Zbigniew Szuszkiewicz
                                Krakow Polen
                                PcDuo BBS in Krakow
                                Fido : 2:486/18
}
USES crt;
VAR
  vert_video          : byte;      { max rows on screen }
  hori_video          : byte;      { max characters per line }

PROCEDURE VIDEO_NORMAL; ASSEMBLER;
ASM
     mov ax,lastmode   { al }
     mov ah,0h
     int 10h           { set video mode }
     mov vert_video,25
     mov hori_video,80
END;

PROCEDURE VIDEO_CONDENSED;
CONST
   tryb_video_132x28 : array[1..4] of byte =($24,$54,$47,$80); { te znam }
VAR
  byteidx, kk  : byte;   { must be a local variable}
  vertvideo    : byte absolute 0:$484; { EGA max rows on screen - 1}
BEGIN
    IF lastmode = 7 then begin
                          vert_video:=25;
                          hori_video:=80;
                          windmin:=0;   { SET WINDOW( max video mode); }
                          windmax:=(vert_video-1) *256 + hori_video - 1;
                          exit;
                         end;
     kk:=1;
     repeat
        byteidx:=tryb_video_132x28[kk];
        asm
          mov ah,0h
          mov al,byteidx
          int 10h         { set video mode }
          mov ah,0Fh
          int 10h         { get video mode }
          mov hori_video,ah
          add kk,1
        end;
     until (kk > 4) OR
           ((hori_video = 132) AND (vertvideo < 40));
     if kk > 4 then begin        { must seek other unknown number }
                    kk:=25;      { start number to seking }
                    repeat
                       inc(kk);
                       asm
                         mov ah,0h
                         mov al,kk
                         int 10h         { set video mode }
                         mov ah,0Fh
                         int 10h         { get video mode }
                         mov hori_video,ah
                       end;
                    until (kk > 99) OR  { end number to seeking }
                          ((hori_video > 80) AND (vertvideo < 44));
                    if kk > 99 then asm
                                     mov ax,lastmode   { al }
                                     mov ah,0h       {return old video mode}
                                     int 10h         { set video mode }
                                     mov hori_video,80
                                    end;
                    end;
     vert_video:=vertvideo + 1;
     windmin:=0;                        { SET WINDOW( max video mode); }
     windmax:=(vert_video-1) *256 + (hori_video - 1);
END;

BEGIN  { test program }
   VIDEO_CONDENSED;
   if hori_video > 80
           then begin
                 gotoxy(46,vert_video shr 2);
                 writeln('Yes ! This is very good video procedure');
                 writeln;
                 for textattr:=1 to 132 do
                     if textattr mod 10 = 0
                        then write(' ':8,textattr div 10:2);
                 writeln;
                 for textattr:=1 to 132 do write(textattr mod 10);
                end
           else begin
                gotoxy(25,15);
                write('This is HGC or other older video !');
                end;
   gotoxy(59,vert_video);
   textcolor(14 + blink);
   writeln('This is ',hori_video,' x ',vert_video,' mode.');
   textcolor(15);
   write('Press Enter to continue ...');

   readln;
   video_normal;      { return to lastmode }
END.
