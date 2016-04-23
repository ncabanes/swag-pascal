{
 The following TP code assigns a new Environment to the COMMand.COM
 which is invoked by TP's EXEC Function.  In this Case, it is used
 to produce a Dos PROMPT which is different from the one in the Master
 Environment.  Control is returned when the user Types Exit ...
}

{ Reduce Retained Memory }

{$M 2048,0,0}

Program NewEnv;
Uses
  Dos;
Type
  String128   = String[128];
Const
  NewPrompt   =
    'PROMPT=$e[32mType Exit to Return to The Fitness Profiler$e[0m$_$_$p$g' + #0;
Var
  EnvironNew,
  EnvironOld,
  offsetN,
  offsetO,
  SegBytes    : Word;
  TextBuff    : String128;
  Found,
  Okay        : Boolean;
  Reg         : Registers;

Function AllocateSeg( BytesNeeded : Word ) : Word;
begin
  Reg.AH := $48;
  Reg.BX := BytesNeeded div 16;
  MsDos( Reg );
  if Reg.Flags and FCarry <> 0 then
    AllocateSeg := 0
  else
    AllocateSeg := Reg.AX;
end {AllocateSeg};

Procedure DeAllocateSeg( AllocSeg : Word; Var okay : Boolean );
begin
  Reg.ES := AllocSeg;
  Reg.AH := $49;
  MsDos( Reg );
  if Reg.Flags and FCarry <> 0 then
    okay := False
  else
    okay := True;
end {DeAllocateSeg};

Function EnvReadLn( EnvSeg : Word; Var Envoffset : Word ) : String128;
Var
  tempstr : String128;
  loopc   : Byte;
begin
  loopc := 0;
  Repeat
    inC( loopc );
    tempstr[loopc] := CHR(Mem[EnvSeg:Envoffset]);
    inC( Envoffset );
  Until tempstr[loopc] = #0;
  tempstr[0] := CHR(loopc);       {set str length}
  EnvReadLn := tempstr
end {ReadEnvLn};

Procedure EnvWriteLn( EnvSeg : Word; Var Envoffset : Word;
                      AsciizStr : String );
Var
  loopc   : Byte;
begin
  For loopc := 1 to Length( AsciizStr ) do
  begin
    Mem[EnvSeg:Envoffset] := orD(AsciizStr[loopc]);
    inC( Envoffset )
  end
end {EnvWriteLn};

begin   {main}
  WriteLn(#10,'NewEnv v0.0 Dec.25.91 Greg Vigneault');
  SegBytes := 1024;    { size of new environment (up to 32k)}
  EnvironNew := AllocateSeg( SegBytes );
  if EnvironNew = 0 then
  begin    { asked For too much memory? }
    WriteLn('Can''t allocate memory segment Bytes.',#7);
    Halt(1)
  end;
  EnvironOld := MemW[ PrefixSeg:$002c ];   { current environ }
  { copy orig env, but change the PROMPT command }
  Found := False;
  offsetO := 0;
  offsetN := 0;
  Repeat  { copy one env Var at a time, old env to new env}
    TextBuff := EnvReadLn( EnvironOld, offsetO );
    if offsetO >= SegBytes then
    begin { not enough space? }
      WriteLn('not enough new Environment space',#7);
      DeAllocateSeg( EnvironNew, okay );
      Halt(2)     { abort to Dos }
    end;
    { check For the PROMPT command String }
    if Pos('PROMPT=',TextBuff) = 1 then
    begin { prompt command? }
      TextBuff := NewPrompt;          { set new prompt }
      Found := True;
    end;
    { now Write the Variable to new environ }
    EnvWriteLn( EnvironNew, offsetN, TextBuff );
    { loop Until all Variables checked/copied }
  Until Mem[EnvironOld:offsetO] = 0;
  { if no prompt command found, create one }
  if not Found then
    EnvWriteLn( EnvironNew, offsetN, NewPrompt );
  Mem[EnvironNew:offsetN] := 0;           { delimit new environ}
  MemW[ PrefixSeg:$2c ] := EnvironNew;    { activate new env }
  WriteLn( #10, '....Type Exit to return to normal prompt...' );
  SwapVectors;
  Exec( GetEnv('COMSPEC'),'/S');  {shell to Dos w/ new prompt}
  SwapVectors;
  MemW[ PrefixSeg:$2c ] := EnvironOld;   { restore original env}
  DeAllocateSeg( EnvironNew, okay );
  if not okay then
    WriteLn( 'Could not release memory!',#7 );
end {NewEnv}.
(*******************************************************************)
