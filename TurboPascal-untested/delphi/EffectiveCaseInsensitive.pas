(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0318.PAS
  Description: Effective case insensitive 
  Author: MARTIN WALDENBURG
  Date: 08-30-97  10:08
*)

{+--------------------------------------------------------------------------+
 | Unit:        mwIPos
 | Created:     8.97
 | Author:      Martin Waldenburg
 | Copyright    1997, all rights reserved.
 | Description: Two simple and effective case insensitive "Pos" functions.
 |              The typecast in the parameters is a bit uncomfortable, but
 |              otherwise it would be significant slower.
 | Version:     1.6
 | Status:      FreeWare
 | Disclaimer:
 | This is provided as is, expressly without a warranty of any kind.
 | You use it at your own risc.
 +--------------------------------------------------------------------------+}
{ the following contains additional files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members.

{ ------------------            CUT              ----------------------}

*XX3402-004641-240897--72--85-49788------MWIPOS.ZIP--1-OF--2
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
hc3t+E++PLR4MLBoJ4ZhNGtkMLBEGkI4++++++6++U-s++++6UI+++++I2g1--E++++6+4O3
30BzJYm4Ck2++220+++7++++JKtdR12iN4NhTN1BHg7+2AT5vQQe5t49WRts+YDV0P1GE+Fd
u-esOOK9rRXiYioOufBtwiM9SJLHPZIUoQhzAtaRLyMrbnIUrbEqQO1HQV++wPqCHHkVIwQe
olnHZH9Sk0-WXNEpNt48XEykVtExlAds+Sm4OwI2hzLzVWSsCbTXI4NIsSD9URSz4NBPRxWT
-EBGopqF06YPmqHCS0EqVCOeLXMo39oTZRJpa38vCEbOEQWnRY+ZKybtE1obh+tBbyIomLke
FrkNcvhO+OcEHQ1YsYYdkP3yh+VOZ-uyxY-LZEMuyv2kFvv61YZsDtIFZEXkZ9g7KnvWFgId
8k09108af06ex4a7PZIbSjoy2HftdFqMlMeqbhdVx9MNbTwMO6jFUrrBvfNazfSagKBdv3hq
8wguGHRSa0b0IacJgSCu+6+jI2g1--E++++6+7dNxG8xKgjMW++++9k++++A++++I57jOaJX
R12iN5-m8mX8Hmx8n3I68AfDGYoiAPHatS9Z8WpC9SPZIZ-kmmz89RM-gI9nAYgA3H9n3BH-
99q0l47pVKeEj42hK2ipGd00ZZuEOr+hW7SIaduN-x9bK30EYtaQK78NbuTb0RGNaNWHKNJe
XGvZL7GOK768AYsX-4mc1hViEooAZI4ZSI0lp9kIDJsi+3-9+kEI++++0++UOlUXq1WAEKY0
++-y-+++1++++3-mPqdZMrEl9aFjNapHqr9OA--xNsNzw+woMk77oqPw+AVd8+EQ16Eqt25M
KuAU76og7u3TrpoNQdZoD5CoNvIfvNuJvzhuNsE2yx-gR8CkqSUFx+YMEIlkFT+XOXIPpkE1
cXw7VUEXUVi0ASpC0-8WhkFHUdFUFX+bK-1Q2Gkdy-RNjwZ8BzftKWVLyWEYRxkecEfDtoes
fVGwV18u2qeqBvKFuyTm2hT2uinBkROWXiWla2WxSm0lhPLRP1EPxmCVhZu+4quiI+iuP36t
Ivb7yh3TrRSep-8ulZ0J1BNJAJ-zh4xQeBHlP7i8jl0pnhgL5HfbtNojv3mQTHp5qLOwU-uK
5rJOrnfh2+DX3q-ENZMM7vG8T1JAKAWQhU98VqARu6he+Rvn39XBBUZr4mE7rcTbZx4WDpeq
kohQOaGxsrdkdnQ74fTHN6P996vbUrfpUPUW1bflMYnPwKksbMxPsSImrtdhsNL6-FL9NFYR
d2VpNHD+agUn9y4pZB+rZ519Ry1+IXzHGbZCcRSuR0Wd3-ZzOry-QIU0oVTX-meHJEvcDEfS
fNl4PuwGAjQ1s6zOsXtB-cRFqzHkE+87HKzu4Cj97GClw4szBN+79igBwQGRxv8FTxYXbL37
MqmreDoQqmiEbduRTecr4A8SaeFzWejx4Bj4diV7TNkmSEttISgYd6wuFMZEpYDK0+ciyxfg
fGUqviWMKNv1XhghuHT-9M2NR7megz0JtpLalVzMduikjVrELyMvW3ywl5Zkb-hqk9uj42Wn
2I3vhKH1JHryYxn604bk7M0Z+Sg0-YwUhO5HUe3kzor2UjJf7YAGaDeWNiATI2g1--E++++6
+9Vg40Ae-Nscy+6++7c7+++8++++PLR7I4xn9b-VQypJLIzPA-FxFy6z5A398oc3PA-c8R92
BebG7W2cElAeYdjQhVOdLRYC6KDvvvhq2ddGY8O7DKpyGCjfyr5iiGTCkxPqeuqhxHLwk8KG
fcBmnP9yaPP-Tad6C6e9crThcwBUTNyueHOZzlRVb3Gs2YZAOdGOGF4ctvaFYubn9fh5FsQh
W0F-A3YMgaHi84s5rkxY6mDbHafJkG1Hg56qHkV0lO1la06bvkWFg+Gd90YfUq41EKtUb8f6
FxcWpx6OH+YiblC5CUu3szpQ412XFwN0KUWAd+Cbo9ClBYuA2adVZ9fJL7e1HGMx-cRAdoaA
2H5GWN7X4EbZM-CRYGZUTCLwcNrETjgU40yQQ8YhOThYW8u2cM6-OOB2m-aNHhUDdX9+alhx
7qC86Tmq-PeTArIqmN375Y5ei63A4ADZQyUlAtPXJeeGpqwuFJc+3UutHUpodbU4Bj6CfmaW
byhfuqgdWuUIHxTjdK8Olm9W5Va43lEiQbjdNC9DiPS6shEE8yWKHeT011nxT38B31tHsoms
3UNonzcwwpvBHdznHgUwxTmsshe3Tz7F-typab-QDTVC4+zdgL952tZTPyuoqthvyzh1HyUc
RpHosVIt6wIXt5fSwX9yAb4zUoKl2IqYwZOK4Nzog+CbkKIEOqw45XrwuczFuCA2-qyPsHLU
nH4CRdhSkac-yRfzOzGPEovMllPSv3I78C5-DyzL9Ll6lTnDDs45tFsEljbvMmUPDYxJwC7T
vxU0ltotIkqXFg6tqHFlbcLi6d0rz8kAcJEjJ+maP0cNK5ZkUyAHPCuIrBKMYwnPcigWvwoE
DGkNEsdVEKN3q-9xe81recfRlR2X2dzv2QXH-0xWsM+LkK12xyphRma9WVd3P9BPPLl6gyNJ
X97Khk9LwxXeLTep+fEqXu7hP+TSgPLPLTNPVJQjHTuyHg6hzEnAZG5L-DXU7TOAujvkZTtP
EiErf8mCvRrzejkbJDalY4KTjqpG7D7vSTxXyQMA2TlFzEJEGkA23+++++U+y4kM6pktijHf
+U++SEQ+++Y+++-JPaZoAGtkMLDJJIpj4X2EjIT8TlWdZFMOUY7mG2CIEk8VEW6euV73DNfR
mS7WPAjqEV1BTyyA3k72HLi78bK3KAy5rrXanLVLFwTjxVkR5g-Du1UI+TAqwDCtSL2ShRRZ
a-VL8S3Ci0+pD+WJcluLfeUq4fhogdU2RaZRL7krE0U3ISL-cIQrlvkNTPjcAmRhY2Or6NIn
el-mb-ZsB+vupjX89EoWZ5sRhSQE5sH10Y1uH+YtExSCwaUWDR1DCXCLCSMUK4k+DZa8vBIG
3d6m8+A6K+XbV+t9A6wUx-8aIeyDxRqII5c2GKs-ZeNoM-OOIj+NCvlbfNwD1ksDGYqFviaj
RQaWp+5RcwUkqXluWUYDR1enc3Hi8+xF68rGdPwDIh4ecsHrfDfWV7r6X3J4-qTMq1BiFeyi
3AcIh7UhyYDX4kmOVfkHb6f8bj-VF7KAFkV9mkK42KxikFJY582KlHcP+4v826lihK3IfGsf
BICkQUyE1PQttIQ4TiycnjNJ3RPdOpHWAwCwR9U7qp2maxNGp1ZF1uCjslyMVTcPreRzw9NC
nebFsv6QYpw3gM7VZ6uvC3L00KtFpD1AJc87FNc9lq6gILhRecd+PiENuV0rgKPpwFhwObNv
Rt5jvTaeHQqz7PKCBA8bA7+OOJO0Yve60TEPA4n+k-XPAOICPSVHylHcm1X4EafqqJejc5L0
nyISrVIYCplr-hRdiiMueFmNp0OBcOhsWiD7K-1A3VlmkwOLe+-1wi3aekov2y3eGHMEeIze
RC6cPy9LBwGhs+MnkOD5AkaNaJadoA4s90-AY+d4gmqMrn2JCAtmhF5+InrcxgU63uk6B24u
0HJh+h+JFTLnRGcAUF-+7WU+HHJcl5mnbl97y7tGQceIUX89XKIjUSH1mSyCjxALqqcN4wLM
y2pqtXfj27L+2NApAgFaPJVzQHvPC3R+hodMXzZuZ1PBxoMDjRrezrAD+JCEFAmY+TTKcigE
WOwPu7wGUD3fwEhEGk20AUg8++++++-9LMUVMGwRgf+3++0k-E++1U+++++++++++0++hc2+
++++PLR4MLBoJ4ZhNGtuOL-EGk20AUgI++++0+-aVFEXTpNAVXg-++--+U++0E++++++++++
+0++hc5Q-E++JKtdR12iN4NhI2g-+X693+++++U+aZbp6fpOmxW6++++j+++++k+++++++++
+E+U+9O-DUQ++3-mPqdZMrEl9aFkQZ-9+E6m0lE++++6+0-f40DMC6l-OE6++5s2+++A++++
++++++2+6+0qUT+5++-EQaxeNKBoAGtYPqNEGk20AUgI++++0+0sP-UX8UKS8DU0++0O0E++
***** END OF BLOCK 1 *****



*XX3402-004641-240897--72--85-49589------MWIPOS.ZIP--2-OF--2
0U+++++++++-+0++hc410U++PLR7I4xn9b-VQp-9+E6m0lE++++6+DVg40BQCPfouk6++5Y5
+++7++++++++++2+6+0qUOAB++-JPaZoAGtkMLBEGkI4++++++M+-U-K+E++hF++++++
***** END OF BLOCK 2 *****


