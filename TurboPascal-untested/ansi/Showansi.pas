(*
  Category: SWAG Title: ANSI CONTROL & OUTPUT
  Original name: 0017.PAS
  Description: SHOWANSI.PAS
  Author: GUY MCLOUGHLIN
  Date: 10-28-93  11:38
*)

{===========================================================================
Date: 10-10-93 (13:21)
From: GUY MCLOUGHLIN
Subj: Ansi in TP 6.0
---------------------------------------------------------------------------}

(* Program to demonstrate how to do display ANSI files *)
 program ShowANSI;
 uses
   crt;       (* Required for "ClrScr" and "Delay" routines.         *)

 const        (* ANSI display delay factor in 1/1000th's of a second *)
   co_DelayFactor = 40;

 type         (* Type definition.                                    *)
   st_80 = string[80];

   (***** Check for I/O errors.                                       *)
   (*                                                                 *)
   procedure CheckErrors(st_Msg : st_80);
   var by_Temp : byte;
   begin
     by_Temp := ioresult;
     if (by_Temp <> 0) then
       begin
         writeln('Error = ', by_Temp, ' ', st_Msg); halt
       end
   end;       (* CheckErrors.                                         *)

 var          (* Temporary string varialble.                          *)
   st_Temp   : string;

              (* Temporary text file variable.                        *)
   fite_Temp,
              (* Text "device-driver".                                *)
   fite_ANSI : text;

              (* Main program execution block.                        *)
 BEGIN
              (* Assign "text-device" driver to standard output.      *)
   assign(fite_ANSI, '');

              (* Attempt to open the ANSI "text-device" driver.       *)
   {$I-}
   rewrite(fite_ANSI);
   {$I+}
              (* Check for I/O errors.                                *)
   CheckErrors('Opening ANSI device driver');

              (* Assign ANSI ART file to display.                     *)
   assign(fite_Temp, 'TEST.ANS');
   {$I-}
   reset(fite_Temp);
   {$I+}
              (* Check for I/O errors.                                *)
   CheckErrors('Opening TEST.ANS file');

              (* Clear the screen.                                    *)
   clrscr;

              (* Diplay the ANSI ART file. While the end of the       *)
              (* ANSI ART file has not been reached, do...            *)
   while not eof(fite_Temp) do
     begin
              (* Read line of text from the ANSI ART file.            *)
       readln(fite_Temp, st_Temp);

              (* Check for I/O errors.                                *)
       CheckErrors('Reading from TEST.ANS file');

              (* Delay for co_DelayFactor milli-seconds.              *)
       delay(co_DelayFactor);

              (* Write the line of ANSI text to the "text-device      *)
              (* driver".                                             *)
       writeln(fite_ANSI, st_Temp);

              (* Check for I/O errors.                                *)
       CheckErrors('Writing to ANSI "text-device driver"')
     end;

              (* Close the ANSI ART text file.                        *)
   close(fite_Temp);

              (* Check for I/O errors.                                *)
   CheckErrors('Closing TEST.ANS');

              (* Close the ANSI "text device driver".                 *)
   close(fite_ANSI);

              (* Check for I/O errors.                                *)
   CheckErrors('Closing ANSI "text-device driver"')
 END.

