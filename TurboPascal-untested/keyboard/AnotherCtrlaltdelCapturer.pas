(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0093.PAS
  Description: Another Ctrl-Alt-Del Capturer
  Author: DAVE JARVIS
  Date: 05-26-95  23:01
*)

{
> I was wondering if anybody out there has written a PROCEDURE to
> disable control-alt-delete in a program.
}

USES DOS, Crt;
 
CONST 
  KBD_INT  = $9;    { Keyboard interrupt service routine (ISR) } 
 
  CTRL_ALT =  12;   { Control + Alt toggle flag status } 
  KEYBOARD = $60;   { Keyboard port address } 
  DEL      =  83;   { Delete key, before mapping translation } 
  ESC      = $1B;   { Escape key, after mapping translation } 
  PIC      = $20;   { Priority Interrupt Controller port address } 
  EOI      = $20;   { End of interrupt signal } 
 
VAR 
  KbdIntVec : PROCEDURE;                  { Calls old keyboard handler } 
  SwitCheck : BYTE ABSOLUTE $0000:$0417;  { Checks keyboard toggle flags } 
  Reboot    : BOOLEAN;                    { TRUE if 3-fingered salute } 
 
{$F+}
PROCEDURE KeyClick; INTERRUPT; 
Begin 
  IF ((SwitCheck AND CTRL_ALT) = CTRL_ALT) AND (Port[ KEYBOARD ] = DEL) THEN 
  Begin 
    Reboot      := TRUE; 
    Port[ PIC ] := EOI; 
  End 
  ELSE 
  Begin 
    Inline( $9C );  { PUSHF } 
 
    { Call old ISR using saved vector } 
    KbdIntVec; 
  End; 
End; 
{$F-} 
 
VAR 
  Ch : CHAR; 
 
BEGIN 
  ClrScr; 
 
  GetIntVec( KBD_INT, @KbdIntVec ); 
  SetIntVec( KBD_INT, Addr( Keyclick ) ); 
 
  Reboot := FALSE;

  WriteLn( 'Start typing.  Press CTRL-ALT-DEL to quit.  /[:)' );

  Repeat
    IF KeyPressed THEN
    Begin
      Ch := ReadKey;

      Write( Ch );
    End;
  Until Reboot;

  WriteLn;
  WriteLn( 'Shranks!' );

  SetIntVec( KBD_INT, Addr( KbdIntVec ) );
END.

