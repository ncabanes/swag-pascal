
{
 KB> How do get the disk size or the total clusters on a CD-ROM?
}

 program CD_Info;

 uses crt, dos;

 Type   tReq_Blk = Array[0..255] of Byte;
        tReq_Hdr = Array[0..017] of Word;

 Const  MSCDEX_GETDRIVES  = $1500;
        MSCDEX_GETVERSION = $150C;
        MSCDEX_DRIVER_REQ = $1510;

        MSCDEX_GetSecSize = 7;
        MSCDEX_GetVolSize = 8;

        RAW_DATA          = 1;

 Var    CPU             : Registers;
        Akt, Cnt, First : byte;
        Req_Hdr         : tReq_Hdr;
        Req_Blk         : tReq_Blk;
        SecSize         : word;
        VolBytes        : real;
        VolSize         : LongInt;

 function CallDriver( Var R: Registers ):byte;
 begin
   Intr($2F, R);
   if (R.FLAGS and FCARRY) <> 0
     then CallDriver := R.AL
     else CallDriver := 0;
 end;



 begin
   writeln; writeln;
   writeln(' CD-ROM Info v1.0           (c)  Norbert Igl 1994 ');
   writeln;
   With CPU do
   begin
     FillChar( CPU, Sizeof( CPU ), 0);
     AX := MSCDEX_GETVERSION;
     If CallDriver( CPU ) <> 0 then
     begin
       writeln(' MSCDEX not installed ... ');
       halt(1);
     end
     else begin
       writeln(' MSCDEX Version   : ',Hi(BX),'.',Lo(BX):2 );
     end;

     FillChar( CPU, Sizeof( CPU ), 0);
     AX := MSCDEX_GETDRIVES;
     If CallDriver( CPU ) <> 0 then
     begin
       writeln(' GETDRIVES Error  : ',Lo(AX) );
       halt(2);
     end
     else begin
       Cnt   := BX;
       First := CX;
       write(' Installed Drives : ',Cnt,' ( ');
       write( CHAR( 65+first ),':');
       if Cnt > 1 then
         write(' .. ', CHAR( 64+first+cnt),':');
       writeln(' )');
     end;
     For Akt := First to First+Cnt-1 do
     begin
       FillChar( CPU, Sizeof( CPU ), 0);
       FillChar( Req_Blk, Sizeof( Req_Blk ), 0);
       FillChar( Req_Hdr, Sizeof( Req_Hdr ), 0);

       Req_Hdr[0] := $000D;  { length of req_hdr }
       Req_Hdr[1] := $0003;  { IOCTL_READ }
       Req_Hdr[7] := Ofs(Req_Blk);
       Req_Hdr[8] := Seg(Req_Blk);
       Req_Hdr[9] := $0004;

       Req_Blk[0] := MSCDEX_GetSecSize;

       AX := MSCDEX_DRIVER_REQ;
       CX := Akt;
       ES := SEG( Req_Hdr );
       BX := OFS( Req_Hdr );
       If CallDriver( CPU ) <> 0 then
       begin
         writeln(' GetSecSize Drive(',Char(Akt+65),') Error  : ',Lo(AX) );
       end
       else Move(Req_Blk[2], SecSize, 2);

       FillChar( CPU, Sizeof( CPU ), 0);
       FillChar( Req_Blk, Sizeof( Req_Blk ), 0);
       FillChar( Req_Hdr, Sizeof( Req_Hdr ), 0);

       Req_Hdr[0] := $000D;  { length of req_hdr }
       Req_Hdr[1] := $0003;  { IOCTL_READ }
       Req_Hdr[7] := Ofs(Req_Blk);
       Req_Hdr[8] := Seg(Req_Blk);
       Req_Hdr[9] := $0005;

       Req_Blk[0] := MSCDEX_GetVolSize;;

       AX := MSCDEX_DRIVER_REQ;
       CX := Akt;
       ES := SEG( Req_Hdr );
       BX := OFS( Req_Hdr );
       If CallDriver( CPU ) <> 0 then
       begin
         writeln(' GetVolSize Drive(',Char(Akt+65),') Error  : ',Lo(AX) );
       end
       else Move(Req_Blk[1], VolSize, 4);

       VolBytes := VolSize;
       if VolBytes < 0 then
       begin
         VolSize :=  ( VolSize shr 1 );
         VolBytes := Volsize;
         VolBytes := VolBytes*2;
       end;
       VolBytes := Volbytes * SecSize;
       VolBytes := Volbytes / ( 1024*1024 );
       Writeln(' Disk in Drive ',Char(Akt+65),'  : ',VolBytes:6:2 ,' MB ');
     end;
   end
 end.
