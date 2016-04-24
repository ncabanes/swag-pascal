(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0118.PAS
  Description: Detecting Debug 2
  Author: ANDREW EIGUS
  Date: 11-26-94  05:07
*)

{
>> Possible. Just capture int 01h (as your HelpPC describes:
>> Single Step) and int 03h (as your HelpPC describes: Breakpoint).
>> They will be executed when there will be someone trapping your program
>> by steps. You may place such code in those interrupt procedures:
}

Program NoDebug;

uses Dos;

var
  OldInt01, OldInt03, OldExitProc : pointer;

Procedure DebugDetected;
Begin
  WriteLn('Hey! Stop tracing my program!');
  Halt
End; { DebugDetected }

Procedure NewInt01; interrupt; assembler;
Asm
  call dword ptr [OldInt01]
  call DebugDetected
End; { NewInt01 }

Procedure NewInt03; interrupt; assembler;
Asm
  call dword ptr [OldInt03]
  call DebugDetected
End; { NewInt03 }

Procedure NewExitProc; far;
Begin
  ExitProc := OldExitProc;
  SetIntVec($01, OldInt01);
  SetIntVec($03, OldInt03)
End; { NewExitProc }

Begin
  GetIntVec($01, OldInt01);
  GetIntVec($03, OldInt03);
  OldExitProc := ExitProc;
  ExitProc := @NewExitProc;
  SetIntVec($01, Addr(NewInt01));
  SetIntVec($03, Addr(NewInt03));

  WriteLn('Here your program goes...')
End.

