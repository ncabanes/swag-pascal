(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0003.PAS
  Description: PROMPT.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:45
*)

{$A+,B-,F-,L-,N-,O-,R-,S-,V-}

Unit prompt;

{

Author:   Trevor J Carlsen
          PO Box 568
          Port Hedland
          Western Australia 6721
          61-[0]-91-73-2026  (voice)
          61-[0]-91-73-2930  (data )
          
Released into the public domain.

This Unit will automatically create a predefined prompt when shelling to Dos.
if you wish to create your own custom prompt, all that is required is to give
the Variable NewPrompt another value and call the Procedure ChangeShellPrompt.

}

Interface

Uses Dos;

Var
  NewPrompt : String;

Procedure ChangeShellPrompt(Nprompt: String);

Implementation

 Type
   EnvArray  = Array[0..32767] of Byte;
   EnvPtr    = ^EnvArray;
 Var
   EnvSize, EnvLen, EnvPos: Word;
   NewEnv, OldEnv         : EnvPtr;
   TempStr                : String;
   x                      : Word;

 Procedure ChangeShellPrompt(Nprompt: String);

   Function MainEnvSize: Word;
     Var
       x      : Word;
       found  : Boolean;
     begin
       found  := False; x := 0;
       Repeat
         if (OldEnv^[x] = 0) and (OldEnv^[x+1] = 0) then
           found := True
         else
           inc(x);
       Until found;
       MainEnvSize := x - 1;
     end; { MainEnvSize}

   Procedure AddEnvStr(Var s; Var offset: Word; len: Word);
     Var st : EnvArray Absolute s;
     begin
       move(st[1],NewEnv^[offset],len);
       inc(offset,len+1);
     end;

 begin
   OldEnv   := ptr(MemW[PrefixSeg:$2C],0);
   { this gets the actual starting segment of the current Program's env }

   EnvSize      :=  MemW[seg(OldEnv^)-1:3] shl 4;
   { Find the size of the current environment }

   if MaxAvail < (EnvSize+256) then begin
     Writeln('Insufficient memory');
     halt;
   end;

   GetMem(NewEnv, EnvSize + $100);
   if ofs(NewEnv^) <> 0 then begin
      inc(LongInt(NewEnv),$10000 + ($10000 * (LongInt(NewEnv) div 16)));
      LongInt(NewEnv) := LongInt(NewEnv) and $ffff0000;
   end;
   FillChar(NewEnv^,EnvSize + $100,0);
   { Allocate heap memory For the new environment adding enough to allow }
   { alignment to a paraGraph boundary or a longer prompt than the default }
   { and initialise to nuls }
   EnvPos   := 0;

   AddEnvStr(Nprompt,EnvPos,length(Nprompt));
   For x := 1 to EnvCount do begin
     TempStr := EnvStr(x);
     if TempStr <> GetEnv('PROMPT') then
       AddEnvStr(TempStr,EnvPos,length(TempStr));
   end; { For }
   inc(EnvPos);
   { Transfer old env Strings except the prompt to new environment }

   if lo(DosVersion) > 2 then
     AddEnvStr(OldEnv^[MainEnvSize + 2],EnvPos,EnvSize-(MainEnvSize + 2));
   { Add the rest of the environment }

   MemW[PrefixSeg:$2C] := seg(NewEnv^);
   { let the Program know where the new environment is }
 end;  { ChangeShellPrompt }

end.  { prompt }
  

