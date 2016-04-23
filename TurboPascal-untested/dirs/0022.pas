(* -------------------------------------------------------------- *)
(* FileSpec.PAS v1.0a by Robert Walking-Owl November 1993         *)
(* -------------------------------------------------------------- *)

{ Things to add...                                                 }
{ - have # and $ be symbols for ASCII chars in dec/hex?            }

(* Buggie Things:                                                 *)
(* - anti-sets don't work with variable lenght sets, since they   *)
(*   end with the first character NOT in the set...               *)

{$F+}

unit FileSpec;

interface

uses Dos;

const
  DosNameLen  = 12;     (* Maximum Length of DOS filenames        *)
  UnixNameLen = 32;     (* Maximum Length of Unix Filenames       *)

  MaxWildArgs = 32;     (* Maximum number of wildcard arguments   *)
  MaxNameLen  = 127;

  fCaseSensitive = $01; (* Case Sensitive Flag                    *)
  fExtendedWilds = $02; (* Use extented wildcard forms (not,sets  *)
  fUndocumented  = $80; (* Use DOS 'undocumented' filespecs       *)

type
  SpecList   = array [1..MaxWildArgs] of record
                   Name:  string[ MaxNameLen ];  (* or use DOS ParamStr?  *)
                   Truth: Boolean
                   end;
  PWildCard  = ^TWildCard;
  TWildCard  = object
                 private
                   FileSpecs: SpecList;     (* List of filespecs      *)
                   NumNegs,                 (* Number of "not" specs  *)
                   FSpCount:  word;         (* Total number of specs  *)
                   function StripQuotes( x: string ): string;
                   procedure   FileSplit(Path: string;
                                   var Dir,Name,Ext: string);
                 public
                   PathChar,                (* path seperation char   *)
                   NotChar,                 (* "not" char - init '~'  *)
                   QuoteChar:     Char;     (* quote char - init '"'  *)
                   Flags,                   (* Mode flags ...         *)
                   FileNameLen:   Byte;     (* MaxLength of FileNames *)
                   constructor Init;
                   procedure   AddSpec( name: string);
                   function    FitSpec( name: string): Boolean;
                   destructor  Done;
               (* Methods to RemoveSpec() or ChangeSpec() aren't added *)
               (* since for most applications they seem unnecessary.   *)
               (* An IsValid() spec to see if a specification is valid *)
               (* syntax is also unnecessary, since no harm is done,   *)
               (* and DOS and Unix ignore them anyway ....             *)
               end;


implementation

procedure UpCaseStr( var S: string); assembler;
asm
                PUSH    DS
                LDS     SI,S
                MOV     AL,BYTE PTR DS:[SI]
                XOR     CX,CX
                MOV     CL,AL
@STRINGLOOP:    INC     SI
                MOV     AL,BYTE PTR DS:[SI]
                CMP     AL,'a'
                JB      @NOTLOCASE
                CMP     AL,'z'
                JA      @NOTLOCASE
                SUB     AL,32
                MOV     BYTE PTR DS:[SI],AL
@NOTLOCASE:     LOOP    @STRINGLOOP
                POP     DS
end;


constructor TWildCard.Init;
begin
  FSpCount  := 0;
  NumNegs   := 0;
  NotChar   := '~';
  QuoteChar := '"';
  Flags := fExtendedWilds or fUndocumented;
  FileNameLen := DosNameLen;
  PathChar := '\';
end;

destructor TWildCard.Done;
begin
  FSpCount := 0
end;

function TWildCard.StripQuotes( x: string ): string;
begin
  if x<>''
    then if (x[1]=QuoteChar) and (x[length(x)]=QuoteChar)
      then StripQuotes := Copy(x,2,Length(x)-2)
      else StripQuotes := x
end;

procedure TWildCard.AddSpec( Name: string);
var
  Truth: Boolean;
begin
  if Name <> '' then begin
  Truth := True;
  if (Flags and fExtendedWilds)<>0
    then begin
      if Name[1]=NotChar
        then begin
          inc(NumNegs);
          Truth := False;
          Name  := Copy( Name , 2, Pred(Length(Name)) );
         end;
      Name := StripQuotes( Name );
    end;
  if (FSpCount<>MaxWildArgs) and (Name<>'')
    then begin
      inc( FSpCount );
      FileSpecs[ FSpCount ].Name := Name;
      FileSpecs[ FSpCount ].Truth := Truth
      end;
  end
end;

procedure TWildCard.FileSplit(Path: string; var Dir,Name,Ext: string);
var
  i,p,e: byte;
  InSet: Boolean;
begin
  p:=0;
  if (Flags and fCaseSensitive)=0
    then UpCaseStr(Path);
  for i:=1 to length(Path) do if Path[i]=PathChar then p:=i;
  i:=Length(Path);
  InSet := False;
  e := succ(length(Path));
  repeat
    if not Inset
       then case Path[i] of
              '.': e := i;
              ']',
              '}',
              ')': InSet := True;
            end
       else if Path[i] in ['[','{','('] then InSet := False;
    dec(i);
  until i=0;
  if p=0
    then Dir := ''
    else Dir := Copy(Path,1,p);
  Name := Copy(Path,Succ(p),pred(e-p));
  if e<=length(Path)
    then Ext := Copy(Path,e,succ(Length(Path)-e))
    else Ext := '';
end;

function TWildCard.FitSpec( name: string): Boolean;

procedure Puff(var x: string); (* Pad filename with spaces *)
begin
  while length(x)<FileNameLen do x:=x+' ';
end;


var x,b: set of char;
procedure GetSet(s: string; EndSet: char; var k: byte);
var
    c: char;
    u: string;
    i: byte;
    A: Boolean;
begin
  A := False;
  if s[k]=',' then repeat
      inc(k)
    until (k>=FileNameLen) or (s[k]=EndSet) or (s[k]<>',');
  u := '';
  if (k<FileNameLen) and (s[k]<>EndSet) then begin
    repeat
      u := u + s[k];
      inc(k);
    until (k>=FileNameLen) or (s[k]=EndSet) or (s[k]=',');
    if u<>'' then begin
      if u[1]=NotChar
        then begin
          A := True;
          u := Copy(u,2,pred(length(u)));
          end;
      u := StripQuotes(u);
      if (length(u)=3) and (u[2]='-')
        then begin
           for c := u[1] to u[3]
             do if A then b := b+[ c ]
                   else x := x+[ c ]
           end
        else begin
           for i:=1 to length(u)
             do if A then b := b+[ u[i] ]
                   else x:=x+[ u[i] ];
           end
    end;
  end;
end;

function Match(n,s: string): Boolean;  (* Does a field match? *)
var i,j,k: byte;
    c: char;
    T: Boolean;
    Scrap: string;
begin
  i := 1; (* index of filespec *)
  j := 1; (* index of name     *)
  T := True;
  Puff(n);
  Puff(s);
  repeat
    if s[i]='*' then i:=FileNameLen (* Abort *)
      else
         case s[i] of
         '(' : if ((Flags and fExtendedWilds)<>0) then begin
                 Scrap := '';
                 inc(i);
                 repeat
                   Scrap := Scrap + s[i];
                   inc(i);
                 until (i>=FileNameLen) or (s[i]=')');
                 Scrap := StripQuotes(Scrap);
                 if Pos(Scrap,Copy(n,j,Length(n)))=0
                   then T := False;
               end;
         '[' : if ((Flags and fExtendedWilds)<>0) then begin
                x := [];  b := [];
                k:=succ(i);
                repeat
                  GetSet(s,']',k);
                until (k>=FileNameLen) or (s[k]=']');
                i := k;
                if x=[] then FillChar(x,SizeOf(x),#255);
                x := x-b;
                if not (n[j] in x) then T := False;
               end;
          '{' : if ((Flags and fExtendedWilds)<>0) then begin
                  x := [];  b := [];
                  k:=succ(i);
                  repeat
                   GetSet(s,'}',k);
                  until (k>=FileNameLen) or (s[k]='}');
                  i := succ(k);
                  if x=[] then FillChar(x,SizeOf(x),#255);
                  x := x-b;
                  while (n[j] in x) and (j<=FileNameLen)
                    do inc(j);
               end;
       else if T and (s[i]<>'?')
          then if s[i]<>n[j] then  T := False;
       end;
    inc(i);
    inc(j);
  until (not T) or (s[i]='*') or (i>FileNameLen) or (j>FileNameLen);
  Match := T;
end;

var i,
    NumMatches : byte;
    dn,de,nn,ne,sn,se: string;
    Negate : Boolean;
begin
  Negate := False;
  if FSpCount=0 then NumMatches := 1
    else begin
      NumMatches := 0;
      for i:=1 to FSpCount
        do begin
          FileSplit(name,dn,nn,ne);
          FileSplit(FileSpecs[i].Name,de,sn,se);
            if ne='' then ne:='.   ';
          if (Flags and fUnDocumented)<>0 then begin
            if sn='' then sn:='*';
            if se='' then se:='.*';
            if dn='' then dn:='*';
            if de='' then de:='*';
          end;
          if (Match(dn,de) and Match(nn,sn) and Match(ne,se))
             then begin
               inc(NumMatches);
               if not FileSpecs[i].Truth
                  then Negate := True;
               end;
          end;
      end;
  if (NumNegs=FSpCount) and (NumMatches=0)
    then FitSpec := True
    else FitSpec := (NumMatches<>0) xor Negate;
end;


end.

{---------------------  DEMO ------------------------- }

(* Demo program to "test" the FileSpec unit                             *)
(* Checks to see if file matches filespec... good for testing/debugging *)
(* the FileSpec object/unit, as well as learning the syntax of FileSpec *)

program FileSpec_Test(input, output);
  uses FileSpec;
var p,                                       (* User-entered "filespec"  *)
    d:  String;                              (* Filename to "test"       *)
    FS: TWildCard;                           (* FileSpec Object          *)
begin
  FS.Init;                                   (* Initialize               *)
  WriteLn;
  Write('Enter filespec -> '); ReadLN(p);    (* Get filespec...          *)
  FS.AddSpec(p);                             (* ... Add Spec to list ... *)
  Write('Enter file -----> '); ReadLN(d);    (* ... Get Filename ...     *)
  if FS.FitSpec(d)                           (* Is the file in the list? *)
    then WriteLN('The files match.')
    else WriteLN('The files don''t match.');
  FS.Done;                                   (* Done... clean up etc.    *)
end.


FileSpec v1.0a
--------------

"FileSpec" is a public domain Turbo Pascal unit that gives you advanced,
Unix-like filespecs and wildcard-matching capabilities for your software.
This version should be compatible with Turbo Pascal v5.5 upwards (since
it uses OOP).

The advantage is that you can check to see if a filename is within the
specs a user has given--even multiple filespecs; thus utilities like
file-finders or archive-viewers can have multiple file-search specif-
ications.

To use, first initialize the TWildCard object (.Init).

You then use .AddSpec() to add the wildcards (e.g. user-specified) to the
list; and use .FitSpec() to see if a filename "fits" in that list.

When done, use the .Done destructor. (Check your TPascal manual if you do
not understand how to use objects).

"FileSpec" supports standard DOS wilcards (* and ?); also supported are the
undocumented DOS wildcards (eg. FILENAME = FILENAME.* and .EXT = *.EXT).

However, "FileSpec" supports many extended features which can make a program
many times more powerful.  Filenames or wildcards can be in quotes (eg. "*.*"
is equivalent to *.*).

Also supported are "not" (or "but") wildcards using the ~ character.  Thus
a hypothetical directory-lister with the argument ~*.TXT would list all
files _except_ those that match *.TXT.

Fixed and variable length "sets" are also supported:

[a-m]*.*           <- Any files beginning with letters A-M
[a-z,~ux]*.*       <- Any files beginning with a any letter except X or U
*.?[~q]?           <- Any files except those that match *.?Q?
foo[abc]*.*        <- Files of FOO?*.* where '?' is A,B or C
foo["abc"]*.*      <- Same as above.
foo[a-c]*.*        <- Same as above.
test{0-9}.*        <- Files of TEST0.* through TEST9999.*
x{}z.*             <- Filenames beginning with X and ending with Z
x{0123456789}z.*   <- Same as above, only with numbers between X and Z.
("read")*.*        <- Filenames that contain the text "READ"

If this seems confusing, use the FS-TEST.PAS program included with this
archive to experiment and learn the syntax used by "FileSpec".

Playing around with the included demos (LS.PAS, a directory lister; and
XFIND, a file-finder) will also give you an idea how to use the FileSpecs
unit.

One Note: if you use the FileSpec unit with your software, please let users
know about it in the documentation, so that they know they can take full
advantage of the added features.

