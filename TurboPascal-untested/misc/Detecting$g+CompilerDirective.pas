(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0116.PAS
  Description: Detecting $G+ Compiler Directive
  Author: ALFONS HOOGERVORST
  Date: 11-26-94  05:07
*)

(*
> I have now added the {$IFOPT G+} to most of my current sources, but I
> would like default detection code in my libraries (often used TPUs)
> Even if my TPUs are compiled in G- (which they always are, because
> I update them with TPC from a batch file), but if my 'main' source
> files are accidentally G+ I would like that detected by my library
> code.
*)

{$X+}{<<< Need this and strings unit }
{===========================================================================
 Copyrighted by Alfons Hoogervorst 1994 AD.
 Well. Ok. It's dumped in the public domain.
 ==========================================================================}

program Test8086;

uses
  WinCrt, Strings;

const
  { My firstname expressed in bytes, I guess. Use same bytes if possible
    to overcome the byte ordering on PC's }
  SEARCHID = $A2A2A2A2;
  SEARCHBYTE = Byte(SEARCHID); { LoByte }
  PUSHINT  = 2;


procedure CallInOne(int: Integer);
begin
  { So I return }
end;


procedure CheckThisOut;
begin
  asm
    jmp @Continue
    dd SEARCHID                 { Bytes we're looking for }
  @continue:
  end;
  { if G+:  push 0x02
    else  mov ax,02;  push ax
  }
  CallInOne(PUSHINT)
end;

type
  TGOption = (Error, Goff, Gon);

function IsOptionGOn: TGOption;
type
  PDword = ^Longint;
var
  Opcodes: PChar;
  i: Integer; { Say 50 bytes }
begin
  IsOptionGOn := Error;
  OpCodes := PChar(@CheckThisOut);

  { Find our ID }
  for i := 0 to 49 do { search some 50 bytes, must be enough }
  begin
    if PDword(OpCodes)^ = SEARCHID then
    begin { Found our bytes }
      OpCodes := OpCodes + sizeof(Longint); { Next instruction }

      { Check if it's PUSH PUSHINT instruction }
      if (OpCodes^ = #$6A) and ((OpCodes+1)^ = Char(PUSHINT)) then
        IsOptionGOn := Gon
      else IsOptionGOn := Goff;
      exit
    end;
    OpCodes := OpCodes + 1 { Try next }
  end;
end;

begin
  WriteLn('I Call You Call Me? Ok!');

  case IsOptionGOn of
    Error:
    begin
      WriteLn('Error... Borland Pascal code generation changed dramatically');
      WriteLn('The world is collapsing, all programs have become
incompatible');      WriteLn('The Horror of It! Get me some assembler and I''ll
fix it!')    end;
    Gon:
    begin
      WriteLn('''t Was On');
    end;
    Goff:
    begin
      WriteLn('''t Was Off');
    end;
  end;
end.

(*
What am I doing here? Just looking for a push instruction. If {$G} on
constants are pushed with an immediate push instruction. Sounds
dificult? Well, just forget it, implement these functions in a unit
and you have your long-awaited test function.

I have some notes on my own code. If you're using my check-80X86 function
NEVER do the following things:
*)

if (OptionGOn = Goff) then
begin
  WriteLn('This code is compiled with $G+');
  Halt(2) {<<<<< PROBLEMS!!! }
end;
(*
Why?

If $G has been enabled you'll get:

push 2
call far HALT

And (as you noted) an 808X does not accept this.

Instead use this:
*)

if (OptionGOn = GOn) then
begin
  WriteLn('Option $G enabled message');
  Halt(Integer(OptionGOn)) { Or pass a variable }
end;

(*
In plain words: after checking the G-state with my function, don't call a
function with constant parameters. Always pass variables/function-results as
parameters.
This is not "portable":
*)

const
  ERROR_GERROR  = 2;
  ANOTHER_CONST = 3;

if { my test } then
begin
  IWantToExitRightNow(ERROR_GERROR, ANOTHER_CONST, 4, 6, 7);

end;

{ Instead try this: }

if { my test } then
begin
  IWantToExitRightNow(VarIndicatingError, VarForAnotherConst,
     FunctionCall4, FunctionCall6, VarContaining7)

end;

{
This is _only_ necessary in the "code" block immediately following my
function, not in your other code. By the way: I have written a unit for
detecting this $G-state. It's partly written in asm. This unit does not
require the "use" of other units.
}

