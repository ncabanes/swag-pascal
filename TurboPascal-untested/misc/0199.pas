Unit Usefull;

{ Copyright (C) 1995 by Tobin T. Fricke, All Rights Reserved            }
{ Use this and have fun, but tell me first.  BBS 714-586-6142           }
{ Make sure to mention that you used this in your documentation of your }
{ program(s) if you do use it.  Thanks.                                 }
{ I didn't write all of the routines, but I wrote most of them.         }

{ If you use this, I'd appreciate it if you could send me a postcard    }
{ from where you live, or at least send me an email.  My email address  }
{ is tobin@mail.edm.net.  If that doesn't work, try using               }
{ fricke@roboben.engr.ucdavis.edu.  My postal address is:               }
{ 25001 El Cortijo Ln., Mission Viejo, CA 92691-5236, USA.  Thanks!     }

{ Updated May 1995 }

Interface

{$IFDEF WINDOWS}
type
    { Date & time recored used by PackTime }
    { and UnpackTime }
  DateTime = record
    Year,Month,Day,Hour,Min,Sec: Word;
  end;
{$ENDIF}

 Type MIDRecord = Record
     InfoLevel : Word;
     SerialNum : LongInt;   {This is the serial number...}
     VolLabel  : Array[1..11] of Char;
     FatType   : Array[1..8] of Char;
     End;

{$IFNDEF OS2} Function Label_Fat(Var Mid : MidRecord; Drive : Word) : Boolean;
{$ENDIF}
Function LongToHex(L:Longint):String;
Function  Center(S:String; B:Byte):String;
{Center returns a S, centered with spaces, of length B }
Function  Left(S:String; B:Byte):String;
{ returns a Left-Justied string, length B              }
Function  PadRight(S:String; B:Byte; C:Char):String;
{ returns S padded with B of C on the Right            }
Function  Right(S:String; B:Byte):String;
{ same as Left, but right-justifies                    }
function  FileExists(FileName: String): Boolean;
{ does Filename Exist?                                 }
Function  UpString(S:String):String;
{ Returns S in upper case                              }
Function  LoString(S:String):String;
{ Returns S in lower case                              }
Function  LoCase(C:Char):Char;
{ Returns C in lower case                              }
Function  Str(X:integer):String;
{ Converts X to a string                               }
Function  Strw(X:Word):String;
{ Convert a Word to a String                           }
Function  Strl(X:LongInt):String;
Function  StrR(X:Real):String;
Function  WhatDir:String;
Function  Val(S:String):Integer;
Function  ValW(S:String):Word;
Function  ValL(S:String):longint;
Function  Rep(S:String; C:Word):String;
Function  TempFile( Path: STRING ): STRING;
Function  SizeOfFile(S:String):LongInt;
Function  NameCaps(S:String):String;
{ Capitalize The First Letter Of Each Word             }
Function  Del(S:String; Index: Integer; Count:Integer):String;
{ Delete, but as a function                            }
Function  Strip_(S:String):String;
{ Changes _'s to spaces                                }
Function  ActualFileSize:LongInt;
{ How big is your EXE?                                 }
Procedure Lines(S:String);
Procedure Lines50;              { Go into 50 lines-mode}
Procedure Lines25;
Procedure Lines35;
{$IFNDEF OS2}
Function  NetworkDrive(Drive:Char):Boolean;
{$ENDIF}
Function  StrBool(S:String):Boolean;
Procedure SwapStr(Var A,B:String);
{ Swaps A and B:  C=A; A=B; B=C; }
Procedure ConvertBase(BaseN:Byte; BaseNNumber:String;
                                  BaseZ:Byte; var BaseZNumber:String);
{ Converts base 2-36 to base 2-36                                  }
Function WordWrap(S:String; Var Remainder:String; Len:Byte):String;
{ Tobin's wonder-word-wrap.                                        }
Function AN(S:String):String;
{ prepends "a " or "an " to S, based on the first letter }
Function LastDrive: Char;

var UError:Word;

Implementation


{$IFDEF WINDOWS}
Uses WinCRT, WinDOS;
{$ELSE}
Uses CRT, DOS;
{$ENDIF}

{$IFNDEF OS2}
Function Label_Fat(Var Mid : MidRecord; Drive : Word) : Boolean;
Var Result : Word;
Var Regs   : Registers;
Begin
     FillChar(Mid,SizeOf(Mid),0);
     FillChar(Regs,SizeOf(Regs),0);
     With Regs DO
     Begin
          AX := $440D;
          BX := Drive;
          CX := $0866;
          DS := Seg(Mid);
          DX := Ofs(Mid);
          Intr($21,Regs);
          Case AX of
               $01 : Label_Fat := False;
               $02 : Label_Fat := False;
               $05 : Label_Fat := False;
               Else Label_Fat := True;
          End;
     End;
End;
{$ENDIF}
(*
Var Mid : MidRecord;
Begin
     ClrScr;
     If Label_Fat(Mid,0) Then
     With Mid DO
     Begin
          Writeln(SerialNum);
          Writeln(VolLabel);
          Writeln(FatType);
     End
     Else Writeln('Error Occured');
End.
*)

Procedure ConvertBase(BaseN:Byte; BaseNNumber:String;
                                  BaseZ:Byte; var BaseZNumber:String);

var
  I: Integer;
  Number,Remainder: LongInt;

begin
 Number := 0;
 for I := 1 to Length (BaseNNumber) do
  case BaseNNumber[I] of
    '0'..'9': Number := Number * BaseN + Ord (BasenNumber[I]) - Ord ('0');
    'A'..'Z': Number := Number * BaseN + Ord (BasenNumber[I]) -
      Ord ('A') + 10;
    'a'..'z': Number := Number * BaseN + Ord (BasenNumber[I]) -
      Ord ('a') + 10;
    end; BaseZNumber := ''; while Number > 0 do
  begin
  Remainder := Number mod BaseZ;
  Number := Number div BaseZ;
  case Remainder of
    0..9: BaseZNumber := Char (Remainder + Ord ('0')) + BaseZNumber;
    10..36: BaseZNumber := Char (Remainder - 10 + Ord ('A')) + BaseZNumber;
    end;

end; end;

Procedure SwapStr(Var A,B:String);
var C:String;
begin
 C:=A;
 A:=B;
 B:=C;
end;
{$IFDEF XXX}
Type Registers = record
                case Integer of
                  0: (AX,BX,CX,DX,BP,SI,DI,DS,ES,Flags: Word);
                  1: (AL,AH,BL,BH,CL,CH,DL,DH: Byte);
              end;
{$ENDIF}

{$IFNDEF OS2}
FUNCTION NetworkDrive (Drive:CHAR):BOOLEAN;
{$Ifdef windows} var reg:Tregisters; {$else} var Reg:Registers; {$endif}
var DosErrorCode:Word;
  BEGIN
    Drive := UpCase (Drive);            { Drive _must_ be 'A'..'Z'  }
    IF (Drive IN ['A'..'Z']) THEN BEGIN { make sure of 'A'..'Z'     }
      Reg.BL := ORD(Drive) - 64;      { 1 = A:, 2 = B:, 3 = C: etc. }
      Reg.AX := $4409;                { Dos fn: check if dev remote }
      MsDos (Reg);                    { call Dos' services          }
      IF ODD(Reg.FLAGS) THEN          { Dos reports function error? }
        DosErrorCode := Reg.AX        { yes: return Dos' error code }
      ELSE BEGIN                      {   else ...                  }
        DosErrorCode := 0;            { 0 = no error was detected   }
        IF ODD(Reg.DX SHR 12) THEN    { is Drive remote?            }
          NetworkDrive := TRUE        { yes: return TRUE            }
        ELSE
          NetworkDrive := FALSE;      { no: return FALSE            }
        {END IF ODD(Reg.DX...}
    END; {IF ODD(Reg.FLAGS)}
  END;    {IF Drive}
END    {NetworkDrive};
{$ENDIF}

Function SizeofFile(S:String):LongInt;
var F:File;
begin
 Assign(F,S);
 FileMode:=0;
 Reset(F,1);
 SizeOfFile:=FileSize(F);
 Close(F);
end;

Function ActualFileSize:LongInt;
var F:File;
begin
 ActualFileSize:=SizeOfFile(ParamStr(0));
end;


Procedure Lines50; Assembler;
 ASM
  MOV AH, 11H
  MOV AL, 12H
  MOV BL, 0
  INT 10H
 END;

Procedure Lines25; Assembler;
 ASM
  MOV AH, 11H
  MOV AL, 14H
  MOV BL, 0
  INT 10H
 END;

Procedure Lines35; Assembler;
 ASM
  MOV AH, 11H
  MOV AL, 11H
  MOV BL, 0
  INT 10H
 END;

Procedure Lines(S:String);
Begin
 If Val(S)=50 then Lines50;
 If Val(S)=25 then Lines25;
 If Val(S)=35 then Lines35;
End;

Function Strip_(S:String):String;
var B:Byte;
begin
 For B:=1 to length(S) do if S[B]='_' then S[B]:=' ';
 Strip_:=S;
end;


Function Del(S:String; Index:Integer; Count:Integer):String;
begin
 Delete(S,Index,Count);
 Del:=S;
end;

Function WhatDir:String;
var s:String;
begin
 GetDir(0,s);
 whatdir:=s;
end;

Function Str(X:integer):String;
var S:String;
Begin
 System.Str(X,S);
 Str:=S;
End;

Function StrL(X:LongInt):String;
var S:String;
Begin
 System.Str(X,S);
 StrL:=S;
End;

Function StrW(X:word):String;
var S:String;
Begin
 System.Str(X,S);
 StrW:=S;
End;

Function StrR(X:Real):String;
var S:String;
Begin
 System.Str(X,S);
 StrR:=S;
End;

Function Val(S:String):Integer;
var A,B:Integer;
begin
 System.Val(S,A,B);
 If B=0 then Val:=A else begin Val:=0; UError:=B; End;
end;

Function ValW(S:String):Word;
var B:Integer;
    A:Word;
begin
 System.Val(S,A,B);
 If B=0 then ValW:=A else begin ValW:=0; UError:=B; End;
end;

Function ValL(S:String):longint;
var B:integer;
    A:longint;
begin
 System.Val(S,A,B);
 If B=0 then Vall:=A else begin Vall:=0; UError:=B; End;
end;

Function Upstring(S:String):String;
var
    I:Byte;
begin
 for i := 1 to Length(s) do s[i] := UpCase(s[i]);
 Upstring:=S;
end;

Function LoCase(C:Char):Char;
begin
 If (Ord(C)>64) and (Ord(C)<91) then
         LoCase:=Char(Ord(C)+32)
    else LoCase:=C;
end;

Function LoString(S:String):String;
var
    I:Byte;
begin
 for i := 1 to Length(s) do s[i] := LoCase(s[i]);
 Lostring:=S;
end;

Function NameCaps(S:String):String;
var I:byte;
begin
 S:=LoString(S);
 S[1]:=UpCase(S[1]);
 For I:=1 to Length(S) do
   If S[I]=' ' then
     if I<Length(S) then S[I+1]:=UpCase(S[I+1]);
 namecaps:=s;
end;

function FileExists(FileName: String): Boolean;
{ Boolean function that returns True if the file exists;otherwise,
 it returns False. Closes the file if it exists. }
var
 F: file;
begin
 {$I-}
 Filemode:=0;
 Assign(F, FileName);
 FileMode := 0;  {( Set file access to read only }
 Reset(F);
 Close(F);
 {$I+}
 FileExists := (IOResult = 0) and (FileName <> '');
end;  { FileExists }

Function Center(S:String; B:Byte):String;
var A:Byte;
Begin
 Repeat
  A:=Length(S) div 2;
  If A<(B Div 2) then S:=' '+S+' ';
 Until (Length(S) div 2)>=((B) Div 2);
 If Length(S)<B then S:=S+' ';
 Center:=S;
End;

Function Left(S:String; B:Byte):String;
var A:Byte;
Begin
 Repeat
  A:=Length(S);
  If A<B then S:=S+' ';
 Until Length(S)>=((B));
 While Length(S)>B do Delete(S,Length(S),1);
 Left:=S;
End;

Function  PadRight(S:String; B:Byte; C:Char):String;
var A:Byte;
Begin
 Repeat
  A:=Length(S);
  If A<B then S:=C+S;
 Until (Length(S)>=(B));
 PadRight:=S;
End;

Function Right(S:String; B:Byte):String;
Begin
 Right:=PadRight(S,B,' ');
End;

Function Rep(S:String; C:Word):String;
var W:Word;
    T:String;
begin
 T:='';
 For W:=1 to C do T:=T+S;
 Rep:=T;
end;

Function StrBool(S:String):Boolean;
begin
 S:=UpString(S);
 StrBool:=(Pos('T',S)>0);
end;

FUNCTION TempFile( Path: STRING ): STRING;
VAR
 {$IFDEF WINDOWS}
   DateStr  : TDateTime;
 {$ELSE}
   DateStr  : DateTime;
 {$ENDIF}
   Trash    : WORD;
   Time     : LONGINT;
   FileName : STRING;
Begin
 If (Path<>'') AND (Path[length(Path)]<>'\') Then Path := Path + '\';
 Repeat
  With DateStr Do
    Begin
     GETDATE( Year, Month, Day, Trash );
     GETTIME( Hour, Min, Sec, Trash );
    End;
  PackTime( DateStr, Time );
  {$R-,Q-}
  System.Str(Time,Filename);
  FileName := Copy(Filename,1,8);
  FileName := Filename+'.$$$';
  {$R+,Q+}
 Until Not FileExists(Path + FileName);
 TempFile := Path + FileName;
END;


Function WordWrap(S:String; Var Remainder:String; Len:Byte):String;
Var W:String;
    I:Integer;
begin
 If S[1]=' ' then delete(S,1,1);
 If Length(S)<=Len then
  begin
   WordWrap:=S;
   Remainder:='';
   Exit;
  end;

 For I:=Len downto 1 do
  begin
   If S[I]=' ' then
    begin
     WordWrap:=Copy(S,1,I);
     Remainder:=Copy(S,I,Length(S)-I+1);
     Exit;
    end;
  end;
end;

Function  AN(S:String):String;
begin
 While S[1]=' ' do delete(S,1,1);
 If UPCASE(S[1]) IN ['A','E','I','O','U'] THEN INSERT('an ',S,1) ELSE
                                               INSERT('a ',S,1);
 AN:=S;
end;

Function LastDrive: Char; Assembler;
Asm
  mov   ah, 19h
  int   21h
  push  ax            { save default drive }
  mov   ah, 0Eh
  mov   dl, 19h
  int   21h
  mov   cl, al
  dec   cx
@@CheckDrive:
  mov   ah, 0Eh       { check if drive valid }
  mov   dl, cl
  int   21h
  mov   ah, 19h
  int   21h
  cmp   cl, al
  je    @@Valid
  dec   cl            { check next lovest drive number }
  jmp   @@CheckDrive
@@Valid:
  pop   ax
  mov   dl, al
  mov   ah, 0Eh
  int   21h           { restore default drive }
  mov   al, cl
  add   al, 'A'
end;

Function LongToHex(L:Longint):String;
var S:string;
begin
 ConvertBase(10,StrL(L),16,S);
 LongToHex:=S;
end;

End.
