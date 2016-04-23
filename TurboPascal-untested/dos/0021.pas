{
Subject: Enviro.pas Unit to change Dos Vars permanently


Had this floating round, hope it helps someone.
It works under Dos 5, NDos 6.01, and should work For any other Dos as well,
no guarantees tho' .

}
Unit Enviro;

Interface

Var EnvSeg,
    EnvOfs,
    EnvSize  :  Word;

Function  FindEnv:Boolean;
Function  IsEnvVar(Variable : String;Var Value : String):Boolean;
Procedure ChangeEnvVar(Variable,NewVal : String);

Implementation

Uses Dos;

Type MemoryControlBlock =     {MCB -- only needed fields are shown}
      Record
        Blocktag   :  Byte;
        BlockOwner :  Word;
        BlockSize  :  Word;
        misc       :  Array[1..3] of Byte;
        ProgramName:  Array[1..8] of Char;
      end;

    ProgramSegmentPrefix =   {PSP -- only needed fields are shown}
      Record                                           { offset }
        PSPtag     :  Word;  { $20CD or $27CD if PSP}  { 00 $00 }
        misc       :  Array[1..21] of Word;            { 02 $02 }
        Environment:  Word                             { 44 $2C }
      end;

Var
  MCB      : ^MemoryControlBlock;
  r        : Registers;
  Found    : Boolean;
  SegMent  : Word;
  EnvPtr   : Word;
  Startofs : Word;

Function FindEnvMCB:Boolean;
Var
  b        :  Char;
  BlockType:  String[12];
  Bytes    :  LongInt;
  i        :  Word;
  last     :  Char;
  MCBenv   :  ^MemoryControlBlock;
  MCBowner :  ^MemoryControlBlock;
  psp      :  ^ProgramSegmentPrefix;

begin
FindEnvMCB := False;

Bytes := LongInt(MCB^.BlockSize) SHL 4;    {size of MCB in Bytes}
if mcb^.blockowner = 0 then                { free space }
else begin
  psp := Ptr(MCB^.BlockOwner,0);            {possible PSP}
  if   (psp^.PSPtag = $20CD) or (psp^.PSPtag = $27CD) then begin
  MCBenv := Ptr(psp^.Environment-1,0);
  if   MCB^.Blockowner <> (segment + 1) then
    if psp^.Environment = (segment + 1) then
      if  MCB^.BlockOwner = MCBenv^.BlockOwner then begin
         EnvSize := MCBenv^.BlockSize SHL 4;      {multiply by 16}
         EnvSeg := PSP^.Environment;
         EnvOfs := 0;
         FindEnvMCB := True;
         end
    end
  end;
end;

Function FindEnv:Boolean;
begin
r.AH := $52;            {undocumented Dos Function that returns a Pointer}
Intr ($21,r);           {to the Dos 'list of lists'                      }
segment := MemW[r.ES:r.BX-2];  {segment address of first MCB found at}
                               {offset -2 from List of List Pointer  }
Repeat
MCB := Ptr(segment,0);    {MCB^ points to first MCB}
  Found := FindEnvMcb;    {Look at each MCB}
  segment := segment + MCB^.BlockSize + 1
Until (Found) or (MCB^.Blocktag = $5A);
FindEnv := Found;
end;

Function IsEnvVar(Variable : String;Var Value : String):Boolean;
Var Temp : String;
    ch   : Char;
    i    : Word;
    FoundIt : Boolean;
begin
Variable := Variable + '=';
FoundIt := False;
i := EnvOfs;
Repeat
  Temp := '';
  StartOfs := I;
  Repeat
    ch := Char(Mem[EnvSeg:i]);
    if Ch <> #0 then Temp := Temp + Ch;
    inc(i);
  Until (Ch = #0) or (I > EnvSize);
  if Ch = #0 then begin
    FoundIt := (Pos(Variable,Temp) = 1);
    if FoundIt then Value := Copy(Temp,Length(Variable)+1,255);
    end;
Until (FoundIt) or (I > EnvSize);
IsEnvVar := FoundIt;
end;

Procedure ChangeEnvVar(Variable,NewVal : String);
Var OldVal : String;
    p1,p2  : Pointer;
    i,j    : Word;
    ch,
    LastCh : Char;
begin
if IsEnvVar(Variable,OldVal) then begin
  p1 := Ptr(EnvSeg,StartOfs + Length(Variable)+1);
  if Length(OldVal) = Length(NewVal) then
     Move(NewVal[1],p1^,Length(NewVal))
  else if Length(OldVal) > Length(NewVal) then begin
     Move(NewVal[1],p1^,Length(NewVal));
     p1 := ptr(EnvSeg,StartOfs + Length(Variable)+Length(OldVal)+1);
     p2 := ptr(EnvSeg,StartOfs + Length(Variable)+Length(NewVal)+1);
     Move(p1^,p2^,EnvSize - ofs(p1^));
     end
  else begin   { newVar is longer than oldVar }
     p2 := ptr(EnvSeg,StartOfs + Length(Variable)+Length(NewVal)-length(OldVal)+1);
     Move(p1^,p2^,EnvSize - ofs(p2^));
     Move(NewVal[1],p1^,Length(NewVal));
     end;
  end
else      { creating a new Var }
  begin
  i := EnvOfs;
  ch := Char(Mem[EnvSeg:i]);
  Repeat
    LastCh := Ch;
    inc(i);
    ch := Char(Mem[EnvSeg:i]);
  Until (i > EnvSize) or ((LastCh = #0) and (Ch = #0));
  if i < EnvSize then begin
    j := 1;
    Variable := Variable + '=' + NewVal + #0 + #0;
    While (J < Length(Variable)) and (I <= EnvSize) do begin
      Mem[EnvSeg:i] := ord(Variable[j]);
      inc(i); Inc(j);
      end;
    end;
  end;
end;

begin
end.

{ TEST Program }
Uses Enviro;

Var EnvVar : String;

begin
if FindEnv then begin
  Writeln('Found the Enviroment !!');
  Writeln('Env is at address ',EnvSeg,':',EnvOfs);
  Writeln('And is ',EnvSize,' Bytes long');

  if IsEnvVar('COMSPEC',EnvVar) then Writeln('COMSPEC = ',EnvVar)
  else Writeln('COMSPEC is not set');

  if IsEnvVar('NewVar',EnvVar) then  Writeln('NewVar = ',EnvVar)
  else Writeln('NewVar is not set');

  ChangeEnvVar('NewVar','This is a new Var');

  if IsEnvVar('NewVar',EnvVar) then  Writeln('NewVar = ',EnvVar)
  else Writeln('NewVar is not set');

  ChangeEnvVar('NewVar','NewVar is now this');

  if IsEnvVar('NewVar',EnvVar) then  Writeln('NewVar = ',EnvVar)
  else Writeln('NewVar is not set');

  end;
end.
