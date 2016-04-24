(*
  Category: SWAG Title: CRT ROUTINES
  Original name: 0022.PAS
  Description: 80x50 text mode
  Author: IAN LIN
  Date: 08-24-94  13:17
*)

 AS> Could someone tell me how to access 80x50 text mode in
 AS> Tp 6.0 = mode con lines=50 in dos.

Uses Crt;
begin
 textmode(c80+font8x8); {80x50}
 textmode(c80); {80x25}
end.

