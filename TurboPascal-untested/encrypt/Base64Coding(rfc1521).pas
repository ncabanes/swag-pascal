(*
  Category: SWAG Title: FILE & ENCRYPTION ROUTINES
  Original name: 0037.PAS
  Description: Base64 coding (RFC 1521)
  Author: HENDRIK T. VOELKER
  Date: 08-30-97  10:09
*)


UNIT base64;

 {
   Copyright (c) 1996 Hendrik T. Voelker <basicbaer@emcom.doo.donut.de>

   Base64-Kodierung nach RFC 1521
 }

 INTERFACE { ************************************************************** }

   TYPE
     tripel_at          = ARRAY [1..3] OF
                            Byte;

     quadrupel_at       = ARRAY [1..4] OF
                            Byte;

   FUNCTION codeb64
           ( cnt        : Byte;
             t          : tripel_at )
           : STRING;

   PROCEDURE decodeb64
            (     strg  : STRING;
              VAR cnt   : Byte;
              VAR t     : tripel_at );

 IMPLEMENTATION { ********************************************************* }

   CONST
     padd               = 64;

     code64             : STRING[65]
                            = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
                              'abcdefghijklmnopqrstuvwxyz' +
                              '0123456789+/=';

   FUNCTION codeb64;

     VAR        { *codeb64* }
       q                : quadrupel_at;
       strg             : STRING;
       idx              : Byte;

     BEGIN      { *codeb64* }
       IF (cnt < 3)
         THEN BEGIN
                t[3] := 0;
                q[4] := padd;
              END
         ELSE q[4] := (t[3] AND $3f);

       IF (cnt < 2)
         THEN BEGIN
                t[2] := 0;
                q[3] := padd;
              END
         ELSE q[3] := Byte (((t[2] SHL 2) OR (t[3] SHR 6)) AND $3f);

       q[2] := Byte (((t[1] SHL 4) OR (t[2] SHR 4)) AND $3f);

       q[1] := ((t[1] SHR 2) AND $3f);

       strg := '';
       FOR idx := 1 TO 4 DO
         strg := (strg + code64[(q[idx] + 1)]);

       codeb64 := strg;
     END;       { *codeb64* }

   PROCEDURE decodeb64;

     VAR        { *decodeb64* }
       idx              : Byte;
       q                : quadrupel_at;

     BEGIN      { *decodeb64* }
       cnt := 3;

       FOR idx := 1 TO 4 DO
         BEGIN
           q[idx] := (Pos (strg[idx], code64) - 1);
           IF (q[idx] = padd)
             THEN Dec (cnt);
         END;

       t[1] := Byte ((q[1] SHL 2) OR ((q[2] SHR 4) AND $03));
       t[2] := Byte ((q[2] SHL 4) OR ((q[3] SHR 2) AND $0f));
       t[3] := Byte ((q[3] SHL 6) OR (q[4] AND $3f));
     END;       { *decodeb64* }

 { INITIALIZATION ********************************************************* }

   END.


