{
 Program Name : 16550.Pas
 Written By   : Jon Schneider & Rick Petersen
 E-Mail       : nothing
 Web Page     : nothing
 Program
 Compilation  : Turbo Pascal 5.0 or later

 Program Description :                                                        }

(*    This program will toggle the state of a 16550 UART's FIFO buffer.      *)
(*    It only seems to work with the Fossil driver X00.SYS version 1.09b.    *)
(*    By toggling the buffer ON, even 4.77 Mhz PC's are able to receive      *)
(*    files at a fixed rate of 19,200 baud without error.                    *)
(*                                                                           *)
(*    The code uses portions of the 'Turbo Professional' library. It         *)
(*    will not compile without it.                                           *)
(*                                                                           *)


{$R-}    {Range checking off}
{$B-}    {Boolean complete evaluation off}
{$S-}    {Stack checking off}
{$I+}    {I/O checking on}
{$N-}    {No numeric coprocessor}
{$M $4000, $4000, $A0000}


program a16550;


Uses
  Crt, TpString;

var
   num_params : Integer;
   input_byte : Byte;
   state : String;
   cmd_tail : Boolean;
   com_port : Word;

      
Procedure usage;

begin
   Writeln;
   WriteLn('16550 - A TPBoard utility for toggling the 16550''s FIFO buffer');
   WriteLn;
   WriteLn('USAGE:  16550 [1-4] [on/off/?]');
   WriteLn;
   WriteLn('        Where ''1'' thru ''4'' is the COM port,  ''on'' or ''off'' will toggle');
   WriteLn('        the FIFO buffer''s state, and ''?'' will show it''s status. Turning');
   WriteLn('        the buffered mode on is guaranteed to lock up your system if you');
   WriteLn('        are using OpusCom, and may cause problems with other programs.');
   WriteLn('        It WILL work with X00 version 1.09b, TPBoard, and ProComm Plus.');
   WriteLn;
   Halt
end;


begin                         { 16550 }
   CheckBreak := False;
   num_params := ParamCount;
   cmd_tail := num_params = 2;
   if (not cmd_tail) then
      usage;
   if ParamStr(1) = '1' then
      com_port := $3fa
   else if ParamStr(1) = '2' then
      com_port := $2fa
   else if ParamStr(1) = '3' then
      com_port := $3ea
   else if ParamStr(1) = '4' then
      com_port := $2ea
   else
      usage;
   state := StUpcase(ParamStr(2));
   if state = 'ON' then
      Port[com_port] := $07 
   else if state = 'OFF' then
      Port[com_port] := $00
   else if state = '?' then
      begin
         WriteLn;
         input_byte := Port[com_port];
         input_byte := input_byte and $c0;
         Write('FIFO buffer is turned ');
         if input_byte = $c0 then
            WriteLn('ON.')
         else
            WriteLn('OFF.');
      end
   else
      usage;
   WriteLn;
end.                    { of 16550.Pas }


