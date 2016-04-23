{Here is my solution to the problem of trapping Ctrl-Alt-Del. As extra suger,
I'm providing hooks to make this Program TSR. Happy hacking!

<<File: trapboot.pas>>

{$m 1024,0,0} { Necesarry if you want to make the Program resident. }
{****************************************************************************}
{* NoBoot                                                                   *}
{*                                                                          *}
{* This Program stops rebooting While it is running by trapping             *}
{* Ctrl-Alt-Del.                                                            *}
{*                                                                          *}
{----------------------------------------------------------------------------}

Uses
  Dos, Crt;

Var
  OldKBVec : Pointer;

{ Declare all Variables in our interrupt routine global so that no stack }
{ allocation of Variables will be done during the interrupt.             }
Var
  Regs : Registers;
  temp : Byte;
  KBflag1: Byte Absolute $40:$17;

Procedure MyKB; inTERRUPT;
Const
  EOI = $20;
  KB_DATA = $60;
  KB_CTL = $61;
  inT_CTL = $20;
  DEL_sc = $53;   { Scancode of the del key }

begin
  { Check if Alt and Ctrl are pressed }
  if ((KBFlag1 and 4)=4) and ((KBFlag1 and 8)=8) and
    (Port[KB_DATA]= DEL_sc) then begin { get scancode of pressed key }

    { The following four lines signals that the key is read and that the }
    { hardware interrupt is over. }
    temp:=Port[Kb_CTL];
    Port[KB_CTL]:= temp or $80;
    Port[KB_CTL]:= temp;
    Port[inT_CTL]:= EOI;

    { Don't do ANYTHinG here that requires BIOS. This 'Writeln' is using the }
    { Crt Unit.                                                              }
    Writeln('Ouch! That hurts!');  { Show we are here and alive! }
  end
  else begin
    intr($69, Regs); { Call the old interrupt routine }
  end;
end;

Var
  Ch : Char;

begin
  GetIntVec($9, OldKBVec);
  SetIntVec($69, OldKBVec);
  SetIntVec($9, @MyKB);

  { Keep(0); } { Uncomment and erase the rest of the lines to make this Program}

  Repeat
    Writeln('Press escape to Exit. or Ctrl-Alt-Del if you want...');
    ch:= ReadKey;
  Until ch=#27;

  { Forgetting the next line will very surely crash your Computer. }
  SetIntVec($9, OldKbVec);
end.
