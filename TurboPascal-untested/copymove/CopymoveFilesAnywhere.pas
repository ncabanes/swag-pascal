(*
  Category: SWAG Title: FILE COPY/MOVE ROUTINES
  Original name: 0016.PAS
  Description: Copy/Move Files Anywhere
  Author: SWAG SUPPORT TEAM
  Date: 06-22-93  07:50
*)

{$A+,B-,D+,E+,F-,G+,I+,L+,N-,O-,P-,Q-,R-,S-,T-,V-,X+,Y+}
{$M 16384,0,655360}

USES DOS,Crt;

   TYPE

   { Define action type MOVE or COPY }
   cTYPE = (cMOVE,cCOPY);

   { Define the special structure of a DOS Disk Transfer Area (DTA) }
   DTARec      =  RECORD
                     Filler   :  ARRAY [1..21] OF BYTE;
                     Attr     :  BYTE;
                     Time     :  WORD;
                     Date     :  WORD;
                     Size     :  LONGINT;
                     Name     :  STRING [12];
                  END {DtaRec};

VAR
    OK : Integer;
    IP,OP : PathStr;  { input,output file names }

   FUNCTION Copier (cWhat : cTYPE; VAR orig: STRING;VAR nName: STRING) : Integer;

   { Copy or Move file through DOS if not on same disk. Retain original date,
     time and size and delete the original on Move.  The beauty here is that
     we can move files across different drives.  Also, we can rename file if
     we choose.     If error, function returns error number }


      CONST bufsize = $C000;            { About 48 KB - 49152 }

      TYPE
       fileBuffer = ARRAY [1..bufsize] OF BYTE;

      VAR   Regs: registers;
            src,dst: INTEGER;
            bsize,osize: LONGINT;
            buffer : ^fileBuffer;
            DTABlk : DTARec;
            fError : BOOLEAN;

      FUNCTION CheckError(err : Integer) : BOOLEAN;
      BEGIN
      CheckError := (Err <> 0);
      fError     := (Err <> 0);
      Copier     := err;
      END;

      PROCEDURE delfile (VAR fName: STRING);

         VAR   Regs: registers;

         BEGIN
            WITH Regs do BEGIN
               ah := $43;             { Make file R/W for delete }
               al := 1;
               cx := 0;               { Normal file }
               ds := Seg(fName[1]);   { fName is the fully qualified }
               dx := Ofs(fName[1]);   { pathname of file, 0 terminated }
               MsDos (Regs);
               IF CheckError(Flags AND 1) THEN EXIT
               ELSE BEGIN
                  ah := $41;            { Delete file through fName }
                  { ds:dx stil valid from set-attributes }
                  MsDos (Regs);
                  IF CheckError(Flags AND 1) THEN EXIT;
                  END
               END
         END;

      BEGIN

         Copier := 0;  { Assume Success }
         FindFirst(Orig,Anyfile,SearchRec(DTABlk));
         IF CheckError(DosError) THEN EXIT;

         WITH Regs DO BEGIN
            ah := $3D;                  { Open existing file }
            al := 0;                    { Read-only }
            ds := Seg(orig[1]);         { Original filename (from) }
            dx := Ofs(orig[1]);
            MsDos (Regs);
            IF CheckError(Flags AND 1) THEN Exit
            ELSE BEGIN
               src := ax;               { Handle of the file }

               ah := $3C;               { Create a new file }
               cx := 0;                 { Start as normal file }
               ds := Seg(nName[1]);     { Pathname to move TO }
               dx := Ofs(nName[1]);
               MsDos (Regs);
               IF CheckError(Flags AND 1) THEN Exit
               ELSE
                  dst := ax
               END
            END;

         osize := DTABlk.size;       { Size of file, from "findfirst" }
         WHILE (osize > 0) AND NOT ferror DO BEGIN

            IF osize > bufsize THEN
               bsize := bufsize        { Too big for buffer, use buffer size }
            ELSE
               bsize := osize;

            IF BSize > MAXAVAIL THEN BSize := MAXAVAIL;

            GETMEM (buffer, BSize);    { Grap some HEAP memory }

            WITH Regs DO BEGIN
               ah := $3F;               { Read block from file }
               bx := src;
               cx := bsize;
               ds := Seg(buffer^);
               dx := Ofs(buffer^);
               MsDos (Regs);
               IF CheckError(Flags AND 1) THEN {}
               ELSE BEGIN
                  ah := $40;            { Write block to file }
                  bx := dst;
                  { cx and ds:dx still valid from Read }
                  MsDos (Regs);
                  IF CheckError(Flags AND 1) THEN {}
                  ELSE IF ax < bsize THEN
                     BEGIN
                     CheckError(98); { disk full }
                     END
                  ELSE
                     osize := osize - bsize
                  END;
               END;

            FREEMEM (buffer, BSize);   { Give back the memory }
            END;

         IF NOT ferror AND (cWHAT = cMOVE) THEN
         WITH Regs DO
            BEGIN
            ah := $57;                  { Adjust date and time of file }
            al := 1;                    { Set date }
            bx := dst;
            cx := DTABlk.time;          { Out of the "find" }
            dx := DTABlk.date;
            MsDos (Regs);
            CheckError(Flags AND 1);
            END;

         WITH Regs DO
            BEGIN
            ah := $3E;                  { Close all files, even with errors! }
            bx := src;
            MsDos (Regs);
            ferror := ferror OR ((flags AND 1) <> 0);
            ah := $3E;
            bx := dst;
            MsDos (Regs);
            ferror := ferror OR ((flags AND 1) <> 0)
            END;

         IF ferror THEN EXIT            { we had an error somewhere }
         ELSE WITH Regs DO
            BEGIN
            ah := $43;                  { Set correct attributes to new file }
            al := 1;                    { Change attributes }
            cx := DTABlk.attr;          { Attribute out of "find" }
            ds := Seg(nName[1]);
            dx := Ofs(nName[1]);
            MsDos (Regs);
            IF CheckError(Flags AND 1) THEN EXIT
            ELSE
               If (cWHAT = cMOVE) THEN DelFile (orig) { Now delete the original }
            END                                       { if we are moving file }
      END;

BEGIN
clrscr;
IP := 'queen1.PAS';
OP := 'd:\temp\queen1.pas';
OK := Copier(cCOPY,IP,OP);
WriteLn(OK);
END.
