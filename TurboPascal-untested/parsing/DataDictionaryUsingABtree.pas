(*
  Category: SWAG Title: PARSING/TOKENIZING ROUTINES
  Original name: 0010.PAS
  Description: Data Dictionary using a BTree
  Author: UNKNOWN
  Date: 05-31-96  09:16
*)

program Dict;
(* simple dictionary using a btree.
  The program reads in an ASCII file with one word per line and stores the
  words in an btree. A btree is something like binary tree but every node
  can have more than two descent nodes. This is done by linked list.

  This method has two advantages:
    * when a word is wrong you can easily give some proposes how the word
      is written correctly (just change the path in the tree a little)
    * bigger dict. may save space. E.g "base, basicly, basement" etc.
      share the same path on the first three niveaus.

  ATTENTION! I don't free any mem I've allocated. This is done by the
  heap manager (i.e. he allocates large blockes and releases them } when
  the program ends. But this can be added easily.

  Also, there is no function included that deletes words (I don't need it in
  my project). I suggest it is not that easy to add such a function but
  have a try ;-))

*)

{ $DEFINE DEBUG} { if DEBUG is defined (just erase space between "{" and "$")
                   then some actions are logged while building the tree and
                   while searching. }

const debugfile = 'dict.log';     { log file (if needed) }
      dictFileName = 'dict.dat';  { data input (words in ASCII) }

type  PNode     = ^TNode;
      TNode     = record
                    Character : Char;    { the current character }
                    WordEnd   : Boolean; { is this char. the last of one word?}
                    right,down: PNode;   { right: points to next char on the
                                                  same niveau
                                           down : points to the next char in
                                                  word }
{$IFDEF DEBUG}
                    Level     : byte;    { level of the tree }
{$ENDIF }
                  end;

var BTree: PNode;                       { our tree }
    DictFile: Text;                     { our ascii dictionary }
{$IFDEF DEBUG}
var f: Text;                            { log file handle }
{$ENDIF }


procedure CreateBTree;
{ just initalizes the tree w/ a dummy element }
begin
  Btree:=NIL;
  New(Btree);
  BTree^.character:=#$1A; { #$1A is END-OF-FILE. shouldn't be used in any word }
  BTree^.right:=NIL;
  Btree^.down:=NIL;
  BTree^.Wordend:=true;
{$IFDEF DEBUG}
  BTree^.level:=1;
  writeln(f,'B-Tree with dummy element created.');
{$ENDIF }
end;

{$IFDEF DEBUG}
function GetNode(Character: Char; LevelPtr: PNode; Level: byte): PNode;
{$ELSE }
function GetNode(Character: Char; LevelPtr: PNode): PNode;
{$ENDIF }
{ returns the node in Level "LevelPtr" that contains "Character".
  if there is no node, it is created }
var p: PNode;
begin
  if levelptr=NIL then begin
    New(P);
    P^.right:=NIL;
    P^.down:=NIL;
    P^.character:=character;
    P^.WordEnd:=False;
{$IFDEF DEBUG}
    P^.Level:=Level;
    writeln(f,'#New niveau-node enterd. Content of the first node: '+
            ' "',character,'". Level ',level);
{$ENDIF }
    GetNode:=p;
  end else begin
    p:=levelptr;
    while (p^.right<>NIL) and (p^.character<>Character) do p:=p^.right;
    if p^.character=character then
    begin
      getnode:=p;
{$IFDEF DEBUG}
      writeln(f,'Node "',character,'" found on level ',level,'.');
{$ENDIF }
    end
      else begin
        { p^.right is NIL! }
        new(p^.right);
        p:=p^.right;
        p^.character:=character;
        p^.right:=NIL;
        p^.down:=nil;
        p^.wordend:=false;
{$IFDEF DEBUG}
        p^.level:=level;
        writeln(f,'#Entered new node. Content "',character,'". Level ',level);
{$ENDIF }
        GetNode:=p;
      end; {if}
  end; { if }
end;

procedure InsertWord(wort: string);
{ inserts the word "wort" into btree }
var p1,p2,p3: PNode;
    i: byte;
begin
  if wort='' then exit;
  p2:=btree;
  for i:=1 to length(wort) do
  begin
{$IFDEF DEBUG}
    p1:=getnode(wort[i],p2,i);
{$ELSE}
    p1:=getnode(wort[i],p2);
{$ENDIF}
    if p2=NIL then p3^.down:=p1;
    p3:=p1;
    p2:=p1^.down;
  end;
  p1^.wordend:=true;
{$IFDEF DEBUG}
  writeln(f,'Wort "',wort,'" eingetragen.');
{$ENDIF }
end;

function ProofWord(Wort: string): boolean;
{ returns true if "wort" is in our dictionary }
var P1,p2: PNode;
    I: Byte;
begin
  ProofWord:=FALSE;
  if wort='' then exit;
  p1:=BTree;
  i:=1;
{$IFDEF DEBUG}
  writeln(f,'Searching for word "',wort,'".');
{$ENDIF }
  while (p1<>NIL) and (length(wort)>=i) do begin
    while (p1^.right<>NIL) and (p1^.character<>wort[i]) do p1:=p1^.right;
    if p1^.character=wort[i] then begin
      inc(i);
      p2:=p1;
      p1:=p1^.down;
{$IFDEF DEBUG}
      writeln(f,'Character "',wort[i-1],'" found on level ',i-1,'.');
{$ENDIF }
    end else p1:=NIL;
  end;
  if (i=length(wort)+1) and (p2^.wordend) then proofword:=TRUE;
end;


var OldExitProcPtr: Pointer;

procedure MyExitProc;far;
begin
  ExitProc:=OldExitProcPtr;
  if exitcode = 214 then writeln('Huston! We''ve got a pointer problem!');
{$IFDEF DEBUG}
  close(f);
{$ENDIF }
end;

var s: String;

begin
  OldExitProcPtr:=ExitProc;
  ExitProc:=@MyExitProc;
  {$IFDEF DEBUG}
  assign(f,debugfile);
  rewrite(f);
  {$ENDIF }
  assign(dictfile,dictfilename);
  createBTree;
  reset(dictfile);
  write('Reading dictionary...');
  while not eof(dictfile) do
  begin
    readln(dictfile,s);
    insertword(s);
  end;
  writeln('done.');
  writeln('Request mode. End with "END"!');
  s:='';
  repeat
    write('OK>');
    readln(s);
    if s<>'END' then
      if proofword(s) then writeln('Word found!',#7)
                      else writeln('Word not fond!');

  until s='END';
  {$IFDEF DEBUG}
  close(f);
  {$ENDIF }
  ExitProc:=OldExitProcPtr;
end.=====================Code ends===============================

