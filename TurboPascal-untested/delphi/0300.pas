
These units demonstrate the implementation of a TextSort engine,
which uses a three-way merge for Memory and a five-way merge for files.
I've wrote this because I've wasted so mucht time waiting for sorting.
It's very fast, one Million lines with an average length of 40 in 210 seconds.
It isn't true that QuickSort is the fastest Algorithm available.
This is only true for pure Integer or Word arrays.
With text or records MergeSort can compete and is in many cases faster.
In all cases of interrest it may be slightly slower in the worst case but
it can overcome Quicksort several times, especialy with large keys or
a time intensive comparision like AnsiCompareText.

This implementation is very fast but not the fastest possible.
There are some ways to improve it.

You can compile it with Delphi 2+3 and the BCB, with little changes with
Delphi 1 too.
It will be fast with Delphi 1 too, because it can run in little memory.

TTextSort has no compare function:
You must provide one like this!

function Compare(Item1, Item2: Pointer): Integer;
begin
   Result:= CompareText(PMergeData(Item1)^.Data, PMergeData(Item2)^.Data);
end;

Put it with the constructor.
TextSort:= TTextSort.Create(Compare);

With MaxLines you can determine the maximum number of lines for the in-memory
merge. More than 200000 are seldom useful.
With MaxMem you can determine the maximum number of Bytes for the in-memory
merge. More than 1/3 of main momory is seldom useful.

E-Mail me at Martin.Waldenburg@t-online.de

{ the following contains additional files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members.

{ ------------------            CUT              ----------------------}


*XX3402-011551-160797--72--85-38244----MWTXTSOR.ZIP--1-OF--3
I2g1--E++++6+4O5vm7P5Efo7E2++CE-+++D++++F4JhPp-mPqdZMrEiN4xaHN-THw6k3ALT
Zymvg1+FMzM+P+U8AVa6GbUccw8JoHNh3x-DPoyboNRTvvZzqhCv5gWHccffHFXoYZMMx62-
Y+6NA+HiYWUAFg+MwVts+0P+35V2REPYY2z+50W+-P+2bc2Jw69aJoFjW6e1D6x6KCC5b3Ul
9IXgjJs8gfq8aC2aKN3MT8caqAaniLJbfaLtZoWrp5HookmWeTu6HCga1cAkK2x65Do0dYkB
rGvkq8mqefOnvMRzSW03YFLj8EKL8RzKyv3sZzvX7+f9maB-Lnm7CipiX5gizr8hi5hprL3f
Cv2xvnjvGFnRlCqKOwkiDCKap8EgGN3sBmZdLZedWNjBfkyLQwK0ApoSQaMDWPSo6omlmXG1
CRDgl0rLa7jLkajIjU3EGkA23+++++U+ysjj6e3DCv9T2U++Fuk+++s+++-hRpFZS5FHPr7o
9b-VQyoROowPGT7vdDm5picYn43wY4ErWJaWMobMEki20yl4dsWHqdsqn4Iwstg5sCLsvpTJ
vrbNsv2l7dbNJFVrJpRLpviuFyevXQq3DFjDbt5zYRxxBysGEcMrtykqDUj0a1TjVsn4nA2S
EfNzv4mxvflxnLjqYjUe02I5CONVvDfYAzIQtjSGw36A1YPXo9qwWjbUhqxThkbpDA8P6V8m
W6LLnCZkqDQgucTi85M1jojqG+l2Y+WcM02N-04VDYZwnloCLO04o44Ey127-U6iWJlTn7Vu
86ajEgMqPyWM13ZsmHWa6Fg4sFUE+VcmQ8zhTUskQ1oK0O9yM4520S69u4nllfCMlYYYtnW+
0HvHYD4SkrUh6eAki5MR716WPhEaBmvk8MZVgVgOVhGDloUrxQTYeyj9lTwfG4+FX9U+3dBl
Y6EYiD4-IJ3T+5nMD8Oi-pFWjq-qln1vvz3a+AnlKQR-EVOd4zTDbnpzZc-iK6elUqprTzao
mHjlDxQ5CEpcbr5cW2LYP-nx5fgSfDwnf18sUNRxXoPElIT5sl3GGguDYSzvkL+2D0GvN71s
TJE-oXeAqL0vHT1DWmst1TUIuppm05wjKPW1coztu1rUuVX4zjjQzBklm3IrAbzwNOjHqPd+
+IWA3dvrB8M41TumgAXCYDK1oA3axT0C9WV301esMzIkrxYFr9YXtqR7vuIUl42123E2egZ6
1vHMcO29Dp2Z02+763FCVk3tEkvf1V+jXh+EPUGw+Zg0TTK1iAA7VLtC8we6v5aLEEWeBoFE
FWAL1+ZgqO2xXr4R-5nEooSVRCshWFVGRoJjuzlXvnyg5uxXxmVofw2VW5IS5BDP9XY8z2iE
mcvc1a6+NNl3cuHbiLo7SgE4gM2Zt6tgUWnRq8KSymRMGlmEfEutZx0To2JI-kRCRAYjES+l
uYgNx+AzWgCY5kC5V-Bf+PJzI0xV4iyuV5KM-bqDfw3sVkHL9+n-XWI698nDb+GI38ZcsKcy
y2uPQ29V9MTH11U-gy4Be-4s2cj3xwMMi7sQmrPCS92wrHNR52UJVqq1O3l5jL6OyMyiBTSC
Yi390LTCVWDtSbN1Fr9+OQOcMAEyChyo7M9br8QXqbTXQHTRPjVkla63ondVBpbsDCAyr6sc
Bu8ALV5X7btZQSjERxWh7aSxan7h4xxdYULSsTv3i7TQ29vs3VWIR35RhAQG+qkxfu-8ajUx
lqaZtwwmpF0m1ucRNV2QoGUiLuvq-RDctsB496H6Z-MhRlVGriE4j+aHDv91Q-LFZnFj9nFZ
+Uq6Gi6+CSmU5uG7ZwAYhH4ZRt8AstHS4d6nSWGUhHf8CGrZAn89fcF08JShTG0OkU4Y+RBh
Pc-U7rH6AW4+8VH+QP-zT7AxyDA6r5dak6+vARi5HTCZ7aeJifkuzYqvetnHmmspdnrq2eEM
g8Y0kzZGeb5w+A2yyekhrgtj+jK4mNtwDs+IGfp0WhQp6ZLgzdX2VS6N5Dd5PVGrCMFsku5s
VhuH9llzO92ddZXG97JQEJ+GouJEpkd9G6TkJfO-ZxhvnYZI4mM3bJuoYfJgfKFU6dKgZaCU
iIHdF2Bo58DnH1QDU5+Jux6SEyhMpx8rb-UnJebIdZHylFmPf+POQ0gNQKimI4PG2eVRkffK
bFC2wgimLII6zJiuSD9H3Xk3q4nd4JnEOa50LkfDeuohXOZEjRnVm4B1tYC--i2FKqliahGb
AnYVv939ptR8VeuKR5S7cZwYIuYKHADVxk5p6gJkd-nPp+EvWYdAzwHY6jInAf0catdV6VOV
Hm73n-6AAwjV8OeVKG4HvSt+fj0R6-Z813xsQPYSkj+TqL6SNZO0V2tMVssY3bqirqzl8RQB
0GpB+mRj5MiOZYrLSduk3-osYO11AUO924ILCJeiKAXr2qk+VJGq0PlKObuTbiIsBsSSkSFg
FHAddRLNb2MpCGzIu1yl08o0CK8GAa0bPARaZEBlxZbdhAeZjUXM0oG0Az9CElEFlvViYKZ7
KB4d2KeGv-HTn9t-ramzTH23KMLeE2yXIEDN3imCs+fpj8+DTeBZGVh1mpz74RGD5kQhlRfp
v0Wf17cmPA7eZCUhYbZafRl4wLlPCK9A2aGTjTGhWJcodHEeIWCZ3LnMlIHgqR8X+-oG64i5
HP6xVK4JOXD1nHGZZjee8SvCQLQ1zdSPUAFgwcJ-2iBS4G1urFx+2d9ss6wxPWLY-l4QsOw2
6ntX1e-l5-QtE1qtUEWXxrlfZmIC0+EqE1TYoq-KtDc2ByJcG47rmDF461WfY77cl9T9Y2G5
Prrqk1isTVSOTiaETmEI2C+qo525mXnzAcc1jkpIbMMI7B25AUvxnN25C1X-CBoDPFU9mQ2k
wE2+WSLPGfWejTpXwb8vhTrqnNjpBbbtugramlxTwCqH+Z3Ie5ajOMVWEBIx1G9G7KvSDSbC
LKhXcgBTiGOHamjAxpidLcmZurnR9PC3YKYqqlaekkb+MFxHsDRF26nYdd1Zu9ZPB+jGJjIZ
GxV3quWKBHrjKWQzUwZlJuekNWOdCt4xcD8d0eT1FniE9tfb3mZnnj4TLClYYJUUJU4c5f+e
ik4HUgIEZZpu2KIKH13dJch3O7f6mc98G5qtQYdDLgEA1T52dNHeluFEnerGEiL5GEozsEGD
uE5aBgRmIumirTDeKeaSnGEu9PYNDDYAcdjPJ7T8hgJ7PcctHX13Sh6fgvgtlHRzG5mmhfQQ
0Ec-NgK5mF9TVUV4MwnKyH5uUFj0GydQ0e3GOti9iGYuGxWQJPqAqmUYz6np+x14iGYjBSgA
sII4baJspWsssFaucHk73o1q-2L823ugIc7oLHGR-DtamDd749bLQawMjw5+IiYD3cv7UC7y
C-UowsDYwYdzGr3BLEwDZV2EXu5xNBVX6OunnwrSXLUpYYFMsoE2Om8chs6Fp2LIOlDOkvfc
tRxSsMVz7avzutaQxH03UI1-AwOGvVe7UOYNQMQX+8KsUFU+vyAfuYC-pMQzZrkb24gW3nWS
l96uWwk2K81VRlVx4b58Kp-dMSrrZQ2Yo1SGlpQIiFOpyQQVv7PW7eDsvcETckzM1Mai2-oK
Sp45s-vqEFUAyPQigY02OHbklxM7wGv7mHcEhGMy+UVwM2II6zjOk31ewx6Fg62s6o13zdh+
hORcsWB0Fn1LxIR7r04wp-q02jJgTU-k321NWOi97hNuoww6NPp5quHL7joqCKZ1jSg2xhuv
eQqpPSCKMKvDJSo6PAjx14JEZM0hYyk8s0Q+hArTEXM0+4INb5GnUNjhVbJ09k7NbfM5HNFg
b3VBTKXedNgYtjpoeyLhyBMigZ2H8I4oLy2EmCIgV4L+58MjN7+-mlPjdUwssrdWm1jk6Lrf
57RM-zv4jSmEinoDxBybAOcYTdwYhlC2ELHipKUp+cKWT7N4fJiUJoyXSp347ljYl5-Ao5aG
6x6C9W2nCyrOQJiBhZgInQf3dEs2Y1EwxiXcop8hlKP5pXt75SGqc55zgHJ+ohE4psEhTXpT
uM49bXwzYnaWqhLbPvk1r95i6nyz6qhfJdeI0WVvISFSyUXPoiTHPHDMu+d28FMP4BA-QzZ-
H1s2+uhrKZPqWJ55wyodpFasfPakEaHXjnjwM4lLkuF-gYQFseaSbCpvEQHG52UHwG22TpbK
OQhUPGpBUDlZ6afN+MbK+Va5XQtBMKteAJKMCcKV-QmIX1FAHApNcDtYWjshGkEd+FV191sN
oV6cC9FtvoMXcAzMxAE3KcgfLNMWfSkE85TMZD3GyelOVPaGHkMayuu-59J9l2i7hocRPSa7
0zVISHJqpe2FsXyJjZOk48nfIFnwoKSNOVFPnqy0cZMw+71hhWfZ5agATY-GU+cz7dZdpxZS
HwhEXgfJhaXamZNpUnaDIuvEkWfc9oJPW9cITMtYApodxh6N8gwWS1pp2bl87w85Tok+fZ7x
whAq4aEtm9GLgFwBLP0jeNvApehinar-eeQClNkVpIbas7Bd9iUdK2bl8aMHPc44DelslMHJ
iGLUjowFNlce5VlIAy9dTeVoUieHB7vWqz2IFaCK6poyrkmwEj1jFPuNpbF9xO9fAL6KbJMx
OAuGbSKVUldABoB6+yX42xZDYvC6tWNbaKX21t4nB7t0DIrCYbeOb0LvD4nC6bylz5QCC4rR
TOKmjOCm9m8OTO2WgQtHU4b62eKNrzHbWxfH6rOVwhcBepGMDoZFJTCPIrpaIlaZbbZG2+rN
KComIhAb8OfZKSoGQcDI+N8MPaJmUyZ7OtAPT-StEPLetFj91GfJ7kNoNL81FJdhYlgw5Oih
iODoXSI4GvDOL4tEDnacx547aCtlQcAuypZB8PcmGSqWD2mH3mnJkuUTRT80VvLMdUlx6VPP
t+F9hRVuCI43MsD3NkJH2jYa9oUzXlRiafmUmEiSH3tEtuGWR+dwZZ0FTvxqKzi1daxEL8iG
6xHzh41i545KnPua2YYz4f9lBIoZoiE6HMuUbmN5g7saFrWgvksSxl-VpWq6Egnsp0oDBJG-
MCdNH5pJben40rLbRQtkNpfhh7+v8RmiCBwLNsVqdftORZXrMw8JBwDdsRK+9Rg63wnopP5-
FHBxUFOsAgTdCEigaJyjjUJCnNUAqB6hQ93ALm29L11HOpZUVTqelnuwOi8UTaNnmLBNMNre
TxYtsCemTe4qi265mIp2pAxgnbb-hfXUa9VOhfU0QT3-jyaMsYYPGplNGpnMXji1VO4bOcPp
XpATyxmoqH5EnnHZTB0Eq8GbWodDNvH33Te4cRYvoAxgnbb-hhWYdkwP3lSObgsMk-d9PB9H
vmwxfN06nay6gmMpXLxi1D6vBQXWPFgfKWvht91C-ce4m10WiffJWMgO6Xxf9KMju7CZKHDz
pK9sNBxLvjS8a1vfniHmhW-LWiSHjJudluidtUjOwtrgy3SQsFBRSuZPfpbQpDEfQywc9BWZ
ngTmVTeJ4Gj8tNKC8wLmVr6fWzn8OQOmSgINzZ-iNP4b-bBLNExUsWieuMjR6dupPbo0X5wU
XJzcBgGgFSj1Oxq8ANoDoQaWihvsAwtCQVQn6qnV9Q4nNbWupu8nY16RPscdAnQjnodOONEc
WV13d-Y56GxLHhCaPpSSaPFmYmsqto9mX-YJIcTRwJIRwgdJjp1hWsbHlZlAb1icGJidSFGO
Ve6Bzk6F0A7Rm6F9+zYPjunMRXMJfWhqqYHTggebDtZkTn2iGxuIO3qkq94jIdEEbLqDoN+r
dOsIlXhh-y8KlQuyjg3q6CoCwSMjbdLxcDmHyp5z7Y8U1Yk4+24I+EUpGR3Crd3huTEh9F0+
z19VbnDkVE40nulivQGNpwU4+QOT-w1WpcbF3PmprDddrJVfp2oXAr+VspedUImD3hOSsvE8
FZ79K29QoFRQpwICdkJT9Sc4lKj4E0MKn0y8bcMDZNw56EthrK7O+Lxz7jnxaT2vAy3rNgPD
Ng8TiSJJlmtlXrN-t-1LNlRuPL3fRd59t1pCYQDWDNOqO1TJmjcQoKwiUQpfca7ClXaEnSpd
***** END OF BLOCK 1 *****



*XX3402-011551-160797--72--85-55555----MWTXTSOR.ZIP--2-OF--3
WJ-OVsiMZwt3wcePHoB2OyseR9FBuTo4ye7MGMKyEJPFYnCmvet4Y1R+smoB-QcdqfRr8oSM
PlBFDxAeUaqqYEQtep2FUKracZcRIIHImJkCTVhXZvdphnnQO5YJLvmf-isGyGOOPMwcBDnU
aBvW-QoFUPOThi1FnQRgW6qjhfNYgpd-uIrXYjUeBsoPEhGfc3-3W2bFI6LlcfbDMVeW5gVk
19sSKfjw5ad2mmRFQtEo6n3hwUjhTnKz1brnfiuoHYLrknPtfQpFb9ZzEVT24LP7VCcVA4Mb
LL98lMXjBXQChHKMOJ1XItmluI4lLZ3Td0UTPaAHMxdYfRCXLxS23Pc16W0+TJ59lW0iy0Pj
aQRWsHhC+KCMVV36f5+ci0Zn9lDGlArhcZCoW30h9VOLDTa6DU-qv6IV5OCYXpzmJngp66OV
lZzMMWeAv6T8-OKIWTglSum0ghRbrKiS-zkYsrrqXb1oT5dCKRfeZIZz0w374NegQhL8N-QM
ayn6Q8qYyUr3JSl86jZvq0rCuOYqXdVz4JypB1HNS8A5b90PZh7IUoOpWDmuKrGXipseQXW9
ETUAwRl7vhlbd4wZqMBAR-i+JzkBjF+Ivc2xF6QlIGVmv6Ql0uJXkcMIjvEBvVcYLruvo8hE
-MNFUTH81ITINSqHJse2GndATAteXZaC1ViZz98kK6M43dvKQdAzezVigI4LBRnSR6oXUoo8
YG8le-980iYHww3AC4qqbontYXmckKm454HV9G09ErcnlJdPDG9GDXwnjMUn8hfMhxHfQ1DD
7TLEq5byv4tn+EzUUwE06VwYitydtn0zZsGLGAoFy-H8yZxN01DH0B9P3uylzTLqHuxSY8D2
iL2j6kLw8ki5p-zXulZ2+oP4YCR+-i4kywIFybxEGkA23+++++U+H6Tj6gAWxSnM+U++9kQ+
++k+++-2NKpjJKtdR0tkMLChJ2hj4X2EjWDl5yNEeR1+0fWY6I7e0u48JBccY2OxJ18v+vXN
hJTq9+GZySzpqAgXGEgxN0zfaSznjAQD7wpLyoue3TUBBodG3k+4a4YySqLTc0-AK+zEvYGh
oyXgp0AT0pdc2k+M0IBGkOp62pHHkgn1NNqjXNkjm3wyCnhhU2VHw0c9-WqO7GOFtkvElYPa
79LeyV-UdUrE+a40xnHKVU1JL0cAxCxcf8Ruop598wQYe9+V6VUOl3hVo0CLxBN0PjFG7dW+
g0-h+pPGNJ+E03U7MsGWBSUN09K4Cub8g5vc+Ue96-qBM8o9+reZL+cq1cG9tYX6317YD7EV
qdLV+nKpGXbeV+BtnNsxJWi3ux8qLSTJGfIW3O4NWFVNQ53PtlFiLHNutF6ScPJWXisoLhgP
YeYvxJBV9Ogy4t2jNAkefQVc-cTONCsrY09JQxhUMqB8yaEMn3OPnj-t80lBN6My13fbb0tA
q2+PSV0nZtcLukk+T0e6h4drMF7Cto5x9IQJr14oYofsWtVWmcUzbCyPuXkrlR2kxIZg19Ut
W12d1DfwkcHLleUGBClnyUhXejyJusPIJKNxb3lapoxZTDSzvAs-RavYoYJN7ZOKrL2qlo+e
dgt0s1n+ZNSO+vl9VF4wJuXUYJ5bk5Rd8Em9jYTRgZRVWf6wlEkJyKigSLVn1SyWkL1omB8g
I12XPZ8mr8pMvN6kOnS+TusBJxeDMPo9ZyszFyCAHh5hfUzh4aqFIfSriQkdp8t4OCMs20G0
fTfDW6I4D+Au7Q-JqOGleqB66HfQpKoYqn9qRbKAmbhZP2TR5-W63rsWTd2C4HkqB3i9QfOz
7x53DQM36HyKHlpSiaSVhgwQmVGzWUn1I4pt6r5zlPpFpZKWoy9j-Hn0n65jKrgcPpTYLhlm
y9PgDJJ7oPYLkyt4TF2SyJu7LuEWhtWIyraYCDzSYKplyeaqytPEDyJz+3-9+kEI++++0+-8
UywWEoHD03E-+++z+U++1++++2FZPKxJPaZo9aFaPMJGkIs0AF+hiv63ZYowsg429p1Ut3Zk
Ul3QsXPVOc2-4fghuMs-njuEby5Fbz4gPfh0cUQjorbharbn7jpg2-Mb1yAiuNlSScGkGRk7
K8lBperOS1807Tdjl4Rusq3p8VOsxgwfkF12Ocry0u3xjY4VJF+lq44e1PM5YCZ4f-JSx9LI
VXPbQWfIEaw9FaUTL9brIPTcbaQEFCCobL8JhpAkMibeIxl902YhILo1562qWe3QLYzI+56o
SYz1sfM2oIHgECMHA9RejjMS4sJc8FSFU6rs14FUcnDb1OqrIyTBwsA1aJ-qzMmc3LJ5mKxN
zZL7jzjVbloqIIqF4uklDYjA+cl5uDTwIgmTO9BgNB4TzXqrv3Tmfo-TuVmC+dLT+fpG64H7
-hF+Q8ZLsH5hFf4EQ9AEO-RAUqJS+4SjNhJfFL4qXLaCH4FE9I9t4RvRT0p0m-REGkA23+++
++U+DNvf6iOg+ZyA++++lE++++w+++-2NKpjI57jOaJXR0tYQ56f8AdD9ofAJL-7nQoD8AfD
GYoigSPZsiIe9IshtiJGI5199wchpU4lE0d0wn79319n3BFV59q0l47pVKeE8gBOgANeZG+3
9PoUpy-O20wdBHon1uHPgO+U7nAtgGEnDozD2uUlAn2bgmfJ4Zr8iGUpgGEJN7l40BVE5P+9
11IlJ+OJtU53IjBGx5Wt+3-9+kEI++++0+1AWywW5Lvsn-E1++++-U++0U+++37ZMKFhNGto
S5GBJAhi4nYEj+wkzx+tqINYfFwtCJVUMqQD+JO+YnJUt-8+aaZd0DAVY2r9wvLv8ubaX9FC
QcZUE3OHf8ueTXkAb7Z8g78dNlx1ZaG2GEMaurSCDEQlMaCUi0311zkWzwMYl43f+mzONXzM
Pe0GCSBMVgFwjXQXSItPdYpAh+7g4ga25VQqxjbbwsppb7RhwybYaKaTMgpiAuqtAs0Z8Kum
Q2wtYWzR60HKOx081Ri8YY28zmiCb4FuNeHQsB40Ma-OKSRIUkDbH5gf+zWEkGo13UtW265+
RlRY+ppRLZ1a9cOywV8mCNkUNmd8nEVx9fNveXO+dpeZaHU9TL1Pa61iUKqgAqj5E5VECTW9
kMoHWX9SZEFlELX9WT1vAGMsZ76NBSiXQVGsfIQ7N38TMGJAerYvoCyWrn5QIaQpEG-jkcUX
fIJZZ7EyR1crFm5F6aB8GhM85cnkaP8nqo3+9fis-lh+eOdxH3beGpcLOFgvtMqk1PZtgY4B
VphedOhZmEjWjCDC4U-KetrFKXzl0+8dPQlIDGIGAjeV0X57teZ0HokT29yfERO4Use1WHyq
d5pJO8J66QcDxRX3bCqV0+mzUMVKePo1BV6JAI2En8VNjgNmx-NxeFtJ0FzNvEN9JqyjexqO
szPiRX5fgm8sqkoaPCTqOdjtlGKGl8a9xaV0RPimTMpOvmmC1HzPb2fEEgnUjYvFtAFl0+SH
6Lbq1w+ZRCf9nOH1ZzzU+BHNbigIJ4xphhscnC2qnIuTTV9qZkjGfugPicypIwti1XrujarK
X83j4m9ukfYsiTaHLdLdx9vqtoQXNg6uyvPI5kjuuS-eDXU176TyjP8t9r6oKxrhuWcebIFh
scBW71meLxsZlecubFaQJNUuBWjnwYwRx54iNcwlGFuV0irBWzL3ImVyfOCraRS01aLRSy3w
QfhhudNOoWeaCjZM1FTuaRe6LFyxPftBQIjuDnQKraxbjVrZBnBTzb4h1vnFCMxpdO9xTm5F
BbyTfv-uo102HPImiVOLXwPp5BMZPTyGQukV23fqX2dy-p-9+kE8+++++++YWiwWMDTsHJg6
++-P0+++0k+++37iN3FZS5EiSaZkI2g1--E++++6+Aq0809kYzMXx++++3U-+++8++++IaJV
N4pZ9bFsR0KEEKj1A+m3vs5w-yLIGmWgXDIwq-W1vfGBgOBPmsZLlmeGr1HzTb61gULmxrVu
zVeXU7K1+HCmIq66RhVZHlCYa34++WXSRBgqrs8Vd1iV8-fn+27wvwxd66suWK5jiV4sA3qX
FkyiCjG+hkiXG3dUXXdGIHCR5NiH9hL0tELCALjHzp8-6UXF46K30UDB4HX8mJtT84wIXgZB
03NslEklJ-WRmcdX5anp5WOvOvtUrOGjyMyKrZ1P9n1KoSTc43TFWHlqLRQqPTDVOWfsQQZX
DVMSqiNULy9kR2MKtGrgxaqnTrVurA4Vy1YCgZ7jm7AZyEREGkA23+++++U+usbj6VTbGhnB
+E++K+A+++g+++-GPaFJPaZo9aFaPMKGkKvIA-04jIYquKsOIEsQs27s+NFQ2CQi1Jilqpop
Zbd0khYsXJL5fVmrd-SSdro7nXk0Xw+9Q6PMXXQU8d41tQbATDzAS5vB+QkqtygI72R93k0s
nF6TNZkouJGTrUdLojo4LAWj5Hax68KgrSL2Lq7mKIjr8kUKu3cGnjmLvn51+YbQldGkziFJ
5+j2Ghv22bRmbb2aLmwstG6srB29obgykxsFOcQ-CXxbqXd11TOXRFvbW9JlXUKdH5sivmUC
EPEZ5OPh3chHheiRHrA34V+FwC283NW4h8-bBoq-lOPGTHWjR-hTH-jCqfQNymOSa5VJyocp
+GlfpfBKaDLFNW6Ds0zIqrxFcE928YTK++Hky2N8nUs8mL87VA2sgOOw40UT9CLtbX9JkEQE
3FhFMi4+MAAKZCmiUgWGh1Ye-DrzYssARLs5zpDkJD+cABY95+uUUHy37mKFFvWIReOb2XTh
bsDxC8VoJiLNm5IwxIGyZmN7Ma3F1pBHSaGk3bLr0Acp80Rx+w+A9aewinfarQlSVdqxBu1Z
+26Kx5HTSLFihdDeBlft5U+VnB2hTYQEtNTVS2qXX30gGhRv4DVJekkX42mIcDg1xBxjI2g1
--E++++6+-00806dO4rjW++++9w++++9++++IatYJ4JsR0tYQ56f8AdD9ofAJEX8GkZ7fGWl
tiLWtGchHWratJ7EQAgjmWrK+P4+ge3taGI8aLY8uZ0qLY3WgPd0BIWBMGpMKvJ8Y68KLd-f
Q0q6ZtGObdY5oihMI70HaNlMYdaTdyQ7p7WNa7BNZKeB9iJQZ7dMYUcmHWA2P8UCq5t1HEmJ
EOJtE95Ij-ExLWs+I2g1--E++++6+D4Gv07Ow1q9RUA++BU6+++9++++IatYJKtdR0tkMLCh
JKpj6XQEzcv2TlWdZM+qKEKddmPYIWY5mMYc9uT+BKdDxw4vCs+PfspgPw6qijzS4SwPhB3l
fScDf1ojnskxnkkjVzz1yh9hjA0xHiSswT+f18AVz8QJQ-ugx-spl+LQ0CiZVUSVIhFlPdQk
D1btCTcqb+x877W0By-L0-zmKAY27WMHIix583T+iHISD1eD5duZLw22pLcZVxy8kGjUH5rD
kReO7tZGKg8-R+Q-oSES-1k9OsLq-NU303r+cxHdrqA2bBxA1fZ1YCHZcH0t-TCgkIeLz8hv
AIsaWc+ZR+edRBv8CDQ-Sa2FJP25Y55qgqDz6dli7xQIZYXoYPub971OcppE2MDKcShq+-vc
KQknjRkBCWSKG9hNsHtueKUrJg6t3fqrUaeIgAVcPkof9srBu1CFEdaZCq0kaIz5rWcLkjZW
XGmQgy2EnW-Vh5ss1ZU-25gxwwH72QnTtRsPTRf69nPm5q7AzKqSlKXj3ZCDaGDxFFcilxeN
SA6maG2dqZDfT0opLeBSfjmidsdJXIi8Ol4XOXKBkvNwjA9YwNrNQ8FuLua6YREaiQLaRaBe
ZATy15K8ZinjsXwkwMDLnDbGLv3SKzYYD7OCWpkbLVfB7NsFoTFmJ5t8ox0SdSJ9pOm52rlI
kUfqcbbkVPII7VHfGJUyVZ8Bed8JdAbK0XDIDfWltCLvSzUVaZnS-7MpONEyoGjNJBVL-o-j
CE8asF7hG3CAJs7imPzVn7hnuhhW-BmylOSX8DfduCHBNyvWmWf4dRFgn4Vbl1YvBpDhyng3
XbVoZewa3qqtcf1X8PP0UB4+pL+oAp8HxSZEJsXwuEFjsHVsJLP5dyrnIH4AVGgUwF5DFnMz
***** END OF BLOCK 2 *****



*XX3402-011551-160797--72--85-18384----MWTXTSOR.ZIP--3-OF--3
527e8XOrAE+gfZ5syVHinrvXZSpLcRwQ1y-5i9BdjrTS4xFN+CGOaV9udQjPAyXxrVg+lOoY
jt-2x3fntWYzLLqa+87tsnPfPGD8aQqyCucoxyVmtIBaZEYdOfNoCmphevfj7Lj3+dfvOxUZ
kRlQGcJYH0LXLF1SWAq30XoyPImPVtkihfgxihVUkaDqZO8SCmSLaZ5vNNW15IyKr6cA-wqh
yRymhVrgp9X7O7RnClBdWrPrcNfmHqk6IZvx16PAYFehMgYCFo6CGXQNBnpJdJZbB3P4sRPR
-ZgZSep+LlojHEM7cqsVoHTeRjs0I2g-+X693+++++U+nM6c6j0HxWDo++++K+2+++c+++++
+++++E+U+9O-+++++37ZMKFhNGtoS5FEGk20AUgI++++0+1fWSwW3yR8rAo-++-M+k++0k++
+++++++-+0++hc2Q+E++IatYJKtdR0tYNapEGk20AUgI++++0++EUWUW8KVhvsU+++0z++++
0k+++++++++-+0++hc2G+k++IatYJ4JsR0tYQ57EGk20AUgI++++0+1lYikWKj+xWrM1++1M
0+++0k+++++++++-+0++hc51+k++IatYJKtdR0tkMLBEGkI4++++++E+-+1X++++MUQ+++++
I2g1-+c++++++2hRW03V9lqmg+I++9+3+++C++++PLR4MLBoJ4ZhNGtuOL-EGkA23+++++U+
9d3M6OZKPkVB+E++l+I+++s+++-hRoNVQrFIOKpZ9aFXQgKHDIs1AF03LlMYe2WCEAY-C+-6
20Y3B2HW0VlXGrRQOMym-EIJqX8RaHxv7htB+F7WRWrjtra7lnwD+8udtOmhXQyitAycfKFg
gvYs9zYPyzoRhFJoiCxk6bdtoTTOwIATkn-EnmBNLWt2CbuYfcmjLwFcgnNM-f1CWS6xsofH
qLV0sEBlBaNxtfHdHJ1H6a0qh+W67uwROy8ONg2VHL3di2kVHE9WU1Bix0BGucC+oWY6C-o3
YbO-dZr+utLkzR5kzMbQuaTvrNv5Xk9z54xodqz-Rv515YxslFPrS85jDLP2XuNPwUOrsUrw
UHQSabUyrfeD7FthJiC0DA+QjI3wt+rXuUrHJqzczvYrN9vU1NizSYDfQqwcinSgzbfLXOgL
Hb0XRqzMTBIPJYyxyZejSoDLsxscumprrTOXSa4-KzpgjxjnW15Xxfmz+J-9+kEI++++0+1c
M3gVZgdJabo1++0-0k++1U+++4prFa3nR3FdPKIiQ43nfJPPPVAl25qDZ5wM5Z-G8MGY60uB
S6-0c38-EU6JEXksitCBpJpv4RhRJZLtRgNCghaa1EYhcpnqAbDaRXnqlMDz67TBlUKAgq6c
X-r91C2fx9gxi6o2e3CGpe80GEbj-Jads3GYAOe7ckHuntwzuSu4QuXnYaEmgrx1Sdaa27EA
2-eYQsmvOnXXaHH+bm2VbUf0vSujGQ+tgWo1CSZn4KAAkaBqc7-qddo3+MIU2geKc8QUJ+Zb
IgLffU9CByr+4EH7JVN8vEVocHU92yoOKcKHWH7U0FJ196oZCL2qE2wtqvHQ+VVkLb5sGmmZ
9FXyZnvL23eVuSnj62iQcuarK+j1DwaQgQj0US041KK8tePEDAtqkauLFPzUdoCGO9UvvtUX
w-aBHdqJKX4tb976cLzwCWSAdD2jTDQajeBJLfpCfxRvxUUm1bac0T0L7Qmsi4-aaWlMLXA4
v+kx+ppeEm2b03CFQaTyRptCQJJLWrLEP1EPoeQm3F5u4uO1OHPUZCab0qPce1FTf2ntuX+J
VZym0HEPhglN5Osgz-QESNLqy3-biJOcv7tLmIaS0lio+O6Ce1tzxkxUT0kckGBqbW+Btey5
Pp8F4sk1rU4AT6J4n+SJ1CNEqa7YAEsrPd98O+4f3RD4FNM9T2X6vhcjDlM8uO+Kn20T6l4n
OC2glgfahPzItPf40SYQWFTZlf0sOG8y2jP8BA9M2Q96wj0tsObC-pIONXPDeSPmUwWiVH2K
jUucsh0rj+9vX+Yjap13oB+gHtZWmUdDJjzYsjSCQfYFSA8LmgSnT3MJpfFPKR5eT8xlsQRS
3GS2nvw3I4xb1PKviPKpy8GOwP7ZYZlZkhuWa4gQSk4hpdpWfP4c5ieGIHQ4hbdtSvwf8hLR
9gZKCTr2AukwsTKh8FAeEhv4S8mde4l5wseg8ml4KpjpJnrwRkdhWWuETaBkZSzxSKnpJb4b
UddhhoP6-6bB+RlDKVrsnifRHov27tkuDC1tIhrhDMGcieZlYbyv6OThArCnVCZyzK0lgkHv
Mxtu-INbGAk6DpxVzyZqom1-zabzmSBxC5Nl6FBn0zxjoJSyr8txLM9x5GHMXpn0Os4b34wk
D9NsZky1msEXGOFtluyRVs0DLp-U4aZSiQjHaJ-blXA197Jy64RZgBjlZ1WOSQlkJD3KxvNO
fSGiin9Pzk3EGk20AUgI++++0++iYJUVeJNj02o-++12-E++1U+++++++++++0++hc2+++++
PLR4MLBoJ4ZhNGtYMr7EGk20AUgI++++0+1cM3gVZgdJabo1++0-0k++1U+++++++++-+0++
hc3t+E++PLR4MLBoJ4ZhNGtkMLBEGkI4++++++6++U-s++++6UI+++++I2g-+X693+++++U+
NcTj6ZgR0jEZ+E++t+2+++w++++++++++E+U+9O-+++++2FZPKxEQaxeNKBo9aFjNZ-9+E6m
0lE++++6+Di9vm8VHnimrl6++2Sg+++C++++++++++2+6+0qUJ6-++-hRpFZS5FHPr7o9b-V
Qp-9+E6m0lE++++6+2m5vm916jLgq+6++0w5+++A++++++++++2+6+0qUJoI++-2NKpjJKtd
R0tkMLBEGk20AUgI++++0+-8UywWEoHD03E-+++z+U++1++++++++++-+0++hc3T3k++F4Jh
PpJiOLEiN4NhI2g-+X693+++++U+DNvf6iOg+ZyA++++lE++++w++++++++++E+U+9O-rFU+
+2FZPKxEQaxeNKBo9aFkQZ-9+E6m0lE++++6+Am9vm6RTjXA3+A++++4+++8++++++++++2+
6+0qUNMN++-GNK3YPKIiR5VoI2g-+X690U++++++76fj6a1ry2pP0+++KkU+++g+++++++++
+++U+9O-oVk++37iN3FZS5EiSaZkI2g-+X690U++++++Gpq66K2j5P8k-E++g+I+++s+++++
+++++++U+9O-JWI++4prFa3nR3FdPKIiSaZkI2g3-U+++++6++U+pk2++16f++++++++
***** END OF BLOCK 3 *****

