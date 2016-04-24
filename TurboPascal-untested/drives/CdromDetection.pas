(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0074.PAS
  Description: CD-ROM Detection
  Author: OLAF GREIS
  Date: 08-24-94  13:28
*)

{
Q: How do I detect, a certain drive is a CD-Rom?

A: The foolowing function returns True if the drive is a CD-ROM.
}

   Uses DOS;
   FUNCTION Is_CDROM(Drv : Char):BOOLEAN;
   VAR R  : Registers;
       CDR: string;
       cnt: byte;
   BEGIN
     Is_CDROM := false;
     CDR      := '';
     WITH R DO
       BEGIN
         AX := $1500;
         BX := $0000;
         CX := $0000;
         Intr( $2F, R );
         IF BX > 0 THEN
           BEGIN
             FOR cnt := 0 TO (bx-1) DO
             CDR := CDR +CHAR( CL + Byte('A') + cnt );
           END;
         Is_CDROM := POS( upcase(Drv), CDR ) > 0
       END
   END;

