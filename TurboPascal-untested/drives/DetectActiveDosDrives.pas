(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0008.PAS
  Description: Detect Active DOS Drives
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:38
*)

{ JW│ How do I detect active drives in Pascal?  My Program would crash if you
   │ Typed in a non-existent drive as either source or destination.

Here's the method I use:
}
Uses
  Dos;

Var
  Isthere : Boolean;

Function ChangeDrive( drv: Char ): Boolean;
(*
Takes drive letter as parameter, returns True if change
succeeded, False if change failed (invalid drive)
*)
Var
  Regs:   Dos.Registers;
  NewDrv: Byte;
begin
(* Calculate drive code For desired drive *)
  NewDrv := orD( UpCase( drv ) ) - orD( 'A' ); (* A: = 0 *)

(* Change drive *)
  Regs.DL := NewDrv;
  Regs.AH := $0E;            (* Function 0Eh: Select Disk *)
  MSDos( Regs );

(* See if the change 'took' *)
  Regs.AH := $19; (* Function 19h:  Get current drive *)
  MSDos( Regs );
  ChangeDrive := (Regs.AL = NewDrv);
end; (* ChangeDrive *)

begin
  isthere := ChangeDrive('a');
  Writeln ('a: ',isthere);
  isthere := ChangeDrive('b');
  Writeln ('b: ',isthere);
  isthere := ChangeDrive('c');
  Writeln ('c: ',isthere);
  isthere := ChangeDrive('d');
  Writeln ('d: ',isthere);
  isthere := ChangeDrive('e');
  Writeln ('e: ',isthere);
end.

