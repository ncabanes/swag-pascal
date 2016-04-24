(*
  Category: SWAG Title: ANSI CONTROL & OUTPUT
  Original name: 0031.PAS
  Description: FAST ANSI Display Unit
  Author: LARRY HADLEY
  Date: 02-03-94  11:01
*)


{
JW>I would be interested in such code - and a BP7 version is hardly needed,
JW>since I am happily working with TP4.0.

  Well the problem is mainly keeping my code confidential, and I
  don't have a TP4 compiler, I no longer have a TP5.x compiler,
  either.

  Fortunately, the "top secret" stuff is all in .asm, and I can send
  you the .obj file without any complications. The .pas "wrapper"
  for the .TPU is very simple.

  A couple of caveats:

  - there are a couple of minor bugs in the implementation, it
    works fine, but occasionally the output will get *slightly*
    mangled.

  - This code writes *directly* to the video buffer, bypassing all
    CRT or SYSTEM unit calls. This makes it generally incompatible
    with windowing routines. (This is one reason I want badly to
    upgrade it to BP7 - I pretty much have to support TurboVision to
    be of any future use) The plus side: all CRT variables are
    updated, and so calls to HANSI can be intermixed with calls to
    normal CRT unit functions.

  - *Only* ANSI codes relating to the CRT are translated, keyboard
    redefinition, etc, is ignored. (ie, eaten by the emulator)

  - ALWAYS USE THE CALLS THE WAY I SET THEM UP! The functions
    internal to the .obj file are NEAR calls, and will not work
    correctly when called externally to the .TPU.

  - Use care to make sure you do not pass strings longer than 256
    characters to the HANSI unit - longer strings will be truncated,
    and do strange things to your output.

{------------------------ snip, snip ----------------------------}

Unit HANSI;

{$F+,A+}
INTERFACE

Uses
   CRT;

TYPE
   CURS_COORD = RECORD
                   x, y : byte;
                END;

   BUF_STRUCT = array[0..127] of byte;

VAR
   temp : byte;
   loop     : word;
   cpr_buf  : array[0..8] of char;  { 8 dup (0), '[' }

   input_buf        : string;      { input buffer for ansi proc }
   str_ofs, str_seg : word; { seg and offset parts to point to input_buf }
   attr_parm        : integer;

   cur          : CURS_COORD;
   ansi_params  : BUF_STRUCT;
   saved_coords : word;

   brkkeybuf,      { db  3  control C }
   fnkeybuf,       { db  0  holds second byte of fn key codes }
   driver_init,
   max_x, max_y, ega_rows,
   wrap_flag, attrib,
   string_term, recurse, cur_page                  : byte;

   crt_cols, crt_len, columns, lines,
   buf_size, cur_parm_ptr, video_mode, escvector   : word;

   crt_disp_mode : byte ABSOLUTE $0040:$0049;
   crt_page      : byte ABSOLUTE $0040:$0062;
   crt_curs_mode : word ABSOLUTE $0040:$0060;
   crt_curs_pos  : array[0..8] of word ABSOLUTE $0040:$0050;
   crt_EGA_rows  : byte ABSOLUTE $0040:$0084;

Procedure Bip;

Procedure A_Write(buf:string);

Procedure A_WriteLn(buf:string);

IMPLEMENTATION

Procedure Bip;
   BEGIN
      Sound(1100);
      Delay(5);
      NoSound;
   END;

Procedure Init_Ansi; external; { defined for NEAR calls - do not
                                 call directly! }

Procedure AnsiWrite; external; { defined for NEAR calls - do not
                                 call directly! }
{$L hansi.obj}

Procedure ANSI_init;
   BEGIN
      if driver_init = 0 then
         Init_Ansi;
   END;

Procedure A_Write(buf:string);
   BEGIN
      if buf<> '' then
      BEGIN
         input_buf := buf;
         ega_rows := crt_EGA_rows;
         AnsiWrite;
      END;
   END;

Procedure A_WriteLn(buf:string);
   BEGIN
      input_buf := buf+#13+#10;
      ega_rows := crt_EGA_rows;
      AnsiWrite;
   END;

Function CurrentMode:byte;
   BEGIN
      CurrentMode := crt_disp_mode;
   END;

Function MaxRows:byte;
   BEGIN
      MaxRows := crt_EGA_rows;
   END;

BEGIN   { init all EXTRN's req'd by the asm module }
   Lines   := Hi(WindMax)+1;
   Columns := Lo(WindMax)+1;
   driver_init := 0; buf_size := 127;
   escvector := 0;   wrap_flag := 1;
   video_mode := LastMode;
   string_term := 0; cur_page := crt_page;
   crt_cols := columns;
   recurse := 0; brkkeybuf := 3; fnkeybuf := 0;
   ega_rows  := crt_EGA_rows;
   str_ofs := OFS(input_buf);
   str_seg := SEG(input_buf);
   Writeln;
   ANSI_Init;
   Writeln;
END.

{------------------------- snip, snip ----------------------------}

   Here is the .OBJ file that goes with the .pas "wrapper"
   you will need XX3402 and PKZIP 2.04 to decode this output:

   Cut this out to a file named HANSI.XX.
   Execute XX3402 d HANSI.XX

   You will then get the file HANSI.ZIP which will contain the
   OBJ code.

*XX3401-006692-291193--68--85-59886-------HANSI.ZIP--1-OF--2
I2g1--E++U+6++-xFlVXLQHlg-Y++-Qa+++7++++G23CIoYiHo78hJdrT3H3xdwtQqNi
0e3r8O5bEJl0SMUE67hYIm1NHLMr6I3l5mdK3+k7HMIUDUo7+WeWoY5oDG36IEEI77-4
YK635VOOAG4c3AKcYDnCr9h9S9wzTjzxK9znaTCRAySQ8TTAjFDnEpbk6lCSbDecnSt7
5JoEnVXntiLQDnbQDbLel0TibnEl7nkwQq9Cp2QbDlYyo-MpsAK03WmadeR6OBzMPK4-
60tZ8H1qW8uiLP7IAMlnlHgQPlUgsf6-b6zIJ9nROowU8cYlkLbf-Me7qCEohfU+KQmN
XgAK-1CJuD8ugf9NovRFQGZiVmi3fExE6Qm6RuGY71gRv85Pi4GblyHGzvif7wvBJhl4
XIpmi-pNv7LzHKKnZkBI8+jmCf8wRezLnQuON308XXIikwraab8rEEiOgGMSSuMXrVTb
QfbXDKmDqF+mSY2EYubq93wKClHcuaSmqQ2+2wN0AdDX5GtT8YoGinzEZIPVwPdxfUED
uz4zC6wXYII4i8MgZ9VYNu9Dur0bgdw0NWZkWh4LNYxog9w0N-AKDBNhHzAZdBUHKT3h
fAAHZya6wvfQP4j+g1PUxh8EIXmgCY1GG0qfvZFT4Yp7IO0-dYvDIL6gKrpP-6t2iwzh
4ihV3kAY1Q5h6-AS-lhxaq80QskXCnMXUFar-FLf5iBbDkekBBdsRr8akyp9RWNvqMrP
H70SntAwni5rNIqBrSZ7ph5OInognCFvqnFD2PURHewttOpiqnWoBaOw+zrQsiOAwK1H
UAzVX2xbv9s0mK9CVf+Yeoa5sRBS8UpONBrIVEqqaXEvpdrgROF7BiNKImheOa6Nd6UH
54sLMxA1BfLLRTlZ9Jt2tWU6MX5bqnD3yge0M8dqc0Sm7qhapXjeCUwf08Lu5JHjEKVW
GdpA0KYehRHNZ1U9BeIidWEN3bFUASRWaDsbIVnCY-VuM3aygASvElsjO2uOLNIpxwUc
1kkdO5B9bKQ3lL0hn9C1bWpcHOfREjG0KdgThDdNAw7Sf0Lf458Z60nEBFzgOPoy8qV7
PHq0n0tqRrN9rS2ygoA2mqQRUtvHUTcvg6U5H+yxEwnJxPcnsfntiYCOhZ7xKvfGKKXV
Yfw2slRMOzs1OwifK5jy6yj+exYRj6NpsVRNNru7VTCTK5TyAyj3Tq3xy4IKkOykjjke
uwRjgYVSnzfn-XO6AztrnjZR5DVE9jUkXXmOGnuG4rkI1y7q5glXSEWDtu2wWHTVcrYM
5wCPwZHSX8TlthnBKr+DjsBvSGSSnPjkSrYTDdt5w+TtrzV2rdQzlDjlFrUYTsnTmNzU
BjsYvwybw0WSkkTkL1uEHyC1y0kya1x1IQmV8CPmizYwWi8TT1VzYG7Nk2TkFFHBmlHB
elHB2cfaBFv5Jz1vy2fmgcewf02juwX9KyHZ5TssznSTl1SGhorYvHoyaKwVXxj6szjY
vIAybSzWAzUSDdDj6wyZz4ZSkNzZ-zZgTcEWCAPnySQIkJTwSLuG3z-HT1vzZfz2jyQ9
yLa8t+S8t073Q6YjtNTtAbuJ9yTL8NcuWiEaFR3+IE0gtkfStg5k9Uy-1HkABj6KIAlP
ksSw5SnUvK2bvkWvS0TsW5S3DHkQxj7ig6xrVzqw7tHmrZ146u0QxsI85UaJr+O5y4+s
nCy06rkM5CIXs-WDUSAw3fvWwT+p5kobS+fwVvjUBDT+Bnk9jiDXsLjy+7nV2y20TkFy
s6x03LwQ9j77IAhns-9DVNzsHDWNDkBLy4msmdy5Ozk3y7ILkKxw6RHllT+5Tlbyt8z-
1TsurCFjEXpT1Upw7EVM1EXfEA7uID+C49+-Ua+XB6BWO+uPc+Kw-mpV8vG0vR+ORY+P
q+ZhsGDc-9iVArk0LO+2ig7y06Qmu+sJo+ACE0ws-9rV4DG-9u2jb6-yQ-6WsHxUUyyU
Dtm381UD+y354+ELsSxk0Su0bq+sz+nFw+iAU8gk2bu3IT+vlA-TM6Q4W+IVsY08S102
+s73+cG87+UHmR-0X6MqMUmo2ovc63nEIOF-Nt2CLMIPSUUDx-7Su0Amc8z6V2Ul3e72
BUkIsq06i+S4WLgVKcm5YS6yW-2yW-KDE9ls3-nWAIUEXoCWa+H7sUYM6tu2312NL468
iAJHs-ItA3NAVKmF0yB25ckLow+bdgDxMUMw84P0F1295VNDkmHl11kVbcIdMXPYW1Yk
HSH1R12LNcXbM8OM-vB26HkhWi-NwMrtx0y2CS7Ja0iKk1z3On-T96IWwHew7Bu2FK6N
9-P9sJKl+ZsHeq0dK+pjW1KkEem3ZK6Rf-JjkRhWDTl9j+rz3gLkfhU24wIKq0GqkqPl
6KkJCy-xgEiqWszUEz2lv-0Tk0ul3nsK7P-5v6CxMXzg2uJE8geUL7F1dHU+-wF-C0kC
kF3l46u7Hy4sC+8TWuDkVHU4LsbXQ27w+OT2Zz+TwFKQ3Zz1hy6YT0xCkHZl4Wu6Pu38
T+QzWXBE9SsKBK82i0WS3NT2P53Nn-5Ll+jWibVFz0Y8FPpM91Wy9c9kHF44moFHL0uO
sofF2ZS7RfVORAEp6VnT3LpkUsX+XO6j3ch6r0Fgy7u6kgpW+4sJUr0L46MTWS5sgFW-
iwIcr0Dgi3T2MMZks1uFWDh38dM99pO6H8kIKLV+XAB1sZsw95lsF2n+cy7-D0sSlFDW
8HkdQj0ImADHMXdy6tv4voEyTWySknDWSHkftiAtgE-z22jkFz2uzW7KsqKl-ey6RLVJ
fARfsarwHPm1BwFvS3Bglbel3Fj2ywVkCk9iE64v2D3XZ9UP3Lu0-dNU2Cv1M0n3dbUM
ay2FP6v5g+JyWOrk-9P4Pv2RTczhwGlqkDDM2Lz+Cz-5v6Epq-ZfgEjyVBrk3ym3Jv+r
LgIyS+rvsezM1uxX7DuCRy6Tq-xjM-HKsk+IQW-8CEV1tK+AYoCkeFm8nSHRq374Mqgt
+hj7YRVSXg8CocuRNFlqZT2M9VrMLGNUHta6jKEGxdNXg6xAkPsm3Th77oP8B9lHdiB+
uQ4VAUC5mT2sEhu5AT6T40gbM78w5pDZN2mHIx+XQn-1HgJgaMTXtHHomSbs1nY1vtQn
wK2t0lyHny+YyGlCZfBledm1SH6TNwWtC2jCkxbmSNkfLw1btMhM7+hkUNmD9wZ0T2IK
sF8t+3yL9y28iF-LmIKsJWv4RT7ZT2gilErmRRkYrwHBQVZiYwhlVpm7iyIer0BLsrut
3WjYSXkgBy4bwXow8XTXNr69TWursdRm7tuEiz+PyEaSZLjlb0n-0r6zJgZGf7NZy7Ag
lmim+ez7GemH-z-DSEUPt43YuZDYuUW0CcecXa4kCcuVuYgAImSkdHe7fRJzg8ouXFrI
hrW5ic-RJCuGsQ1s1xVBzMUxJ+p4e6gMeKeljve2+xFDC3XxX2DI9nVILQPVuWeCIhTE
fbv3SDIP7eXfa8Vylx4e1gScDn-3zMLduUNu3AdA7SIxGYaTAiE23GETIA5m2FIW5pBB
t4EJ7eScdj6dpInaeCMmJvKEopF9yMle6qSfhb8SOWQ9J5hNd1f8ZpEbiJ-pZchJ3za8
uWeLe50tJ5KHPuXiQdbe6JScbb8JuWLLeBtmbScXpug6yMve8xxJYP7MqSFaBJ-iIsDY
Vqekr8by9bSd6T6XBJFyf2P6HxF6iJSBYaIeFdMfiulIWT8EGd75J96wdYP9nxEMyMJ8
YJydJ5Z0CSJdtN9Te1FtJeL9wmdPJeZlwYRpXvmYvdIzez5m3rKTj8lwwceO85xJ1wYu
xP1wEnoWzp8HtIopFH9X8MZ4XZH4J-ZgtAZEMtdgNYmL9MoNgfIlIvMlNgZqlXCmUz4g
v4nAZZqBCP8PYGzv4Az7jgMwqRxsLUsktgj-Fe4wmmWGRlgjmS54EVZh976XXQImlbVN
lVajG6TleYkmZgXFlZ6tlbV1dVdjGdSlH8MNmqKugJNuXLImqrVPXXDy7Lr4BZZVv7OJ
lVttmDV25X38t13XbznA87BT4CLmOyCUD4YQYeSBkz8AwOawM-mFBQMlSR2s9bwl2UiO
g7UezlhjJwCfrs0fPbifvKPQ94V8p8qrpVt4cOLHy3vOqvVMo6ecsCFsbzJ3Fezfx88Q
fRxUeo6GT53dpfRP0B2CRY-zD3QNQKZi5rpw-F4Lm+tPejc9mzeMobEGyx7G7Ejuiopn
mOn8ftdYds-G5+ZSPLIoiq1FzWx0QeXd3Decow4eN8TDaN4e1HVNEo3PcjvfGoHfiZW8
BMdPrnmOHKS10dcF8wrjh8v2S7XHgYY1w1XGBHKKzKtFpbSPditVTyUjVudEycdoiLpS
Sqm8Ewy8XoohO2RwaDZxZi0oKfGb1Km7pGDFtMeDnTMuL-ZSrGCQfvBakQzFNkpjnIxP
kwr8xbZRDfQXoODdGDtCEISWamQuj9vM39hnX5wqROCLppXXcvg+Joe89mBBgyDtXzcn
dIcsAp8ohtJwiGIbNONdSFL7dbSGTRaiANdvWoQrQZYKxnuzgt5nCAn6DyFFyaCZ8gXY
z6c5yTvPG9z3fzVqmqhQkZUhby7DyiJMgzpvDgAztv3XT3OLWvRIsdpOjgETwggNNi-L
SOezGoOOjwhB5aSdSC7AZEMSOwZiGku-iunEr6tALq11hMKhzYu7PerI1bdMGWHvIZki
gqQsH9QqZGPXL2tjgXD1LCv-2CLTZsbu0P0vst6oDEmyhLOJdURclUJX4ta-abY2FjXL
mywcmq8zgiNNglGbtWP-f2PB18STbErv4UBBG2Yq+poAPOrFC79BtGu4BE2tLgivsEpz
7rCHC36pyFp3OytAIj8ZiJpl1cx5wnz0xtOmtiBRHbD2Zy0IBK7B7WQuLKuHzUa4K13e
qiiWdoinDwDQFaKb8wrZAHRCa9XSuB-9dBphwVr2gYMXd4uN5WU4KaC6xtUf30zez99D
5CDHsaAnmM2pt1aWZHK1mGYyJtf1r1lnlHFfxXJbvdJ3+jqRsfHsffVeWT4ai2ZQgzHX
srnKWasKrBdiaf3AP-Tzge6ZmibmX9KP8r-8D5R9oKox7xLW6Qisltni4f58jlJGTKuD
lGnlvu7IgiHJ3pYKXJMigSV2bO7RPeiZZLwNIrra3Nh3vfMq8Sbu2gZ4Ib8Qrzlwztt8
xGKtIVoKpyEK3pXO4h5AWhBhlbaFsalDMZAfZKIssvn79eSNW3NGBf04YC7ka93S6iTa
YWPEzNLCyzMooyNpwIJ-Jy9P7AHG+t9hxB6JcQDhddGNODSO4jJWZXKKVBiuQGmptXP-
3yiqlsql7X667kSC57o-vSt2Qrlxw1gzHNRmXJhm23sBV8GpnPFjDdnsHqhO2l9HT8bq
P3xuVgg8lMj3zVvIYimtlRy9Paha9IiBNy-HK3LEaFdO7GFun5gvbtCiJ-hR9Q33UM+R
RifcG2rKx4dwr1wuVoQrK7jo5HkEI8Mdj4LXDPlLLqZJBRB-OEgyafmsJDDtCcnfzM3F
apvqU6TjQKNUGjF6+jdLg8BzUAaIB1Cwyh1IT3CNruUSNkwYVXsGzKbjhcLH1GCckJmn
y85YpaSZpxrmKi+sxkMGtkbN6f0CRC2OMAz80M2Zdl1WjCNnKmIrK15ci-ebi23K-qN3
RkyM03Az-lPLr7uCf4EfhOUJ+LLO63sTrOZfieruz5MfUFrTFJo7V8SnihhGnZFz-ZVu
***** END OF XX-BLOCK *****

*XX3401-006692-291193--68--85-50512-------HANSI.ZIP--2-OF--2
CU6S7ui1hv2-0vDJIShlHx+bjNb0rpKf+sfKVXPNMfIvg6RiDG-akqOplrk1ExfetbPS
dUPvNmTKskjYUcxJHQ-D9DpNE3CTe4K-Xb5aeVlGbE9HqXXm8fIfgBRQ8PTAzOcS0DFB
GH1DHbL75pt8Ugtatj4U4o8Bk3dFEq1I5MmpXOGSCIrqBNvnjofdeH-DFyC7EB0-JTMO
Jk69cTSfLXhBXnDS1B0XIxCw+SpllfyhjKzSBdhbouoM8ckppg-irIPH3H-DYorwvue-
uqjBJVd3Ot9p8ugakibijbxacXpwU0oeT4XIX831kWDWzdMm6GRbNbXGV+QbHNkNDi1i
ikS4rlbyoCGQQCjjF4YHdXskMJ9s23hIK2XDVxQMydrq1cDxgeOdTf3YIJ3FtUommpaV
K7ZGo13bnLS0LV8hTkNj069T4RNlqN+TJA1OzgvOplYRtf+iROlf5MPLEPQupPqCxuWH
DSh2fncXMV5vqu8Mjcj0ymruFyGWtbQiGfAhWiezO+cRIzEWR6fSZpOOjpK2rLEHBoQw
9PGwGOnYzxRDuxTsRGu8RbGT3KWVintuDqfIX5sk7mVhms+BKLQym9sAYJ3F9tnNEDyJ
fa4gg1RXFGQ5LbWZg59UVLv5Mkh9DTIZVJosirvy5eXAzt87YhR9PMKxYpXyVHaZONto
RoPaKBJZIACU2icRIrHmgnB3Zsh8fqgn-rOmbEhD9WmtxbPFsI0L9S5LBbMpTDSB5tRx
HpNdOIV79YxOlxaUYbZzE6sehaH4n2Us4uMMauN664dMvo0RgqdjEmbxTM5JbcWUQeeg
c79J5a88gxem00cpFHiWRcTTo3iAZOtZf60eN8dq1LC45gn10aHqsjFc6nQVyctQPnH9
IvM8pFPMfUvgsrjNj37V4qOQeQjfOQgTGKmie9MnKp2WhsKf74M9cU5ROcVUqSSqZpdW
reyqSf7GrNfJLjEfb9DJBmI4KCr7BBiO73NstjWbpWzzkjGS-G3ZhbJ798jIbSMDhyV+
Ji3jhRpnco6DtYN4wplDBCHpA+Rd1egucxsxu41V28dBfGywIRWKgNpA5KYyfhFRTHwF
7CV4nFTOC8gj5zPnR-lsw2XnkeMKEwP9rRJruPt1eDrcX31eEVOd+mbdPdcyBCCxkdw5
5elxOulP9HWkgCHaLURPErl7xNuPKsNjc3Wdiira3jS49K4qyGCnqMORWOlTdSqhgSm4
AQtLyc4eVEyAkd4AxFp7OpYt1POkhCdxBkhjN4opkr-PffHHQOLPSGpgNwDqHsD0zKBT
9efNncdy3pT2ZSibsB-qRiBu4Qxhwa9xnO7xGO72p6b9eWjhemDJCHTpZffV8mqhjHaT
oU4hR2o2334hUHNAHHEz7rQ4MSo3qw6i1ZMQTIzS7JhF3lSfA-WhhNAlOiu1hSL3oGBm
XSVFiQ7NOtmHnuoM-KIi9mx97rU64MGlV4n0DMHl--xV+i2-kYH0ksF50MwHbW-A7Xl3
a2f66okbn0EwHLWKA6QkZn0Dw2z0WsHtV090GsF3V7Q7fl7S6vlCS7Ckb90Gg7ekZj+K
sKo0LS5TITOtUWNZLmg68OjJlEoj9qxCJ5Zb-K5ZzIZ87fcwKlTrui6TibVEOnmeWoZO
b87pwrElEsjtibV-3khowOcirhH3OZqwfMhrRJ4g69FwWmsyoC6CLLlB5fyZqDt3S7Sk
YP07g7akZT+yMHhV-yZR6jnZtFKA6+ah0No6jEYqkZ-08g39VWimRD4I9ePdMWt3Kp36
6uVMdKjfRCoRrO-1eRWdWkdRT82PHibOhvesGiNycocZooIn9uxgFSV+W0+nZN4O5OK9
SCdLaOEt4bvPmeI8KZSip9KpifO3Cbl2q2yUIJMSwD6aOzM8zbTQCElfhlJ5FyKoWPtv
Scj6e+91r5Lwb4zbSpXvFbHrL6niYnRt7qA9Hp7WAXTdCPLn8Oltie5MN5I8BCbQZhFt
S7RoBiw9RiuwJgZec3pAqeil7fKVC5ds9hWRtpsVZnIX4vHDxiGnRKHI0sNvKwXpQyCM
QOu4jBNoOsUSbhQwMAdu0aerFwTYX6iSBHonShko3HoVlladAhCvFAOw6IfY-YPtiqW6
WzIvOfiicwzZxZTBs5H8vviT+jy+ISfC2mhWJhcOqbLBjgxAxtIuMP5EnqiCApDPYgqa
aV+keG7uy-TGgnecd9XcU4o-1RCY8JLf7vXkD1rBxNwKx1MD-59XDqyue4LOIjo-cU6p
ncmizaB35ngZpPDyggpjCdfNtUx7MKuRCrZFKzxIrXWTBixDBWtLp7lYXIf3oNpmddnv
UoOOkalfFvByyqlzIuAd3tgF3qwQTSMjImwrh9O3OSNAOJuE4KvB+GhgAoDfz9tCXsV0
vfizjaGRZR7BiPsYXF7cH7cNx80GaWbwBazYGDgvrvfFrzYUKVtuhuZxkpMI0BDoJ2k5
JgTcgBn-oG4t1oE5tsN4-yIqdsCgTQp4JZD+OhkrOy7j1eDlHVQiJqmBem5RR7YRIZ6H
pq+4obTz-ulTLPwubM7XHMxBS2qT-jhpDJBtGjTeo4+qxjinrtzINGWRD1amqjhbPRBu
eevFWluXIv4BrfuWKKuk4GefwHM2f7qexrh8rws81yGTBOuTmhwLpCyn3HdXfwmiqJJj
Oaso7vDayLexlDzTjwATAKg4DkUyogqgv8IZanzGlQF6gt9C2grBQfVolEtSFVRjNLQE
vj9by1NSTW100qJr8aVFBd02YGH2Om4NKhq2QMFQTyNSuQzAtMFD0JxEVxDIsMlCoZIu
DpCy8qiU356kq+jZnOVGrhP91rMWcPi0NiKx3HEjXm7a21313HEhXpPEdhmiOsYuLsxK
o9swZT9GYSlAkonaFlv610dznAnPZ2zdL0abhBWVT74qjMEYWeRw+y31+iKgwbo2mZTZ
blBCYuRnLXVsYPlRpfpy6v7CEL1tHNorIOTA63q2uO6J3ITPNo73HweW2ME-zWERHoUV
oC3tmCi3WXbIyKVF7exMeeqgpkJ3c3BnesdxKXecQzMFPTCY9YtffccoTW5IIHtZCjhq
ppaNEATVsOK2pJuc73hRn6mvGI5bmapIcJCboz70yfx0Qjw5I2g-+VE+3++0++U++5p5
44BRlD4k4E++3mM+++Y++++++++++++U+++++++++2V-HZB79Yx0GZ-9-EM++++++E+-
+1Q+++1L4E++++++
***** END OF XX-BLOCK *****

---end of HANSI---

