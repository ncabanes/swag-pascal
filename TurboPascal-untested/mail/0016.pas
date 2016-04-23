{DAT2TXT v0.90- Free DOS utility: Converts .QWK MESSAGES.DAT to text.}
{$V-,S-}
program DAT2TXT ;
uses dos ;
const
   Seperator = '---------------------------------------------------------------------------' ;
   herald    = '===========================================================================' ;
type
   CharArray = array[1..6] of char ;  { to read in chunks }

   MSGDATHdr = record  { ALSO the format for SWAG files !!! }
      Status   : char ;
      MSGNum   : array [1..7] of char ;
      Date     : array [1..8] of char ;
      Time     : array [1..5] of char ;
      UpTO     : array [1..25] of char ;
      UpFROM   : array [1..25] of char ;
      Subject  : array [1..25] of char ;
      PassWord : array [1..12] of char ;
      ReferNum : array [1..8] of char ;
      NumChunk : CharArray ;
      Alive    : byte ;
      LeastSig : byte ;
      MostSig  : byte ;
      Reserved : array [1..3] of char ;
   end ;

var
   F           : file ;
   txtfile     : text ;

procedure showhelp(problem:byte); {if any *foreseen* errors arise, we are sent}
                             { here to give a little help and exit peacefully }
const
 progdata = 'DAT2TXT v0.90- Free DOS utility: Converts .QWK MESSAGES.DAT to text.';
 progdat2 = '(By SWAG contributors.)';
 usage    = 'Usage:  DAT2TXT infile(s) [/o]';
 usag2    = 'The "/o" causes DAT2TXT to overwrite (not append to) existing messages.txt.';
 note     = 'DOS * and ? wildcards ok with "infile(s)".  Output is always to MESSAGES.TXT.';
var
   message : string[80];
begin
   writeln(progdata);                  { just tell user what this program   }
   writeln(progdat2);                  { is and who wrote it                }
   writeln;
   writeln(usage);
   writeln(usag2);
   writeln(note);
   writeln;
   writeln('Error encountered:');
   case problem of
     1 : message := 'Incorrect number of parameters.';
     { plenty of room for other errors! }
   else
        message := 'Unknown error.';
   end;
   writeln(message);
   halt(problem);
end;

function converttoupper(w : string) : string;
var
   cp  : integer;        {the position of the character to change.}
begin
     for cp := 1 to length(w) do
         w[cp] := upcase(w[cp]);
     converttoupper := w;
end;

function ArrayTOInteger ( B : CharArray ; Len : byte ) : longint ;

var I : byte ;
    S : string ;
    E : integer ;
    T : integer ;

begin
   S := '' ;
   for I := 1 to Len do
      if B[i] <> #32 then S := S + B[i] ;

   Val ( S, T, E );

   if E = 0 then
      ArrayToInteger := T
   else
      ArrayToInteger := 0 ;
end ;

procedure ReadWriteHdr ( var HDR : MSGDatHdr );
begin
   BlockRead ( F, Hdr, 1 );
   if ArrayToInteger ( Hdr.NumChunk, 6 ) <> 0 then
      with Hdr do begin
         writeln ( txtfile, herald );
         write ( txtfile, 'Date: ', Date, ' (', Time, ')' );
         writeln ( txtfile, '' : 23, 'Number: ', MSGNum );
         write ( txtfile, 'From: ', UpFROM );
         writeln ( txtfile, '' : 14, 'Refer#: ', ReferNum );
         write ( txtfile, '  To: ', UpTO );
         write ( txtfile, '' : 15, 'Recvd: ' );
         if Status in ['-', '`', '^', '#'] then
            writeln ( txtfile, 'YES' )
         else
            writeln ( txtfile, 'NO' );
         write ( txtfile, 'Subj: ', Subject );
         writeln ( txtfile, '' : 16, 'Conf: ', '(', (MostSig * 256) + LeastSig, ')' );
         writeln ( txtfile, Seperator );
      end ;
end ;

procedure ReadMSG ( NumChunks : integer );
var
   Buff : array [1..128] of char ;
   J    : integer ;
   I    : byte ;

begin
   for J := 1 to PRED ( NumChunks ) do begin
      BlockRead ( F, Buff, 1 );
      for I := 1 to 128 do
         if Buff [I] = #$E3 then
            writeln ( txtfile )
         else
            write ( txtfile, Buff [I] );
   end ;
end ;

procedure ReadMessage ( HDR : MSGDatHdr ; RelNum : longint ; var Chunks : integer );
begin
   Seek ( F, RelNum - 1 );
   ReadWriteHdr ( HDR );
   Chunks := ArrayToInteger ( HDR.NumChunk, 6 );
   if Chunks <> 0 then begin
      ReadMsg ( Chunks );
      writeln ( txtfile );
   end
   else
      Chunks := 1 ;
end ;

var
   MSGHdr   : MSGDatHdr ;
   repordat : boolean ;
   ch       : char ;
   count    : integer ;
   chunks   : integer ;
   defsavefile : string ;
   fileinfo : searchrec ;
   fdt      : longint ;
   ps1,ps2  : string [2] ;
   fileexists,
   overwrite  : boolean ;
   response   : char ;

   dpath, tpath  : pathstr ;
   {epath & dpath are fully qualified pathnames of .dat & .txt files}

   ddir,  tdir   : dirstr ;
   dname, tname  : namestr ;
   d_ext, t_ext  : extstr ;
   txtfileinfo   : searchrec ;

begin
   if ( paramcount < 1) or ( paramcount > 2) then showhelp(1);
   ps1 := converttoupper ( paramstr (1));
   if (ps1 = '/H') or (ps1 = '/?') or
      (ps1 = '-H') or (ps1 = '-?') then showhelp(0);

   DefSaveFile := '' ;
   ps2 := '/A' ;
   if paramcount > 1 then ps2 := paramstr ( 2 );
   overwrite := (upcase ( ps2[2] ) = 'O');
   dpath := fexpand ( paramstr ( 1 ) );
   fsplit ( dpath, ddir, dname, d_ext );
   { break up path into components }
   findfirst ( dpath, anyfile, fileinfo );
   while doserror = 0 do begin
      fsplit ( fexpand ( fileinfo.name ), tdir, tname, t_ext );
      dpath := ddir + fileinfo.name ;
      tpath := ddir + tname + '.TXT' ;
      Assign ( F, dpath );
      { whatever file .. ( MESSAGES.DAT for .QWK ) }
      Reset ( F, SizeOf ( MsgHdr ) );

      assign ( txtfile, tpath );
{$i-} reset ( txtfile ); {$i+}
      fileexists := (ioresult = 0);

      if fileexists then close ( txtfile );
      if fileexists and ( not overwrite ) then
         append ( txtfile )
      else
         rewrite ( txtfile );

      write ( 'DAT2TXT: ', dpath, ' to: ', tpath );
      Count := 2 ;                     { start at RECORD #2 }
      while Count < FileSize ( F ) do begin
         ReadMessage ( MSGHdr, Count, Chunks );
         INC ( Count, Chunks );
      end ;

      getftime ( F, fdt );
      close ( F ); close ( txtfile ); reset ( txtfile );
      setftime ( txtfile , fdt );
      close ( txtfile );

      writeln ( ', done!' );
      findnext ( fileinfo );
   end ;
end.
