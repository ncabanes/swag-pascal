(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0012.PAS
  Description: HEX2BIN1.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

Function Hex2Bin (B : Byte) : String;

Var
  Temp : String [8];
  Pos, Mask : Byte;

begin
  Temp := '00000000';
  Pos := 8;
  Mask := 1;
  While (Pos > 0) Do
    begin
      if (B and Mask)
        then
          Temp [Pos] := '1';
      Dec (Pos);
      Mask := 2 * Mask;
    end;
  Hex2Bin := Temp;
end;







Function Hex2Bin( HexByte:Byte ):String; External; {$L HEX2Bin.OBJ}
Var i : Integer;
begin
  For i := $00 to $0F do WriteLn( Hex2Bin(i) );
end.
(*********************************************************************)

 The Assembly source ...

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
code        segment Byte 'CODE'     ; HEX2Bin.Asm
            assume  cs:code
; Function Hex2Bin( HexByte :Byte ) :String;
String      equ     dWord ptr [bp+6]
HexByte     equ     [bp+4]
            public  Hex2Bin
Hex2Bin     proc    Near            ; link into main TP Program
            push    bp              ; preserve
            mov     bp,sp           ; stack frame
            les     di, String      ; result String Pointer
            cld                     ; Forward scan
            mov     cx,8            ; 8 bits in a Byte
            mov     al,cl           ; to set
            stosb                   ; binary String length
            mov     ah, HexByte     ; get the hex Byte
    h2b:    xor     al,al           ; cheap zero
            rol     ax,1            ; high bit to low bit
            or      al,'0'          ; make it ascii
            stosb                   ; put it in String
            loop    h2b             ; get all 8 bits
            pop     bp              ; restore
            ret     2               ; purge stack & return
Hex2Bin     endp
code        ends
            end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 Here's the assembled OBJ File ...

 Put all of this remaining message in a Text File named HEX2Bin.SCR,
 then Type "DEBUG < HEX2Bin.SCR" (no quotes) to create HEX2Bin.ARC;
 then extract HEX2Bin.OBJ using PKUNPAK or PAK ...
 ---------------------------- DEBUG script ----------------------------
 N HEX2Bin.ARC
 E 0100 1A 02 48 45 58 32 42 49 4E 2E 4F 42 4A 00 5E 65 00 00 00 4A 19
 E 0115 13 22 60 F2 65 00 00 00 80 0D 00 0B 68 65 78 32 62 69 6E 2E 41
 E 012A 53 4D A9 96 07 00 00 04 43 4F 44 45 44 98 07 00 20 1D 00 02 02
 E 013F 01 1F 90 0E 00 00 01 07 48 45 58 32 42 49 4E 00 00 00 6A 88 04
 E 0154 00 00 A2 01 D1 A0 21 00 01 00 00 55 8B EC C4 7E 06 FC B9 08 00
 E 0169 8A C1 AA 8A 66 04 32 C0 D1 C0 0C 30 AA E2 F7 5D C2 02 00 21 8A
 E 017E 02 00 00 74 1A 00
 Rcx
 0084
 W
 Q
 ----------------------------------------------------------gbug-1.0b--

