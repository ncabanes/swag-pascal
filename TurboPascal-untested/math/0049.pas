{
From: GREG VIGNEAULT
Subj: 32-bit unsigned integers
Does there exist a 32 BIT unsigned (0..xxxx) word in pascal ??
i've got a hexidecimal string (ex. 'E72FAB32') .. now i want to
convert this to a decimal value (not below 0 such as longint and
extended do) so i can devide this by for example 5000000


 (Note: check at END of code for the required ULONGS.OBJ file)
}

(*******************************************************************)
PROGRAM Longs;                      { compiler: Turbo Pascal v4.0+  }
                                    { 18-Nov-93 Greg Vigneault      }
{ Purpose: arithmetic functions for unsigned long integers in TP... }
(*-----------------------------------------------------------------*)
{ The following external (assembly) functions *MUST* be linked into }
{ the main Program, _not_ a Unit.                                   }

{$L ULONGS.OBJ}                         { link in the assembly code }
FUNCTION LongADD (Addend1,Addend2:LONGINT):LONGINT;   EXTERNAL;
FUNCTION LongSUB (LongWord,Subtrahend:LONGINT):LONGINT;  EXTERNAL;
FUNCTION LongMUL (Multiplicand,Multiplier:LONGINT):LONGINT; EXTERNAL;
FUNCTION LongDIV (Dividend,Divisor:LONGINT):LONGINT;  EXTERNAL;
FUNCTION LongMOD (Dividend,Divisor:LONGINT):LONGINT;  EXTERNAL;
PROCEDURE WriteULong (LongWord:LONGINT;     { the longword          }
                      Width:BYTE;           { _minimum_ field width }
                      FillChar:CHAR;        { leading space char    }
                      Base:BYTE); EXTERNAL; { number base 2..26     }
(*-----------------------------------------------------------------*)
PROCEDURE TestLongs ( Long1,Long2 :LONGINT;
                      Width       :BYTE;
                      Fill        :CHAR;
                      Base        :BYTE);
      PROCEDURE Reduce1;
        BEGIN
          WriteULong (Long1,1,Fill,10);  Write (',');
          WriteULong (Long2,1,Fill,10);  Write (') result: ');
        END {Reduce1};
      PROCEDURE Reduce2;
        BEGIN
          CASE Base OF
            2  : WriteLn (' binary');   { base 2: binary            }
            10 : WriteLn (' dec');      { base 10: familiar decimal }
            16 : WriteLn (' hex');      { base 16: hexadecimal      }
          END;
        END {Reduce2};
  BEGIN {TestLongs}
      Write ('LongADD (');  Reduce1;
      WriteULong ( LongADD(Long1,Long2),Width,Fill,Base );  Reduce2;
      Write ('LongSUB (');  Reduce1;
      WriteULong ( LongSUB(Long1,Long2),Width,Fill,Base );  Reduce2;
      Write ('LongMUL (');  Reduce1;
      WriteULong ( LongMUL(Long1,Long2),Width,Fill,Base );  Reduce2;
      Write ('LongDIV (');  Reduce1;
      WriteULong ( LongDIV(Long1,Long2),Width,Fill,Base );  Reduce2;
      Write ('LongMOD (');  Reduce1;
      WriteULong ( LongMOD(Long1,Long2),Width,Fill,Base );  Reduce2;
      WriteLn;
  END {TestLongs};
(*-----------------------------------------------------------------*)

VAR Long1, Long2  :LONGINT;
    Width, Base   :BYTE;

BEGIN

  Long1 := 2147483647;
  Long2 := 1073741823;
  Width := 32;

  WriteLn;
  FOR Base := 2 TO 16 DO
    IF Base IN [2,10,16] THEN
      TestLongs (Long1,Long2,Width,'_',Base);

END.

---------------------------------------------------------------------------

 Run this program, it will create ULONGS.ZIP, which contains the
 ULONGS.OBJ file needed for the LongXXX functions...

(*********************************************************************)
 PROGRAM A; VAR G:File; CONST V:ARRAY [ 1..701 ] OF BYTE =(
80,75,3,4,20,0,0,0,8,0,236,50,114,27,51,246,185,93,71,2,0,0,189,3,0,0,
10,0,0,0,85,76,79,78,71,83,46,79,66,74,189,83,77,104,19,65,20,126,179,
187,217,196,53,104,67,176,162,1,181,135,10,118,80,212,158,36,151,166,
110,215,22,154,4,76,119,133,66,75,241,160,23,169,146,102,123,14,132,80,
233,92,4,65,132,122,8,197,91,142,198,155,212,52,238,138,181,136,157,205,
65,75,15,5,91,145,18,255,64,76,80,138,248,54,19,17,4,193,147,11,111,190,
247,190,247,189,111,222,30,38,31,6,205,190,118,125,250,234,204,169,68,
38,249,228,78,24,64,209,19,99,9,229,124,90,31,234,185,27,132,169,19,32,
73,164,142,217,192,126,73,150,201,158,91,195,0,82,112,52,157,186,144,
208,245,9,128,118,154,76,235,5,34,82,125,196,250,218,97,51,230,224,141,
95,2,115,116,1,64,187,116,113,100,108,200,244,9,0,168,220,84,0,22,9,47,
157,4,2,255,254,157,45,69,37,9,192,100,239,153,161,244,109,23,171,185,
36,251,204,12,141,89,225,254,21,246,154,213,250,189,86,243,118,171,57,
87,207,36,138,85,251,67,209,179,119,152,17,234,219,142,47,207,70,216,
58,93,102,207,42,210,188,165,190,232,121,211,98,171,21,105,60,255,252,
116,254,251,185,89,57,95,11,34,247,113,162,166,117,204,153,165,202,70,
40,106,105,19,181,144,160,52,106,168,217,195,118,8,253,168,161,100,187,
16,153,133,164,18,179,84,95,68,171,212,107,52,81,186,251,24,128,122,216,
46,239,93,195,49,60,115,91,180,90,46,211,13,186,66,189,167,42,192,49,
62,173,242,73,101,166,75,198,34,122,4,99,31,70,55,0,63,142,209,253,59,
126,32,111,123,172,222,89,2,141,119,255,112,190,239,59,35,143,43,151,
153,161,150,253,114,105,192,95,166,125,27,118,120,47,55,37,110,42,220,
84,249,26,175,115,206,189,56,90,103,207,196,209,60,75,227,120,125,182,
55,142,139,100,143,82,60,99,88,199,176,19,67,77,33,64,10,166,4,5,83,193,
80,33,101,63,96,1,102,74,127,221,198,150,119,240,215,255,235,66,254,46,
218,189,6,56,37,32,132,128,179,164,16,226,172,138,252,37,130,12,78,29,
33,0,206,43,132,32,56,27,162,183,41,122,91,162,247,78,244,26,254,240,
55,204,15,129,27,65,136,128,75,69,53,136,112,16,220,97,132,3,224,166,
16,162,224,142,9,201,184,128,73,65,94,22,146,43,98,96,174,61,94,92,192,
135,164,17,119,81,40,31,9,207,186,144,172,139,129,77,49,254,86,72,26,
2,62,9,242,139,144,180,218,3,15,231,241,5,228,126,2,80,75,1,2,20,0,20,
0,0,0,8,0,236,50,114,27,51,246,185,93,71,2,0,0,189,3,0,0,10,0,0,0,0,0,
0,0,0,0,32,0,0,0,0,0,0,0,85,76,79,78,71,83,46,79,66,74,80,75,5,6,0,0,
0,0,1,0,1,0,56,0,0,0,111,2,0,0,0,0
); BEGIN Assign(G,'ULONGS.ZIP'); Rewrite(G,SizeOf(V));
 BlockWrite(G,V,1); Close(G); END {Gbug1.5b}.
(*********************************************************************)
