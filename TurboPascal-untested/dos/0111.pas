{
I recently loaded some SWAG Pascal files from a CDROM and found the question -
How do you get or set the DOS version ?

Getting the DOS version is easy - call INT 21H, Function 30H - }
 
USES Dos;
 
procedure id_version;
 
var regs : registers;
 
begin
  regs.ah := $30;
  msdos( regs);
  write( 'DOS version = ', regs.al,'.' );
  IF ( regs.ah < 10 ) THEN write( '0' );
  writeln( regs.ah );
end;
 
Setting the DOS version is another matter - I suspect you will have to 
disassemble your boot files to do this. I've not tried it and cannot recommend 
it!

However, some DOS programs ( especially games ) do test the DOS version before
running by using the INT 21H Function 30H as above. This CAN be programmed
around by diverting calls to INT 21H to a custom handler and capturing the
Function 30 calls. I've included a minimal TSR to do this.
 
I can't see this being of any use to users with standard MSDOS setups as your
program still won't run but is of use if you have an unusual or custom setup
e.g. DRDOS or Novell DOS users. 
 
Many thanks anyway for the tips in the SWAG collection - I've used several
including WHATCPU routines, PCX file readers / writers and Douglas Webb's
JumpToInterrupt !
 
Finally - do you have a compuserve forum?
 
Richard Muirhead.
 
100675.2153@compuserve.com.

(***************************************************)
 
PROGRAM dos6;
{$M 1024, 0,0 }
 
USES dos;
 
CONST
  new_dos_version = 6;
{
  new_dos_version must hold the word in AX returned by INT 21H, Function 30.
  As AL = major version number, and
     AH = minor version number, the following are valid codes:-
 
    DOS version                new_dos_version 
    3.20                       5123
    3.30                       7683
    4.00                          4
    4.01                        260
    5.00                          5
    6.00                          6
    6.22                       5638 
    6.23                       5894
 
  new_dos_version = 256*minor_version + major_version
}
 
VAR p : pointer;
 
{
 FROM SWAG - Douglas Webb 27/1/94.
 
 If you have an interrupt handler and you want to jump to the original
 interrupt handler and NOT return to your handler.
 
 Call the following procedure with a pointer to the old interrupt handler
 ( which you'd better have saved ) :-
}
 
PROCEDURE JumpToInterrupt( oldvector : Pointer );
 
INLINE(                        { Jump to old Intr from local ISR  }
   $5B/                        { POP  BX IP part of vector        }
   $58/                        { POP  AX CS part of vector        }
   $87/$5E/$0E/                { XCHG BX,[BP+14] switch ofs/bx    }
   $87/$46/$10/                { XCHG AX,[BP+16] switch seg/ax    }
   $8B/$E5/                    { MOV  SP,BP                       }
   $5D/                        { POP  BP                          }
   $07/                        { POP  ES                          }
   $1F/                        { POP  DS                          }
   $5F/                        { POP  DI                          }
   $5E/                        { POP  SI                          }
   $5A/                        { POP  DX                          }
   $59/                        { POP  CX                          }
   $CB                         { RETF      Jump [ToOldVector]     }
   );                          { to original timer vector         }
{end JumpToInterrupt}
 
PROCEDURE New21( Flags,CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP : word );
interrupt;
 
BEGIN
  IF Hi( AX ) = $30 THEN
      AX := new_dos_version
    ELSE
      JumpToInterrupt( p );
END;
 
BEGIN
  getintvec( $21, p );
  setintvec( $21, @new21 );
  keep( 0 );
END.
 
(***************************************************************)

program getver;
 
uses dos;
 
procedure id_version;
 
var regs : registers;
 
begin
  regs.ah := $30;
  msdos( regs);
  write( 'DOS version = ', regs.al,'.' );
  IF ( regs.ah < 10 ) THEN write( '0' );
  writeln( regs.ah );
end;
 
begin
  id_version;
end.

