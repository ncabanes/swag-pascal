(*
  Category: SWAG Title: FILE & ENCRYPTION ROUTINES
  Original name: 0027.PAS
  Description: Criptation code
  Author: EMIDIO SPINOGATTI
  Date: 05-31-96  09:16
*)

{
I want to let you see a program I made to criptate binary and
text files... it just traslate ALL THE FILE of a bit to right,
then adds the old extension to the start of the file, followed by
a (eof) #26... try it and tell me what do you think!

I you have something to suggest... i'm here!... for example how
to add a password to coded files, how to increase the speed of
the program and so on...

Sorry for my english :-) }

program NCode;

{FREEWARE! 1996, Emidio Spinogatti (2:335/622.18@fidonet)}

uses dos;

var
  f1, f2: file of byte;
  DirInfo: SearchRec;
  P: PathStr;
  D: DirStr;
  N: NameStr;
  E: ExtStr;

procedure code;
const eofile:byte=26;
var
  b, LByte, SByte: byte;
  ctrl_bit: boolean;
begin
  writeln('CODIFICA IN CORSO...');
  assign(f1, paramstr(1)); assign(f2, n+'.cod');
  reset(f1); rewrite(f2);
  b:=ord(e[2]); LByte:=ord(e[3]); SByte:=ord(e[4]);
  write(f2, b, LByte, SByte, eofile); {INTESTAZIONE DEL FILE}

  {LEGGE L'ULTIMO BIT E LO SALVA IN CTRL_BIT} seek(f1, filesize(f1)-1);
  read(f1, b); if ((b or 1) = b) then ctrl_bit:=true
                                 else ctrl_bit:=false;

  {TORNA ALL'INIZIO DEL FILE} seek(f1, 0);

  repeat
    write(#13, round((filepos(f1)+1)/filesize(f1)*100), '%');
    read(f1, LByte);

    if ctrl_bit then SByte:=128
                else SByte:=0;
    if (LByte or 128)=LByte then SByte:=SByte+064;
    if (LByte or 064)=LByte then SByte:=SByte+032;
    if (LByte or 032)=LByte then SByte:=SByte+016;
    if (LByte or 016)=LByte then SByte:=SByte+008;
    if (LByte or 008)=LByte then SByte:=SByte+004;
    if (LByte or 004)=LByte then SByte:=SByte+002;
    if (LByte or 002)=LByte then SByte:=SByte+001;

    write(f2, SByte);

    if ((LByte or 1) = LByte) then ctrl_bit:=true
                              else ctrl_bit:=false;

  until eof(f1);

  close(f2); close(f1);
end;

procedure decode;
var
  Hold_Bit, Ctrl_Bit: boolean;
  LByte, b, SByte: byte;
begin
writeln('DECODIFICA IN CORSO...');

  assign(f1, paramstr(1)); reset(f1);

  read(f1, LByte, b, SByte); {LETTURA INTESTAZIONE DEL FILE}
  e:='.'+chr(LByte)+chr(b)+chr(SByte);
  assign(f2, n+e); rewrite(f2);

  read(f1, LByte); {LETTURA EOF 4° CARATTERE}

  read(f1, LByte); {PRIMO BYTE "SIGNIFICATIVO"}

  if ((LByte or 128)=LByte) Then Hold_Bit:=true {"CONSERVA" IL PRIMO BIT}
                            else Hold_Bit:=false;
  SByte:=0;
  while not eof(f1) do
  begin
    write(#13, round((filepos(f1)+1)/filesize(f1)*100), '%');
    read(f1, b);
    if ((b or 128)=b) then Ctrl_Bit:=true   {CONSERVA IL PRIMO BIT DEL BYTE}
                      else Ctrl_Bit:=false; {SUCCESSIVO}

    if Ctrl_Bit             then SByte:=SByte+001;
    if (LByte or 001)=LByte then SByte:=SByte+002;
    if (LByte or 002)=LByte then SByte:=SByte+004;
    if (LByte or 004)=LByte then SByte:=SByte+008;
    if (LByte or 008)=LByte then SByte:=SByte+016;
    if (LByte or 016)=LByte then SByte:=SByte+032;
    if (LByte or 032)=LByte then SByte:=SByte+064;
    if (LByte or 064)=LByte then SByte:=SByte+128;

    write(f2, SByte);
    LByte:=b;
    SByte:=0;
  end;

    if Hold_Bit             then SByte:=001;
    if (LByte or 001)=LByte then SByte:=SByte+002;
    if (LByte or 002)=LByte then SByte:=SByte+004;
    if (LByte or 004)=LByte then SByte:=SByte+008;
    if (LByte or 008)=LByte then SByte:=SByte+016;
    if (LByte or 016)=LByte then SByte:=SByte+032;
    if (LByte or 032)=LByte then SByte:=SByte+064;
    if (LByte or 064)=LByte then SByte:=SByte+128;
    write(f2, SByte);

  close(f1); close(f2);
end;

procedure guida;
begin
  writeln(#13#10,
          'Questo programma serve a codificare file binari e di testo.');
  writeln(#13#10,
          ' (Codifica)  NCODE <filename.estensione>');
  writeln('(Decodifica) NCODE <filename>.COD');
end;

function FileExists(FileName: String): Boolean;
{ Boolean function that returns True if the file exists;otherwise,
 it returns False. Closes the file if it exists. }
var
 F: file;
begin
 {$I-}
 Assign(F, FileName);
 FileMode := 0;  { Set file access to read only }
 Reset(F);
 Close(F);
 {$I+}
 FileExists := (IOResult = 0) and (FileName <> '');
end;  { FileExists }

begin
  writeln('NCode 1.0 - Nogat Software 1996');
  if paramcount<>1 then begin guida; exit end;
  {CONTROLLO} if not FileExists(paramstr(1)) then begin
                                                  writeln('File inesistente.');
                                                  exit
                                                  end;
    FindFirst(paramstr(1), Archive, DirInfo); { Same as DIR *.PAS }
    fsplit(dirinfo.name, d, n, e);
  {CONTROLLO} if ((e='.COD') or (e='.cod')) then decode
                                            else code;
end.

