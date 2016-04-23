{
 INI File Reading Unit--
  THis UNIT will allow you to use *.INI files for config instead of a
  full blown setup program, it will read ALMOST ALL INI files, except
  for ones such as CGA.INI.
  I'm sure no one will have trouble with it, it is pretty straight
  forward (even a C/C++ programmer could understand it <g>)

 NOTE FROM AUTHOR:
  Well, I'm sure I bugged some people on the FIDOs about stupid errors
  while making this, as it turns out, I have finished my until already
  after just getting rid of the last known bug.

  I am releasing this as public domain, if you find it usefull, I would
  appreciate credit. And please, if you make changes, send me a copy.

 USE: (An example is included at the end)
  1) Change the constant MAXINI to the maxium amount of variables.
  2) Declare a variable of INI_TYP.
  3) Run INIVALS at the start of your program
  4) Assign the ITEMSTR value to the keyword to look for
     (ie.. if you wanted to associate ANYVAR[1].ITEMSTR := 'HERE',
      then if this is found in the file "HERE=THERE", the return
      result of ANYVAR[1].RESULT will be "THERE")
  5) Run READINI on the INI file.
  6) Use the values returned in RESULT for config.

FYI.. Case/Spaces/Tabs do not matter NO MATTER WHERE THEY ARE!

BTW.. I cut this code from a program of mine where I originally created it,
      if it doesnt work tell me and I will add whatever I forgot. So far
      it seems to have no obvious problems.

SWAG use is permitted.

ONE FINAL NOTE:
 I blame all bugs/spelling errors/etc.. on my word processor.
 You use this program at your own risk, I will do accept any liability
 for ANY problems whatsoever.

No animals were harmed in the making of this program.
}



{$IFDEF DEBUG}
{$A+,B-,D+,F-,G-,I-,K-,L-,N-,E-,P-,Q+,R+,S+,T-,V-,W-,X+,Y-}
{$ELSE}
{$A+,B-,D-,F-,G-,I-,K-,L-,N-,E-,P-,Q-,R-,S-,T-,V-,W-,X+,Y-}
{$ENDIF}

UNIT INIT;  { see test program below }

Interface

Type
      Str12  = String[12];
      Str26  = String[26];
      Str35  = String[35];
      Str75  = String[75];
      Str127 = String[127];

 Const
    MaxIni = 5; {Change this to whatever}
    CommentSet : Set Of Char = ['[','!','#','/','>'];
    INI_FNotFound = $02;  {Returned by READINI}
    INI_FIOError  = $01;  {""}
    INI_FOk       = $00;  {""}

 Type
      INI_REC = Record
                 KEY : Str35; {keyword}
                 Result  : Str35; {Found after: ItemStr,'=',Result}
                 Found   : Boolean; {Found yet?}
                End;

      INI_TYP = Array[1..MaxIni] of INI_REC;

Procedure InitVals(Var a999 : INI_TYP);
Function ReadIni(F:Str75;var InIv : Ini_Typ):Byte;
Function _S3(Base : String;Var S1,S2 : String):Byte;
Function EraseChar2(Ch:Char;St:String):String;
Function UpStr(const s:string):string;

Implementation

 Procedure InitVals(Var A999 : INI_TYP);
 Var W:Word;
  Begin
  For W := 1 to MaxIni do A999[W].Found := False;
  End;

Function EraseChar2(Ch:Char;St:String):String;
 Var NB:Byte;
 Begin
  For NB := 1 to length(St) do If St[Nb] = CH then Delete(St,Nb,1);
  EraseChar2 := St;
 End;

{Function EraseChar(Ch:Char;St:String):String;
Begin
 While Copy(St, 1, 1) = CH do
 Delete(St, 1, 1);
 While Copy(St, Length(St), 1) = CH do
 Delete(St, Length(St), 1);
 EraseCHar := St;
End;}

Function _S3(Base : String;Var S1,S2 : String):Byte;
 var B,B2:Byte;
 Begin
  _S3 := 0;
  B := Pos('=',Base);
  If B > 1 then
   Begin
    S1 := Copy(Base,1,B-1);
    S2 := Copy(Base,B+1,Length(Base));
    S1 := EraseChar2(' ',S1);
   End Else _S3 := 1;
 End;

Function ReadIni(F:Str75;var InIv : Ini_Typ):Byte;
  Var INIFILE:Text;
      TempStr : Str127;
      S1,S2 : Str35;
      W1 : Word;
  Begin
   Assign(INIFILE, F);
   Reset(INIFILE);
   READINI := 0;
   IF IOresult <> 0 then
    Begin
     ReadInI := INI_FNotFound;
     Exit;
    End;
  While not EOF(INIFILE) do
    Begin
     Readln(INIFILE, TempStr); {Load String}
     If length(TempStr) > 3 then {Min: A=A}
      Begin
       TempStr := UpStr(TempStr); {Make it caps}
       TempStr := EraseChar2(' ',TempStr); {Get rid of spaces}
       TempStr := EraseChar2(#9,TempStr); {Get rid of tabs}
       If not (TempStr[1] in CommentSet) then {Not a comment?}
       If _S3(TempStr, S1, S2) = 0 then {Is it a valid param?}
       For W1 := 1 to MaxIni do
         Begin{Search all INI variables}
          If not INIV[W1].Found then {has not been checked out}
          If UpStr(INIV[W1].Key) = S1 then {Do they match?}
           Begin
            INIV[W1].Result := S2;
            INIV[W1].Found := True;
            W1 := MaxINI; {ENd search}
          End;{Begin If ItemStr = S1}
       End;{For W1 to}
     End;{If Length > 3}
  End;{While not EOF}
   Close(INIFILE);
  End;

Function UpStr(const s:string):string; assembler; {Upper Case String}
{This is the only code that is not mine...}
  asm
    push ds
    lds  si,s
    les  di,@result
    lodsb            { load and store length of string }
    stosb
    xor  ch,ch
    mov  cl,al
    jcxz @empty      { FIX for null length string }
  @upperLoop:
    lodsb
    cmp  al,'a'
    jb   @cont
    cmp  al,'z'
    ja   @cont
    sub  al,' '
  @cont:
    stosb
    loop @UpperLoop
  @empty:
    pop  ds
  end;  { UpStr }

ENd.


{------------------ test program -----------------------}

{This will open the windows INI file WIN.INI and find data}

Program Test;
Uses INIT;

Const
 INIFILEStr = 'C:\WINDOWS\WIN.INI';

Var
  ANyA : INI_TYP;
  Result : Byte;

Begin
 INITVALS(ANYA);
 ANYA[1].Key := 'sCountry';
 Result := ReadINI(INIFILEstr,ANYA);
 If Result <> INI_FOK then
  Begin
   Writeln('');
   Writeln('It seems that you are missing the file ',INIFILEStr);
   Writeln('so I cannot detect your country.');
   Writeln('');
   readln;
   Halt(1);
  End;
 Writeln('');
 Writeln('It seems that you live in the ',ANYA[1].RESULT,'.');
 Writeln('What a great place!');
 Writeln('');
 Readln;
ENd.