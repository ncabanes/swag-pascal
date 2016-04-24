(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0417.PAS
  Description: Creating a Control Panel Applet
  Author: JOHN BATES
  Date: 01-02-98  07:34
*)


> Is anybody have examples on how to create a Control
> Panel Applet in Delphi 2.0 ?

Borland stuffed up on this one - they didn't bother to
port the CPL.H header file to a Delphi unit. But never
fear, Johnny's here. :-)

I've attached a Cpl.pas unit that is the port and a
CplTest project that tests it out. The important thing
is the CplApplet function - it must be exported as
"CplApplet" since the Control Panel searches for a
function with this name. With only minor changes, the
entire CplApplet function can be reused for any
applet.

Depending on what you need to do, you are probably
better off NOT using the VCL (Forms, etc) and using
the old fashioned Windows dialog box functions, etc.
(you can still do this with Delphi). You'll save at
least 150K of disk space this way.

{ the following contains additional files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members.

{ ------------------            CUT              ----------------------}


*XX3402-006132-281197--72--85-40319-----CPLTEST.ZIP--1-OF--2
I2g1--E++U+6+BZnHW71fgIt1k2++Bk-+++C++++J2JBI0xpPaZoAGtkMLC3I2pDkn+ADJCd
zw251ViO8jKuWEiRlU4a6Pe7QteO2YWH8bO5dabzbLmAQNb27TNvTbuqAlf3gDBDiQWnD3C4
oPo9WE4AV7Fb+4z8hDOPNf-46h4Vnyc1vJVdbpJO2+LeoMbVEwZ+KQDCVi98ihu5dF9ORXE9
NXKr3HhBQFkT-UnYBUV9i+QNr0MFHYA-s3YoeAgtP4CmGCHauK3YhgPH8HbnUvAGqx5VFJ3d
7PwaBNcKbJRjaYyID6rmkOaxM2mRFrV723foGnX-mVe0IlGCXLStu08u6jAnsZ3vsE8A7wrD
duLDvESBDFeCLM2trfv0LP3QfIw-zKqTacdzXqWkIxvcdh8KoCDT3Lkgwik5I2g1--E++U+6
+BVnHW87arq-B+2++9k-+++C++++J2JBI0xpPaZoAGtYNaoxY23Ckn+EFFq57eJd7-Ngq00T
c4frPBd62OUhWMWV0nOsuPGlQCr6AJ+YPg6Ji-tfG7moYXLmmDtjtjyz+O7lwf0QcD53XsAE
HSClFqCZxtCSfKQ9q-frmr4d8Zr50OStsSwE8Kao2bszaQzSX32ma0ax+NqNHk3yTppZLCve
KwF8ktLofXg-GNY2EONZ8Q+E0dIVnNFV71V6QkhwJlXr4kJhjy6PIvX64QGpSVEdcPEznAK8
msruc5+kULpcNTXrr5PrP+xSiAl6laF3Ah-wqyfhPU28Irs+IOKUvqFSs7R-+ycE6T9cUep-
S9Oqtj3HslrTxCkuyB2vTXutiuE3foVx414BdKphOMGEHxhgHW4pi4S98nfQz6WvCi3kAixH
hYuOE15m2pabYPzusF3XKsHEDp-9+kEI++6+0+1JQYsWAzhwb4+-++-g+k++2++++3F3HJ+j
Er-gJ4JnR0tmNLCZIv3Ckn+EDHSJqYW636aRXcnRqUoE2kDk0qlZX6HISABGVrXgOaLVBu6g
zdGCX72uV85eQSTUp0pZsdmLmvhrXVrb1U-UH2-gQKmTDOx5-C3Wcp3wtjLfbzar-+5xBhW1
Domt0tFe5ExugBOGtkWuWnTW5+yr9vcB4vpMm2OzBBANdl8TnpwPbSvtTrHhHH5LY4RgbghT
CaVo4NaPnmzI81jRTGk3wYmeXJmqb+BNbYlnDEAToCZ4dYCTE+4GORZNRq+PyFN3EyYHp1Fr
SNDiGAI3qzu6HIb1V9kgmf8XQJ3KdX6-BsIl6GwsMnyTiJY3r7FJ2TnGq-n6h4-pm0bVg+VW
QpEJlrlpcb9K+AYdY-FtK6--HP2hUGdaU3MggEO-qxs5PdAORpl9BaeV+hU-6I3QLm5KV8wP
l-o-4Sw2j8E37esony2Fvi+-bUXrw2nSKxULr+o0liCyukfi6U5TI2g1--E++U+6+7BlHW7G
ggGvBUU++8QK+++A++++J2JBI0x1I2kiI23HvJVPPm973LviYSMzb4US3YwM-XlvGKkt2U2w
Us8-M-lq30KXcfi+qbFLcOteAukpzrrDCJJ+BxVnKIJt0j81ivfeL9tnyuc9fFlopibZwqTD
bmbhN9sEgOG5kYfvz3Zo6uoJGqbfA3AuAFi9ClxkjHAOHWSXEODrQkwq8Yp-O9iFCPWJgd1t
EvWKE0c85OzkLl1fRGcRmMtaBlwusw45EThiq5b58x3a958F+TxScIVG-WiIY2ck0sV3aWex
704oCurg5cmbhxA7PRAWsypS3nUHx7xevLKxLeUebYviSeyjqsDP5eWxa6qkEMtAy2lJzT-i
A0-V+0Scf6ppJInE79SGv+z0hJZ7nQx-ImtRYKh9gad8BidyEn+FdEWs3uZ8ejWQDLzqWTH5
FZhrv4QILIIpL9avvIryq4cqaqSLdp+QvKaRQHswh44-HXhZB8lnssnPfWIgH+uRQRdaUqhb
fDa-rWFm+MDFw0rIqiBy1s3s1mzPsz4UBzokbckuNvJrgq2LJViRMA9JsOszb27aZrJzm2DO
eXmRbppuwJB2e4PGt+kGsEFMZlQl+WL9VY-K6BM9EZrd-dsXax1JkFUxvEyjFr+3zkvz2UG5
pJn47iT+eeGD63t2J+Z9aJx4oMD0-RlVHN552ZFG7mXiJG6Ha4yDU0+-Ewn+WU-CGPGMgVTZ
B9t0FZwjHBI6LDUa4KYLQPe6IeCL86N2M1rbU03G4YwEWfFDuiEG5U6G1DISh43j3hPP-3nd
YQ0fjXo+a4lipOzcTlFpNuB7ZlFPZOZItDj2BpaKdAhDTjRp8dPqgBojjdDdiaDEyszisW-b
VOhsadR741dIRXLucfDFmUQrWhvpgJ1rkTKmuftAwQxgR+1pIApojDGfNK69QsYe258NSAnh
fnvqIGHmL4nzqKkorfHyFRqcfOref+G4wg4iHCusHMInDhOZAnyyCHt1XjbCJfBCi+8P2Heq
IodcLOiI3CxZhAtzCVOm3at3fX8AK0KmV83DUp7Aboe3KHIJNhJIaDoz3PuM0XCgq4xBVR8N
rtw87G5TYUendp8VaUbJFA-rpLulPy7V0hfHlip5qMLjxmzIcXPf1zzFaw-Tfe1tgTYxnepD
VkZ5gujvThWyuLQyH5erC9uON+4ek81l7e2RVAWUNkaC-3WbG4o6WZm8xB1Gypr9AsomojTz
CcfmXFlkrPRXh1mPmxnGSRetwrEzWVc+EtBbCBOrRRtVhxP712IFYu6J8qZs3zFU+1Ar3v31
MxR8veLiX97AbOknCC7kDGDn-Me8-J8E-clo90jvUEM28iRFHOaf+wb+vKJf612cKlj0I2i2
VEWG2Ebm0bE60dpWT5UzZkoOK7-1U7D5asr9c3nXB+HUN7fOgWfIEWTMVcelRNUL1Yr2LM6g
E43gEs+Jt9rAIOL8G-KEaOkuIFMXi8qs8iM4FG4rJ8WFfC62E7CFe+OTuCEK8oP3v2YWMmk2
d3L0JGElKthHYUQxAUZqKfXhjlrqfziRxb+uS+yrUx2Awx7Vkitgcf3Q3fP6HJOCprGvxiff
Q+kPWiTwN7sbi8bZ-baXo19Zke-Qp5MhMyR-91EX2ucTwwOOX9fDjS6ok6lB75TME+y+auH7
GEtJFUZ86YYD9v1WYSayTUb5-EQjLpRc7NbS5zObpDKichOVs5PI3jypIbDIYNuWlut8o6V4
9omVYwOCvJ4OIzUxqkC-uItd2xdp+mNAVtaIImY4LitZ2yW64c90hIhcJw11xZeY0Q2EMkcp
HZltqthqFbT18HZnzZZb2angSMMKQEFoEMrUQAZUF4Y+vD8agTSctKx+Lz1iQO3PIq-GKfmt
F7LY1tCnv8az11ES0RPTvzeH5cTfnRASIjAv9GcduBP4lVn0dKm+CZlLUhZcM0uL0Ugufzgf
GW3x2HHdLOoABxuLKaQvWSSIZJGd0qE3OwSGl4CxxRfHSj-iLMyygvhS1PtHytvBbNcl7mO+
goqaq1kqWiNRdJoav1IpXX1q+w-p5evY6+d7d6pnhKNE+jZK0Ru2uNo+5gJw5O5a+w7O2mhA
yQHfqxpqclQ-jBDsrDM4jQuIkzDxoy2tiW8GtqHn0chd9j3Jb8fsDuWpK-hRHXoT8uV4OfBG
43MeF6hw7LOIVjg2fNnsXavz5YOCtubtrPwCCcCzgTYzz5vn2pDAIzbeTyI3J6kADI7dtGVo
JHgH7J8nV9bty2XcdeClvsAzTfukGaJoU87OjfVRTZHInvvYyBBSEgL5fXaI86oChJ+ltcYI
ab8sK0Dnmlw7OCzbLLDzuKabTW4mBdS9E2qCT82dNy2uZr8Utfb6hpzR19g4bzKfnpWBYVur
4vbajhJRFLwuq-t+ggHYV6JGHoH2NPlqNHU3f+pz+SAaJCKndIv2UUBPw6WIk0Vf64xlg0fb
Slnq5YlhHvZezXADz+35vJbZ2+gaL69kfuT1hxDqN1cPhmQrF6TzT-f+BLeOdX9pCDXWxTB2
i58e5RS2QdNNoPsMM2NV64u4l43-b7Vl3i31Zx9r7hsnIPnXITFccdU3mdbQ1Pi1USyVXiI2
ZgsoVZYlWgJP7+bkl7l0JR-Xsz1ZfrIFbJP5sTLt-HNk46ndem-3IqxDFPD3aJei57KTNJ6P
VSxj3l3H1iJNyEt-OXXyac7rdDorEcnKJl8dsyszjFhnhNoraszK4qSXlfh8i0xrEeaBiRE6
kNhqTvVX1+rc2ph3EIMXoHoorzqbJkXFcHv9oxY9nH6iHC6rGQ3HPbxp6N8CGQDFP+ET5evy
SnwKeH6o9YBnKEqhG8861oLsBcqPTUBEGkA23++0++U+y5FC6YCvmj7I-+++XUY++-++++-I
FIpE9oBkP3FZQrEiN5-mZJNhPy6s2DuQZTcTtbcb+JKOhjgFp7BOcBhc6L0ILizHJGMlkHdX
tqk5GV5zzQNCEUBodHoY3AQSnwgnnwm2gtYWOUDRX2ydBdqn9qRTQYrpqFTjVMZ2ffIDHljx
P-X53IftSD6UpJ9PFGuMiE2acC3KEINo+vPqy4PbJ4pzaw-3ACYzvSlPdaFAYplFuAav9CDI
BBQWEOJhS5m7SVrUMu96weMBL6eI0JDhTBrjh31hXC68fKzlvzIYn7ovE2pgLH290bxq-v+a
anM8c45Dqa6lAIm862F54S5gbLOCHfe82YChwwqd0w25xqUR0otmsM6f5-UdqAUQMdbn--+u
YDWQ2vp+INd+WG9AQl5PqlcsysSqrLrD4p8hGIfjtJi7VBxsN1-RI2JzOTWB+eG4Dvlz5Lpj
3IMxeOfPDEl2djPm6VHO2-3Hjn5Q3BgBjxHMsyYMULRVqBzhvSxEvU5HYB+tgstGfibO4bP8
2HMeYUtgeomt-3N-E5TAmkEi1XCM1rLOViQkabuGHSj+GI7fmRMaWEbb5O-jaJFKTYIILZ8f
BZvwI787C4BhPn0CyWzRwG0A5YMpKgE2Yq1x+1YjU28Npn+8dqqcN1ljCu2aJk8237TjJ2Zc
HWTDzNMZ2yUwXX2lDVE51rS17nmFm0mpNdeuyooOd+2cyazC388be7OtWWbeAo-KV52msxGF
AaU3A0EPG8Y-4ltBb67ZnUp10A4k7RLc4JeaXfp66ULlEYegEo0hE+ecRGjMiOi6lmrQR9mh
RRZh3PaeshlxVDqhDyqCbeD1o3IFyew629+MCLaJCAdcX1mnm4B+gkruUjEUJTPfRgz3yN5N
mguiXjUTny4YTq-NnfF2REWAyVly6o4nJ91tlW5dCcPKBDaNk7qtaUD6XgxwgCG25CYPtQhP
OBfLJYbJ1dtTLK3xL+R-2sCwj4YJVUj4rI8RQgqGmaJVCN4zUqHxV9o3FHIyt9nt6Lwgxw-7
eZ5kyaXzYT8g8sKVPyPYZDS66GSvWl0HO9qH7959tfITxg9Lin2OvhtBkp3Iqht4xpViqeUs
qsVa0xOAQvWssxUfxEJ2nsD-dO3emEEqEYT3KHuTIpLGPbylB8jT6v8YJNR0PaSqBnHwAj61
eJPdkOaCIAnZLgQ08zlIUFLtgE89pkD1MagohablCWNagHhFIkZKeVmP0WEzO6HtudwkeLQz
u+uy5v16cdDaFhgOgijxPBjx-Aiifcs7hVqAcazUocjGxeKIzhelZ3kl+cSIVaMlQKMI07nP
IXq5n8VKuPKr1M6+Wf64ZSDMgOoRQ9Ckhlz+NTzqGxzwEp8L25bPgWISpJm-GkqcdyZcz3af
QGJSOuqv5mT+eeVdvDxpp9RH9aS2Ewkd2LaqPmHzks7JKJWkAwySTMVN8LlAeAPqX7hepOYa
6O7I4sL3W99TGThxBtzr5mR1iQ6qOeZFyrP+2MQJVNwdqCReYlIB-DPmTp-9+kEI++6+0+0m
QosW+D66u0I-++1Y+E++2++++3F3HJ+jEr-gJ4JnR0tYPqNBY3xDkX+IlRyLv9h+a6UlTE+q
-+KN12EZD7FFsQdcZvM9s8SrdtDcmqzbr1z9uJrppP4YEiVp45FNAkluf-24TG04HO+4k+Dg
2-U-Xw+H4aCc0REnp-F6UFTINY+4n623w+cgUHTAjEATE9NLdm37OutamPIYiTBy6QZq0y74
***** END OF BLOCK 1 *****



*XX3402-006132-281197--72--85-22653-----CPLTEST.ZIP--2-OF--2
49MYCPyIhRWeYvZrrpGfz8wEPuWSuAI7HBrxBMbKhEu1A3WBGFvw+GOw59VPg7NvFKL9mYsr
LwPTEoaX0h2hGkG7lOPOXSGbwUwbaJaS5n9u3enNPbIWzCTwfxO6CXSrPLSq6xy7bcjDciNR
p4eskSEgMa3mHOIZ7NZD2tAKiJKOV3ZTQvWOOqO0urmTQfhbDh8KgAI9ImyaLDCXg27XPpN7
vx5v+J-9+kEI++6+0+1vQIsWo93GuuU1++-00+++2++++3F3HJ+jEp-AJ2JHJ0tEEJCJJZpj
sXcETIuZzcRFvkD78UrhDc7u7Edo4mo2Zc7ubvMmWEaKX7pfCp08yCwvHg7rJxdxkVaDnwkQ
blb1qJEFhMNqlgRIayPppTJJfeayjb7SaFUe4KgTQ1JSNlFL9qgxAMnX0UwInhRL4HfF73QI
Cf8JNNkORmIGr4z+wqjIOE6T2YIKxkrUIeFAa7rZuxvW6RGIsUf1xebK78KDwfq0wKjD14N8
9UvsLgqjVK6aOnsSQ7nysxjUCoU3i+XPUmWAbUOXTagQ1W89H2LGVAriw9PASdO9q1+dc1rY
3SfwBCqwfxA4HA7cz2Y7Bit33IQJOdD2VDAaoDRA8iiz7+cDeKI11lt+AV3bfC5oVZ5rhHrg
qQmDi6W7dYIS64QqOQR-bvQk0gQBqDYsnaN2HOs200ZiDuWGs6t5Yus5AqF2tr4AVDdEPXmp
SWys6wqQeVLHh1XjoW+BEB5zQuNcUUghQlJHl1B+ZcFlAiLI-qfWk+iUHxOEIUCqD7cI+6iQ
4sMIUa29eX2nX6kTQwlRIkLlL2eI30+eY77evELPsWXmwE1rHKRXImtAtKrhuhkSmjvK5PQ5
YyWoR3KKzUwG-0mKEhQHFfVABJOSKSOlcCYOQq4uWboKxoPQb6LRlRYSAztX2cuu7t5ZJ2i2
Eq9ItzEP0NeZUgrK-NB3aqVBYnwdj+VrZ+0esvAQf1UVFzZ4yS6-LDjdJJ7hsbuxzj+jr+K-
WoLSrbhZs37l1r+gCPSGghQwiDkAYhI9yu1cej35nhm1zvbT2mSdFgSvAzgntJZP0YDTnQIi
vl-19enn20zFNWR7MdTibFxqkfTK2+CrxlphOswSgRqoIL4q3es58wMtT4bl3Jbf9l-BSfpP
ExK00K788IvnqMmeGbPvUpJMzF4F-TJftGF+PKRqBhHwej6H9uz8s-91XeExlVkvz-9+ijkS
kD9pl91NOfJBKbsCWNZj9q-qXXicEYoZYkQNsLpp9tHISSmpSxxDJ4HNGLCXPEzNxLuUPzx+
NTLuiQ+qjI5o1MffFKzvILZzPJd79Va-Ioa14wiQMtxG65-XKzI4AeCw8ahb2kE-Z4oB8VQO
Q5VFE4ANPzweJDDPfr9nHoJRISFged3spbAZ9oR2jMk5kwx4HR5WFuBpyzg9g--5WBrzniNq
miKIQ6Ut7G9DxcDY9m7Mm160tSIoDvVN9zkNIMrX4MpeiLw9YOKXlv-wcimHjvQLHriF8Knu
fH1O3WQ1qD1HzkhczkJEGk20AUgI++6+0+1NQosWEuv3CEw-++1Q+E++1U+++++++++-+0++
hc2+++++J2JBI0xpPaZoAGtkMLBEGk20AUgI++6+0+1MQosWWNhxUHE-++0w+E++1U++++++
+++-+0++hc2v+E++J2JBI0xpPaZoAGtYNapEGk20AUgI++6+0+1JQYsWAzhwb4+-++-g+k++
2++++++++++++0++hc4P+U++J2JBI0x1Q4lINLBo9b7ZQp-9+E6m0lE++U+6+7BlHW7GggGv
BUU++8QK+++A++++++++++2+6+0qUGY2++-IFIpE9oBEH0tEEJBEGk20AUgI++6+0+1sR2sW
Evj8wZE2++0C0E++2++++++++++-+0++hc471+++J2JBI0x1Q4lINLBo9aFkQZ-9+E6m0lE+
+U+6+97nHW6+wUXc7E2++CE-+++E++++++++++2+6+0qUEgF++-IFIpE9oBkP3FZQrEiN4xa
I2g-+X693++0++U+yr3C6h0lIiic+k++EUU++-+++++++++++E+U+9O-LV6++3F3HJ+jEp-A
J2JHJ0tEEJBEGkI4++++++Q+-k0e+E++B-M+++++
***** END OF BLOCK 2 *****


