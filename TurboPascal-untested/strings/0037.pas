TYPE
     String2 = STRING[2];
     String4 = STRING[4];
     String8 = STRING[8];

{*****************************************************************************
 * Function ...... HexB()
 * Purpose ....... To return a byte's hexidecimal representation
 * Parameters .... b          Byte to convert to Hex
 * Returns ....... The hex string equivalent of <b>
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION HexB( b: BYTE ): String2;
CONST
     HexChar : ARRAY[0..15] OF Char = '0123456789ABCDEF';
BEGIN
     Hexb := HexChar[b SHR 4] + HexChar[b AND $F];
END;

{*****************************************************************************
 * Function ...... HexW()
 * Purpose ....... To return a word's hexidecimal representation
 * Parameters .... w          Word to convert to Hex
 * Returns ....... The hex string equivalent of <w>
 * Notes ......... Uses function HexB
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION HexW( w: WORD ): String4;
BEGIN
     HexW := HexB(HI(w)) + HexB(LO(w));
END;

{*****************************************************************************
 * Function ...... HexDW()
 * Purpose ....... To return a double-word's hexidecimal representation
 * Parameters .... dw          Double-word to convert to Hex
 * Returns ....... The hex string equivalent of <dw>
 * Notes ......... Uses functions HexB, wHi, and wLo
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION HexDW( dw: LONGINT ): String8;
BEGIN
     HexDW := HexB(HI(wHi(dw))) + HexB(LO(wHi(dw))) +
              HexB(HI(wLo(dw))) + HexB(LO(wLo(dw)))
END;
