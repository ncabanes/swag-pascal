(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0060.PAS
  Description: Keyboard Handler
  Author: FRED JOHNSON
  Date: 01-27-94  12:10
*)

{
>Can anyone shed some light on how to add characters to the keyboard
>buffers so i can echo commands right after my program exits?
}

unit kb;

interface

type

  string16 = string[16];
{
Procedure Name: StuffKBD();
Description   : Places a string of 16 chars or less into the
                keyboard buffer.
Returns       : Nothing
Calls         : Int 16h
}
procedure StuffKBD(sCommand : string16);

implementation

procedure StuffKBD(sCommand : string16);
var
  iStuff : integer;
  ucMove : BYTE;
begin
  for iStuff := 1 to length(sCommand) do
  begin
    ucMove := byte(sCommand[iStuff]);
    asm
      mov ah, $5;
      mov ch, $0;
      mov cl, ucMove;
      int     $16;
    end;
  end;
end;

end.

program kbstuff;
uses
  kb;

begin
   StuffKBD('kbstuff');
   {You can even add StuffKBD(#13);}
end.


