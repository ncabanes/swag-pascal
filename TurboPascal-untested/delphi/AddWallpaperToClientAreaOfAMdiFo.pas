(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0283.PAS
  Description: Add wallpaper to client area of a MDI fo
  Author: SWAG SUPPORT TEAM
  Date: 05-30-97  18:17
*)


{ CODE LOCATED AT THE END !! }

HereI are the steps to add a wallpaper to the client area of of a
MDI parent form:

1) Create a new project
2) Set the form's FormStyle to fsMDIForm
3) Drop an image on the form and select a bitmap into it.
4) Find the { Private Declarations } comment in the form's
   definition and add these lines right after it:

   FClientInstance,
   FPrevClientProc : TFarProc;
   PROCEDURE ClientWndProc(VAR Message: TMessage);

5) Find the "implementation" line and the {$R *.DFM} line that
   follows it. After that line, enter this code:

PROCEDURE TForm1.ClientWndProc(VAR Message: TMessage);
VAR
  MyDC : hDC;
  Ro, Co : Word;
begin
  with Message do
    case Msg of
      WM_ERASEBKGND:
        begin
          MyDC := TWMEraseBkGnd(Message).DC;
          FOR Ro := 0 TO ClientHeight DIV Image1.Picture.Height DO
            FOR Co := 0 TO ClientWIDTH DIV Image1.Picture.Width DO
              BitBlt(MyDC, Co*Image1.Picture.Width, Ro*Image1.Picture.Height,
                Image1.Picture.Width, Image1.Picture.Height,
                Image1.Picture.Bitmap.Canvas.Handle, 0, 0, SRCCOPY);
          Result := 1;
        end;
    else
      Result := CallWindowProc(FPrevClientProc, ClientHandle, Msg, wParam, lParam);
    end;
end;

6) Start an OnCreate method for the form and put these lines in it:

   FClientInstance := MakeObjectInstance(ClientWndProc);
   FPrevClientProc := Pointer(GetWindowLong(ClientHandle, GWL_WNDPROC));
   SetWindowLong(ClientHandle, GWL_WNDPROC, LongInt(FClientInstance));

7) Add a new form to your project and set its FormStyle to
   fsMDIChild.

Now you have a working MDI project with "wallpaper". The image
component is not visible, but its bitmap is replicated to cover
the MDI form's client area.

There is still one problem; when you minimize the child window its
icon will be drawn against a gray rectangle.

{ the following contains additional files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members.

{ ------------------            CUT              ----------------------}


*XX3402-008093-240597--72--85-23227---------MDI.ZIP--1-OF--2
I2g1-+Y++++6+9mgDG8OanoRak6++D+3+++8++++Epx4Hp7B9YF1JQqIDKVHIFW4jyzariEa
p-e0Eu-4CbH6c-79Vkm3FVCG1UMjBgIAUGPchEb2t78PkN8U1UMQCcUsG5+E0YsRb-rY1UsW
0-pX-t4+K8LI9Y45EbrDjTYdoVErDTSSDDRvnrTyjiyQ7C99ZkWZGrZu9PqLhj3owFFRuusb
S-9o-eol7d6d8UI1Snl-wzHrtFveXBHaUNpXZEoyud5eKlMTpvwrRiEKnz9sSICwCKlJrD4J
qxLO5O61hISqffWLpgmu1aZiIcK+Jp2V9RR9NFDvDEVlnl3jZ0eNBIC5S1QzmmcDF8pKjEbl
lwwIVtWv2BCuOFNKVSQJ9MT30IxDj3kkHO5pCUObbBudKg2cZYHj9txOb5D2S9JGfpL3t0zT
hhZU6Gd7f-f8VyEahtnl2eJ0iPc8vTgqIJhcYXgXr4OrS7Swt9oUqt5QUoLYHQhq--l97NSb
mO6p6-3xaxfU7XGWbIAbHZ5vRz8MO9cISkdwGOVWdjwVfoG58AvLBCc4FJXMIyEbEPbj7RAk
qn6RmH8AILMRctxJ48BgmXH86Vd4qMAlmdd8Uqn-TtUZHCqQDNZchrHzb0yyYflqDLpFivnY
RVMrI-97h101TymrGokKyl1f+3JC8P1R7pEDTMKjcAI-wh3dN9sl7d9B2u9wPofz65ju5AVF
4htT6hr8Ax2uyAu38kZiUIqk+ns+Ro+zi+zCU9z+Vu-T7ge+EL+C16CDkMUgdh0h41UD9c6l
A+jalLnUJR++ns8TkKSIhQ76M-ogUcz+3u+4jU8nMAl1x-HIk+FcUPT+1ZU2xw2m88uU6Td9
FCR3CtWX-Oi1QG8U5ru9cAPWZ0zMykwHKK53DWrKB5V4v6y67eUFMreC6FglflqwVeLOBpyr
Dhfhjk3EGkA20E++++U+Wqdz5VY2cDn7++++vE++++c+++-1LoNDIYoiF2NB9MpVGgB+36FT
2vjfdUcxUUQE8Pp0Gf-UPP09zKhALgm1HJv6Df2xJmzV7Hm3-p0nxQwkkn1nzGFUgyrHNUa9
yFQ+q1lP87jlo0ubEGwSg7Ps2q99TJFCxpF72twauVvdfN5sRe9HcVTWHdbBObqHBiGe7CBC
vZ7qDCWfoiqdezX1sY3acHVDcqwHoaDFcZ8vclRgnwCR5-rCk6nws5JGyvznw5qRok4Rnr3M
RqIHjJnav4bYOxDn0ijWrMZy7Yyj1YomEjxlQs-TI2g1-+Y++++6+CldTlvI0LT9l++++1U-
+++8++++Epx4Hp7B9Z--IqpEDEj0A-1R0zoDBnWcG6SCWdCWIu5sUOD2SCd-adFQ8cXsrwqZ
uiHqjiuxYAtGUALlsbknmvAw6ljELtF46FoXtlb+xg5vE6MbQ00vSvHMcxcv5J43nCceqg6c
NU3ffxcPON4Q1Rv3IyZNlNKc9IYNRyKo3q8PK1jlGdW1ZctVcWAlKYxr3J64s+ZpHy4AASVJ
64QNLWbMbEndLmulDn4otnFwJzvvd59uaSxzc4YBBaV1iV9ZCRX+i3WiedSkK31YqFhEGkA2
0E++++U+iKNz5bWP2S4F++++w+++++k+++-BF2ZTEYRGF0t2I36f8AdD9ofAJT-BmMlDGWx8
gSPZsiIe9IshtiJGI5199wchpU4l+i9HU4m3n1k3xM-sBzwULvo+lq-pVKeE0gBOg-7bV-7b
R0J4hK-nepK039HoUZm1Oo4wdBHon1mEHgS0UdnAtAGGnDkwDSSWpAGGJ7+SXF0ksHc8M2fH
ad-86sV86omJEOJtE95Ij-ExLWs+I2g1-+Y++++6+AegDG95Ce1uOEM++0sI+++A++++HIF7
Lo75IYEiF3B9ZJXfPi6s3DtTWLTM-yWWC+Y7JAcDfZAoo99EOPgOeWcY-XnBPFBbdjqnnvv5
RVmQM8dNJGLqyHsT5txP9hyLDYaSG-8ajpsuJyAQylFve5DpG+emWzVkEtbAv3khw7tuFiTe
6QrMtMa2xCUtBUljAHYQeMQAM0rxRovwoyNXFeu4MY5TuDCNieNnxLqJdlbCuQQw8H6Qo1Hz
r-mXOQtU6Cp-UpthXyboiCtVF+t7X-CuwWBA8TsxpQUFiaqnJmjjcpftk7Jqzk-vZrvW5z-j
4aoOZRb6eDpcCpOhqa6i+hpDDUqCvS+M5-f-t0p9GI9pyBWD6hUoS9g+dr4K7i0FccrQYU8Q
zz4896OYNE9aU444BnvuCMIFwVtwC-KAH14OYEXTyH3i9fRDmoqyzdajTJuGV0xxVVG+USK-
sDbFXoeaoTN+Kgxu13iEa9-h5P4Nl3njhCphrug4+szWUddg7sAD2FhK3VRglQebFoOSjjCn
a3v-O4lc0JOLzpPuY3o77nvpFrtFmrgeyS2Xso8b2YeGusrxX76oMNCyJmn+Bl61GkiOAkbn
Vi4l1HMo7wa-nGi97Kn0ML2IXh7rBfDeKLRCQHlDEgnZhfT-TVsQuz1oHd4eH3jFbApQ9pal
p0bMdCwZr8ZwAi04g5qvD5UgEcMLW+5m8iyfQSupspl+qea7+UdloZrX6Ap1eFDQDYp05juz
Gdlzu1Wq+j3YI9Fl-lHTnFQledneO0WcGL2p38B7uSgdku6Cno1922abBJ7NWt1SG7JWeVEK
XtqGSNM8ub7JCUlmZAIFoaESMi0mL73qCUp6t8cG0Cqd6MD5cpaNj5r7mmn11Lo11GHmKfD2
T-2dfc5EWoVr1LEasbbz6Ud0-IIdw6DAoXkKVE+dSQ-oHm8Q04x-FFFdaERMZPbSpnHSmJLx
SWMf4ge1rGutuBNDEZtPI-wpPkk1oEC4+GIzgOWO6LShx8fJG1SpZ7muZBnCeKAWUlTAb3T9
kYwCdLz+j1sqTmreuDGw2D2G+-DaYuPSEPh2xnTPCAqnstPpjiqjDHAxwkiyLFCXz1+0AphM
XVBZdLKCyaKlfp0vVPu-cmecps9qNF9sMJWVHUgBSM68n4pVgBxdMPw3lV0s0VdszcouFsd5
RimKimoHEd32YFTSP2AQNISm3HanzFZ2qr15bJB6aeabkLyL7245Zys3FJ83TMYEdMQkCYVO
vl6hc5ZIqyBQN8J7EKiOsgEgHkyt5wSBe8CyVd0lVtsrWfQ3z5Onz2S5Bs5HVXYy-4aQ+FsR
QW7XMb75+sJXQFZFIeINz2-y6gZ1byqtlq+znehhnEhy9qWcigCoDZANZLgexRaT2LRZQ7F2
bfVOl4YUp77mhmZbnmQGuXSU-7QpAXVPJ04KcP4IHm5VG6Sr5YpgkTCkjZ8jh+b9jRUaugIL
KYKB8qJhTiN4VKRdgWP4QKe3RSgs7pUVIAvvVnO-5JpOlUJJwZ7L+tSOGIpcxWZRwUTy6Qxq
w7VKhtZnHfUXcK67Ifl8q9rNPDMWvZIs5MsWr4VVJZJNHDQ-vteFsWbBd62TeT8SZ-Sep75G
bGdpdTETJReLIhIKbf5yDZO3dYWbU9p2B6tY6Zo0Q7tYa3tk6lfzBXhy38HMImVjbyvwj1mJ
xnabHAc0pvr5pX1MIId86gbdOHVlGBXnZuEs3skVmHuJ53T12GqCp6TeOnUtxYAEGQd+Noo-
UjrdfahcC4mUiBt0bdt1sbyf89+rkWU3Nzr-rd5MCm4vjVfSv4Ovj3yjPfQDowr1xa2sKYmv
ey5a4cazWcROjDLoPbOzLaeMtXZny4onon0h3jDfzL8YcRYh4aUPHWMOMex3L+vbRleOou6x
LHW6qy9BjhqBHlhPpXImfaqf6jRPtAbkMJdjrbDhOxC3uw0iu6AHTPKyzv6S9dQBCmlMMA+S
D4v9B0l3mCeLRG5WkNhA3ujPyLPoC3tgluxGVuGUBaItaPyCjekbrQZe9IZaavFGx2l1Ibq+
29gXPVBv3XNM2g3JTDYsmJ31PhFmIwAzOHRywwA8YVxKHhxgPCjoUQdWrpgS0OugBI3daSQs
cIkaBCBTVZSFI4I43vt6TpGfWXFzNfUMzgq4gD407BkgNgosXFE3u8H+yBw8y6QU7QXhPo-h
NDAFvx86GQK6dRLZK4yK2AVr59+rYciguTCoQzITI2g1-+Y++++6+BNeTlut0CUriU+++-Q-
+++A++++HIF7Lo75IYEiHp-I5MpD1k2l3AHjHTdR906QSg+GUZXKrsV1fPQoPBhIasVDfxD9
N5vjnKEiMxBMxGNrtKkcAgt4cgJN1XS3awAh62h6+RbUgMKIk-rQ5is+CE7DQ4Q6NtSZoewo
g77q4fQEk4oIuddQqeBPSAlpPE-fupKXTXHtdaHdNTIe6sigpyZrCNiFh6bvqO0R-b9ZeD94
8TdQMnxs4rmwWJUauOdb6TonkhXciz98ODbyW3Egd7ABSL9cPMBCXBwTI2g1-+Y++++6+BNe
TluGMYNJEU2++-c1+++A++++HIF7Lo75IYEiIYJHdJClHgAk25pdY86id2XgR4FYOnR+H-oc
jw-4loURb+p9ZNeAf3MKTWD8sYzdm-WdGsOeltq1akGuwGsjpbhr3mjCVI7EUAbYOkHQ+dUm
5tU-9i1+zbZcRo5fRd5E6XKghE16LG-e3kYGGI1IeCoqOxFfAtwZQ5epSaiIvjFzwgcX2OqE
tU8jgnxt8AcRL9wwI33qmfiLNGDBgqGTfJghFdv4wpHBs+qZxtaCT+2PbCNhTE4sSlC4INNs
DIxRrFowUWh-RwGat1-xLFNZSN9XcelANLfO3APoRG2JLPxcwx5Hdek8R-WPEFckpJ-n+H+o
AAFjDKXzkEu6nl3+u4a-e4Pjk7G76Fhge2N+Vx2b5S8OXX79BamdSvEFAmPOrF1JnCOSuAUY
sHg79j5wi3UibZuKDDbLvR3nH8QHBzTm9kHs-Z-9+kE7++++0+0oOrwSJ7zvkLQ1++-b-k++
1++++2p2GJx0Fp729ZFMJ7pJPKzWC-1y5WbzMJGRh30VO5ijIejxI-7coGo3+PTcDepAAc0r
XVrNVeVrqjxyAovG-OsbfEt3-4P4nnknhdxtF6gH2-P-vl4Qlwe-Bm08+UHIEeZ8J4XNlDtQ
GRGSkkKM9HwWXePN-0cmYKBfP5YPFr3oosSIUXkGWgMO8aiyMCvXuAQy9B25A+tytq-AfuJz
IQV7hcvEq-75DzIVguM0cI4KMcRUxCgmAVPUI-2Y0BV6Lsc8d0M+uNAsyfYDMoYF5Dsrn8ow
AdAAQmKgwB7c-pwVBqL7b8IyMFB5+31UJaf7QG2Dxs6W568G4VpMiRhHqep50x85QU3Ub6PS
H9HnEiQsO6lnWwT4APQaVphMXMLZbrT-DpzAoZ5qlq62HR-O3yngTPdTk-GRcv7dGTifTwSd
TXadvIeKZI8i6ZFp3EU4ne5m5lNkbKHXuRT4vjT0VulPctGd5TQ8vYANv+d-+m0kM7+CQZBU
8CwPnFLjnIrmbKn7kEab9pZ8dSynB3GxA+B61FbKlVNYqS-CObPIoiwv60VAs+etQ+VHhkCn
PEk+uybboS7yCFfyzj0IrLNKU3SUvhAYzU0fxLFY0KTsz809LYQkOTZobz3gERkszXqgNiqC
D49MvKnm0GNw0ayGiQnxkK9GSKOb4+p8ScambaGflvR+pf8UaWwl+6PG1tLjQE5QfCirZUq6
vTKPd+OLQ+-j+znDpQBksN7Iu8BkmODEVQ6-j+zDQd4agzaTzPDK9h+RZCSar7nMIFThDpEC
Czirq3EchNOuA5IsNVSLOR1hI7iSngU+ufakcVm+0ixy-lwGBRxlx0h7Y-TKgv9AR0hH7Tex
8JU3nYKaCjWnmmwpzCSRNwtHwMmn1KhRNyqRLNOKofy2sEDAXSGfprh+rlHxoSVRvvn4VzL5
nyibXCxXjoJOTZzs+BUzoPtrEPfTmAdjTPUDagxe5Ofr-ZvAkLPGrIei-ybDBPiF3BPhR0xJ
YH1OYuZtASn3YGR+PSmnp1g6Yu830tTxubL0L0KkqWA2dMwXoiP8u81C1fHlQ7FCPfWYnO3V
o4ay+siJYfbkK11Zr-nFlV5j6KRfNwn7r+fw87J3LimwJ+cc3TCW-CIRp5jIULkdhGnZLxVA
***** END OF BLOCK 1 *****



*XX3402-008093-240597--72--85-05882---------MDI.ZIP--2-OF--2
DeuBG5CbaI+QmRlce5bt-e4kchMURY7eto5+nccLg7VvcLQ82zU5I2g1-+Y++++6+9mgDG8Q
puKkAkM++D+9+++8++++I3x4Hp7B9YF1JQJKOqkIJFEyRqNqRfiIDc16aZdM29PPVtP33fMF
Ev5hhUE94ofHeWFh+kCoZ4qnLIYPah9MZilOEjW-wcWO7YEGYoN62AADVJ3fS+EBoNUUDsl0
W3G62Y8VBUrfRqNaZl9+s-yxiqSySvzniDSSiMwd9ujp2QcJOeGNmYh81LtjsjS5AgDagZLO
ca7I6b7-39cbiKP6oX9e3DHIdMSikjREoaCxQ6XqVzkfXRODXsZt-H9qlAU1Mf5Zcnz4BpgA
7paP4anMp-PSFbEeCaNOqxGOfcu6-eccnE20Ttg1J4qYiPK1e5EmKsmNN3pnO3pLikOmgr2l
-dwUUy4q1G1zj3QdgYqmKijcOBfAZew4pqBkHBf9KdguCdUPixEi8Yr1mb-HytNaxfvqws-M
Pt7ZPO36i6ovDn7m00ZWoVP+eA3w4lUK+qOwwiOapfPBs5uzf6h1dah3NuEg2aPLUG4WMGMZ
RFrvyeu7atF08GwcFc7ZuGMFdJEfFZfAZcBYSpGkBYQeYIOn1chiQ2HLsqPmzAMnnIdZZwHD
pR67c8mir6Ptye9REdNKGniaLF+ZYi9YTgj0KZB2mun8E0SzmYHquMuYgm-JWbBiyx61NOrB
KWWmAhEFOEdho-mx09FTycGsOqW1MKqvOQ57RjF1Sw9EvdTudti8ih-4paIuLCWd8xaHKEER
mOcFBW9NNWE136y+Qz9z9oiJ9gf1wY5th2kYquqpgx-7b3YSRdwg8nJOuuMJeY5lc44cJ5SJ
ZsbvQOOeFBlsWqjPlCF1F3aPa2UGehaRQcDvIKioo2MhDAy7JoX4Sy0MJXSfYxoElJ3AFvTl
R3bXnn0StuVSg1s9PQODFOyNFJd2QvUnmxd3mKqao7HhtO6dqqcKHRZCWqX8BZ9ckTPlodFh
Uq+DhciP2hg2xgbhwFlBqFPfm1c-389n9HjbC6ABUHJfepwAfeWlodBUmUDJr3lat1kPhLaI
GKYdgcCQTbzj034uF2KYQ8e8cJp0Bb9CTTONl6FtQEUg4WSJGBCEo3GgyLEgpkn2mwGGakrA
dXstYsPZiLFORaAFi43LH1TYJ+dBhp56YIcTd9W-lPFJxRAPhV92J+pdE7lVOGsR9wWbebTw
23Crn7p9hxm3R9PKHrjvH4tTJWMYanvDSduCGUiccR-15o94gkcUVS+9uHj6JIUWTfMjVkvs
j7-Qp5C-SQ+wCfwcbssgnuTlVTaKfNpyklnvZyHEwGJS8Wsed6DpGs3yG6aVNxYuPFcJdCR+
j7-QG-sY5zaN1S2wn2QSD2+DQd41bCIU5puU3rkiufacto95a+T7Fms9sJiAj0t39dSWvISx
V7lMFv6IdTZMEYSm3hCX7TcjPerzdZVbh1ai8SSa625RM8rnpRHP9Si2gtyGhpdhvBf7B1f2
PBzBh72SNunbviv+i4TExgcgWgWXOkEsnq033+jQ5yZFDGBTR+gwxd-ONnU3EJfJpkzSymgK
iCDHLkvQqGuD8W6Ka9kVlkCHHyJrazpikyx9WUIaq4wWjjqlLFsQD1hsSH+ksTgy4SZ7BdDz
NDDoNCnAbewSfENPe6KqL8+Khx52W1+-d8kwXcuF+pF3T8HbfiRAVIAEbYuW4oIQDrtWZw0X
blxdUYrWlNvsKl72VGV4D8NX3EtDfBNtvfm1LtFDhlH6r4aWYlV0LM9ll+NuVGTqvhhan7P7
8MdyJil88+04IOwkH1WqJHGxIF1h-duJWHe-3s5Rk2j+Li-paMxlHPw3L++Q-zM1AlEy81LR
-Gk0Sc3vUMgILamOLefkiOXdJQ-GM1qkYTg1jUNgJzXIpTFTU+ScLjSeF-5U3a+IC+EA+cw-
us4ZRe7xk00k58U1Bk6j+PQ+Pk3PUTkpogvy2Z2-umKyO7PfZpGy9dPf4P0f+UM3rkL9XTZv
WLGjnPWqR9SBvlXAXsVG8Jceu5q2N1lA0YIBzWCXzGZ7lDUpTIMvx2Pkru0RMdsSCeTMUHUz
4L36DmO6v9F85t6t9zIuLs4JO7yInLZ5oRtdhMz0bXyYHZbqDpXh8tPybgKbWZLu+S+wM-L4
LE1YPtOZMe2SJMU0k05USw9gLwLsy4fCc4UjsolyDrOSBykkG-zkt2lyfsbmBp-9+kE7++++
0+0bObwS4oW7I060++1G+k++0U+++3-TFYxGHGt2FYpRIfhiqn+IdSpMWdoIQBRC5XgIET67
XECX-d94e+JYfGfHhZ-N74EaN0MNLQWB5x8lDq-oujxo61SK1nx9wL2j1wZnvfomLN+A5vww
r61friwK+AZsS-oZEpEhPxdyDfi5Ax9u+pc7kgqgzNFDmO9pel3xUjZwEJcT4j2UlGF5NTHi
sKvI5uQJ92aTtaHFztNaryQJSWubrG2emRI+3OW89vDW8GybW0OEYEgDV9SOTnjSytkiMFFB
LZQ29gD30LYhs+LcC25SXXinZKJnzdhlna0l4gBeJ4O9thTnlr7EkNH+iCjUM5QRptOZ-u7Y
h2nbAD7n09+NsUDPy5visrjPO5wgwbYNbuT3cAVhP7TXD0DD3PmuGobOzR2262tiQv7AwMip
PlzQvBe95Szhu4x5+tk3M6jjKaxjfLo5urJMr9RqvVdgBVivMrk5lcH3TQOt-gl0aoSnYqPk
WMgAXItU8j+lf+LboF4gV8Ps+0hOOuuWDQmstfL4yxiQ8ubNvUL1BBCQpF9j5aTGPZ+NB-Wa
C9Qv6aV+iZNQ0AgMB-X3e-0prv2OYC58O0Y2hMjJMCn1EX3Fpo412Idf8XGntmFX47aOuJd8
sHJMFgDgMKrdb+Pgy8GGZfjaH5Z-7b-99FECSdbb3b6PY-5IlOwNrWKH8QSxntWFL+b-w04R
n-6SNRl6ufYD0RKQ5VT205tGA4HsOI5zeySVrj42J7-YWks+s-xEGkA20E++++U+madz5frH
g73d+U++mEI+++c+++-ELoNDIYoiI23HbJHBPi6k29sXwEtnq2B+IJGifLcc0J0oHMY0qqVD
ZNiss8qlYKqUeCevvxWCyoDFehccYgTnwworsv4rUVYcvVyZKZxoCxoC2sOeFp7HixZeefgR
UDZ-zn8AulUe7VO51TJGcKGBIYup7YifGnbFqUcHFHMfJZiJ32N719IsMwm0ickF9dQcX7tB
OVHL9fB-LCiog3s1i6HOcYJiqvA4UCYOwknCMS420uzQ6+jOP-Jpw8aWlB-cHYJ13LfC5jvE
qjGQvoOl5Fdxq+gITUgBlIm840O3VZRj5OSQIK4aEVgWOVerqY9FbPTMqU5lloFNwEgLvpK7
lZeXiugmh+ZXKeYZhLrUf5vXt5Mb842xfYgvcY6b-yRhfzn-fHSQfX4bWv8OZlwZx7Bgb9zO
rHgp5tFwYq4PA1xY8ROvmZ95idHqO33FGKK7DR+Z2xOkNqMJU80FjeuOO+etLc7wx+e+8fwT
ZJTnoT1bt1Mv1pe+Bu1kyQGLg8XmYI8QsRB2B32Ua9FwkcRnXBmgzlaSTLg8ptEhJkOmuJov
EIb-OcChG67ZxV51cuH58BIoKpmT+eZMUnITMk+AaFZm2xY0P9Dudw7WNBgzGGcyVUAs1T0T
oQViHHN7GgGCuCGOW6PH4AvQDmzHR3PwvbpePIbpZVjPZA25jNx97r3BUzvRBmKQJokoQiz4
vCU4lS42qjEs6n5g0u96CUPipZu+Rsb0BM0H6zrj-y-hh6sihuKNYmTeDMAqybEzD6gjxzwG
0iZSn4V0XGznFcdZx9aeGLJnLxpaFHZ9SltczXrj48lx8YloFBb-V3vUabEvTk3EGk203++7
++++0+0wf1oWadgx5Ng0++1k-E++0U+++++++++++0++++++++++Epx4Hp7B9YF1JJ-9+E6I
++Y++++6+6heTlsN-81wmE+++Co++++8++++++++++++6++++AA0++-1LoNDIYoiF2NBI2g-
+VE+0E++++U+v4Zz5hE7Rwj2++++C+2+++c++++++++++++U++++h+A++2BTFYxGHGtEEJBE
Gk203++7++++0+0tNbwSS7gFsN2+++1k++++1++++++++++++0++++0U-+++HIF7Lo75IYEi
F3-GI2g-+VE+0E++++U+mekx6gQucDdd-U++9VE+++k++++++++++++U++++KkI++2p2GJx0
Fp729YFHGp-9+E6I++Y++++6+BNeTlut0CUriU+++-Q-+++A++++++++++++6++++Cs9++-B
F2ZTEYRGF0tDI3FEGk203++7++++0+1KObwSYa74JI6-+++O+k++1++++++++++++0++++1G
1+++HIF7Lo75IYEiIYJHI2g-+VE+0E++++U+h4hz5ZGTyw3r+k++NkQ+++k++++++++++++U
++++DUs++2p2GJx0Fp729ZFMJ3-9+E6I++Y++++6+9mgDG8QpuKkAkM++D+9+++8++++++++
++++6++++BwF++-ELoNDIYoiF2BJI2g-+VE+0E++++U+dqdz5Vh6WJ+W+U++oUA+++c+++++
+++++++U++++CVU++3-TFYxGHGt2FYpEGk203++7++++0+18ObwSjRCkYKY0++17-E++0U++
+++++++++0++++024U++I3x4Hp7B9Z--Ip-9-EM+++++0k+9+560+++J5E++++++
***** END OF BLOCK 2 *****


