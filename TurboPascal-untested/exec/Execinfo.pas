(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0002.PAS
  Description: EXECINFO.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:45
*)

{$M 4096,0,4096}

Uses
  Dos, Prompt;

begin
  ChangeShellPrompt('Hi There');
  SwapVectors;
  Exec(GetEnv('COMSPEC'),'');
  SwapVectors;
end.
