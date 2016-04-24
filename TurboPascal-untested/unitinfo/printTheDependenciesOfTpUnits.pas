(*
  Category: SWAG Title: UNIT INFORMATION ROUTINES
  Original name: 0006.PAS
  Description: print the dependencies of TP units
  Author: UWE MAEDER
  Date: 01-02-98  07:34
*)

{
Purpose: bpxref is a ms-dos program that prints the
dependencies (cross reference) of Turbo Pascal units by
parsing import (uses) lists of the sources.
Run bpxref with no parameters to display the calling syntax.
Output to stdout (for piping).
With source. I think little effort is necessary to extend
it to Delphi sources (in addition you have to parse the .dpr file).

Installation:
files: bpxref.exe (executable binary)
       bpxref.pas (the source)
       readme.txt (what you're just reading)
Extract the desired file(s). Ready.

Status of the Program: Freeware.

Distribution status: freely;

Author: Uwe Maeder, university of wuerzburg, germany
        tuze001@rzbox.uni-wuerzburg.de


}
PROGRAM bpxref;
{$M 32000,0,255360 }
{    ^  stack size (recursion!) }

{ Borland Pascal Cross Reference Lister. Short description see main }
{ uwe maeder, wuerzburg, germany }
{ 10/88: BP4.0, at this time no oop, sorry! }
{ 10/97: BP7.0, Version: 1.0 }
{ thanks to Prof. N. Wirth: Compilerbau }
USES crt,dos;

TYPE NameStr = string[64];
     TimeStr = string[20];

{ ==== defs for the mini parser ===========}
TYPE symbol = (NulSym,EOFSym,ident,number,literal,
               IntfSym,UsesSym,ImplSym,Comma);

      SymSet = SET OF Symbol;

CONST NoKW = 3;
CONST KWtbl: ARRAY[0..NoKW] OF NameStr =
            ('',
             'USES','INTERFACE','IMPLEMENTATION');

      wsym: ARRAY[1..NoKW] OF symbol =
             (UsesSym,IntfSym,ImplSym);

{ === structure to hold information: tree and list==== }
TYPE tpUseNode = ^tUseNode;
     tUseNode  = RECORD
                 name: NameStr;
                 next: tpUseNode
                END;
     tpNode    = ^tNode;
     tNode     = RECORD
                  Name: NameStr;
                  dirx: word; { Index of Dir in DirList }
                  time,size: LONGINT;
                  left,right: tpNode;
                  pUseList: tpUseNode;
                END;

VAR Root: tpNode;


CONST PLAST = 32;

VAR DirList: ARRAY[1..PLAST] OF STRING[50];
    DirCnt: WORD;
    SourceSize: LONGINT;
    SourceCount: WORD;
    stdout: text;
    verboose: boolean;


{ =============misc routines==================== }
function UpperCase(s: string): string;
var i: integer;
begin
 for i:=1 to length(s) do
  s[i]:=upcase(s[i]);
 UpperCase:=s;
end; { UpperCase }

FUNCTION Trim(s: STRING): STRING;
VAR p1,p2: integer;
BEGIN
 p2:=length(s);
 WHILE (p2>0) and (s[p2]=' ') DO
  dec(p2);
 if p2=0 then
  trim:=''
 else
 begin
  p1:=1;
  WHILE s[p1]=' ' DO
   inc(p1);
  trim:=copy(s,p1,p2-p1+1);
 END;
END; {trim}


FUNCTION Piece(CONST s: STRING; delim: CHAR; n: WORD): STRING; ASSEMBLER;
{ gets the n-th element of the list s, separator delim  }
ASM
 PUSH DS
 LDS  SI,s              { DS:SI String }
 LES  DI,@result        { ES:DI Result }
 PUSH DI                { merken }
 MOV  BX,n              { BH = nummer n }
 XCHG BL,BH
 MOV  BL,delim          { trenner }
 CLD                    { aufwärts geht's }
 XOR CX,CX
 XOR DL,DL              { Counter Result }
 MOV CL,DS:[SI]         { Länge s }
 CMP CL,0
 JZ @ready              { leer: raus }
 MOV AH,1               { result default: TRUE }
 INC SI                 { Begin  1 weiter }
 DEC BH                 { copy ab n-1 }
 JZ @copy               { n=1: sofort kopieren }
@loop:
 LODSB
 CMP AL,BL              { trenner? }
 JNZ @lend
 DEC BH                 { gefunden: DEC no }
 JZ @copy0              { =0: jetzt copy }
@lend:
 LOOP @loop
 { Hier Länge erreicht }
 JMP @ready
@copy0:
 DEC CL                { 1- wegen keine LOOP }
 JZ @ready
@copy:
 INC DI                { ziel }
@cloop:
 LODSB
 CMP AL,BL             { trenner }
 JZ @ready             { ja: fertig }
 STOSB                 { Store und INC DI }
 INC DL                { Länge }
 LOOP @cloop
@ready:
 POP DI                 { ES:DI -> Result }
 MOV ES:[DI],DL         { länge Ziel }
 POP DS
END; { piece }

FUNCTION AdStr(s: STRING; len: BYTE): STRING; ASSEMBLER;
{ format string s}
ASM
 PUSH DS
 LDS SI,s
 LES DI,@result
 CLD          { aufwärts gehts }
 MOV AL,len
 STOSB        { new len }
 CMP AL,0
 JZ @ready
 MOV BL,AL    { BL : len }
 LODSB        { al = len(s) }
 XOR CH,CH
 MOV CL,AL    { cx len(s) }
 MOV BH,AL    { bh: length(s)  }
 JCXZ @cont   { nothin to move }
 REP MOVSB    { move string s }
 SUB BL,BH    { len - length(s) }
 JBE @ready   { result <= 0: ready }
@cont:
 MOV CL,BL    { BL bytes Blank }
 MOV AL,' '
 REP STOSB
@ready:
 POP DS
END; { AdStr }


FUNCTION DateTimeStr(time: longint): TimeStr; { german format }
VAR   dt: DateTime;
      s,s0: TimeStr;
      i: word;
BEGIN
  UnpackTime(time,dt);
  with dt do
  begin
   str(day  :2,s0); s:=s0+'.';
   str(month:2,s0); s:=s+s0+'.';
   str(year :4,s0); s:=s+s0;
   str(hour :2,s0); s:=s+':'+s0+'.';
   str(min  :2,s0); s:=s+s0+'.';
   str(sec  :2,s0); s:=s+s0;
  end;
  FOR i:=1 TO length(s) DO
   if s[i]=' ' then s[i]:='0';
  DateTimeStr:=s;
END; (* DateTimeStr *)


{ ========== dir list load ================ }
PROCEDURE EnterDir(dir: DirStr);
VAR i: WORD;
BEGIN
 if DirCnt>=PLAST then exit;
 dir:=UpperCase(dir);
 if dir[length(dir)]<>'\' then dir:=dir+'\';
 i:=DirCnt;
 WHILE (i>0) AND (dir<>DirList[i]) DO DEC(i);
 IF i=0 THEN
 BEGIN
  INC(DirCnt); DirList[DirCnt]:=dir;
 END;
END; { EnterDir }


PROCEDURE LoadDirList(const path: string);
var f: text;
    s: string;
    dir: DirStr;
    i: integer;
BEGIN
 DirCnt:=0;
 assign(f,path);
 {$I-} reset(f); {$I+}
 if IOresult=0 then
 begin
  while not eof(f) do
  begin
   ReadLn(f,s);
   i:=1; dir:=trim(piece(s,';',i));
   while dir<>'' do
   begin
    EnterDir(dir);
    inc(i); dir:=piece(s,';',i);
   end;
  end;
  close(f);
 end;
end;  { LoadDirList }

{ ================ file search in DirList =================  }

PROCEDURE FindDir(uname: NameStr; VAR dirx: word; VAR time,size: LONGINT);
VAR i: INTEGER;
    s: SearchRec;
BEGIN
 dirx:=0; time:=0; size:=0;
 i:=0;
 {$I-}
 REPEAT
  INC(i);
  dos.FindFirst(DirList[i]+uname+'.PAS',Archive,s);
  if DosError=0 then
   dirx:=i;
 UNTIL (dirx>0) OR (i>=DirCnt);
 {$I+}
 IF dirx>0 THEN
 BEGIN
  time:=s.time;
  size:=s.size;
 END;
END; { FindDir }

{ ============ list routines ===================}

FUNCTION search(const id: NameStr; VAR p: tpNode): tpNode;
BEGIN
 IF p=NIL THEN
 BEGIN
  NEW(p);
  WITH p^ DO
  BEGIN
   name:=id; dirx:=0; time:=0;
   pUseList:=NIL; left:=NIL; right:=NIL;
   search:=p;
  END;
 END ELSE
  IF id<p^.name THEN search:=search(id,p^.left)
 ELSE
  IF id>p^.name THEN search:=search(id,p^.right)
 ELSE search:=p;
END; { search }

FUNCTION Used(id: NameStr; p: tpUseNode): BOOLEAN;
VAR q: tpUseNode;
BEGIN
 q:=p;
 WHILE (q<>NIL) AND (q^.name<>id) DO q:=q^.next;
 Used:=q<>NIL;
END; { Used }


PROCEDURE UsedBy(const uname: string);
{ prints all units that import unit uname }
var l: word;

 PROCEDURE PrUsedBy(p: tpNode);
 BEGIN
  IF p<>NIL THEN
  WITH p^ DO
  BEGIN
   PrUsedBy(left);
   IF Used(uname,pUseList) THEN
   BEGIN
    IF l>69 THEN
    begin
     WriteLn(stdout);
     l:=0;
    end;
    Write(stdout,Name,'':10-Length(Name)); inc(l,10);
   END;
   PrUsedBy(right);
  END;
 END; { PrUsed }

BEGIN
 IF root=NIL THEN EXIT;
 WriteLn(stdout,uname,' USED by:'); l:=0;
 PrUsedBy(root);
 WriteLn(stdout);
END; { UsedBy }

procedure PrintPaths;

 procedure traverse(p: tpNode);
 begin
  if p<>nil then
   with p^ do
   begin
    traverse(p^.left);
    if dirx<>0 then
     WriteLn(stdout,AdStr(DirList[dirx]+name+'.PAS',50),
                    ' ',size:6,' ',DateTimeStr(time));
    traverse(p^.right);
   end;
 end; { traverse }

begin { PrintPaths }
 IF root=NIL THEN EXIT;
 WriteLn(stdout,'All Files:');
 traverse(root);
end; { PrintPaths }


{ ======= recursively collect all uses lists ============= }
PROCEDURE GetStructure(VAR UName: NameStr; VAR p: tpNode; Level: WORD);
CONST EOFch = #31;
      EOLch = #13;
VAR ref: tpNode;
    up,p1,p2: tpUseNode;
    F: TEXT;
    udirx: word;
    ch0,ch: char;
    sym: symbol;
    id: NameStr;
    str: string;

 { mini parser. it seems to be enough to skip comments and
    to recognize
     INTERFACE, IMPLEMENTATION and USES
    GetNumber and GetLiteral may be omitted.
    Source must be syntactical correct!
    Parser doesn't know about compiler directives, i.e. in
     uses (*$IFDEF debug*) debug, (*$ENDIF*),gbase;
    the unit debug is included! }

   PROCEDURE getsym;
   VAR j: integer;

    PROCEDURE  getch;
    BEGIN
     IF EOF(F) THEN
      ch0:=EOFch
     ELSE
     IF EOLn(F) THEN
     BEGIN
      ReadLn(F); ch0:=EOLch;
     END ELSE
      read(F,ch0);
     ch:=UpCase(ch0);
    END; { GetCh }

    PROCEDURE GetId;
    BEGIN
      id:='';
      REPEAT id:=id+ch; getch UNTIL not (ch IN ['A'..'Z','0'..'9','_']);
    END; { GetId }

    PROCEDURE GetNumber; { result as string in str }
    BEGIN
      str:='';
      REPEAT str:=str+ch; getch UNTIL not (ch IN ['0'..'9','.']);
    END; { GetNumber }

    function GetLiteral: boolean; { result in str }
    var stop: boolean;
    begin
     str:='';
     GetCh; stop:=false;
     while not (ch in [EOFch,EOLch]) and not stop do
     begin
      if ch='''' then     { check for "''" -> "'" }
      begin
       GetCh;
       if ch='''' then
       begin
        str:=str+ch;
        GetCh;
       end
       else
        stop:=true;
      end
      else
      begin
       str:=str+ch0;
       GetCh;
      end;
     end;
     GetLiteral:=stop;
    end; { GetLiteral }

    PROCEDURE Comment1;
    BEGIN
     REPEAT
      GetCh;
     UNTIL ch IN ['}',EOFch];
     GetCh;
    END; { Comment1 }

    PROCEDURE Comment2;
    BEGIN
     REPEAT
      WHILE NOT (ch IN ['*',EOFCh]) DO GetCh;
      GetCh;
     UNTIL ch IN [')',EOFCh];
     GetCh;
    END; { Comment2 }

  BEGIN (* getsym *)
   WHILE ch in [' ',#13] DO getch;
   CASE ch OF
    'A'..'Z': BEGIN
               GetId;
               KWtbl[0]:=id; j:=NoKW;
               WHILE id<>KWtbl[j] DO dec(j);
               IF j>0 THEN sym:=wsym[j] ELSE sym:=ident;
              END;
    '0'..'9': begin GetNumber; sym:=number end;
    ''''    : if GetLiteral then
               sym:=literal
              else
              begin
               WriteLn(stdout,'Error in literal');
               sym:=EOFsym;
              end;
    ',':     BEGIN sym:=comma; GetCh; END;
    '{': begin
          Comment1;
          GetSym;
         end;
    '(': BEGIN
          GetCh;
          IF ch='*' THEN
          BEGIN
           GetCh; Comment2; GetSym;
          END ELSE sym:=NulSym;
         END;
    EOFch:   sym:=EOFSym;
    ELSE     BEGIN sym:=NulSym; GetCh; END;
   END;
  END; { GetSym }

 procedure ParseUseList;
 begin
  GetSym; { USES }
  p1:=up;
  WHILE sym=ident DO
  BEGIN
   p1^.name:=COPY(id,1,8);
   if verboose then WriteLn(stdout,'':(level+1),id);
   NEW(p2); p1^.next:=p2;
   WITH p2^ DO
   BEGIN
    next:=NIL;
    name:='';
   END;
   p1:=p2;
   GetSym; IF sym=comma THEN GetSym;
  END;
 end; { ParseUseList }


BEGIN { GetStructure }
 INC(Level);
 ref:=search(UName,root);
 IF ref^.pUseList<>NIL THEN EXIT; { schon da }
 FindDir(UName,udirx,ref^.time,ref^.size);
 IF udirx=0 THEN EXIT;
 if verboose then
  WriteLn(stdout,'Scanning ',DirList[udirx]+uname,' ... ');
 INC(SourceCount); SourceSize:=SourceSize+ref^.size;
 ref^.dirx:=udirx;
 NEW(up);
 WITH up^ DO
 BEGIN
  Name:='';
  next:=NIL;
 END;
 ASSIGN(F,DirList[udirx]+UName+'.PAS'); RESET(F);
 ch:=' ';
 GetSym;
 { collect the USES lists }
 WHILE NOT (sym IN [EOFSym,IntfSym,UsesSym]) DO GetSym;
 if sym=IntfSym then
 begin
  if verboose then WriteLn(stdout,'':(level+1),'interface uses:');
  GetSym;
  if sym=UsesSym then
   ParseUseList;
  WHILE NOT (sym IN [EOFSym,ImplSym]) DO GetSym;
  if sym=ImplSym then
  begin
   if verboose then WriteLn(stdout,'':(level+1),'implementation uses:');
   GetSym;
   if sym=UsesSym then
    ParseUseList;
  end;
 end
 else     { no INTERFACE }
 if sym=UsesSym then
 begin
  if verboose then WriteLn(stdout,'program uses:');
  ParseUseList;
 end;
 CLOSE(F);
 { Parse the files in pUseList recursively }
 ref^.pUseList:=up;
 p1:=up;
 WHILE (p1^.name<>'') DO
 BEGIN
  GetStructure(p1^.name,root,level);
  p1:=p1^.next;
 END;
END; { GetStructure }


PROCEDURE OutputStructure(r: tpNode);
var lc: WORD;
    line: string;

  PROCEDURE PrintStructure(r: tpNode);
  VAR p: tpUseNode;

    PROCEDURE PrintUseList(p: tpUseNode);
    VAR q: tpUseNode;
        empty: BOOLEAN;
    BEGIN
     q:=p;   empty:=TRUE;
     WHILE (q<>NIL) AND (q^.name<>'') DO
     BEGIN
      empty:=FALSE;
      IF length(line)>74 THEN
      BEGIN
       WriteLn(stdout,line);
       line:=AdStr(' ',16);
       INC(lc);
      END;
      line:=line+AdStr(q^.name,10);
      q:=q^.next;
     END;
     IF empty THEN
     BEGIN
      line:=line+'-';
     END;
    END; { PrintUseList }


  BEGIN { PrintStructure }
   IF r<>NIL THEN
   WITH r^ DO
   BEGIN
    PrintStructure(left);
    line:=AdStr(name,10)+' USES ';
    IF dirx<>0 THEN
     PrintUseList(pUseList)
    ELSE
     line:=line+'No PAS-file';
    WriteLn(stdout,line); line:='';
    INC(lc);
    PrintStructure(right)
   END;
  END; { PrintStructure }

BEGIN { OutputStructure }
 IF r=NIL THEN EXIT;
 lc:=0;
 line:='';
 PrintStructure(r);
END; { OutputStructure }


PROCEDURE DisposeStructure(VAR p: tpNode);

 PROCEDURE DisposeUseList(VAR u: tpUseNode);
 BEGIN
  IF u=NIL THEN EXIT;
  WHILE u^.next<>NIL DO DisposeUseList(u^.next);
  DISPOSE(u); u:=NIL;
 END;

BEGIN
 IF p=NIL THEN EXIT;
 IF p^.left<>NIL THEN DisposeStructure(p^.left);
 IF p^.right<>NIL THEN DisposeStructure(p^.right);
 DisposeUseList(p^.pUseList);
 Dispose(p); p:=NIL;
END; { DisposeStructure }

PROCEDURE ScanUnits(const SelPath: string);
VAR dir: DirStr;
    name: NameStr;
    ext: ExtStr;
    mdirx : word;
    dummy: LONGINT;
BEGIN
 fsplit(SelPath,dir,name,ext);
 EnterDir(dir);
 FindDir(Name,mdirx,dummy,dummy);
 if mdirx<>0 then
  GetStructure(Name,root,0)
 else
  WriteLn(stdout,'File not found');
 WriteLn(stdout,SourceCount,' PAS-File(s)');
 WriteLn(stdout,'Size: ',SourceSize DIV 1024,' KByte');
END; { ScanUnits }

var pcnt,i: word;
    options: string;
begin { main }
 if ParamCount<2 then
 begin
  WriteLn('bpxref dirs path[.pas] [units] [/v] [/p] [/x]');
  WriteLn('prints dependencies of Turbo Pascal units');
  WriteLn('by scanning the uses lists of the source files.');
  WriteLn('Output to stdout.');
  WriteLn('dirs    : file containing the dirs, separated by semicola');
  WriteLn('          example: \pas;\db;\graphic');
  WriteLn('path    : path of unit or program');
  WriteLn('units   : unit list, prints all units uses by the elements');
  WriteLn('/v      : verboose, prints scanning information');
  WriteLn('/x      : print x-reference list');
  WriteLn('/p      : print paths of all units');
  Writeln('Example : bpxref \bin\bpdirs.txt \db\myprog gbase hex /p > myprog.xrf');
 end
 else
 begin
  assign(stdout,''); rewrite(stdout);
  pcnt:=ParamCount;
  while pos('/',ParamStr(pcnt))>0 do dec(pcnt);
  options:='';
  for i:=pcnt+1 to ParamCount do
   options:=options+UpperCase(ParamStr(i));
  verboose:=pos('/V',options)>0;
  LoadDirList(ParamStr(1));
  if DirCnt=0 then WriteLn(stdout,'No DirList');
  verboose:=UpperCase(ParamStr(pcnt))='/V';
  if verboose then dec(pcnt);
  root:=nil;
  SourceSize:=0; SourceCount:=0;
  ScanUnits(UpperCase(ParamStr(2)));
  WriteLn(stdout,'Start-File: ',ParamStr(2));
  if pos('/X',options)>0 then OutputStructure(root);
  for i:=3 to pcnt do
   UsedBy(UpperCase(ParamStr(i)));
  if pos('/P',options)>0 then PrintPaths;
  DisposeStructure(root);
  close(stdout);
 end;
END.


