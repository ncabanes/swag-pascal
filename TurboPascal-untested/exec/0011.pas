{
KELLY SMALL

>Does anyone know how to change the "master" environment?  I want to have my
>program change the dos prompt and have it be there after my program ends.
>DOS's stupid little batch language can do it, so there must be a way.

Here's a procedure that should do it from TeeCee:
}

procedure InitNewPrompt;
{-set up a new prompt for shelling to dos}
type
  _2karray = array[1..2048] of byte;
  SegPtr   = ^_2karray;
const
  NewPrompt : string = ('PROMPT=Type EXIT to return to program$_$p$g'+#0);
var
  EnvSegment,
  NewEnvSeg   : word;
  PtrSeg,
  NewEnv      : SegPtr;
begin
  EnvSegment := memw[prefixseg:$2C];
  {-this gets the actual starting segment of the current program's env}

  PtrSeg := ptr(pred(EnvSegment), 0);
  {-The segment of the program's MCB - (Memory control block) }

  getmem(NewEnv, 1072 + length(NewPrompt));
  {-Allocate heap memory and allow enough room for a dummy mcb }

  if ofs(NewEnv^) <> 0 then
    NewEnvSeg := seg(NewEnv^) + 2
  else
    NewEnvSeg := succ(seg(NewEnv^));
  {-Force the new environment to start at paragraph boundary}

  move(PtrSeg^, mem[pred(NewEnvSeg) : 0], 16);
  {-copy the old mcb and force to paragraph boundary}

  memw[pred(NewEnvSeg) : 3] := (1072 + length(NewPrompt)) shr 4;
  {-Alter the environment length by changing the dummy mcb}

  move(NewPrompt[1], memw[NewEnvSeg : 0], length(NewPrompt));
  {-install new prompt}

  memw[prefixseg:$2C] := NewEnvSeg;
  {-let the program know where the new env is}

  move(mem[EnvSegment : 0], mem[NewEnvSeg : length(NewPrompt)], 1024);
  {-shift the old env to the new area}
end;
