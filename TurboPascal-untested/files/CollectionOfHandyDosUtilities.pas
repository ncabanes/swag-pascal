(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0108.PAS
  Description: Collection of handy DOS utilities
  Author: KITO MANN
  Date: 08-30-97  10:09
*)

{$A+,B-,D+,E-,F+,I-,L+,N-,O+,R-,S+,V-}

Unit CWare;

(* Version 1.1 - CollisionWare Premium SoftWare - Compiled by Kito Mann *)
(* This unit is a simple collection of some some procedures aquired     *)
(* from other programs and myself. New versions will have added         *)
(* procedures, and the present ones will be improved. Comments, bugs,   *)
(* and questions accepted.                                              *)
(* Keep in mind that there is NO WARANTY! It IS NOT GAURANTEED that all *)
(* these procedures will work!                                          *)
(* If you modify the procedures included, or add your own, I request    *)
(* that you send me a copy of the new unit and source code.             *)

(* It'd probably be helpful if you declare ErrorCode: byte in your main *)
(* program. It is used as an Error variable much like the DosError used *)
(* in the DOS unit.                                                     *)

(* The Collision Theory pm-BBS *)
(*         24 hours            *)
(*      (703)503-9441          * <--- NUMBER AND HOUR CHANGE! *)
(*         Burke, VA           *)
(* "Dedicated to Intelligent   *)
(*        Conversation"        *)

INTERFACE

Uses Crt,
     Dos;

const
  MaxDirEnteries=       20;    { Maximum number of directories that can be specified to search }
                               { This doesn't include those searched "below" ones specified.   }

type
  FullNameStr=          string[12];                 { Type for storing name+dot+extention                                 }
  DirSearchEntry=       record                      { This data type is used to store all the paths that will be searched }
                          Dir:         DirStr;      {   <-- Path to search                                                }
                          Name:        FullNameStr; {   <-- File spec to search                                           }
                          Below:       boolean;     {   <-- TRUE=search directories below the specified one               }
                        end;
  ProcType=             procedure(var S: SearchRec; P: PathStr);
  AnyStr=               string[255];


var
  EngineMask:           FullNameStr;
  EngineAttr:           byte;
  EngineProc:           ProcType;
  EngineCode:           byte;

  Reg:                  Registers;   { Register storage for DOS calls }
  OldSeg,OldOfs:        word;
  BufData:              longint;
  BufferSeg:            word;
  BufferOfs:            word;
  BufferLen:            word;
  BufferPtr:            pointer;
  T:                    text;
  P:                    PathStr;


(* File and Keyboard Buffer procedures *)

function FileFound(F: ComStr): boolean;

procedure SearchEngine(Mask: PathStr; Attr: byte; Proc: ProcType; var ErrorCode: byte);

function GoodDirectory(S: SearchRec): boolean;

procedure SearchOneDir(var S: SearchRec; P: PathStr);

procedure SearchEngineAll(Path: PathStr; Mask: FullNameStr; Attr: byte;
                          Proc: ProcType; var ErrorCode: byte);

procedure IPP;

procedure NewExitProc2;

procedure ResetBuffer;

function BufSize: word;

function InBuffer(S: string): integer;

procedure InstallInterruptHandler;

procedure DeleteFiles(P: string);

procedure DeleteDir(P:string);

procedure ListFiles(P: string; complete:boolean; pausenum:integer);

(* Misc. String procedures *)

function DateString: string;

function TimeString: string;

procedure Tab(s1,s2:AnyStr; i:integer);

Function UpCaseString(StrIn : String) : String;
{ Convert a string to upper case }

Function PathOnly(FileName : String) : String;
{ Strip any filename information from a file specification }

Function NameOnly(FileName : String) : String;
{ Strip any path information from a file specification }

Function BaseNameOnly(FileName : String) : String;
{ Strip any path and extension information from a file specification }

Function ExtOnly(FileName : String) : String;
{ Return only the extension portion of a filename }

Function IntStr(Int : LongInt; Form : Integer) : String;
{ Convert an Integer variable to a string }

Function Strr(Int:LongInt) : String;
{ Same as IntStr but does not use the variable "Form" }

Function SameFile(File1, File2 : String) : Boolean;
{ Call to find out if File1 has a name equivalent to File2.  Both filespecs }
{ may contain wildcards.                                                    }


IMPLEMENTATION

{ -------------------------------------------------------------------------- }

function FileFound(F: ComStr): boolean;
{
  This returns TRUE if the file F exists, FALSE otherwise.  F can contain
  wildcard characters.
}
var
  SRec:                 SearchRec;
begin
  SRec.Name := '*';
  FindFirst(F,0,SRec);
  if SRec.Name='*' then FileFound := false else FileFound := true;
end;


(********* The following search engine routines are sneakly swiped *********)
(********* from Turbo Technix v1n6.  See there for further details *********)

procedure SearchEngine(Mask: PathStr; Attr: byte; Proc: ProcType;
                       var ErrorCode: byte);
var
  S:                    SearchRec;
  P:                    PathStr;
  Ext:                  ExtStr;
begin
  FSplit(Mask, P, Mask, Ext);
  Mask := Mask+Ext;
  FindFirst(P+Mask,Attr,S);
  if DosError<>0 then
  begin
    ErrorCode := DosError;
    exit;
  end;
  while DosError=0 do
  begin
    Proc(S, P);
    FindNext(S);
  end;
  if DosError=18 then ErrorCode := 0
  else ErrorCode := DosError;
end;

{ -------------------------------------------------------------------------- }

function GoodDirectory(S: SearchRec): boolean;
begin
  GoodDirectory := (S.name<>'.') and (S.Name<>'..') and
  (S.Attr and Directory=Directory);
end;

{ -------------------------------------------------------------------------- }

procedure SearchOneDir(var S: SearchRec; P: PathStr);
begin
  if GoodDirectory(S) then
  begin
    P := P+S.Name;
    SearchEngine(P+'\'+EngineMask,EngineAttr,EngineProc,EngineCode);
    SearchEngine(P+'\*.*',Directory or Archive, SearchOneDir,EngineCode);
  end;
end;

{ -------------------------------------------------------------------------- }

procedure SearchEngineAll(Path: PathStr; Mask: FullNameStr; Attr: byte;
                          Proc: ProcType; var ErrorCode: byte);
begin
  EngineMask := Mask;
  EngineProc := Proc;
  EngineAttr := Attr;
  SearchEngine(Path+Mask,Attr,Proc,ErrorCode);
  SearchEngine(Path+'*.*',Directory or Archive,SearchOneDir,ErrorCode);
  ErrorCode := EngineCode;
end;

(************** Thus ends the sneakly swiped code *************)

{ -------------------------------------------------------------------------- }

procedure IPP;
{ Interrupt pre-processor.  This is a new handler for interrupt 29h which
  provides special functions.  See comments in IHAND.ASM}
begin
  InLine(
      $06/                   {          push    es                      }
      $1E/                   {          push    ds                      }
      $53/                   {          push    bx                      }
      $57/                   {          push    di                      }
      $BB/$3F/$3F/           {          mov     bx, 3f3fh               }
      $8E/$C3/               {          mov     es, bx                  }
      $BB/$3F/$3F/           {          mov     bx, 3f3fh               }
      $26/$8B/$3F/           {          mov     di, word ptr [es:bx]    }
      $26/$8E/$5F/$02/       {          mov     ds, word ptr [es:bx+2]  }
      $88/$05/               {          mov     byte ptr [di], al       }
      $26/$FF/$07/           {          inc     word ptr [es:bx]        }
      $5F/                   {          pop     di                      }
      $5B/                   {          pop     bx                      }
      $1F/                   {          pop     ds                      }
      $07/                   {          pop     es                      }
      $3C/$0A/               {          cmp     al, 10                  }
      $75/$28/               {          jne     looper                  }
      $50/                   {          push    ax                      }
      $52/                   {          push    dx                      }
      $51/                   {          push    cx                      }
      $53/                   {          push    bx                      }
      $B4/$03/               {          mov     ah, 3                   }
      $B7/$00/               {          mov     bh, 0                   }
      $CD/$10/               {          int     10h                     }
      $80/$FE/$18/           {          cmp     dh, 24                  }
      $75/$15/               {          jne     popper                  }
      $FE/$CE/               {          dec     dh                      }
      $B7/$00/               {          mov     bh, 0                   }
      $B4/$02/               {          mov     ah, 2                   }
      $CD/$10/               {          int     10h                     }
      $B8/$01/$06/           {          mov     ax, 0601h               }
      $B7/$07/               {          mov     bh, 7                   }
      $B9/$00/$11/           {          mov     cx, 1100h               }
      $BA/$4F/$18/           {          mov     dx, 184fh               }
      $CD/$10/               {          int     10h                     }
      $5B/                   {  popper: pop     bx                      }
      $59/                   {          pop     cx                      }
      $5A/                   {          pop     dx                      }
      $58/                   {          pop     ax                      }
      $9C/                   {  looper: pushf                           }
      $9A/$00/$00/$00/$00/   {          call    far [0:0]               }
      $CF);                  {          iret                            }
end;

{ -------------------------------------------------------------------------- }

procedure NewExitProc2;
{ This exit procedure removes the interrupt 29h handler from memory and places
  the cursor at the bottom of the screen. }
begin
  Reg.AH := $25;
  Reg.AL := $29;
  Reg.DS := OldSeg;
  Reg.DX := OldOfs;
  MsDos(Reg);
  Window(1,1,80,25);
  GotoXY(1,24);
  TextAttr := $07;
  ClrEol;
end;

{ -------------------------------------------------------------------------- }

procedure ResetBuffer;
{ Reset pointers to the text buffer, effectivly deleting any text in it }
begin
  MemW[seg(BufData):ofs(BufData)] := BufferOfs;    { Set first 2 bytes of BufData to point to buffer offset }
  MemW[seg(BufData):ofs(BufData)+2] := BufferSeg;  { And next two bytes to point to buffer segment }
  MemW[seg(IPP):ofs(IPP)+21] := seg(BufData);    { Now point the interrupt routine to BufData for pointer }
  MemW[seg(IPP):ofs(IPP)+26] := ofs(BufData);    {  to the text buffer }
end;

{ -------------------------------------------------------------------------- }

function BufSize: word;
{ This returns the number of characters in the text buffer.  It's what BufData
  now points to minus what is origionally pointed to, eg, the number of times
  IPP incremented it }
begin
  BufSize := MemW[seg(BufData):ofs(BufData)]-BufferOfs;
end;

{ -------------------------------------------------------------------------- }

function InBuffer(S: string): integer;
{ This searched the text buffer for the string S, and if it's found returns
  the offset in the buffer.  If it's not found a -1 is returned }
var
  L,M:                  word;
  X:                    byte;
begin
  X := 1;
  L := BufferOfs;
  M := BufSize;
  while (X<=length(S)) and (L<=M) do
  begin
    if Mem[BufferSeg:L]=byte(S[X]) then Inc(X) else X := 1;
    Inc(L);
  end;
  if X>length(S) then InBuffer := L-length(S) else InBuffer := -1;
end;

{ -------------------------------------------------------------------------- }

procedure InstallInterruptHandler;
{ Installs the int 29h handler }
begin
  BufferLen := $4000;  { Set up a 16k buffer }
  GetMem(BufferPtr,BufferLen);  { Allocate memory pointed at by BufferPtr }
  BufferSeg := seg(BufferPtr^);  { Read segment and offset of buffer for easy access }
  BufferOfs := ofs(BufferPtr^);
  ResetBuffer;    { Place these values in the IPP routine, resetting buffer }
  Reg.AH := $35;
  Reg.AL := $29;  { DOS service 35h, get interrupt vector for 29h }
  MsDos(Reg);
  OldSeg := Reg.ES;   { Store the segment and offset of the old vector for later use }
  OldOfs := Reg.BX;
  MemW[seg(IPP):ofs(IPP)+90] := Reg.BX;  { And store them so IPP can call the routine }
  MemW[seg(IPP):ofs(IPP)+92] := Reg.ES;
  Reg.AL := $29; { DOS service 25h, set interrupt vector 29h }
  Reg.AH := $25;
  Reg.DS := seg(IPP);    { Store segment and offset for IPP.  The +16 is to skip TP stack }
  Reg.DX := ofs(IPP)+16; { maintainence routines }
  MsDos(Reg);
end;

{ -------------------------------------------------------------------------- }

  procedure DeleteFiles(P: string);
  {
    Delete all files in the directory named, including
    Hidden, Read-only, System and other file types.
  }
  var
    SRec:               SearchRec;
    ErrorCode:          byte;
  begin
    FindFirst(P+'\*.*',0,SRec);
    while DosError=0 do
    begin
      Assign(T, P+'\'+SRec.Name);
      SetFAttr(T,Archive);
      writeln('Deleting ',P,+'\'+Srec.Name);
      {$I-}
      Erase(T);
      {$I+}
      ErrorCode := IOResult;
      FindNext(SRec);
    end;
    ErrorCode := IOResult;
end;

{ -------------------------------------------------------------------------- }

procedure DeleteDir(P:string);

{ Simply deletes specified directory }

var ErrorCode: byte;
begin
  DeleteFiles(P);
  {$I-}
  RmDir(P);
  {$I+}
  ErrorCode := IOResult;
end;

{ -------------------------------------------------------------------------- }

procedure ListFiles(P: string; complete:boolean; pausenum:integer);
  {
   If complete is true then will show the name and file size of every
   file. Otherwise will just show the filename. Numlines is the number
   of files it will display before a pause. 0 means no pause.
  }
  var
    SRec:               SearchRec;
    ErrorCode:          byte;
    Size:               AnyStr;
    Index:              integer;
    TheChar:            char;
    Quit:               boolean;

  begin
    Quit:=false;
    FindFirst(P+'\*.*',0,SRec);
    Index:=1;
    while DosError=0 do
    begin
       if Index=pausenum then 
       begin
        write('[Q=quit, ANY KEY=continue]:');
        TheChar:=UpCase(ReadKey); writeln(TheChar);
        if TheChar='Q' then quit:=true;
        writeln;
        Index:=0;
       end;
      if NOT Quit then 
      if complete then begin
        Size:=strr(Srec.Size);
        tab(Srec.Name,Size,15);
        writeln;
      end else
      writeln(Srec.Name);
      FindNext(SRec);
      Inc(Index);
    end;
    ErrorCode := IOResult;
end;

{ -------------------------------------------------------------------------- }

  function DateString: string;
  {
    Returns the current date in a string of the form:  MON ## YEAR.
    E.g, 21 Feb 1989 or 02 Jan 1988.
  }
  const
    Month:              array[1..12] of string[3]=
                        ('Jan','Feb','Mar','Apr','May','Jun',
                         'Jul','Aug','Sep','Oct','Nov','Dec');
  var
    Y,M,D,Junk:         word;
    DS,YS:              string[5];
  begin
    GetDate(Y,M,D,Junk);
    Str(Y,YS);
    Str(D,DS);
    if length(DS)<2 then DS := '0'+DS;
    DateString := DS+' '+Month[M]+' '+YS;
  end;

{ -------------------------------------------------------------------------- }

  function TimeString: string;
  {
    Returns the current time in the form:  HH:MM am/pm
    E.g, 12:00 am or 09:12 pm.
  }
  var
    H,M,Junk:           word;
    HS,MS:              string[5];
    Am:                 boolean;
  begin
    GetTime(H,M,Junk,Junk);
    case H of
      0:     begin
               Am := true;
               H := 12;
             end;
      1..11: Am := true;
      12:    Am := false;
      else   begin
               Am := false;
               H := H-12;
             end;
    end;
    Str(H,HS);
    Str(M,MS);
    if length(HS)<2 then HS := '0'+HS;
    if length(MS)<2 then MS := '0'+MS;
    if Am then TimeString := HS+':'+MS+' am'
    else TimeString := HS+':'+MS+' pm';
  end;

{ -------------------------------------------------------------------------- }

procedure Tab(s1,s2:AnyStr; i:integer);

{ Writes s1, then goes to i-length(s1) and writes s2 }

var j,k:integer;
begin
  j:=length(s1);
  i:=i-j;
  write(s1);
  for k:=1 to i do write(' ');
  write(s2);
end;

{ -------------------------------------------------------------------------- }

Function UpCaseString(StrIn : String) : String;
Begin
   Inline(                   { Thanks to Phil Burns for this routine }

      $1E/                   {         PUSH    DS                ; Save DS}
      $C5/$76/$06/           {         LDS     SI,[BP+6]         ; Get source string address}
      $C4/$7E/$0A/           {         LES     DI,[BP+10]        ; Get result string address}
      $FC/                   {         CLD                       ; Forward direction for strings}
      $AC/                   {         LODSB                     ; Get length of source string}
      $AA/                   {         STOSB                     ; Copy to result string}
      $30/$ED/               {         XOR     CH,CH}
      $88/$C1/               {         MOV     CL,AL             ; Move string length to CL}
      $E3/$0E/               {         JCXZ    Exit              ; Skip if null string}
                             {;}
      $AC/                   {UpCase1: LODSB                     ; Get next source character}
      $3C/$61/               {         CMP     AL,'a'            ; Check if lower-case letter}
      $72/$06/               {         JB      UpCase2}
      $3C/$7A/               {         CMP     AL,'z'}
      $77/$02/               {         JA      UpCase2}
      $2C/$20/               {         SUB     AL,'a'-'A'        ; Convert to uppercase}
                             {;}
      $AA/                   {UpCase2: STOSB                     ; Store in result}
      $E2/$F2/               {         LOOP    UpCase1}
                             {;}
      $1F);                  {Exit:    POP     DS                ; Restore DS}

end {UpCaseString};

{ -------------------------------------------------------------------------- }

Function PathOnly(FileName : String) : String;
Var
   Dir  : DirStr;
   Name : NameStr;
   Ext  : ExtStr;
Begin
   FSplit(FileName, Dir, Name, Ext);
   PathOnly := Dir;
End {PathOnly};

{ --------------------------------------------------------------------------- }

Function NameOnly(FileName : String) : String;
{ Strip any path information from a file specification }
Var
   Dir  : DirStr;
   Name : NameStr;
   Ext  : ExtStr;
Begin
   FSplit(FileName, Dir, Name, Ext);
   NameOnly := Name + Ext;
End {NameOnly};

{ --------------------------------------------------------------------------- }

Function BaseNameOnly(FileName : String) : String;
{ Strip any path and extension from a file specification }
Var
   Dir  : DirStr;
   Name : NameStr;
   Ext  : ExtStr;
Begin
   FSplit(FileName, Dir, Name, Ext);
   BaseNameOnly := Name;
End {BaseNameOnly};

{ --------------------------------------------------------------------------- }

Function ExtOnly(FileName : String) : String;
{ Strip the path and name from a file specification.  Return only the }
{ filename extension.                                                 }
Var
   Dir  : DirStr;
   Name : NameStr;
   Ext  : ExtStr;
Begin
   FSplit(FileName, Dir, Name, Ext);
   If Pos('.', Ext) <> 0 then
      Delete(Ext, 1, 1);
   ExtOnly := Ext;
End {ExtOnly};

{ --------------------------------------------------------------------------- }

Function IntStr(Int : LongInt; Form : Integer) : String;
Var
   S : String;
Begin
   If Form = 0 then
      Str(Int, S)
   else
      Str(Int:Form, S);
   IntStr := S;
End {IntStr};

{ --------------------------------------------------------------------------- }

Function Strr(Int : LongInt) : String; { Added for my own sake - KM }
Var
   S : String;
Begin
   Str(Int, S);
   Strr := S;
End {Strr};

{ --------------------------------------------------------------------------- }

Function SameName(N1, N2 : String) : Boolean;
{
  Function to compare filespecs.

  Wildcards allowed in either name.
  Filenames should be compared seperately from filename extensions by using
     seperate calls to this function
        e.g.  FName1.Ex1
              FName2.Ex2
              are they the same?
              they are if SameName(FName1, FName2) AND SameName(Ex1, Ex2)

  Wildcards work the way DOS should've let them work (eg. *XX.DAT doesn't
  match just any file...only those with 'XX' as the last two characters of
  the name portion and 'DAT' as the extension).

  This routine calls itself recursively to resolve wildcard matches.

}
Var
   P1, P2 : Integer;
   Match  : Boolean;
Begin
   P1    := 1;
   P2    := 1;
   Match := TRUE;

   If (Length(N1) = 0) and (Length(N2) = 0) then
      Match := True
   else
      If Length(N1) = 0 then
         If N2[1] = '*' then
            Match := TRUE
         else
            Match := FALSE
      else
         If Length(N2) = 0 then
            If N1[1] = '*' then
               Match := TRUE
            else
               Match := FALSE;

   While (Match = TRUE) and (P1 <= Length(N1)) and (P2 <= Length(N2)) do
      If (N1[P1] = '?') or (N2[P2] = '?') then begin
         Inc(P1);
         Inc(P2);
      end {then}
      else
         If N1[P1] = '*' then begin
            Inc(P1);
            If P1 <= Length(N1) then begin
               While (P2 <= Length(N2)) and Not SameName(Copy(N1,P1,Length(N1)-P1+1), Copy(N2,P2,Length(N2)-P2+1)) do
                  Inc(P2);
               If P2 > Length(N2) then
                  Match := FALSE
               else begin
                  P1 := Succ(Length(N1));
                  P2 := Succ(Length(N2));
               end {if};
            end {then}
            else
               P2 := Succ(Length(N2));
         end {then}
         else
            If N2[P2] = '*' then begin
               Inc(P2);
               If P2 <= Length(N2) then begin
                  While (P1 <= Length(N1)) and Not SameName(Copy(N1,P1,Length(N1)-P1+1), Copy(N2,P2,Length(N2)-P2+1)) do
                     Inc(P1);
                  If P1 > Length(N1) then
                     Match := FALSE
                  else begin
                     P1 := Succ(Length(N1));
                     P2 := Succ(Length(N2));
                  end {if};
               end {then}
               else
                  P1 := Succ(Length(N1));
            end {then}
            else
               If UpCase(N1[P1]) = UpCase(N2[P2]) then begin
                  Inc(P1);
                  Inc(P2);
               end {then}
               else
                  Match := FALSE;

   If P1 > Length(N1) then begin
      While (P2 <= Length(N2)) and (N2[P2] = '*') do
         Inc(P2);
      If P2 <= Length(N2) then
         Match := FALSE;
   end {if};

   If P2 > Length(N2) then begin
      While (P1 <= Length(N1)) and (N1[P1] = '*') do
         Inc(P1);
      If P1 <= Length(N1) then
         Match := FALSE;
   end {if};

   SameName := Match;

End {SameName};

{ ---------------------------------------------------------------------------- }

Function SameFile(File1, File2 : String) : Boolean;
Var
   Path1, Path2 : String;
Begin

   File1 := FExpand(File1);
   File2 := FExpand(File2);
   Path1 := PathOnly(File1);
   Path2 := PathOnly(File2);

   SameFile := SameName(BaseNameOnly(File1), BaseNameOnly(File2)) AND
               SameName(ExtOnly(File1), ExtOnly(File2))           AND
               (Path1 = Path2);

End {SameFile};

{ ---------------------------------------------------------------------------- }

End {Unit CWARE}.
