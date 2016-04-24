(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0046.PAS
  Description: Setting DOS Prompt
  Author: TREVOR CARLSON
  Date: 02-03-94  16:16
*)


{
TF>How does one alter a DOS environment variable in PASCAL and have the change
TF>reflected after the program terminates, leaving the user in DOS, and the use
TF>types SET?  This has been bugging me for a while. I know that there are two
TF>copies of the environment and I need to access the top one, but I don't know
TF>how.

The following example shows how to change the prompt: }

function MastEnvSeg(var Envlen: word): word;
  {-returns the master environment segment }
  var
    mcb,temp,handle : word;
    lastmcb : boolean;
  begin
    MastEnvSeg := 0;
    Envlen := 0;
    handle := MemW[0: $ba]; {-$2e * 4 + 2}
    {-The interrupt vector $2e points to the first paragraph of
      allocated to the command processor}
    mcb := pred(handle);
    {-mcb now points to the memory control block for the command processor}
    repeat
      temp := Mcb+MemW[Mcb:3]+1;
      if (Mem[temp:0] = $4d) and (MemW[temp:1] = handle) then begin
        lastmcb := false;
        mcb     := temp;
      end
      else
        lastmcb := true;
    until lastmcb;
    EnvLen := Mem[Mcb:3] shl 4;
    MastEnvSeg := succ(Mcb);
   end;


  procedure InitNewPrompt;
  {-set up a new prompt for shelling to dos}
  type
    _2karray  = array[1..2048] of byte;
    SegPtr    = ^_2karray;
  const
    NewPrompt : string =
    ('PROMPT=Type EXIT to return to program$_$p$g'+#0);
  var
    EnvSegment,
    NewEnvSeg      : word;
    PtrSeg,
    NewEnv         : SegPtr;
  begin
    EnvSegment := memw[prefixseg:$2C];
    {-this gets the actual starting segment of the current program's env}

    PtrSeg := ptr(pred(EnvSegment),0);
    {-The segment of the program's MCB - (Memory control block) }

    getmem(NewEnv,1072+length(NewPrompt));
    {-Allocate heap memory and allow enough room for a dummy mcb }

    if ofs(NewEnv^) <> 0 then
      NewEnvSeg := seg(NewEnv^) + 2
    else
      NewEnvSeg := succ(seg(NewEnv^));
    {-Force the new environment to start at paragraph boundary}

    move(PtrSeg^,mem[pred(NewEnvSeg):0],16);
    {-copy the old mcb and force to paragraph boundary}

    memw[pred(NewEnvSeg):3] := (1072+length(NewPrompt)) shr 4;
    {-Alter the environment length by changing the dummy mcb}

    move(NewPrompt[1],memw[NewEnvSeg:0],length(NewPrompt));
    {-install new prompt}

    memw[prefixseg:$2C] := NewEnvSeg;
    {-let the program know where the new env is}

    move(mem[EnvSegment:0],mem[NewEnvSeg:length(NewPrompt)],1024);
    {-shift the old env to the new area}
  end;


