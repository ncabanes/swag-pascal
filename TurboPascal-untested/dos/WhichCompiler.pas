(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0056.PAS
  Description: Which Compiler
  Author: LARRY HADLEY
  Date: 05-26-94  06:19
*)

{
Hi !

   Here is some source code I acquired from a Pascal echo some time
   ago. It shows one method of detecting which TP compiler created
   an .EXE:

-------------------------------------------------------------------
{ to compile type: tpc foo.pas }
{ exe: 9776 bytes by TP5.5 }

{$A+,B-,E-,F-,I+,N-,O-,V+}
{$M 4500,0,0}
{$ifndef debug}
{$D-,L-,R-,S-}
{$else}
{$D+,L+,R+,S+}
{$endif}

Program foo;

Uses
   DOS;  { dos unit from turbo pascal }

TYPE              { normal exe file header }
    EXEH = RECORD
          id,            { exe signature }
          Lpage,         { exe file size mod 512 bytes; < 512 bytes }
          Fpages,        { exe file size div 512 bytes; + 1 if Lpage > 0 }
          relocitems,    { number of relocation table items }
          size,          { exe header size in 16-byte paragraphs }
          minalloc,      { min mem. required in additional to exe image }
          maxalloc,      { extra max. mem. desired beyond that required
                           to hold exe's image }
          ss,            { displacement of stack segment }
          sp,            { initial SP register value }
          chk_sum,       { complemented checksum }
          ip,            { initial IP register value }
          cs,            { displacement of code segment }
          ofs_rtbl,      { offset to first relocation item }
          ovr_num : word; { overlay numbers }
       END;
                { window exe file header }
    WINH = RECORD
          id : word;     { ignore the rest of data structures }
       END;

    str2  = string [2];
    str4  = string [4];
    str10 = string [10];

CONST
    no_error  = 0;        { no system error }
    t         = #9;       { ascii: hortizon tab }
    dt        = t+t;
    tt        = t+t+t;
    qt        = t+t+t+t;
    cr        = #13#10;   { ascii: carriage return and line feed }

VAR
    f        : file;      { source file, untyped }
    exehdr   : exeh;      { exe header contents }
    winhdr   : winh;      { window exe header contents }
    blocks_r : word;      { number of blocks actually read }

    exe_size ,            { exe file length }
    hdr_size ,            { exe header size }
    img_size ,            { load module or exe image size }
    min_xmem ,            { min. extra memory needed }
    max_xmem ,            { max. extra memory wanted }
    o_starup : longint;   { offset to start up code }

    dirfile    : searchrec;
    compressed : boolean;

function Hex(B :byte) :str2;
 CONST  strdex :array [0..$F] of char = '0123456789ABCDEF';
 BEGIN  Hex := concat(strdex[B shr 4], strdex[B and $F]); END;

function HexW(W :word) :str4;
 VAR    byt :array [0..1] of byte absolute W;
 BEGIN  HexW := Hex(byt[1])+Hex(byt[0]); END;

function HexL(L :longint) :str10;
 TYPE   Cast = RECORD
                Lo :word;
                Hi :word;
         END;
 BEGIN  HexL := HexW(Cast(L).Hi)+' '+HexW(Cast(L).Lo); END;

procedure print_info;
   CONST
      psp_size = $100; { size of psp, bytes }
   VAR   i : byte;
   BEGIN
      hdr_size := longint(exehdr.size) shl 4;       { exe header size, bytes }
      img_size := longint(exe_size) - hdr_size;     { exe image size, bytes }
      min_xmem := longint(exehdr.minalloc) shl 4;   { mim xtra mem, bytes }
      max_xmem := longint(exehdr.maxalloc) shl 4;   { max xtra mem, bytes }
      o_starup := hdr_size + longint(exehdr.cs) shl 4
                  +longint(exehdr.ip);              { ofs to start up code  }
      writeln(
         qt, 'Dec':8, '':6, 'Hex', cr,
         'EXE file size:', tt, exe_size:8, '':3, hexl(exe_size), cr,
         'EXE header size:', dt, hdr_size:8, '':3, hexl(hdr_size), cr,
         'Code + initialized data size:', t, img_size:8, '':3, hexl(img_size)
             );

      writeln(
         'Pre-relocated SS:SP', tt, '':3, hexw(exehdr.ss), ':', hexw(exehdr.sp)
         , cr,
         'Pre-relocated CS:IP', tt, '':3, hexw(exehdr.cs), ':', hexw(exehdr.ip)
             );

      writeln(
         'Min. extra memory required:', t, min_xmem:8, '':3, hexl(min_xmem), cr,
         'Max. extra memory wanted:', t, max_xmem:8, '':3, hexl(max_xmem), cr,
         'Offset to start up code:', dt, '':3, hexl(o_starup), cr,
         'Offset to relocation table:', dt, '':3, hexw(exehdr.ofs_rtbl):9
             );

     writeln(
         'Number of relocation pointers:', t, exehdr.relocitems:8, cr,
         'Number of MS overlays:', dt, exehdr.ovr_num:8, cr,
         'File checksum value:', tt, '':3, hexw(exehdr.chk_sum):9, cr,
         'Memory needed to start:', dt, img_size+min_xmem+psp_size:8
            );
END; { print_info }

procedure id_signature;    { the core of this program }
   CONST
      o_01    =  14;        { relative offset from cstr0 to cstr1 }
      o_02    =  16;        {   "        "      "  cstr0 to cstr2 }
      o_03    =  47;        {   "        "      "  cstr0 to cstr3 }
      cstr0   = 'ntime';    { constant string existed in v4-6 }
      cstr1   = 'at '#0'.'; { constant string existed in v4-6 }
      cstr2   = '$4567';    { constant string existed in v5-6 }
      cstr3   = '83,90';    { constant string existed in v6 only }
      strlen  =   5;        { length of cstr? }
      ar_itm  =   3;        { items+1 of string array }

   { the following figures have been turn-up explicitly and
     should not be changed }

      ofs_rte =  25 shl 4;  { get close to 'run time error' str contants }
      maxchar =  11 shl 4;  { max. size of buffer; for scanning }

   TYPE
      arstr  = array [0..ar_itm] of string[strlen];
      arbuf  = array [0..maxchar] of char;

   VAR
      i, j, k : word;    { index counter for array buffer }
      cstr    : arstr;   { signatures generated by tp compiler }
      o_fseg  : word;    { to hold segment value of any far call }
      o_sysseg: longint; { offset to tp system_unit_segment }
      buffer  : arbuf;   { searching for target strings }

   BEGIN
{d}   Seek(f, o_starup + 3);                       { move file pointer 
forward 3 bytes }
{d}   BlockRead(f, o_fseg, sizeof(o_fseg));        { get far call segment 
value }
      o_sysseg := longint(o_fseg) shl 4 +hdr_size; { ofs to system obj code }
      if (o_sysseg + ofs_rte <= dirfile.size) then
      BEGIN
{d}      Seek(f, o_sysseg+ofs_rte);                { offset nearby tp 
signatures }
{d}      BlockRead(f, buffer, sizeof(buffer), blocks_r);
         for i := 0 to ar_itm do
         BEGIN
             cstr[i][0] := char(strlen);
             fillchar(cstr[i][1], strlen, '*');
         END;
         i := 1; j := 1; k := 0;
         repeat
            if buffer[i] in ['n','t','i','m','e'] then
            BEGIN
               if (k > 0) and (k = i - 1) then
                  inc(j);
               cstr[0][j] := buffer[i];
               k := i;
            END;
            inc(i);
         until (cstr[0] = cstr0) or (i > maxchar) or (j > strlen);
         if (i+o_03 <= maxchar) then
         BEGIN
            dec(i, strlen);
            move(buffer[i+o_01], cstr[1][1], strlen);
            if (cstr[1] = cstr1) then
            BEGIN
               writeln(
                    cr, 'Offset to TP system code:', dt, '':3,
                    hexl(o_sysseg):9
                      );

               write('Compiled by Borland TP v');

               move(buffer[i-o_02], cstr[2][1], strlen);

               if (cstr[2] = cstr2) then
               BEGIN
                  move(buffer[i+o_03], cstr[3][1], strlen);
                  if (cstr[3] = cstr3) THEN
                     writeln('6.0')
                  ELSE
                     writeln('5.0/5.5');
               END
               ELSE
                  writeln('4.0');
            END;
         END;
      END;
   END; {procedure}

procedure process_exefile;
   CONST
      ofs_whdr  = $3C;      { offset to MS-Window exe file id }
      exwid     = $454E;    { MS-Window exe file id }
   VAR
      o_sign,
      fsize   :longint;
   BEGIN
      if (exe_size = dirfile.size) then
      BEGIN
         print_info;
         if not compressed then
            id_signature;
         writeln;
      END
      else
      BEGIN
{d}      Seek(f, ofs_whdr);        { offset to 'offset to window exe 
signature' }
{d}      BlockRead(f, hdr_size, sizeof(hdr_size));
{d}      if (hdr_size <= dirfile.size) then
         BEGIN
            Seek(f, hdr_size);     { offset to new exe signature }
{d}         BlockRead(f, winhdr, sizeof(winhdr));
         END;
         if (winhdr.id = exwid) then
         BEGIN
            writeln('Dos/MS-Window EXE or DLL file');
            print_info;
            EXIT;
         END
         else
         BEGIN
            print_info;
            writeln(
               cr,
               'file size (', exe_size, ') calculated from EXE header ',
               '(load by DOS upon exec)', cr,
               'doesn''t match with file size (', dirfile.size, ') ',
               'recorded on file directory.', cr, cr,
               '* EXE file saved with extra bytes at eof (e.g. debug info)', cr,
               '* EXE file may contain overlays', cr,
               '* possible a corrupted EXE file', cr
                   );

            EXIT;
         END;
      END;
   END;

procedure id_file;
   CONST
      exeid = $5A4D;    { MS-DOS exe file id }

   VAR
      zero : str2;

   BEGIN
      if (exehdr.id = exeid) then
      BEGIN
         if (exehdr.cs = $FFF0) and
            (exehdr.ip = $0100) and
            (exehdr.ofs_rtbl = $50) or
            (exehdr.ofs_rtbl = $52) then
          BEGIN
             writeln('Compressed by PKLITE');
             compressed := true;
          END;
          if (exehdr.size = 2) and (exehdr.chk_sum = $899D) then
          BEGIN
             writeln( 'Compressed by DIET');
             compressed := true;
          END;
          if (exehdr.Lpage > 0) then
             exe_size := longint(exehdr.Fpages - 1) shl 9+exehdr.Lpage
          else
             exe_size := longint(exehdr.Fpages) shl 9;
          process_exefile;
      END
      else
         writeln('Not EXE file');
   END; {procedure}

CONST
   blocksize = 1; { file r/w block size in one-byte unit }

VAR
   path : dirstr;
   name : namestr;
   ext  : extstr;
   fstr : string[48];
   n    : byte;

BEGIN
   if paramcount < 1 then
      n := 0
   else
      n := 1;

   fsplit(paramstr(n), path, name, ext);
   if (name+ext = '*.*') or (name+ext = '.' ) or (name+ext = '' ) then
      fstr := path+'*.exe'
   else
      if (path+ext = '') then
         fstr := paramstr(n)+'.exe'
      else
         if not boolean(pos('.', ext)) then
         BEGIN
            path := path+name+'\';
            fstr := path+'*.exe';
         END
         else
            fstr := paramstr(n);

    n := 0;
{d} findfirst(fstr, anyfile, dirfile);
    while (doserror = no_error) do
    BEGIN
       if (dirfile.attr and volumeid <> volumeid) and
          (dirfile.attr and directory <> directory) and
          (dirfile.attr and sysfile <> sysfile) then
       BEGIN
          compressed := false;
          Assign(f, path+dirfile.name); {$I-}
{d}       Reset(f, blocksize); {$I+}
          if (IOResult = no_error) then
          BEGIN
             writeln(cr, dirfile.name);
{d}          BlockRead(f, exehdr, sizeof(exehdr), blocks_r);
             if (blocks_r = sizeof(exehdr)) then
                id_file
             else
                writeln('err:main');
             close(f);
             inc(n);
          END;
       END;
{d}    findnext(dirfile);
    END;

    if (n = 0) then
       if doserror = 3 then
          writeln('path not found')
       else
          writeln('file not found')
       else
          writeln(n,' files found');
END.

