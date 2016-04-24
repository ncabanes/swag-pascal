(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0095.PAS
  Description: Player for MOD files
  Author: UNKNOWN
  Date: 05-31-96  09:16
*)

{$A-,B-,E-,G+,N-,O-,R-,S-,T-,V-,X+}
     {ìÑ Γα«úáΓ∞ ôü£àÆ !!!}
     {MODS File player }
     { See test program and OBJ at the end .. }
Unit Mods;

interface

const
  dvSpeaker   = 0;
  dvDacLPT1   = 1;
  dvDacLPT2   = 2;
  dvDacLPT3   = 3;
  dvDacLPTs   = 4;
  dvDacLPTm   = 5;
  dvSBlaster  = 6;
  dvStereoIn1 = 10;
  dvDSSLPT1   = 11;
  dvDSSLPT2   = 12;
  dvDSSLPT3   = 13;
  dvNoSound   = 255;

const
  lpStopAtEnd = 0;
  lpPlayFirst = 1;
  lpNoBackJmp = 2;
  lpLoopPlay  = 4;

const
  stNoError  = 0;
  stModError = 1;
  stAllrPlay = 2;
  stOutOfMem = 4;

const
  Loop: Integer = lpLoopPlay;
  MixSpeed: Integer = 10000;
  Device: Integer = dvNoSound;
  Volume: Integer = 255;
  Playing : boolean = False;

procedure SetVolume(AVolume: Integer);
function PlayMod(FName: String): Integer;
procedure StopMod;

implementation

Uses Memory;

{$L MODS.OBJ}
procedure ModVolume(v1,v2,v3,v4: Integer); far; external;
procedure ModDevice(var Device: Integer); far; external;
procedure ModSetup(var Status: Integer;
  ADevice, AMixSpeed, APro, ALoop: Integer; var FName: String); far; external;
procedure ModStop; far; external;
procedure ModInit; far; external;

function GetBlock(Size: Word): Word; assembler;
asm
        ADD     Size,16
        PUSH    Size
        CALL    MemAllocSeg
        MOV     AX,DX
        OR      AX,AX
        JZ      @@Exit
        MOV     ES,DX
        MOV     DX,Size
        MOV     ES:[0].Word,DX
        INC     AX
@@Exit:
end;

procedure FreeBlock(Segment: Word);
var
  P: ^Word;
begin
  P := Ptr(Segment-1, 0);
  FreeMem(P, P^);
end;

procedure CheckError; assembler;
asm
        OR      AX,AX
        AND     [BP+6].Word,NOT 1
        JNZ     @@1
        MOV     AX,8
        OR      [BP+6].Word,1
@@1:
end;

procedure Int21h; assembler;
asm
        CMP     AH,4Ah
        JA      @@Old
        CMP     AH,48h
        JB      @@Old
        PUSH    BP
        MOV     BP,SP
        PUSH    CX
        PUSH    DX
        PUSH    SI
        PUSH    DI
        PUSH    DS
        PUSH    ES
        MOV     DX,SEG @DATA
        MOV     DS,DX

        CMP     AH,48h
        JNE     @@1
        PUSH    BX              { GetBlock }
        SHL     BX,4
        PUSH    BX
        CALL    GetBlock
        POP     BX
        CALL    CheckError
        JMP     @@Done

@@1:
        CMP     AH,49h          { Mem Free }
        JNE     @@2
        PUSH    AX
        PUSH    BX
        PUSH    ES
        CALL    FreeBlock
        MOV     AX,1
        CALL    CheckError
        POP     BX
        POP     AX
        JMP     @@Done
@@2:                            { Adj Block }
        PUSH    BX
        SHL     BX,4
        PUSH    BX
        PUSH    ES
        CALL    FreeBlock
        CALL    GetBlock
        POP     BX
        CALL    CheckError

@@Done:
        POP     ES
        POP     DS
        POP     DI
        POP     SI
        POP     DX
        POP     CX
        POP     BP
        IRET
@@Old:
end;

procedure Old21h; assembler;
asm
        DB      0,0,0
end;

procedure Set21h; assembler;
asm
        MOV     AX,3521h
        INT     21h
        PUSH    DS
        PUSH    CS
        POP     DS
        MOV     Old21h.Byte[-1],0EAh
        MOV     Old21h.Word[0],BX
        MOV     Old21h.Word[2],ES
        MOV     AX,2521h
        MOV     DX,OFFSET Int21h
        INT     21h
        POP     DS

end;

procedure Reset21h; assembler;
asm
        PUSH    DS
        LDS     DX,DWORD PTR CS:Old21h
        MOV     AX,2521h
        INT     21h
        POP     DS
end;

procedure SetVolume(AVolume: Integer); assembler;
asm
        MOV     AX,AVolume
        CMP     AX,255
        JLE     @@1
        MOV     AX,255
@@1:    CMP     AX,0
        JGE     @@2
        XOR     AX,AX
@@2:    MOV     Volume,AX
        PUSH    AX
        PUSH    AX
        PUSH    AX
        PUSH    AX
        CALL    ModVolume
end;

function PlayMod(FName: String): Integer; assembler;
var Status: Integer;
asm
        CMP     Device,dvNoSound
        JE      @@Exit
        CALL    Set21h
        LEA     BX,Status
        PUSH    SS
        PUSH    BX
        PUSH    Device
        PUSH    MixSpeed
        PUSH    0
        PUSH    Loop
        PUSH    FName.Word[2]
        PUSH    FName.Word[0]
        CALL    ModSetup
        CALL    Reset21h
        MOV     AX,Status
        MOV     Playing,True
        CMP     AX,0
        JE      @@Exit
        CMP     AX,2
        JE      @@Exit
        MOV     Playing,False
@@Exit:
end;

procedure StopMod; assembler;
asm
        CMP     Playing,False
        JE      @@Exit
        CALL    Set21h
        CALL    ModStop
        CALL    Reset21h
        MOV     Playing,False
@@Exit:
end;

procedure InitMods; assembler;
asm
        PUSH    Volume
        CALL    SetVolume
        CALL    ModInit
end;

begin
  InitMemory;
  InitMods
end.

{   MODS.OBJ needed ..  Cut and Use XX3402 to decode this block }
*XX3402-014336-220295--72--85-64556--------MODS.OBJ--1-OF--4
U+I++opDF7WK2+++02pDF3xIFJVI-2BDF2Kja+Q+8Cgc+UA-670++++--qpjN4ZiOLGT7U+6
LqpjN4ZiOLGZ7U+7PKxYN4JqOKBZ30I+0ZxhPqFYNLNdMqIO7E+6PKxYQqJoRL0r7E+7Lqpj
N5BZR5JkjGI+-qpjN5BoPr-N7U+6LqpjN5BoPr-T7U+7PKxYRaxgRKpZL0I+0ZxhPqFqPqlp
PKJW7E+5c3A++E++Lsc3FpQw+LI3WFt0+AAw+bI9W-uv3SXw3SUt3gAw+rI3W-t-+AAw-5I6
W-uu-iX02AAw-LI3WFt2+AD1kk++++++y0cn+9U1C+Ew--s++3eQ3E120pE-l-FI+QEXJ+52
93E-l1VI+GmU1U+-KU++++++++++++++xu69++3Y+-w++++0++1Bc120+O6+++++++++++++
u6UNuCoNu+2NiW2+iF++ivs+kp-163BkNK3fNL6U60+U60+U60+U6+1z1k++++++y-js4oEj
EG-XPqtqNL7oNL6UPqsUH3-IAE+++++++++0C-ks52EjEG-XPqtqNL7oNL6UPqsUH3-IAU++
+++++++0C-ks52EjEG-XPqtqNL7oNL6UPqsUH3-IAk+++++++++0C-ks52EjEG-jPW+l7X6U
60+cIrFZQaJj8E+++++++++2i-is4oEjEG-jPW+l7X6U60+U60VBPqtj8E+++++++++3aViO
4p7ZQqJmRaJY60+U60+U60+U60+U6++++++++++7pVjK4pBjRKtY627gMLBoNL6U60+cAXwk
8E+++++++++-3VkK52pjPawUF0x-63JnNL6UF4JaOKtZN++++++++++0C-ks53BoNL7ZPm-2
9o2UJLBZQW-2NKMU6++++++++++2i-is4m7HR4JmNKwhPqshAG6U60VAI3Ez8E+++++++++5
qVjO4oFdQqtZSG-HPaEUIr7X60VAI3El8E+++++++++6T-hw4oFdQqtZSG-HPaEUIr7X60VA
I3Em8E+++++++++6T-hw4oFdQqtZSG-HPaEUIr7X60VAI3En8E+++++++++6T-hw4p3pMKEh
PqshPqtZ60+U60VAI3Ez8E+++++++++7JVlK52tj65BjRKtY60+U60+U60+U60+U6+0G2+++
++++y-js4zwsb6I+l-ZI+QEtJ+52CpE-l3dI+QFQJ+52SpE-l5pI+QGQJ+52bZE-l9pI+QGz
J+52rZE-lC-I+QHzJ+53+JE-lG-I+QIWJ+53EJE-lIBI+QJWJ+53N3E-lMBI+QK3J+53d3E-
lONI+QL3J+53lpE-lSNI+QLcJ+54-pE-lUZI+QMcJ+548ZE-Fe0a+U2n+pf1lUOY++P4-Xo+
+CXK3L9kAx891Yk+iqE+WFS1kk9WyMgSGU1Fux5foSjFuoDcv-JmnWuXKU0Cq0u91Yc+Ax9c
i-Jn-SXc3Db19cgSFU0tTk+mt6XUGMcbEnfURzN7RTPyk19YiE+2xy2icq++9cYKMU-EIx5c
oSXFuB5cE6Du+5E1-E+E9cgSGU1Fux5foSjFuoA-kmuVKU1caVJPK58Y9cAyMU++RG2iWktU
+0s11Yc+QVIiWlN8+0u91a++u1YJQkDdTjzdAE+iWlN8+9Y++0bFITXc6VJOQkDdNjwiWktU
+0bF5cnM-E+EXhWu++1su+MJ5rA1uIfzjWc+9gM4J+E+iqE+9cgCH++S-p2noWO916PBunpN
KMn6XhXd7Dw+9gM4J+E-USY+UB5VIPbzzyX4359ViE2+ijzzu9gIQhSu++0Ars55+-0Crpbc
eVFmligi0wZo9JBFoSbFuR5doSZ-oS47myWm33ZPQeciWESCq1DGUTY+U5CaoS5cSVFmZWO9
-6D1+cD45ZZ7R+DdSzzcKlFn+yaezUsT1UTc9U0UJ+Ew+5E1u+Q+u1w+u+sAkksTi6+-WENr
-PWEY6Y4akW7-ec6WENZ0MY4V+P11Vys++C7-bQ3iB5UWEOP06Y4NEas+QW7-ec6kn+eAwa6
1eI+WEua+6UCe+0vnk89kPYI+B5VWES1kk9WyO30+9g8+DTXivM+xzCXhUOXi+OVEU+nocgS
F+1rwuBK+8BM+8BQ+9cG+9XSB6gSEU1rwu7H+9g++zTXcow+WFNF+DX1JsfFUA7Vh+9B6PyT
-SUI+3zc2+0zdELc0U119W+U60++1Ec+WUJ5D+-ovsX0h+9B6SjlkkcBIqJgNKBo643i64xp
R5-pR0-YNLNdMqIUCW++3NnB+AE2J+520JE-l-JI+QEMJ+526pE-l1JI+QEwJ+52HJE-l4lI
+QFlJ+52WJE-l7VI+QGYJ+52f3E-l93I+QGsJ+52jJE-lApI+QHWJ+53+JE-lEJI+QI8J+53
7JE-lOBI+QKuJ+53kJE-lQJI+QL7J+53nJE-lRRI+QLSJ+53sZE-lSZI+QLmJ+53xZE-lTdI
+QLxJ+541ZE-lVhI+QMSJ+546JE-lWRI+QMgJ+549pE-lX7I+QMwJ+54EJE-lYZI+QNBJ+54
L3E-laNI+H8W0U+-pEII+++++E-Yc+A2+SY31+m9wPY++6bTIZBFWQi-kxI3lUQ+UroK+5EE
lUQ-ULoKYV-p+wM5+iVkzpZPKU5HCQto+o5fo9ys-SW0zvU++AoK9448q61v35DmWhCr+651
pEK+Dk-otM+z+bEEWhe+ka4o+goVjuI3u3Dzkvjz+9yZ-SV7zwC95YM+jgw0WYE7UwMIWaE7
UwMIWZk7UwMIWbk7USAzDmIzDwDFs0o1+8AX+sYK5kD13m91kwD1u6cGWw51UnsT+k-o2M+y
8EA-REc4XUMT+vF7nG25kk++++++++++++++++++++++XAWCk6+yDU+-RCCUdE1yk1c4d+-n
288Z+CUR+6+ykEM+RAjdoE+mk88Z+1U4l+No9CU3+CZj+-QJjYAEjQw0u8w0jawEjSA0u8M0
jdgEjTQ0u7o0jgQEjEg1uNE0XUNO+80c+19Y+kN4+6js7ccZAg1FsB5U+kOa+6js+nt8+9t1
29rD+iWy+9tj29rX+iWp+9uP29rr+iWg+9v529o9+yWX+CY++6A4dU+EcAA40g-o0892-gM4
kkM+U1v2-U-o0zsCl+No-MAidU+EU1v4-U-o4QM4lUM+cA+4h+067g+4oS1FsB5UoS0XdU0-
DeM+++Fn+yYZzs+yEE+-R1uUk+Oo+B5UoS1FsB5UcuM+lUP+-U14-g24+80c+Dv+75yWe+09
5YM+7Xd5zbE1uSryU1t-++Fp-gM4e+++kmv4-Xs++Sjm0Um1D+-p0MBw+U-p+yW0+GO9-MY2
7ch3+cZ2+cD5-6d2+WHkoCXEuB1coCW8761Y2+f2REDdWk08q0u6FUsiU2sCU9QSxiS7kjv9
AjzFss51N+09-sZ2-6D016jO7cg5Vi+h+k07F+W7F0UaWoQ0WIEGWC+iW4M7xaEe9cVa00O9
HkO4uMDt-56X7ch5-6PUoS+iWIM8WIEYWIE8WIkC+QU-m2V6G0u7FUnd3U+nk0u7FUkiWIM8
WIE8WIEYWoE6WIECWkG4s0Lz1rI1uLQ3WoE0Vi+Zw+wxI+to5c1w+rI1uFk+UDk3REDd3+0+
z+Zo+yYG+CVD-SYA+CU9-iY4+CUi+iZ+-Mg2Vi+Zzky+T-6+R-evAl4t7++v-rA3UwA0sjS8
F-8lGDPV+QC9-sZ226d25WE2R+H4F-g+WYES72-o-AN25E09F+EiWIM+AwYiWIs09cVC1sh2
0B5U9cZ4-6hA21DG0wZo0u3D+6gKIE1rwMb09cZK-ch2+cPU7T+DDR+CREUiWoM29cZ4+iaq
-+kWWoEEWwUnoUj7R+iVHk093Z2+xz47kWu7JUP1WoE0VgEZzkxoqsdQ+cXNUyADoSC-kxE7
WlTzsWE8cUfo0d696kn91B2Ax+bo0TE72Nl3+QEEJ+52C3E-l33I+QFbJ+52QJE-l5ZI+QFw
J+52cJE-l8JI+QGqJ+52jJE-lAJI+QHYJ+52uZE-lD-I+QHpJ+52z3E-lERI+QI9J+5343E-
lFhI+QIVJ+5373E-lGdI+QIhJ+53ApE-lHNI+QIxJ+53E3E-lINI+QJJJ+53KpE-lJtI+QJV
J+53NpE-lKdI+QJkJ+53QpE-lLZI+QJwJ+53VZE-lMdI+QKFJ+53ZJE-lNdI+QKVJ+53dpE-
lOlI+QKnJ+53hpE-lPpI+QL6J+53n3E-lRRI+QLRJ+53uZE-lStI+QLnJ+53xpE-lTtI+QM0
J+541pE-lVNI+QMRJ+54QpE-lnNI+QSAJ+55Y3E-lw-I+QT2J+55tJE-lyhI+QThJ+55vpE-
lz3I+QTnJ+55xJE-lzRI+QTtJ+55ypE-lzpI+GiU-+E-u+bo0TE7x+bo0QACx+a9F-06msj6
Ax69mLE9cIw+WlNF+DTlWQ6iWJM4WBa+yERp+yax+d0+yEdp+yZJ-ACUdE+mt9A1xjC6s+f+
R-cw+bECWYE1oCXEuB1coCXd1U08F+AY1yY4+6h22CYa+7XFs6jMWYEGgIXqsMhI23OyAl21
w9YY+1gIQkS1lU9Wxpv1Wk-SWwUnoUj7R+iVHk093Z2+xz47kWu7JUP16Woi9lK+DeI++5Ln
lUP0-Uy8F+AW-g64lUP0-jy9H-+mt0b-WIkEUS5z1sDtQLAFWokEUS2+w6D7QMZA265Vzkwn
oUj7R+iVHk093Z2+xz47kWu7JUP1U1uZ++-pyAM4kUMDWYE16UP0-gM4kUPzWokEAiE-kMZA
265Vzky-yJU1QV89H-0-sE1kUQZM+sZA265VzkwnoUj7R+iVHk093Z2+xz47kWu7JUP1WkG4
s0Lz1sb0WYEGgIfqsJSzAl2-lvg++1gFQki1kk81yodpx9h4+6dI2c1W05E6Uzg+R+C1uk89
+Jy7F-W9L-14F-M+CRVo-rColYEK+QD5F-U++AC8F+A8k5E5W2ELlYE1+6Bw4+-ousd23vE+
WokEWpkMU5kK+5II+Q47H-+vqLQSWJkEloEM++1d2k+dkL65WIkECxZm06ZQ2AR24+++WpEE
WYET7+xo6cd22fB6xiA3Al3LWzWv+++v2LA9UwA0Uzh6QjGvFU092Jy9mXDG0wZo0u3D+6gK
IE1rwMb09cZK-gA+WYE10g-o4sdQ4WEDR+K+sz+6ksd2+mHkR+K+skw6ksVQ4cd24x1coCUZ
5k08L-u+skBo6h5UoS1Fs61v+LE3gzzd4U0+T-g+S+SnzmX1uEo+WhXd0+08q19zWdwH2Md2
4WEDxiCHoSjFux5foSjFux5foSi9F-0+T-g+SEI-qCY0+0bMWwUnoUj7R+iVHk093Z2+xz47
kWu7JUO8F-fEuB1c71k+F-j1uB9yuOQ-u55zuO2-WYE10g-o4sdQ50EDR+K+sz+6ksd2+mHk
R+K+skw6ksVQ56d25R1coCUZ5k08L-vEux1foCjEus1X+rEWoC1EsB1UUDg-R+KnzyYO+6-w
4k-s-vDz8ADd1E08qCY6+6jMUQAH2McTWYEQ7+zqssjMoSjFux5foSjFux5fWYEHU5kR+5Y3
+BXd-U+cq5A0Ag+wE560g2+iW2M7xaEe9cVa06d25B1coCUYD+-25QAA16d2+kf+R+C6F008
N0+mk0svFUFn0Wv4FUw+9cZ4+gAiWoM09cZ4-AC8F+C+DY2++bEEzgWWe+14-g+4+AM4kEM-
knc4e+-myTv6ceU+lUP+-U14-g24+QC8F+AwE560g206GtmV+AE+J+52+ZE-l+FI+QE4J+52
03E-l+dI+QEOJ+525ZE-l1pI+QFwJ+52aZE-l7tI+QGkJ+52hpE-l9xI+QH1J+52wJE-lDJI
+QI0J+530JE-lF3I+QIJJ+53FJE-lIZI+QJaJ+5403E-lWhI+QMjJ+54ZpE-lgVI+QPAJ+55
IJE-lwhI+QTHJ+55ppE-lxlI+QTWJ+55uJE-lypI+QTmJ+4Nc3w0+SUBF-AiW2M7xaEe9cVa
0AC8F+C8qB1coCXEuB1cgEfqsM1X1k1MD1xzfO9+-gM4kEM-ksd2+kf+RDUw65A7ceE+lUOZ
***** END OF BLOCK 1 *****



*XX3402-014336-220295--72--85-65182--------MODS.OBJ--2-OF--4
++11WUuY+924xi4u++0t1k1rwMjMcI6+iU++xzCXJU0XK+0XL+11WZk0UyADUCg7QjHFss51
Nku93zzWksMBNUui1RsBxUr11VYC10AiWYE17D-o7R1coCXEuB1cWYkH+A4+yI-m+f3+W2kH
Wg2iW2M7xaEe9cVa0AC8F+AY1sdA2mX-Qk6mmMVA2sf-9cV40TNY8Wu6NUX1WZk1USDk+B5f
oSjFus51q+u93zzWy+uK0iU8yEs41lAD5+xJ1qMCOUyM1ugDiUzK1yEDzEz1WYE17+y+N-zk
02ETksd2+mEDU4ESw+V25gC8F+AY1sV22gC+DeI++5LsWYE17+xo56-w6U-o2TtA6bHaWYEV
cg+4lUP4-U51W2EWuyyVdU1FuB5coSXFu6V26QC8F+AY1x1UoC1EsB1UU4ES1kV25gC8L+C+
skxoxn9Yc8I+0g-p0cgAVia-sTwDRSHqwsPU0g-pr1D+9cZ4+Wu6HUz1U1uZ++-py6d2+mED
uS1ywAX636+ydE++RSK8F+AY1ybjzcd2+mEDCUOZ+5LGg+06F-AiW2M7xaEe9cVa0AC8F+AY
1nc4dE-pxCieks+ydE++RTW8F+AY1s+yl+M+RSnyk891-gC+DeI++5LsWYE17+zEsB1UoC1E
s6-Y5kw6F-w8k5HUWYEToCXEuB1coCU8k5ELikAFAiE-ksc5+2EXWYEX76-p-AN26k118tn-
+AEdJ+529JE-l1pI+QF-J+52FpE-l3VI+QFUJ+52MpE-l4NI+QFsJ+52TpE-l63I+QG1J+52
VJE-l6RI+QG7J+52WpE-lCdI+QHkJ+52wZE-lDFI+QHqJ+52y3E-lDdI+QHwJ+52zZE-lE-I
+QI0J+53-3E-lENI+QI6J+530ZE-lElI+QICJ+53BZE-lJ3I+QJJJ+53LpE-lMpI+QKmJ+53
lJE-lRZI+QLpJ+53zZE-lUdI+QMGJ+543pE-lYFI+QOW0k+-El+8+++++U++wu+4++3L2++-
wO69++3N2+I++++0++1WcUc++KAE0U++++2+pO+4++3h2+++r869++3j2+c++++0++15c+M+
+MAE++92cUg++MIE-E++++6++9OW0U+-Xl+8+++++E0dc+M++NYE++0kcUg++NgE0U++++6+
+7iU-U+-fl++-7OW0k+-gF+3+++++U++We68++4v2+c++++-+5qU-U+-lF+++6GW0k+-ll+8
+++++U++Pu+4++5P2++6Ne69++5R2+I++++0++-ScUc++SQE0U++++2+IO+2-+5l2+++c9c4
caoEcdYEcgIEcj2Ekk+3-UQ60UgB2-AK4W+fE6++4138MLWBcPH3pC1fxDfxzzruxCjUpAKo
cMpsMIcl43U18+Du+h+0dU8++Zk0CU6O+jk-s+53+Ok-Z+3x+KU-Ik3++Gs-5E2B+Ts+w+1W
+BM+mU0y+9E+eU0U+7Q+Xk05+5w+S+-l+3616UDp+gg0cU7x+ZY0Bk6L+jY-rE50+OY-YE3v
+KI-IE2y+Gk-5+2A+To+vk1V+BI+mE0x+9A+eE0T+7M+XU04+5s+Rk-l+2k15+Dk+gI0bU7s
+ZI0Ak6I+jM-qU4z+OM-XU3s+KA-Hk2w+Gc-4U28+Tg+vE1U+BA+lk0w+92+dk0S+7I+XE03
+5o+RU-k+2M13kDe+g+0aE7o+Z+09k6E+j6-pU4w+OA-Wk3p+K+-H+2u+GU-4+26+TY+uk1S
+B2+lU0v+9++dU0R+7E+X+02+5o+RU-j+2+12EDZ+fg0Z+7j+Yk08k6A+iw-ok4t+O+-W+3m
+Js-GU2s+GM-3U24+TQ+uE1Q+B++l+0t+8w+dE0Q+7A+Wk01+5k+RE-i+1c10kDU+fM0Xk7f
+YU07k66+ig-nk4p+No-VU3k+Jg-G+2p+GE-3+22+TI+u+1P+As+kk0s+8s+d+0P+76+WU00
+5g+R+-h+1E1-UDO+f20Wk7a+YE06k62+iQ-n+4m+Nc-Uk3h+JY-FE2n+G6-2U20+TE+tU1N
+Ao+kE0r+8k+ck0O+72+WE0-+5c+Qk-h+0s1++DJ+ek0VU7W+Xw05k6-+iE-mE4j+NQ-U+3f
+JM-Ek2l+G+-2+2++T6+t+1M+Ak+k+0p+8g+cE0M+7++W+0++5Y+QU-g+6g1K+Ac+zc0o+8a
+c+0L+6u+Vc0z+5U+QI-f+4I+Lo-O+3H+I+-9U2R+Eo-zU1k+C6+pU18+9s+h+0e+8++Zk0D
+6Q+Tk-s+6E1IUAW+zI0mk8X+bk0KE6r+VQ0yE5R+Q6-eE4F+Lg-NE3F+Hs-9+2Q+Ek-zE1i
+C2+p+16+9o+gk0d+7w+ZU0C+6M+TU-r+5s1H+AQ+z+0lE8S+bU0JE6n+VE0xU5O+Pw-dU4C
+LU-Mk3D+Hk-8U2O+Ec-yk1h+Bw+ok15+9k+gE0b+7s+ZE0B+6I+TE-q+5Q1FUAL+yc0k+8N
+bE0I+6j+V+0wU5K+Pk-ck49+LI-M+3A+Hc-8+2M+EU-yE1f+Bs+oE14+9g+g+0a+7o+Z+0A
+6E+TE-q+521E+AF+yI0ik8I+aw0H+6f+Uk0vU5H+PY-c+46+L6-LU38+HU-7U2K+EM-xk1d
+Bk+o+12+9Y+fk0Z+7k+Yk09+6A+Sk-p+4g1CUA9+y+0hU8D+ag0G+6b+UU0uk4Yb-I+l+BI
+QE4J+520JE-l+lI+QEDJ+4Zc5g0+T2Ink4p+No-VU3k+Jg-G+2p+GE-3+22+TI+u+1P+As+
kk0s+8s+d+0P+76+WU00+5g+R+-Y+nE1-UDO+f20Wk7a+YE06k62+iQ-n+4m+Nc-Uk3h+JY-
FE2n+G6-2U20+TE+tU1N+Ao+kE0r+8k+ck0O+72+WE0-+5c+Qk-S+ms1++DJ+ek0VU7W+Xw0
5k6-+iE-mE4j+NQ-U+3f+JM-Ek2l+G+-2+2++T6+t+1M+Ag+k+0p+8g+cE0M+7++W+0++5Y+
QU+-+E2-++++++++0ZAS1Vwmt19zc9gJgm5rssb0UQ8y+6jOWoQRU1tI-+3p+sh55sdD5-xP
kpNLIZ3HI0vy-fgJ9c+yilIEREMilUOv3E1cijy9qch53Xo++5HUK3hNKZxSkyWazsjOWoQK
DE++RT9ckzzfvgBKJp7FIp+iU1uv3E-p-Wv4-fgJ20vy1fgJu5fzWxe9FlMx++-os3VPKJdT
LgD1S+6c80Ub7mQa7WMZ7GIY6-wS5FkP4VYM3lMJ3-AG2F2E2+wD1UsB1EoA1+kA0kg90kc8
0Uc80EY70EY70EY70+U60+U60+U60+U6-kQ5-kQ5-kM4-UM4-UM4-UM4-EI3-EI3-EI3-EE2
-+E2-+E2-+E1+kA1+kA1+kA1+U60+U60+U60+E2-+E2-+E2-+E3+E2-+E2-+E2-+DnwzDnwz
DnwzDnwzDXsyDXsyDXsyDXoxDHoxDHoxDHkwD1kwD1kwD1kvCngvCngvCngvCXcuCXcuCXcu
CXYtCHYtCHYtCHYsC1UsC1UsC1QrBnQrBXMqBXIpBHIoB1EnAn6mAH2kA0wi9Gkf8WYc7mMZ
70AW6G6X7NeQ7E12pZE-lC-I+QHdJ+53+3E-lEJI+QIBJ+53E3E-lIVI+QJCJ+5Fc+E2+L2L
1VxEAw0XJ+0UIk0WhlJMu+A+uLk+u1LycvYJUDY+REDdPE0+yE3p-iVa+SZW+61t+bIAWxe9
FlO7-eAWuJ2+UDY6REu9qch53cY4gVzcjE9fDc1t-rI9Wxe9FlO7-bkQumu+yEFp2cjOWoQK
WEOR56h546Y4clnf3s1t-LIGWxe9FlO7-eUTWoQMWEOg5yg+kkOoBP+6nG475aULX+Ne3kSV
O-SXi08VOVSXiW9c0UDY6O7k3zekzyMVylsiWlOt3FsTh0Kk0AoV5mukBCN19e0r3SN+9f++
tY+ig71aEyFV1+DaMTeUQ-Ta6Tj4-Xs++AAC5s+yDU+-REDc7k1c0k4C-Zc+uCE+QiSvN+09
1Yk+WkS1kk69k5E5Xg1cnE-moC9iklES-Z-HIJ7LJZLugDza6TjYMGHwta2ig1HaEmus++1a
E6XUtY+ig9PaEmusAkLaEcXUtY8Am6vMXg+SWlNc3ssSOVSo7P+6nG2Tye-k3yMVyzgilUMy
++5cnjm+yEVp+yWK+JpSLpdNKpU55wC9qWu9FlO7kUIA+0u7-acQ9cY4Kln1i++xnG3my0uX
LU119cgSLU0oDgoVkp-Hh1wiWltS+AoVQUUdm5I2y3hMkkI2+1o++5HoyJhMkzuoGAoVQkMi
lUMx++H1h2bB6LA49gM4DE+2kkNHXg0oGgoVQkMilUMx++FP-wCo+goOWgLc3k08u6f-u-++
WgW6wCU7+6X4Ah8o9QoVkp48m6DV1mHkoCXEuB1coCWn0jPX+QVNkvV++6v+jkU+iEA+gn2a
WlK1yU-o1CUO+5A7zgC1lk9WvDb1WFMS+cUS4k94-fgJ0jX1g+1iEikYU5EBGf1zvY9g76-p
+zV8kzb1uie1kUOk+Sut0U1Wzf++vcD0-iU9+5A0yQCkoSvc+E11iEc+IPbz+CnEk5A5sjZN
sj9tkpbskvV++6v+ikU+iEA+jvs+UwQVgU+aWkQx++-o0MZ33ca3M+5ykcD1+cD56S9bUDc0
QVEacEU+WIIKWIIr7e28+6Z346Z3CEs5ksjOWpQKWFOd+6D0+f+2vgC93eY+Uzc+RDO1kU8k
1Cv1ik+0+lvI7cUSiWO-uvk+WxC+kUmkovY++cX2v+f+SELWySYs+6XUvfbzzy9yUCcAUA64
g+5ivCngv0f+vfYE+341kUWt++9g0g-s-i9tKSY9+61e-ClND8do1S9XUwAEUThU+budyQC9
opDcxTtMWEOv+QM4ilI5I0o++h5coSXFuB5c-106-fQ-KDX1jUMXWnut3MgRUwQ0Uzg+R1O1
yk7o2MgB8wi1lk88-sU2EoPWyCjUU1tI-+3o16gRWoo08wi1lkXfsshR-6hB-Wj9UwQ6uumQ
oE12-ZE-l+ZI+QEAJ+524JE-l1dI+QF9J+52LZE-l4tI+QFpJ+52VJE-l6lI+QGOJ+52bZE-
l87I+QGZJ+52e3E-l8hI+QGnJ+52jpE-lB3I+QHbJ+52vZE-lDNI+QI1J+530pE-lExI+QJV
J+53NJE-lL-I+QJtJ+53bpE-lOFI+QKkJ+53hZE-lQFI+QLcJ+53xJE-lUNI+QNdJ+54PJE-
lb3I+QPFJ+5533E-llxI+QQmJ+55BZE-lttI+QSWJ+55hJE-lvhI+QSzJ+55spE-DO+2-+3l
4xOy-WC7BfYJYAAI+U0y5vYUJm4U6U6+iG++6E+VJm4j5vsTdW9e6U+++U0y5vYUJm4U6U6+
eFro5TERHluZ5uwTdW9e6U+++U0a58YRHluS5k6+eFro5TERHluL58MQdW9e6U++++++++6+
dVmd5IwSbVw0+8YRx-ro5IwSRVmL58MWuW6+++6+jVyt63QVc060+9YU+02+6JQVbVyZ5uMW
uW6++3UQNlk0+9sTiG-L6O+W+U0t6++V+03L6KQQRVma6icW+++0+9sTiG-L6O+W+U0t6++V
+03L6O+WdW8a6icW+++++37EiU++vB1+Qjik2CtMKcX2iU++vB1+QjW6s0m+vWm+UCm+iU++
vcD0+f+-vf++vcXUUyc0vcD0+f+0vf++vWm+UCm+iU++vcXUiU++vVs4I3BGXAWCq1DGcQw0
0w-oBsv+WlvF+XYSok7n1cgSqE8Vqk69k5EUcxA0AiGUpE6+-hs0cBM02QC75h207cc5xWvL
+h5U+hGVsk69k5ErXg095iI0CFvb+bACWlvh+e5j+Uj+R00Xtk6mt81d+U+4wU8UuU6FksYS
tE6aWUTq9ig0oS+0x85r+Uj+R1SCk6gSyE6t5jg0Qku95U21cEA10w-o68Dv+X9YcDo0++M4
+u1y+V51WFvt+WO8-zMizk9Fs+9ocEg10w-oBsv+WlsB+nYS1kBn1cgS3ECV3kA9k5EUckw1
AiGU2EA+-Vc1c-612QC75Uo17cc5xWsH+x5U+hGV5kA9k5F0Xg095W21CFsX+rALlkMT+k++
***** END OF BLOCK 2 *****



*XX3402-014336-220295--72--85-50007--------MODS.OBJ--3-OF--4
U1sd+k3p8EOCk9F7nG25ulwmt8+Z+k+49UCU7UAFksYS6EAaWUTEyB1uoDs0o+9kWR0V5kA9
k5FGXg095W21CFsX+rALlkMT+k++U1sd+k3pCEOCk9F7nG25umwmt8+Z+k+49UCU7UAFksYS
6ECU9UDEoB5HQkSAk+I+26v+7cc5oDXEyh1y+h+0w6bE5UNEIp8Am6vMAx8Vnk69k5F8Xg09
5h20CFvH+bACWlvN+e5P+Uj+R1CXok6mt81S+U64pE8WrU8UpU6FksYSoE8UrU9EoB5HQkSA
k+I+26v+7cc5xWvL+h5U+hGVsk69k5F8Xg095iI0CFvb+bACWlvh+e5j+Uj+R1CXtk6mt81m
+U64uE8WwU8UuU6FksYStE8UwU9EoB5HQkSAk+I+26v+7cc5xWvf+h5U+jGVxk69k5F8Xg09
5jY0CFvv+bACWls-+u21+kj+R1CXyk6mt8+4+k64zE8W-UCUzU6FksYSyE8U-UDEoB5HQkSA
k+I+26v+7cc5xWvz+h5U+jGV0kA9k5F8Xg095Uo1CFsD+rACWlsJ+u2L+kj+R1CX1kAmt81u
b-21l+7I+QE4J+521JE-l+xI+QEFJ+522pE-l-RI+QENJ+524pE-l-pI+QETJ+526JE-l0BI
+QEZJ+528pE-l0pI+QEjJ+52AJE-l1JI+QErJ+52CJE-l1hI+QExJ+52DpE-l23I+QF1J+52
GJE-l2hI+QFBJ+52HpE-l3BI+QFJJ+52JpE-l3ZI+QFPJ+52LJE-l3xI+QFVJ+52OpE-l4pI
+QFjJ+52QJE-l5JI+QFrJ+52SJE-l5hI+QFxJ+52TpE-l63I+QG1J+52WJE-l6hI+QGBJ+52
XpE-l7BI+QGJJ+52ZpE-l7ZI+QGPJ+52bJE-l7xI+QGVJ+52dJE-l8RI+QGfJ+52fJE-l8xI
+QGlJ+52hJE-l9RI+QGtJ+52ipE-l9pI+QGzJ+52kJE-lABI+QH7J+52mpE-lApI+QHDJ+52
opE-lBJI+QHLJ+52qJE-lBhI+QHRJ+52rpE-lC3I+QJ-J+53GpE-lIxI+QJJJ+53K3E-lJxI
+QJYJ+53O3E-lKhI+QJlJ+53S3E-lLxI+QK7J+53XJE-lNBI+QKKJ+53bJE-lO7I+QKaJ+53
eJE-lOxI+QKqJ+53jJE-lQRI+QL9J+53oJE-lRFI+QLPJ+53s3E-lSFI+QLbJ+53vJE-lTFI
+QLvJ+54-JE-lUZI+QMDJ+542ZE-lVZI+QMSJ+546ZE-lWJI+QMfJ+54AZE-lXZI+QN1J+54
FpE-lYpI+QNHJ+54NJE-laZI+QNgJ+54QZE-lcFI+QOCJ+54YZE-ldVI+QOSJ+54g3E-lfFI
+QOrJ+54jJE-lg-I+QPeJ+54x3E-ljVI+QPyJ+55+JE-lkVI+QQBJ+552JE-llFI+QQLJ+55
5JE-lm-I+QQoJ+55CpE-loJI+QR7J+55HpE-lp7I+QRNJ+55LZE-lq7I+QRZJ+55O3E-lqtI
+QRlJ+55VJE-lslI+QSKJ+55aZE-lu-I+QSXJ+55eZE-luxI+QSnJ+55hZE-lvZI+QSzJ+55
kZE-lxNI+QTRJ+55tpE-lyhI+QTlJ+55x3E-lzhI+PqUaEA-QFwO+k642ECW4UCU2UAFksYS
1ECU4UDEoB5HQkSAk+I+26v+7cc5xWsH+x5U+hGvNFPLtY9v960u++1iiU++vWm+iU++vcD0
+f+Avf+2vVs4I3BGXAWCq19GcQw00w-oBMv+WlvF+XYSok7n1cgSqE8Vqk69k5EScxA0AiGU
pE6+-hs0cBM02QC75h207cc5xWvL+U9IcSA00w-oBMv+WlvZ+XYStk7n1cgSvE8Vvk69k5ES
cyQ0AiGUuE6+-j60cCc02QC75iI07cc5xWvf+U9IcTQ00w-oBMv+Wlvt+XYSyk7n1cgS+ECV
+kA9k5ESczg0AiGUzE6+-UM1cDs02QC75jY07cc5xWvz+U9IcEg10w-oBMv+WlsB+nYS1kBn
1cgS3ECV3kA9k5ESckw1AiGU2EA+-Vc1c-612QC75Uo17cc5xWsH+k9IcFw10w-oDcv+WlsV
+nYS6kBn3wQ45kA++6+y8EA-RGI4Xg0oGQoV-ygPAiGU7EA+-Ws1c0M12QC75W217cc5oDXE
yU9EWB0V5kA9k5FCXg095W21CFsX+rALlkMT+k++U1sd+k3pBEOCk9F7nG25umgmt8+Z+k+4
9UCU7UAFksYS6ECU9UDEoB5HQkSAk+I+26v+7cc5oDXEyU9EWB+S-Z-HIcn6XhUmoe5D+Uj+
R2WCk6gSoE6t5hA0Qku95hY0cRg00w-oAODH+X9YcBs0+UPJ+e9S+e1K+V51WFvF+e1S+h1E
oRBn-sn+-E+EXg+aWUTq9hQ0+hGVsk69k5F6Xg095iI0CFvb+bACWlvh+e5j+Uj+R14Xtk6m
t81m+U64uE8WwU8UuU6FksYStE8UwU9EoB5HQkSAk+I+26v+7cc5xWvf+U9IcTQ00w-oG6v+
Wlvt+XYSyk7n1cgS+ECV+kA9k5Elczg0AiGU-UA0-jo0cUM1cDs02QC75jY0c+M1oB1ForA5
XA+3+-0Ck0O8-zMizk60p829+kj+R2WCk6gS1EAt5Uw1Qku95VI1cFQ10w-oAOAD+n9Yc-c1
+UMF+u6O+u+G+l51WFsB+u+O+x1EoRBn-sn+-E+EXg+aWUTq9VA1+hG6o0m+iU++vjwCi+Np
2O4q-eCs-ZdPK+QTuU++++1Dg01a6DwCL+-o-ZdPK+QTnu3K+8BQ+Dw4J+-FJpNJigQ4zx7R
LZxNKZhM-lzD+9c++9c++9c++9c++9c++9c++9c++9c++CvmumOQ1E92+3E-l+FI+QE5J+52
0ZE-l--I+QEHJ+527pE-l0tI+QFNJ+52MpE-l4RI+QFhJ+52Q3E-l5RI+QFwJ+52U3E-l6BI
+QG7J+52Y3E-l7JI+QGTJ+52cpE-l8ZI+QGgJ+52gpE-l9VI+QGwJ+52jpE-lAJI+QHAJ+52
oJE-lBhI+QHTJ+52tJE-lCVI+QHjJ+52x3E-lDVI+QHvJ+53+JE-lEVI+QIBJ+533pE-lFhI
+QIVJ+5373E-lGhI+QIkJ+53B3E-lHRI+QIxJ+53F3E-lIZI+QJHJ+53JpE-lJpI+QJXJ+53
RJE-lLZI+QJwJ+53UZE-lN-I+QKOJ+53bZE-lOFI+QKeJ+53j3E-lQ-I+QL1J+53mJE-lQlI
+QLmJ+53z3E-lU-I+QM4J+540JE-lV-I+QMJJ+544JE-lVlI+QMTJ+547JE-lWVI+QMwJ+54
EJE-lYhI+QNDJ+54JJE-lZVI+QNTJ+54N3E-laVI+QNfJ+54PZE-lbFI+QNrJ+54WpE-ld-I
+QOOJ+54bZE-leFI+QObJ+54fZE-lfBI+QOrJ+54iZE-lfpI+QP1J+54lZE-lhdI+QPTJ+54
uJE-lipI+QPnJ+54xZE-ljpI+QQ0J+55-ZE-lkZI+QQAJ+552ZE-llJI+QQdJ+55BpE-lnlI
+QQzJ+55IZE-lppI+QRUJ+55N3E-lqhI+LqUIk+-ZWEB0Uo8HKZiOIpjN0-qA0skAmsU64BE
6+o8JKtmNKRdQrFZQaJY65NZQbBdPqsV1EccEmYUHK3mOm-862BjS0+lCHYm1EcB0bFZQrEi
PKxYBO68++5Z70o++++-+-mUrEA-2WI++0v4-V6Z+JK9v3-HIJ7KJkMS1UsT-yUP+-w5LptO
KJhMLGu+DV6Z+LI79gM42WI+mUE+mvcV+9YE+9iy+CWMs9Q+l5s47cYRkmv4-V6Z+JK9v3-H
IJ7KJkMS1UsT-sdS16dy0cd406da-iUP+-w5LptOKJhMLGu+DV6Z+LI79gM42WI+mUU+mp-H
gzzcLhc2KpW65aoEW1uN289326UawF11oUEilUMG7E3JWylEIp3GJZQ45UsC5kT3TUPcoE88
FUkilUMO0d+w+LI49gM44Uf1WoMEWpsC1VwC-s+y2mI-RET4-Xo++igcIsfMuDrN+ZjcyBY-
WZs8uD5N+vfR7CUTrL6Bu3PlQUMilUMH7E5f29+-9ccSDE0+yk-o+cf1uk8k+AJy2fE+WEIT
-pxSKZZPK3oiU1sG7E3p0Gv4-V6Z+AcE+AgilUMG7E3JWylEIp3GJZQ45UsC5kTc4E+T-pxS
KZZPK3oiU1sG7E3p-mv4-V6Z+Aj9U1sH7E3p1QM4DU+-lUMH7E1clT519gM42WI-JMjgI3BF
IZNL-VsC1Vw5uDHNidYdEVw5LptOKJhMLGu+DV6Z+LI59gM42WI+mwiE+0v4-V6Z+JK9v3-H
IJ7KJkMS1UsT-lw5LptOKJhMLGu+DV6Z+LI79gM42WI+mV++mmv4-V6Z+JK9v3-HIJ7KJkMS
1UsT-sd4-chS0CUP+-w5LptOKJhMLGu+DV6Z+LI79gM42WI+mUE+mu8c+AAilUMG7E3JWylE
Ip3GJZQ45UsC5kQT-pxSKZZPK3oiU1sG7E3p0Gv4-V6Z+AcE+AgWKKAilUMG7E3JWylEIp3G
JZQ45UsC5kS9HUO8FUXcwBsT-pxSKZZPK3oiU1sG7E3p0Gv4-V6Z+Ac2+AgilUMG7E3JWylE
Ip3GJZQ45UsC5kS9HUO9LUW9FUfckxsT-pxSKZZPK3oiU1sG7E3p0Gv4-V6Z+Ac4+AgilUMG
7E3JWylEIp3GJZQ45UsC5kS8FUvcXhsaWoQKlLs4WEL3TUey+++iU1sG7E3p+ISt3U+aWU+w
+5E4W+J5Fi9ng++iU1sG7E3p-QJy0cbkW+IT-pxSKZZPK3oiU1sG7E3p0Gv4-V6Z+Ac8+Agi
lUMG7E3JWylEIp3GJZQ45UsC5kT3TUPc9U09HUcC5ks5ihoYu-DSl5sA7cY35kRTLZdNKpVR
9c+y2WI-REYilUMG7E180U19jhoY9c+y2WI-RFW81PI+UzY+R+d5WUIiW+F5Fi9r9gM2+AC8
-Gu6-2N5D+-pxQCQKs5XzkxHbNlPUSA+w65v+D0k+5E0g+51wNnd+AE3J+527ZE-l0tI+QEw
J+52HJE-l5dI+QG0J+52ZJE-l7ZI+QGQJ+52c3E-l8VI+QH4J+52o3E-lBxI+QHaJ+52zpE-
lEtI+QIMJ+53C3E-lI-I+QJ8J+53OpE-lLBI+QJuJ+53UJE-lMNI+QKEJ+53dZE-lPJI+QKx
J+53lpE-lSJI+QLhJ+53xpE-lVtI+QMaJ+549ZE-lXFI+QNGJ+54KZE-laRI+QOCJ+54ZZE-
le-I+QP8J+54oZE-lhlI+QQ4J+556JE-lnZI+QR-J+55GpE-lqhI+QS0J+55WZE-lt7I+QSL
J+2xWU6++5E+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
***** END OF BLOCK 3 *****



*XX3402-014336-220295--72--85-00000--------MODS.OBJ--4-OF--4
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++
***** END OF BLOCK 4 *****


{ --------------------------------------------------------------------------}
{   TEST PROGRAM  .. cut }

Uses Crt,Mods;
 var ch : char;
begin
 Device:=dvDacLPTs;
 MixSpeed:=15909; {10000;}
 WriteLn(PlayMod('NIAGRA.MOD'));
 repeat
  ch:=ReadKey; if ch=#0 then ch:=ReadKey;
  Case ch of
   #43 :  begin Inc(Volume); SetVolume(Volume); end; {æÑαδ⌐ »½εß}
   #45 :  begin Dec(Volume); SetVolume(Volume); end; {æÑαδ⌐ ¼¿¡πß}
   #42 :  begin Volume:=255; SetVolume(Volume); end; {æÑαá∩ ºóÑºñ«τ¬á MAX}
  end;
 until ch in [#27];
 StopMod;
end.

