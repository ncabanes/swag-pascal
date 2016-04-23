{$R-,S-,V-,I-,B-,F-}

{Disable the following define if you don't have Turbo Professional}
{$DEFINE UseTpro}

{*********************************************************}
{*                    TPENV.PAS 1.02                     *}
{*                by TurboPower Software                 *}
{*********************************************************}

{
  Version 1.01 11/7/88
    Find master environment in Dos 3.3 and 4.0
  Version 1.02 11/14/88
    Correctly find master environment when run
      Within AUTOEXEC.BAT
}

Unit TpEnv;
  {-Manipulate the environment}

Interface

Uses Opus;

Type
  EnvArray = Array[0..32767] of Char;
  EnvArrayPtr = ^EnvArray;
  EnvRec =
    Record
      EnvSeg : Word;              {Segment of the environment}
      EnvLen : Word;              {Usable length of the environment}
      EnvPtr : Pointer;           {Nil except when allocated on heap}
    end;

Const
  ShellUserProc : Pointer = nil;  {Put address of ExecDos user proc here if desi

Procedure MasterEnv(Var Env : EnvRec);
  {-Return master environment Record}

Procedure CurrentEnv(Var Env : EnvRec);
  {-Return current environment Record}

Procedure NewEnv(Var Env : EnvRec; Size : Word);
  {-Allocate a new environment on the heap}

Procedure DisposeEnv(Var Env : EnvRec);
  {-Deallocate an environment previously allocated on heap}

Procedure SetCurrentEnv(Env : EnvRec);
  {-Specify a different environment For the current Program}

Procedure CopyEnv(Src, Dest : EnvRec);
  {-Copy contents of Src environment to Dest environment}

Function EnvFree(Env : EnvRec) : Word;
  {-Return Bytes free in environment}

Function GetEnvStr(Env : EnvRec; Search : String) : String;
  {-Return a String from the environment}

Function SetEnvStr(Env : EnvRec; Search, Value : String) : Boolean;
  {-Set environment String, returning True if successful}

Procedure DumpEnv(Env : EnvRec);
  {-Dump the environment to StdOut}

Function ProgramStr : String;
  {-Return the complete path to the current Program, '' if Dos < 3.0}

Function SetProgramStr(Env : EnvRec; Path : String) : Boolean;
  {-Add a Program name to the end of an environment if sufficient space}

  {$IFDEF UseTpro}
Function ShellWithPrompt(Prompt : String) : Integer;
  {-Shell to Dos With a new prompt}
  {$endIF}

Procedure DisposeEnv(Var Env : EnvRec);
  {-Deallocate an environment previously allocated on heap}
begin
  With Env do
    if EnvPtr <> nil then begin
      FreeMem(EnvPtr, EnvLen+31);
      ClearEnvRec(Env);
    end;
end;

Procedure SetCurrentEnv(Env : EnvRec);
  {-Specify a different environment For the current Program}
begin
  With Env do
    if EnvSeg <> 0 then
      MemW[PrefixSeg:$2C] := EnvSeg;
end;

Procedure CopyEnv(Src, Dest : EnvRec);
  {-Copy contents of Src environment to Dest environment}
Var
  Size : Word;
  SPtr : EnvArrayPtr;
  DPtr : EnvArrayPtr;
begin
  if (Src.EnvSeg = 0) or (Dest.EnvSeg = 0) then
    Exit;

  if Src.EnvLen <= Dest.EnvLen then
    {Space For the whole thing}
    Size := Src.EnvLen
  else
    {Take what fits}
    Size := Dest.EnvLen-1;

  SPtr := Ptr(Src.EnvSeg, 0);
  DPtr := Ptr(Dest.EnvSeg, 0);
  Move(SPtr^, DPtr^, Size);
  FillChar(DPtr^[Size], Dest.EnvLen-Size, 0);
end;

Procedure SkipAsciiZ(EPtr : EnvArrayPtr; Var EOfs : Word);
  {-Skip to end of current AsciiZ String}
begin
  While EPtr^[EOfs] <> #0 do
    Inc(EOfs);
end;

Function EnvNext(EPtr : EnvArrayPtr) : Word;
  {-Return the next available location in environment at EPtr^}
Var
  EOfs : Word;
begin
  EOfs := 0;
  if EPtr <> nil then begin
    While EPtr^[EOfs] <> #0 do begin
      SkipAsciiZ(EPtr, EOfs);
      Inc(EOfs);
    end;
  end;
  EnvNext := EOfs;
end;

Function EnvFree(Env : EnvRec) : Word;
  {-Return Bytes free in environment}
begin
  With Env do
    if EnvSeg <> 0 then
      EnvFree := EnvLen-EnvNext(Ptr(EnvSeg, 0))-1
    else
      EnvFree := 0;
end;

{$IFNDEF UseTpro}
Function StUpcase(S : String) : String;
  {-Uppercase a String}
Var
  SLen : Byte Absolute S;
  I : Integer;
begin
  For I := 1 to SLen do
    S[I] := UpCase(S[I]);
  StUpcase := S;
end;
Function SearchEnv(EPtr : EnvArrayPtr;
                   Var Search : String) : Word;
  {-Return the position of Search in environment, or $FFFF if not found.
    Prior to calling SearchEnv, assure that
      EPtr is not nil,
      Search is not empty
  }
Var
  SLen : Byte Absolute Search;
  EOfs : Word;
  MOfs : Word;
  SOfs : Word;
  Match : Boolean;
begin
  {Force upper Case search}
  Search := Upper(Search);

  {Assure search String ends in =}
  if Search[SLen] <> '=' then begin
    Inc(SLen);
    Search[SLen] := '=';
  end;

  EOfs := 0;
  While EPtr^[EOfs] <> #0 do begin
    {At the start of a new environment element}
    SOfs := 1;
    MOfs := EOfs;
    Repeat
      Match := (EPtr^[EOfs] = Search[SOfs]);
      if Match then begin
        Inc(EOfs);
        Inc(SOfs);
      end;
    Until not Match or (SOfs > SLen);

    if Match then begin
      {Found a match, return index of start of match}
      SearchEnv := MOfs;
      Exit;
    end;

    {Skip to end of this environment String}
    SkipAsciiZ(EPtr, EOfs);

    {Skip to start of next environment String}
    Inc(EOfs);
  end;

  {No match}
  SearchEnv := $FFFF;
end;

Procedure GetAsciiZ(EPtr : EnvArrayPtr; Var EOfs : Word; Var EStr : String);
  {-Collect AsciiZ String starting at EPtr^[EOfs]}
Var
  ELen : Byte Absolute EStr;
begin
  ELen := 0;
  While (EPtr^[EOfs] <> #0) and (ELen < 255) do begin
    Inc(ELen);
    EStr[ELen] := EPtr^[EOfs];
    Inc(EOfs);
  end;
end;

Function GetEnvStr(Env : EnvRec; Search : String) : String;
  {-Return a String from the environment}
Var
  SLen : Byte Absolute Search;
  EPtr : EnvArrayPtr;
  EOfs : Word;
  EStr : String;
  ELen : Byte Absolute EStr;
begin
  With Env do begin
    ELen := 0;
    if (EnvSeg <> 0) and (SLen <> 0) then begin
      {Find the search String}
      EPtr := Ptr(EnvSeg, 0);
      EOfs := SearchEnv(EPtr, Search);
      if EOfs <> $FFFF then begin
        {Skip over the search String}
        Inc(EOfs, SLen);
        {Build the result String}
        GetAsciiZ(EPtr, EOfs, EStr);
      end;
    end;
    GetEnvStr := EStr;
  end;
end;

Implementation

Type
SO =
  Record
    O : Word;
    S : Word;
  end;

Procedure ClearEnvRec(Var Env : EnvRec);
  {-Initialize an environment Record}
begin
  FillChar(Env, SizeOf(Env), 0);
end;

Procedure MasterEnv(Var Env : EnvRec);
  {-Return master environment Record}
Var
  Owner : Word;
  Mcb : Word;
  Eseg : Word;
  Done : Boolean;
begin
  With Env do begin
    ClearEnvRec(Env);

    {Interrupt $2E points into COMMAND.COM}
    Owner := MemW[0:(2+4*$2E)];

    {Mcb points to memory control block For COMMAND}
    Mcb := Owner-1;
    if (Mem[Mcb:0] <> Byte('M')) or (MemW[Mcb:1] <> Owner) then
      Exit;

    {Read segment of environment from PSP of COMMAND}
    Eseg := MemW[Owner:$2C];

    {Earlier versions of Dos don't store environment segment there}
    if Eseg = 0 then begin
      {Master environment is next block past COMMAND}
      Mcb := Owner+MemW[Mcb:3];
      if (Mem[Mcb:0] <> Byte('M')) or (MemW[Mcb:1] <> Owner) then
        {Not the right memory control block}
        Exit;
      Eseg := Mcb+1;
    end else
      Mcb := Eseg-1;

    {Return segment and length of environment}
    EnvSeg := Eseg;
    EnvLen := MemW[Mcb:3] shl 4;
  end;
end;

Procedure CurrentEnv(Var Env : EnvRec);
  {-Return current environment Record}
Var
  ESeg : Word;
  Mcb : Word;
begin
  With Env do begin
    ClearEnvRec(Env);
    ESeg := MemW[PrefixSeg:$2C];
    Mcb := ESeg-1;
    if (Mem[Mcb:0] <> Byte('M')) or (MemW[Mcb:1] <> PrefixSeg) then
      Exit;
    EnvSeg := ESeg;
    EnvLen := MemW[Mcb:3] shl 4;
  end;
end;

Procedure NewEnv(Var Env : EnvRec; Size : Word);
  {-Allocate a new environment (on the heap)}
Var
  Mcb : Word;
begin
  With Env do
    if MaxAvail < Size+31 then
      {Insufficient space}
      ClearEnvRec(Env)
    else begin
      {31 extra Bytes For paraGraph alignment, fake MCB}
      GetMem(EnvPtr, Size+31);
      EnvSeg := SO(EnvPtr).S+1;
      if SO(EnvPtr).O <> 0 then
        Inc(EnvSeg);
      EnvLen := Size;
      {Fill it With nulls}
      FillChar(EnvPtr^, Size+31, 0);
      {Make a fake MCB below it}
      Mcb := EnvSeg-1;
      Mem[Mcb:0] := Byte('M');
      MemW[Mcb:1] := PrefixSeg;
      MemW[Mcb:3] := (Size+15) shr 4;
    end;
end;

Function SetEnvStr(Env : EnvRec; Search, Value : String) : Boolean;
  {-Set environment String, returning True if successful}
Var
  SLen : Byte Absolute Search;
  VLen : Byte Absolute Value;
  EPtr : EnvArrayPtr;
  ENext : Word;
  EOfs : Word;
  MOfs : Word;
  OldLen : Word;
  NewLen : Word;
  NulLen : Word;
begin
  With Env do begin
    SetEnvStr := False;
    if (EnvSeg = 0) or (SLen = 0) then
      Exit;
    EPtr := Ptr(EnvSeg, 0);

    {Find the search String}
    EOfs := SearchEnv(EPtr, Search);

    {Get the index of the next available environment location}
    ENext := EnvNext(EPtr);

    {Get total length of new environment String}
    NewLen := SLen+VLen;

    if EOfs <> $FFFF then begin
      {Search String exists}
      MOfs := EOfs+SLen;
      {Scan to end of String}
      SkipAsciiZ(EPtr, MOfs);
      OldLen := MOfs-EOfs;
      {No extra nulls to add}
      NulLen := 0;
    end else begin
      OldLen := 0;
      {One extra null to add}
      NulLen := 1;
    end;

    if VLen <> 0 then
      {Not a pure deletion}
      if ENext+NewLen+NulLen >= EnvLen+OldLen then
        {New String won't fit}
        Exit;

    if OldLen <> 0 then begin
      {OverWrite previous environment String}
      Move(EPtr^[MOfs+1], EPtr^[EOfs], ENext-MOfs-1);
      {More space free now}
      Dec(ENext, OldLen+1);
    end;

    {Append new String}
    if VLen <> 0 then begin
      Move(Search[1], EPtr^[ENext], SLen);
      Inc(ENext, SLen);
      Move(Value[1], EPtr^[ENext], VLen);
      Inc(ENext, VLen);
    end;

    {Clear out the rest of the environment}
    FillChar(EPtr^[ENext], EnvLen-ENext, 0);

    SetEnvStr := True;
  end;
end;

Procedure DumpEnv(Env : EnvRec);
  {-Dump the environment to StdOut}
Var
  EOfs : Word;
  EPtr : EnvArrayPtr;
begin
  With Env do begin
    if EnvSeg = 0 then
      Exit;
    EPtr := Ptr(EnvSeg, 0);
    EOfs := 0;
    WriteLn;
    While EPtr^[EOfs] <> #0 do begin
      While EPtr^[EOfs] <> #0 do begin
        Write(EPtr^[EOfs]);
        Inc(EOfs);
      end;
      WriteLn;
      Inc(EOfs);
    end;
    WriteLn('Bytes free: ', EnvFree(Env));
  end;
end;
{$IFDEF UseTpro}
Function ShellWithPrompt(Prompt : String) : Integer;
  {-Shell to Dos With a new prompt}
Const
  PromptStr : String[7] = 'PROMPT=';
Var
  PLen : Byte Absolute Prompt;
  NSize : Word;
  Status : Integer;
  CE : EnvRec;
  NE : EnvRec;
  OldP : String;
  OldPLen : Byte Absolute OldP;
begin
  {Point to current environment}
  CurrentEnv(CE);
  if CE.EnvSeg = 0 then begin
    {Error getting environment}
    ShellWithPrompt := -5;
    Exit;
  end;

  {Compute size of new environment}
  OldP := GetEnvStr(CE, PromptStr);
  NSize := CE.EnvLen;
  if OldPLen < PLen then
    Inc(NSize, PLen-OldPLen);

  {Allocate and initialize a new environment}
  NewEnv(NE, NSize);
  if NE.EnvSeg = 0 then begin
    {Insufficient memory For new environment}
    ShellWithPrompt := -6;
    Exit;
  end;
  CopyEnv(CE, NE);

  {Get the Program name from the current environment}
  OldP := ProgramStr;

  {Set the new prompt String}
  if not SetEnvStr(NE, PromptStr, Prompt) then begin
    {Program error, should have enough space}
    ShellWithPrompt := -7;
    Exit;
  end;

  {Transfer Program name to new environment if possible}
  if not SetProgramStr(NE, OldP) then
    ;

  {Point to new environment}
  SetCurrentEnv(NE);

  {Shell to Dos With new prompt in place}
  {Status := Exec('', True, ShellUserProc);}

  {Restore previous environment}
  SetCurrentEnv(CE);

  {Release the heap space}
  if Status >= 0 then
    DisposeEnv(NE);

  {Return exec status}
  ShellWithPrompt := Status;
end;
{$endIF}

end.

{ EXAMPLE PROGRAM }

Function DosVersion : Word;
  {-Return the Dos version, major part in AX}
Inline(
  $B4/$30/                 {mov ah,$30}
  $CD/$21/                 {int $21}
  $86/$C4);                {xchg ah,al}

Function ProgramStr : String;
  {-Return the name of the current Program, '' if Dos < 3.0}
Var
  EOfs : Word;
  Env : EnvRec;
  EPtr : EnvArrayPtr;
  PStr : String;
begin
  ProgramStr := '';
  if DosVersion < $0300 then
    Exit;
  CurrentEnv(Env);
  if Env.EnvSeg = 0 then
    Exit;
  {Find the end of the current environment}
  EPtr := Ptr(Env.EnvSeg, 0);
  EOfs := EnvNext(EPtr);
  {Skip to start of path name}
  Inc(EOfs, 3);
  {Collect the path name}
  GetAsciiZ(EPtr, EOfs, PStr);
  ProgramStr := PStr;
end;

Function SetProgramStr(Env : EnvRec; Path : String) : Boolean;
  {-Add a Program name to the end of an environment if sufficient space}
Var
  PLen : Byte Absolute Path;
  EOfs : Word;
  Numb : Word;
  EPtr : EnvArrayPtr;
begin
  SetProgramStr := False;
  With Env do begin
    if EnvSeg = 0 then
      Exit;
    {Find the end of the current environment}
    EPtr := Ptr(EnvSeg, 0);
    EOfs := EnvNext(EPtr);
    {Assure space For path}
    if EnvLen < PLen+EOfs+4 then
      Exit;
    {Put in the count field}
    Inc(EOfs);
    Numb := 1;
    Move(Numb, EPtr^[EOfs], 2);
    {Skip to start of path name}
    Inc(EOfs, 2);
    {Move the path into place}
    Path := Upper(Path);
    Move(Path[1], EPtr^[EOfs], PLen);
    {Null terminate}
    Inc(EOfs, PLen);
    EPtr^[EOfs] := #0;
    SetProgramStr := True;
  end;
end;
