{+--------------------------------------------------------------------------+
 | Class:       TTISearch  ( insensitive TurboSearch)
 | Created:     8.97
 | Author:      Martin Waldenburg
 | Copyright    1997, all rights reserved.
 | Description: A very fast case insensitive search engine, based on an article in the German
 |              magazine c't (8/97). However "Look_at" isn't implemented.
 |              The original is in 'C '.
 | Version:     1.4
 | Status:      FreeWare
 | It's provided as is, without a warranty of any kind.
 | You use it at your own risc.
 | E-Mail me at Martin.Waldenburg@t-online.de
 +--------------------------------------------------------------------------+}

{ the following contains additional files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members.

{ ------------------            CUT              ----------------------}


*XX3402-005151-240897--72--85-11462-----TTISEAR.ZIP--1-OF--2
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
hc3t+E++PLR4MLBoJ4ZhNGtkMLBEGkI4++++++6++U-s++++6UI+++++I2g1--E++++6+0xT
2WAZpu0vC+2++0g0+++7++++JKtdR12iN4NhTR1RHg6k3+TkMwRKNF0tAR3sklCM+Iy+YkIX
mA7ew2sb8utlOoZL+vu-fyKBwMKwxKDfo5319otnQhdTyixr5MUraMsvs9FC2E1lDQQWbd-d
lmlePIELmjU+UsUZIiOAFGcqjg+OIjMM8yARg-gi3FDQoiQPbi1en6p1aJ431mw4LjxaFCvQ
MLwO12VRHoIW74vAYlbXYJUFiZNqAR+cyXkciigkdJNn59G1Y4ThU2eqoDQ1xN7E4tcyKxAY
wuawtDAMrRRne0GOUAbtgp80Mvrd6CWqm95KCR-J4ECRz8LM5BwbsQB2FZEWk-Di7anyV-jZ
fCU+H186a19nIif5VRseTyZhwojcu3zPeyKjhDGh9OBPBNlR-ecMrGqXJnLwLMNFALc+BYZL
LdUdkZ7eteKOm5W3rzI1I2g1--E++++6+0ll40AgrDolgk+++DI++++8++++IaJVN4pZ9bFs
R2qDAEy0A-03Rl9ykkg9Y-+QpRZ-GFlAN1R5DO2FKhAK1Dtu1rIkiOLrjjNvfSjenCFI-qHp
u-fvCqbXqLURxAEth+RVMXTXFXt+YSRz+DtvVoqf1FRlp+VkVHIU4FSouVQScKDgqEqm5OWZ
Zw-EOI0qKKrLSFZ5CBUbWkT7oRfvVI6WOWC25Vsx1qk0Lkgof4WI-dIIKI9D986NGtyDtoFS
IGzjpG8oHYgfudRDG7PiY7NjI2g1--E++++6+7dNxG8xKgjMW++++9k++++A++++I57jOaJX
R12iN5-m8mX8Hmx8n3I68AfDGYoiAPHatS9Z8WpC9SPZIZ-kmmz89RM-gI9nAYgA3H9n3BH-
99q0l47pVKeEj42hK2ipGd00ZZuEOr+hW7SIaduN-x9bK30EYtaQK78NbuTb0RGNaNWHKNJe
XGvZL7GOK768AYsX-4mc1hViEooAZI4ZSI0lp9kIDJsi+3-9+kEI++++0+-RQFUXzqUh1-M3
++-X1U++1U+++4prJ2ZHNK3mMqUiQ43nfJRhPlgr1DsS6Dy-O1z2VmFSYvJfwsdpuR6uO9dU
wJMAUH56Rv8htGkNYguSpzKzXxHPjRHdwe38o7kcYi91VyFRDyriTvCpivo3zw73mMkt-fy4
kw2hNneT+TF+GACZ2JMgCEkfDJPy8DBaaXD90qzsebzooYZTJrOaRD-qnPEJ2Xumgi-mLCad
BpG9hFPHaGKJUuCXZrj+mV8Qm61aVigZ9zdCxkoriFM98tEwVhSkt5cB2qMgtAnkJbn4FwrZ
J2Wy-qAw9o-7MDW9ISEZeMCRQLX9xNl7tvuptan8zY3Xm5Qgx3txRzEmuwAvhS7s8nltfxHx
bwky+K2YbcjtciFn9aqAh9K4S6p0E28m2Urctdo9qD4OjrBh5-u5jzzQ0KwhgpJYsJ7nzd3d
vYs4RgT+EeiZ8-+FEqRa1pM0oplNM9-WKXBdpu+aW5IBxo84WDtE3JGI7JGng3OJ-fKGa4SH
SsKTxuyN845CuRlnpOytyh5i8pZWDjc3-T6hmyvnxZMZAOnt8ZPPmTMKzEXAdtukbBA4MnRs
ALl2F4dZxiXtRapygu9oaqhi17hmjr3J57vTOfOMWHkQ84apEVCUrOLGwz1sFf-GHQDaagj8
i0XgSY3s4tpk-XYtvkrJy0ySKmdz72EggTnd2JLtrrMDPdUxFVupYBAH9txQe2fOsk4Wab6R
VHQ8SKv9rf3mwdt9tuDlxuOgA1nmXdiinSpAHCklgPyySxPj5vtsAO6OO0hReDZWmAMZ1sdD
ITBdJ-qj9Mx-LEcdn+nPyGSZGgtYYWC09sG6E9WKv00fN2tWv10voFxKgQI2wg7heb2dQayN
8qagfb8fR7UfkKL-YzkBDOfp0GXgFsrB23HEOQu9GbC29anj+pxVwf0AN0EXusO5gFKLEVib
HBZBaUw-yY-8vHCwRg2pxZq9MllTf+Wwkoc9mwCaOxLBXnRg7Cs9UmMFsFcbumdqmEauILmG
QYyro6Mv5xVwQOEloWB7YtPI1jp2o7XXU0ADEgssMGqOt32vbA5CHhlE0Nz-AvQBxNvqXcGY
5+gybfeCGFiTW1CsN8LlBsIqwle2-i-HW+Ey2sv2MkpWQsYaF5IzB0wG2lQ9b7z34Ca36ZjO
EpoZNMwOnVyVzGgrJIYM7co0W3UOkLd+RQrLW9tGzIiauMt-QsEYe7ubqf1B3zsvhPASvfD4
+EoaD+nsRUwud+Nt6NNku-b0+VcEEK+JsDW-EjaeHJ5E4YmUBw-gzT+wkpRNENhHC1f6TBfG
89iva15R4qEXR1W+LTXyA1fUGBE1Se39SCWL1E5tULcr40I+V98ZTI1O2Jkoy2ILZ-sonBea
g1xcQ2XoD3WBXtd68JSVKs7edqI0MGH6qdLpQDyYYN4IaVrZGXZKw5ZWZoXNE48fKKaZynz2
M0ABAHI7zMDtuQnTKAxvQ9KldDwTgd-tXm8BPxfgUIGgNU6z53rHbxNBvuir+LiEW+w+AKCx
iV-xSMnUx9lFbSHgXXmDFZYXaQrMT63hAA4K4u3NG0O0WfMh8U1HQyO0DuZ3aWxkABNvSgTa
q0IbvixJpZ132g1DEyl0n2O4rvCDUrG3UHKQM0OQUlN2KdpEOGKWoZWgZwi88wigQx7YnGJb
5sAfuvZIfrf6hhu4xFfXGyCy7QAOxKD3sHWBEwuDd4sJIRRbPMzFXLDlRK8j+ejdzXWg4hrm
mLKFvtDhfQPLIRofwHhdszitDcnB3mHS7LTzRzUDI2g1--E++++6+6hk40Bbqyykxk6++0Q4
+++7++++JKtdR12iQ43nVJHfHxgk2DyCpDzV70Mp5F0p68GdX2ag1pP2Mm7-G2BwAAYpwIXh
mb5cCgHzjXgv0OoqOTYEryBrvvAf7GrQoKxkohbdv2VZoQl3UglI7NOR5M-veJ8x8jTV0ghG
N2VIh0vjf0m64VKW93ZoPgEmZka9h974gr8enM8CgFG3ncVMfC7NVA6YyHsvXakugeNkWeYc
PGkLuB8kumIm64M5+nW3V8A2Xiql+i-fNOpKUm52bXflMbP-kWq5f7WYJ0AdyBkE5TshChcK
9MpCA8oABW35VImSUkVJWcOUBowzAP2xVpsOyG6gSgBtdF6fhM7PZIPKG7IBzS4VpFDtwQVL
yCusUn2y3w66hY63PumZA8sZ9w6kulcmf-jXFvNM3fV+NNoNGpszrA95Q1mxSaCiHQDPVDz6
djNxgEyLe6P+Gt0VQKa8IGucGjsvbcYnMwFu068DVrsM5Xy0bXSE7wmYMiGhc8pNmBxy+Cns
36mH-QSyKrBhs+76r+Sf4E25+oWpvobfVny1GlGqsJlCP1T8HR0szBG1DPUlOR+xuzNu7kqq
IfGa25WHnuTEzR5h+QKh7Jx66ffjw9OwVsh50W1Oidh-P6AcNsPhxajB9NNJMJpaBMEInEHT
3uaSlDzqeFu9jn0YOSuC0lPX9rgd3EtVMuZaEtWpkqgvq28dq1V5GAIObclyFgUcEu+4EZcJ
FEWgH+dRdGLYZQcUFz2WWzKyUxUQ8TIiv1KxefziGdEUO9EfFQw19EwXEIU1wPSn488vwzB7
32z423rTr6RY1vi1cxp-jpq-4SIps+oMx4buaxYq7BaoKxjO2x5cTIDstcSF3QPTr9dhdyxx
0oS4hUUrhC4ALfu+aW6gF3JqXeL3h3u54X4ZlqweHKa17ddLfr7N60VhBs0mn15Z4afFBJZg
tOOLXbJjIQXyS0FpLF3RZG5rZoQMOt64h3uNnRw1xpffkxNueWgOndNNImpdv5Mh-f3pQRGs
wAZB0f2gAKqTs4NfuEkvCrw+I2g1--E++++6+8VU2WBP5Efo7E2++CE-+++A++++I57jOaJX
R12iN4xaHN-THw6k3ALTZymvg1+FMzM+P+U8AVa6GbUccw8JoHNh3x-DPoyboNRTvvZzqhCv
5gWHccffHFXoYZMMx62-Y+6NA+HiYWUAFg+MwVts+0P+35V2REPYY2z+50W+-P+2bc2Jw69a
***** END OF BLOCK 1 *****



*XX3402-005151-240897--72--85-18504-----TTISEAR.ZIP--2-OF--2
JoFjW6e1D6x6KCC5b3Ul9IXgjJs8gfq8aC2aKN3MT8caqAaniLJbfaLtZoWrp5HookmWeTu6
HCga1cAkK2x65Do0dYkBrGvkq8mqefOnvMRzSW03YFLj8EKL8RzKyv3sZzvX7+f9maB-Lnm7
CipiX5gizr8hi5hprL3fCv2xvnjvGFnRlCqKOwkiDCKap8EgGN3sBmZdLZedWNjBfkyLQwK0
ApoSQaMDWPSo6omlmXG1CRDgl0rLa7jLkajIjU3EGk20AUg8++++++-9LMUVMGwRgf+3++0k
-E++1U+++++++++++0++hc2+++++PLR4MLBoJ4ZhNGtuOL-EGk20AUgI++++0++jLl6X7RSU
inU-+++f+U++0E+++++++++++0++hc5Q-E++JKtdR12iN4NhI2g-+X693+++++U+952M6mnQ
zH4n++++xE++++c++++++++++E+U+9O-CkQ++37ZMKFhNGtoS5FEGk20AUgI++++0+0OKTIW
jJf9q6U+++0w++++1++++++++++-+0++hc2K0+++I57jOaJXR12iN5-mI2g-+X693+++++U+
LL2M6zxc9EkK-E++Mks+++s++++++++++E+U+9O-m+U++4prJ2ZHNK3mMqUiQ43nI2g-+X69
3+++++U+Wr+M6qTPvv1r+U++7kM+++Y++++++++++E+U+9O-0Us++3JiOLEl9b-VQp-9+E6m
0lE++++6+8VU2WBP5Efo7E2++CE-+++A++++++++++2+6+0qUGUF++-EQaxeNKBoAGtYPqNE
GkI4++++++Q+-k0G+E++Rl6+++++
***** END OF BLOCK 2 *****

