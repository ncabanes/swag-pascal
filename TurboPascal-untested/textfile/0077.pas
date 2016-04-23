
{------------------------------------------------------------------
 ---                          TXT2UNIT  V1.0                    ---
 ---                     J.J. Arenzon    5.10.94                ---
 ---                                                            ---
 ---  Converts a text file into a unit source to be embedded    ---
 ---  inside an executable. You can also find it (with the      ---
 ---  the compiled file) in:                                    ---
 ---          garbo.uwasa.fi/pc/turbopa7/txt2unit.zip           ---
 ---                                                            ---
 ---  To use, just type:                                        ---
 ---                                                            ---
 ---                    TXT2UNIT <filename>                     ---
 ---                                                            ---
 ---  You will see the text and, by pressing U, the file        ---
 ---  filename.pas (or another name that you specify) will be   ---
 ---  created. This is a unit source that can be compiled       ---
 ---  using TP (tested in TP7 but should work in another        ---
 ---  versions without modifications). To use it in another     ---
 ---  program just include the line: USES filename in the       ---
 ---  header and call the routine scroll.                       ---
 ---                                                            ---
 ---  Example:                                                  ---
 ---                                                            ---
 ---          uses example; -> the name of your unit            ---
 ---                                                            ---
 ---          begin                                             ---
 ---          scroll;       -> here you call the routine scroll ---
 ---          end.                                              ---
 ---                                                            ---
 ---  If you find this program interesting, or have questions,  ---
 ---  comments, improvements, etc, please, send a message to:   ---
 ---                                                            ---
 ---               Jeferson J. Arenzon                          ---
 ---               Instituto de Fisica - UFRGS                  ---
 ---               CP 15051                                     ---
 ---               91501-970 Porto Alegre RS                    ---
 ---               BRAZIL                                       ---
 ---               E-mail: arenzon@if.ufrgs.br                  ---
 ---               URL: http://www.if.ufrgs.br/                 ---
 ------------------------------------------------------------------}


 program txt2unit;

 uses crt,dos;

 const versao = '1.0';

 type string12 = string[12];

 var  arqsaida,arqentrada                     : text;
      arquivo                                 : string;
      nome                                    : searchrec;
      lines,i                                 : integer;
      resposta                                : char;
      fulltext                                : array[1..256] of ^string;

{------------------------------------------------------------------
 ---             Cursor ON/OFF (Mike Normand, SWAG)             ---
 ------------------------------------------------------------------}
 Procedure CursorOff; Assembler;
 Asm
     xor  ax, ax
     mov  es, ax
     mov  bh, Byte ptr es:[462h]  { get active page }
     mov  ah, 3
     int  10h           { get cursor Characteristics }
     or   ch, 00100000b
     mov  ah, 1
     int  10h           { set cursor Characteristics }
 end;

 Procedure CursorOn; Assembler;
 Asm
     xor  ax, ax
     mov  es, ax
     mov  bh, Byte ptr es:[462h]  { get active page }
     mov  ah, 3
     int  10h           { get cursor Characteristics }
     and  ch, 00011111b
     mov  ah, 1
     int  10h           { set cursor Characteristics }
 end;

{----------------------------------------------------------------
 ---                      Open Output File                    ---
 ----------------------------------------------------------------}
 procedure openpc;

 var name,outfile         : string;
     nome                 : searchrec;

 begin
 if paramcount=2 then name := paramstr(2)
                 else begin
                      name := Copy(paramstr(1), 1, Pos('.', paramstr(1)) - 1);
                      textbackground( LIGHTGRAY );
                      textcolor( BLACK );
                      gotoxy(1,25);
                      clreol;
                      write('Output filename (default: ',name,')?');
                      readln(outfile);
                      if outfile<>'' then name := outfile;
                      end;
 arquivo := concat(name,'.pas');
 findfirst(arquivo,archive,nome);
 if doserror=0 then begin
                    textbackground( LIGHTGRAY );
                    textcolor( BLACK );
                    gotoxy(1,25);
                    clreol;
                    gotoxy(1,25);
                    write('File already exist! Overwrite (');
                    textcolor(RED);
                    write('Y');
                    textcolor( BLACK );
                    write('/');
                    textcolor( RED );
                    write('N'); 
                    textcolor( BLACK );
                    write(')?');
                    repeat until keypressed;
                    resposta := readkey;
                    end;
 if (resposta='y') or (doserror<>0)
 then begin
      assign(arqsaida,arquivo);
      rewrite(arqsaida);
      writeln(arqsaida,'(* Txt converted using txt2unit V',versao:4,' *)');
      writeln(arqsaida,'(* J.J. Arenzon (c)1994               *)');
      writeln(arqsaida);
      writeln(arqsaida,'UNIT ',name,';');
      writeln(arqsaida);
      writeln(arqsaida,'INTERFACE');
      writeln(arqsaida);
      writeln(arqsaida,'uses crt,dos,printer;');
      writeln(arqsaida);
      writeln(arqsaida,'const lines =',lines:5,';');
      writeln(arqsaida);
      writeln(arqsaida,'type string12 = string[12];');
      writeln(arqsaida);
      writeln(arqsaida,'var linha    : integer;');
      writeln(arqsaida);
      writeln(arqsaida, 'function PrinterOnLine : boolean;');
      writeln(arqsaida, 'procedure cursoron;');
      writeln(arqsaida, 'procedure cursoroff;');
      writeln(arqsaida, 'procedure linhas(writeline : integer);');
      writeln(arqsaida, 'procedure scroll;');
      writeln(arqsaida);
      writeln(arqsaida,' IMPLEMENTATION');
      writeln(arqsaida);

      writeln(arqsaida,'{----------------------------------------------------------------');
      writeln(arqsaida,' ---                    Printer Online                        ---');
      writeln(arqsaida,' ---   By: Jeff Palen (SWAG package)                          ---');
      writeln(arqsaida,' ----------------------------------------------------------------}');
      writeln(arqsaida,' Function PrinterOnLine : Boolean;');
      writeln(arqsaida,' Const   PrnStatusInt  : Byte = $17;    (*  Dos interrupt *)');
      writeln(arqsaida,'         StatusRequest : Byte = $02;    (*  Interrupt Function Call *)');
      writeln(arqsaida,'         PrinterNum    : Word = 0;  { 0 for LPT1, 1 for LPT2, etc. }');
      writeln(arqsaida,' Var     Regs : Registers ;         { Type is defined in Dos Unit }');
      writeln(arqsaida,' Begin');
      writeln(arqsaida,' Regs.AH := StatusRequest;');
      writeln(arqsaida,' Regs.DX := PrinterNum;');
      writeln(arqsaida,' Intr(PrnStatusInt, Regs);');
      writeln(arqsaida,' PrinterOnLine := (Regs.AH and $80) = $80;');
      writeln(arqsaida,' End;');

      writeln(arqsaida);
      writeln(arqsaida,'{------------------------------------------------------------------');
      writeln(arqsaida,' ---             Cursor ON/OFF (Mike Normand, SWAG)             ---');
      writeln(arqsaida,' ------------------------------------------------------------------}');
      writeln(arqsaida,'Procedure CursorOff; Assembler;');
      writeln(arqsaida,'Asm');
      writeln(arqsaida,'    xor  ax, ax');
      writeln(arqsaida,'    mov  es, ax');
      writeln(arqsaida,'    mov  bh, Byte ptr es:[462h]  { get active page }');
      writeln(arqsaida,'    mov  ah, 3');
      writeln(arqsaida,'    int  10h           { get cursor Characteristics }');
      writeln(arqsaida,'    or   ch, 00100000b');
      writeln(arqsaida,'    mov  ah, 1');
      writeln(arqsaida,'    int  10h           { set cursor Characteristics }');
      writeln(arqsaida,'end;');
      writeln(arqsaida);
      writeln(arqsaida,'Procedure CursorOn; Assembler;');
      writeln(arqsaida,'Asm');
      writeln(arqsaida,'    xor  ax, ax');
      writeln(arqsaida,'    mov  es, ax');
      writeln(arqsaida,'    mov  bh, Byte ptr es:[462h]  { get active page }');
      writeln(arqsaida,'    mov  ah, 3');
      writeln(arqsaida,'    int  10h           { get cursor Characteristics }');
      writeln(arqsaida,'    and  ch, 00011111b');
      writeln(arqsaida,'    mov  ah, 1');
      writeln(arqsaida,'    int  10h           { set cursor Characteristics }');
      writeln(arqsaida,'end;');

      writeln(arqsaida);
      writeln(arqsaida,'procedure linhas(writeline : integer);');
      writeln(arqsaida);
      writeln(arqsaida,'begin');
      writeln(arqsaida,'case writeline of');
      for i:=1 to lines
      do writeln(arqsaida,i:5,' : writeln(',char(39),fulltext[i]^,char(39),');');
      writeln(arqsaida,'   end;');
      writeln(arqsaida,'end;');

      writeln(arqsaida);
      writeln(arqsaida,'{-------------------------------------------------------------------');
      writeln(arqsaida,' ---                           SCROLL                            ---');
      writeln(arqsaida,' ---                    L. Sclovsky   6.94                       ---');
      writeln(arqsaida,' ---  Modifications: J.J. Arenzon 94                             ---');
      writeln(arqsaida,' -------------------------------------------------------------------}');
      writeln(arqsaida,' procedure scroll;');
      writeln(arqsaida);
      writeln(arqsaida,' type actions = ( lineup, linedown, pageup, pagedown, gohome, goend,');
      writeln(arqsaida,'                 quit, none );');
      writeln(arqsaida);
      writeln(arqsaida,' const topstatusline = 1;');
      writeln(arqsaida,'       bottomstatusline = 25;');
      writeln(arqsaida,'       firstrow = 2;');
      writeln(arqsaida,'       lastrow = 24;');
      writeln(arqsaida,'       totrows = 23;');
      writeln(arqsaida);
      writeln(arqsaida,' label 1;');
      writeln(arqsaida);
      writeln(arqsaida,' var fim                                         : boolean;');
      writeln(arqsaida,'     y, key 					 : byte;');
      writeln(arqsaida,'     i, currline, writeline,');
      writeln(arqsaida,'     lastpageline, percent    			 : integer;');
      writeln(arqsaida,'     c 						 : char;');
      writeln(arqsaida,'     action 					 : actions;');
      writeln(arqsaida,'     textfile 					 : text;');
      writeln(arqsaida,'     textline 					 : string[80];');
      writeln(arqsaida);
      writeln(arqsaida);
      writeln(arqsaida,'   procedure statusbars;');
      writeln(arqsaida,'   begin');
      writeln(arqsaida,'   {top bar}');
      writeln(arqsaida,'   textbackground( LIGHTGRAY );');
      writeln(arqsaida,'   textcolor( BLACK );');
      writeln(arqsaida,'   gotoxy( 1, topstatusline );');
      writeln(arqsaida,'   clreol;');
      writeln(arqsaida,'   gotoxy( 25, topstatusline );');
      writeln(arqsaida,'   write(',char(39),'On-line help for',char(39),');');
      writeln(arqsaida,'   textcolor( RED );');
      writeln(arqsaida,'   write(',char(39),' YOUR PROGRAM',char(39),');');
      writeln(arqsaida,'   {bottom bar}');
      writeln(arqsaida,'   textbackground( LIGHTGRAY );');
      writeln(arqsaida,'   textcolor( BLACK );');
      writeln(arqsaida,'   gotoxy( 1, bottomstatusline );');
      writeln(arqsaida,'   clreol;');
      writeln(arqsaida,'   gotoxy( 2, bottomstatusline );');
      write(arqsaida,  '   write(',char(39),'Commands: ',char(39),',char(24),',char(39),' ');
      writeln(arqsaida,char(39),',char(25),',char(39),' PgUp PgDn Home End Esc',char(39),');');
      writeln(arqsaida,'   gotoxy( 79, bottomstatusline );');
      writeln(arqsaida,'   Write(',char(39),'%',char(39),');');
      writeln(arqsaida,'   end;');
      writeln(arqsaida);
      writeln(arqsaida,'begin');
      writeln(arqsaida,'if lines > totrows');
      writeln(arqsaida,'then lastpageline := lines - totrows + 1');
      writeln(arqsaida,'else lastpageline := 1;');
      writeln(arqsaida);
      writeln(arqsaida,'fim := false;');
      writeln(arqsaida,'currline := 1;');
      writeln(arqsaida,'action := pagedown;');
      writeln(arqsaida);
      writeln(arqsaida,'{ clear screen }');
      writeln(arqsaida,'textbackground( BLUE );');
      writeln(arqsaida,'textcolor( WHITE );');
      writeln(arqsaida,'clrscr;');
      writeln(arqsaida);
      writeln(arqsaida,'statusbars;');
      writeln(arqsaida);
      writeln(arqsaida);
      writeln(arqsaida,'while not fim');
      writeln(arqsaida,'do begin');
      writeln(arqsaida);
      writeln(arqsaida,'   { refresh screen }');
      writeln(arqsaida,'   if action <> none ');
      writeln(arqsaida,'   then begin');
      writeln(arqsaida);
      writeln(arqsaida,'        textbackground( BLUE );');
      writeln(arqsaida,'        textcolor( WHITE );');
      writeln(arqsaida,'        writeline := currline;');
      writeln(arqsaida,'        for y := firstrow to lastrow');
      writeln(arqsaida,'        do begin');
      writeln(arqsaida,'           gotoxy( 1, y );');
      writeln(arqsaida,'           clreol;');
      writeln(arqsaida,'           if writeline <= lines');
      writeln(arqsaida,'           then begin');
      writeln(arqsaida,'                linhas(writeline);');
      writeln(arqsaida,'                writeline := writeline + 1;');
      writeln(arqsaida,'                end;');
      writeln(arqsaida,'           end;');
      writeln(arqsaida);
      writeln(arqsaida,'        textbackground( LIGHTGRAY );');
      writeln(arqsaida,'        textcolor( RED );');
      writeln(arqsaida,'        percent := trunc( ( currline + totrows - 1 ) / lines * 100 );');
      writeln(arqsaida,'        if percent > 100 then percent := 100;');
      writeln(arqsaida,'        gotoxy( 75, bottomstatusline );');
      writeln(arqsaida,'        Write( percent:3 );');
      writeln(arqsaida,'        end;');
      writeln(arqsaida);
      writeln(arqsaida,'   { reads keyboard }');
      writeln(arqsaida,'   action := none;');
      writeln(arqsaida,'   c := readkey;');
      writeln(arqsaida,'   key := ord(c);');
      writeln(arqsaida,'   if key > 0');
      writeln(arqsaida,'   then case key of');
      writeln(arqsaida,'             27 : action := quit;');
      writeln(arqsaida,'             end');
      writeln(arqsaida,'   else begin');
      writeln(arqsaida,'        c := readkey;');
      writeln(arqsaida,'        key := ord(c);');
      writeln(arqsaida,'        case key of');
      writeln(arqsaida,'             72 : action := lineup;');
      writeln(arqsaida,'             80 : action := linedown;');
      writeln(arqsaida,'             73 : action := pageup;');
      writeln(arqsaida,'             81 : action := pagedown;');
      writeln(arqsaida,'             71 : action := gohome;');
      writeln(arqsaida,'             79 : action := goend;');
      writeln(arqsaida,'             end;');
      writeln(arqsaida,'        end;');
      writeln(arqsaida);
      writeln(arqsaida,'   { process action }');
      writeln(arqsaida,'   case action of');
      writeln(arqsaida,'        lineup : if currline > 1');
      writeln(arqsaida,'                 then currline := currline - 1');
      writeln(arqsaida,'                 else action := none;');
      writeln(arqsaida,'        linedown : if currline < lastpageline');
      writeln(arqsaida,'                   then currline := currline + 1');
      writeln(arqsaida,'                   else action := none;');
      writeln(arqsaida,'        pageup : if currline > totrows');
      writeln(arqsaida,'                 then currline := currline - totrows');
      writeln(arqsaida,'                 else if currline > 1');
      writeln(arqsaida,'                      then currline := 1');
      writeln(arqsaida,'                      else action := none;');
      writeln(arqsaida,'        pagedown : if currline + totrows < lastpageline');
      writeln(arqsaida,'                   then currline := currline + totrows');
      writeln(arqsaida,'                   else if currline < lastpageline');
      writeln(arqsaida,'                        then currline := lastpageline');
      writeln(arqsaida,'                        else action := none;');
      writeln(arqsaida,'        gohome : if currline <> 1');
      writeln(arqsaida,'                 then currline := 1');
      writeln(arqsaida,'                 else action := none;');
      writeln(arqsaida,'        goend : if currline <> lastpageline');
      writeln(arqsaida,'                then currline := lastpageline');
      writeln(arqsaida,'                else action := none;');
      writeln(arqsaida,'        quit : fim := true;');
      writeln(arqsaida,'        end;');
      writeln(arqsaida);
      writeln(arqsaida,'   end;');
      writeln(arqsaida);
      writeln(arqsaida);
      writeln(arqsaida);
      writeln(arqsaida,'1 :');
      writeln(arqsaida);
      writeln(arqsaida,'textcolor(lightgray);');
      writeln(arqsaida,'textbackground(black);');
      writeln(arqsaida,'clrscr;');
      writeln(arqsaida,'cursoron;');
      writeln(arqsaida);
      writeln(arqsaida,'end;');



      writeln(arqsaida,'(*  Initialization *)');
      writeln(arqsaida);
      writeln(arqsaida,'begin');
      writeln(arqsaida,'end.');
      close(arqsaida);

      end;
 end;



{-------------------------------------------------------------------
 ---                           SCROLL                            ---
 ---                    L. Sclovsky   6.94                       ---
 ---  Modifications: J.J. Arenzon 94                             ---
 -------------------------------------------------------------------}
 procedure scroll( textname : string12 );

 type actions = ( lineup, linedown, pageup, pagedown, gohome, goend,
                 quit, none, tounit );

 const topstatusline = 1;
       bottomstatusline = 25;
       firstrow = 2;
       lastrow = 24;
       totrows = 23;

 label 1;

 var fim                                         : boolean;
     y, key 					 : byte;
     i, currline, writeline,
     lastpageline, percent    			 : integer;
     c 						 : char;
     action 					 : actions;
     textfile 					 : text;
     textline 					 : string[80];


   procedure statusbars;
   begin
   {top bar}
   textbackground( LIGHTGRAY );
   textcolor( BLACK );
   gotoxy( 1, topstatusline );
   clreol;
   gotoxy( 20, topstatusline );
   write('View file to be converted to a');
   textcolor( RED );
   write( ' unit' );
   {bottom bar}
   textbackground( LIGHTGRAY );
   textcolor( BLACK );
   gotoxy( 1, bottomstatusline );
   clreol;
   gotoxy( 2, bottomstatusline );
   write('Commands: ',char(24),' ',char(25),' PgUp PgDn Home End Esc');
   textcolor( RED );
   write('         U');
   textcolor( BLACK );
   write('nit');
   gotoxy( 79, bottomstatusline );
   Write('%');
   end;

begin
{ reads full text }
i := 1;
assign( textfile, textname );
reset( textfile );
while not eof( textfile )
do begin
   readln( textfile, textline );

   { if there is no memory then returns FALSE }
   if maxavail < length(textline) + 1
   then goto 1;

   getmem( fulltext[i], length(textline) + 1 );
   fulltext[i]^ := textline;
   i := i + 1;
   end;
close( textfile );
lines := i - 1;
if lines > totrows
then lastpageline := lines - totrows + 1
else lastpageline := 1;

{restorecrtmode;}

fim := false;
currline := 1;
action := pagedown;

{ clear screen }
textbackground( BLUE );
textcolor( WHITE );
clrscr;

statusbars;


while not fim
do begin

   { refresh screen }
   if action <> none
   then begin

        textbackground( BLUE );
        textcolor( WHITE );
        writeline := currline;
        for y := firstrow to lastrow
        do begin
           gotoxy( 1, y );
           clreol;
           if writeline <= lines
           then begin
                write( fulltext[writeline]^ );
                writeline := writeline + 1;
                end;
           end;

        textbackground( LIGHTGRAY );
        textcolor( RED );
        percent := trunc( ( currline + totrows - 1 ) / lines * 100 );
        if percent > 100 then percent := 100;
        gotoxy( 75, bottomstatusline );
        Write( percent:3 );
        end;

   { reads keyboard }
   action := none;
   c := readkey;
   key := ord(c);
   if key > 0
   then case key of
             27 : action := quit;
             85  : action := tounit;
             117 : action := tounit;
             end
   else begin
        c := readkey;
        key := ord(c);
        case key of
             72 : action := lineup;
             80 : action := linedown;
             73 : action := pageup;
             81 : action := pagedown;
             71 : action := gohome;
             79 : action := goend;
             end;
        end;

   { process action }
   case action of
        tounit: begin
                openpc;
                fim := true;
                end;
        lineup : if currline > 1
                 then currline := currline - 1
                 else action := none;
        linedown : if currline < lastpageline
                   then currline := currline + 1
                   else action := none;
        pageup : if currline > totrows
                 then currline := currline - totrows
                 else if currline > 1
                      then currline := 1
                      else action := none;
        pagedown : if currline + totrows < lastpageline
                   then currline := currline + totrows
                   else if currline < lastpageline
                        then currline := lastpageline
                        else action := none;
        gohome : if currline <> 1
                 then currline := 1
                 else action := none;
        goend : if currline <> lastpageline
                then currline := lastpageline
                else action := none;
        quit : fim := true;
        end;

   end;

{ clrscr;
  writeln( ' maxavail = ', maxavail ); }

{ frees memory }
for i := lines downto 1
do freemem( fulltext[i], length( fulltext[i]^ ) + 1 );

{ writeln( ' maxavail = ', maxavail );
  readkey; }

1 :

end;

{-------------------------------------------------------------------
 ---                      Main Program                           ---
 -------------------------------------------------------------------}

 begin
 if paramcount=0 
 then begin
      writeln('Converts text files to a unit source! JJA (c)1994');
      writeln('USAGE: txt2unit <filein> [fileout]');
      end
 else begin
      cursoroff;
      findfirst(paramstr(1),archive,nome);
      if doserror=0 then scroll(paramstr(1))
                    else writeln(paramstr(1),' not found!');
      textcolor(lightgray);
      textbackground(black);
      clrscr;
      cursoron;
      end;
 end.

