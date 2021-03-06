(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0462.PAS
  Description: RAS (Remote Access) API header for Delph
  Author: DAVIDE MORETTI
  Date: 01-02-98  07:35
*)


Version 1.1

Converted to Delphi by Davide Moretti <dmoretti@iper.net>

Feel free to use this code, but, please let me know that you are using it...

History
-------

Version 1.0: Initial release
Version 1.01: Replaced library index number with names to make it run with
   Windows NT. Thanks to Thom Randolph <thom@halcyon.com> for reporting and
   fixing this.
Version 1.1: Added the Extended Ras API functions. These functions can 
   manipulate the entries directly. They are found on Windows NT 4.0 and
   can be used also on Windows 95 using a special library (RNAPH.DLL) that
   is available at http://www.microsoft.com/win32dev/apiext/rasapi.htm.
   Note that in the example code I used only two of them (lack of time) but
   there are more functions available.
   Thanks to Gideon le Grange <legrange@adept.co.za> for sending me the
   new API information and a Delphi translation of them. Please read the 
   Ras.pas comments about the future merge of rnaph.dll into rasapi32.dll

{ the following contains additional files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members.

{ ------------------            CUT              ----------------------}


*XX3402-013859-271197--72--85-26762-------D_RAS.ZIP--1-OF--4
I2g1--E++++6+7pUBW4lbmaeVE+++AQ++++9++++Ia3nJ4JnR0tYQ57ZX2o8kX+EVTS-r42K
EZJ89h0JW28rgFQMRGk1HFcmuQPGiyh6rSXiTSwjtP5D4A0XR0GZgQOOGIWg+HWDCIWhGWAZ
s+XJ3pl0eK-yt81CwdbC4kxvtoyLFSZ8DITR5p6Oy6O3lyXOm6Jls0Qpjx2l2lPGvqqrrhOk
WhpTqozlvJ4wCqhSI2g1--E++++6+0i3BG3jXt9FL+2++4k1+++9++++Ia3nJ4JnR0tmNLCZ
Iv3Ckn+EDHSJqWuYGCloN4FfBo-A1A+jg7Il2Z9X1IgRsf4fZMLTW99sIncmFicEVeX5bJAr
Hgj4qGzCSrRbCssD+4-4E4llOhw1vsw6kabHuLHczHS5z5i0U6AwC7ybBSIu8BICrCX3KYgX
8yUuPwEBrBmyu14ixKcZOzpKnlQQGbmtT8xpoj5zy9IrlJl1Zf7t9gzwcB33d0uT7xEcXrvr
gGFYeJEviKst0qYKnnCx+0zcN0SHgEwUURmof+w+mju6cf5o+KeSiPXPst48GvPiW2p-nMGw
m6jWG0RtINfG-BnYlcEwtsUibvbN-BkINFvwocbdiKb-ggwd+8+jx1aQwUqQqlMUzUjYWXkg
k8UWfG5EXFaV3KigE4+nyA6afb1DRwZ49JE+Cm92WBhfl6fkQsSs7m1XYs-Lh++TCi63DAA1
DA29sF3SOTEKpUJLUs1NPCWeUeh6k0xEGkA23+++++U+t3FX6I16Z9PM++++A+2+++Y+++-2
Lp7-Imt7HYMxXo39ko+EVSw9ylzaK0y7xPW643c0-EIdWYRNReT7M5Mrn2kOxRR9OinhwT5S
svqK-cHg2ne65ymZye5FabOVNqGVYVpgeyq86YdU4jK0xnWADM4mnn9sVI2tkF3HIMEa--G-
tiI+4wdVa09Z1j-9AGyZQaDBeyQCxRdnJxpOoonO3ps5vTqN6g7nMJEZi6zdHnrGW3lZp6Rf
sCrst8-L5JpRnzBQzHheYPFi3zIuWMCK2KTD01Bd1p6a1aXBnWhqVPwRj3CK2Xv-tkWvYh8I
8JnSWHLKz+7EGkA23+++++U+lJFX6NswMTdW+U++H+E+++c+++-mNK3YPKIiR5VoXJBBPxgk
19o5m5zUgEIudKarEsCUG9-iPM4i897WCxAq5EjFVm5FQPlTDofCojMqLmm7pCDXSxFazFDC
BaEx2un9Ya6wVzL96nG23EKcTM+vAaqXdtBDzzhB7xD79kdFSkRnBIzPfxvh8H-JkDs60AI+
RvXL3Q2D5sVNkv8msqeZKkf82Ryamxy71BG-83ricjkO5O5o3Jp+oT23h6NEXUolK68RwvqY
6ADUCw-+QYSv9KVKGWKw-lrNVy5IoISyZkhsR7cp4UWIUHx2tkjMI4ikZ3uA9U84+PGfu+0i
gsJ6pahik84ZaCVOr73IVh0t57ZC+C0rLD-xVCRL-OwBiZpCTKqwVEp8GCG-7QhqpO+d-yxI
uSphBWBEukCbRWElUxLuY9N72zJ-xkKgemcdrV-wCn0thBZUnDvKbGhN2aBWE09SuE-8R70F
9HfRRUONAUMt1ZeuebGUYgqEPktNsBdrfU6dyxMNT3OL7ss7gYUy0+AooPxDjTZmx+QVhZEa
rTzdSfNtLfwwe9ibdzBgOAMGur4Dqa-V0AHYVfZRn4Nxrmifmy0XfnbdBSipivueO1z1JhC-
Nk4Xf3H1JaKUNtwP2kXhlUMDO4KIwaH-swXKCnA+xw8sHXYKngHuLRtdGyRdzX8Ml2G5d2IO
sLRebfWCFRzgjdT73laYrbp+hmJM4hfapIeSLdhuI5xkR1q8SIYWatr6E6vuP8FqYa+l3Ihm
Wsf5twK03QoMC77Lw18yZ00jCvSQcKEaJ6jdFJYf7UjbkbSQsrL5LSe7UV+IZC0kPJFZXBGJ
5YN7fuzGmLHm3p-9+kEI++++0+15I4AVSdv-LtUS+++ec+++-k+++37VQmtkMLDYLKpnqnWG
zblHBTw-5uMeRhPfhKEvQNmRfOIZmiOAF5778IfquYt3GtHBXIleGGeCNqfyyrI16+a+60Kz
H5OenZJ7KIEzE9yVik30w8yjGGxNDuHFnKpCxiPvdDDiLTTDwBzd+FZ3wnH7YaIC7CYuGMAw
Gi612elKVB7b7+qnADoG9fvzvjJfz2TG61iwdPxtsJqGVwGMnwAg6y5LD2nXM2IApu9BviNu
3Qr7PFUgkdEgYpEW6TBJ3ANt-eGzTTzRxxzxGjfVOboPYLYGTkbH1DUUpkyY5rm73W2N7KaM
tl5tuy8CzTPrO-qaVr4MzsrwVa+PC1Yb-j0xrAFnZ06XEPkUKNtitjY4d009Q-ZgJW-GbV+X
ne71MWr7Ev6Vxo4QswBB3bvz5G4HC7cbA0O1gaukoyk+8IVy4t6si6ACkrUFlHTYDgdjmOjd
8o9ZqAFFHfkUSswTcVU2LUPnY9NYU7Z4wG8tVut4c9DU7cHTz6RgYYQfVU1dgtndMrk9eWR-
4d7ZahmFpFqq5RumMEXdqoDH7XyGniZvEjvm3n68jYNranimGCu088MgYZIMryGrJ0VCrHpx
wpuY-eNGZRORuabLENPR7yZ069LBwMLZy1DP47YnnUw1qK4C9EFAlDfTirv6kqmTASwNzUmu
vMRTcbYsTZW5V043BjQqWIBvQrQB127PxolghBP4Md4Wql4a+ebhOxY6EbHSArIm1o3vrqqm
59oVWYAmhSkDdbTQ6RQVS4U6rbSrXZNcpjkqmUWp7fX41IW-VgyWLw6Alo7rlUT5Vpx7sOv7
2ZYsFAAJnYOU1mHZNWTjHeYvqKBmQbX29Dbf1xOUPkt8Hh0RDz+SgLQu778K+ddlbXvMe3Du
+n6SjOwdhKnzYFlrlSMSHCvfMDutJCo7OjPL5wmVPsdXbyksxiaPpg2JkxJ4fpiPQKDrfE5J
HkvSkNlau3v-lCcZQEmszloL5qXrMu3daAErADCcrO4jpwFOE8G7ZZ46YtY22-uyV1Ukldcs
dB5WY7+xDklltdfltetLBe15jjuB1Qy5aB9VWkxgS82d1SQkGT+d6Mhv5pFs9f02HqwVVi9E
toEKUd1gZp9-2ArGB5XsvuD1EpLrzsCiBcKsq9gBa9egUOrs2CqgaZzprecqhHg-eaSYOehn
IVWCM5VwLlWCGqa6aXAYnFbTHbAMz3xEQo7rXxKQl2aftYH3GLe1-Z4VQUttHR0NEoXfsDco
4Rq3WkUyEL8Xnm0o-TdNo6y0JSbuk5rDbvb4l1TvAC+DbOCXAiF+ExylHHfNTyWm-bbKQjNw
538IUnuEV0Z6941pVYM0ENdWB4QRlauGtY+bAc4Dg0ZQMBEF4jVQNef5W0JmHVxm0ccw3ZeV
b4+2aIVl6Z7g6+Z+P7YnjYyJ7gUtoT6-4hsc1Js61UbDrmfDWz+6HKReoqoErsFiYMBz7CwI
+XRBzUIwcjF5GhAkWXzvut0ddeAo4bGsXeUK9pE2ulkr02pv31LWdi2OOdN-YUemR2H3H6Ac
VyMFp3Vr5dEsiNHu8k6FzpMOUQf7VXtfbAGA41kenEK4APA-HBFRAIsDIjwedC7qFEICYtgY
Vb64pDut80X2-3LEcRCaD9bw82oNGPBUy-czojnuYymxb1gTueY5z3-YHF2Uqevk2DDfCYed
YVHWszQWpu7bJvBNb07FBhTGQ2OfiEvVdVxawnGulgVmms9A7gB+3nGbqmfJydGwbazNwuYO
Ci-F9LUkgiptV8QF4ULDGHoU6QtAomFZE8g2DWCbDXadOVA0YxOc8wLE84KrtDdhZ08bmmTb
mlOZp5KWIMaEBmixpPmswZUGUZtUENjRrg5IVPJE0Yn-VAyOQWNZ0dysG3etfz0cN2gaOv8I
eD0bZ6YA8JHOROnEe2T9xLix+vZRrwQ2pdk8urFtqg+jXqQ0BJqUBgkkijcJODjubVLbeElU
pCpYOCnIBeCSN8TOh5WIbKfc7xWdpYSfbSfwhhadDiaPvREqmGg1pAqYgF8Tt96dOtAQhuLW
-KGrlhaSfCZGQChIBv4bX4sy0SlJHmIK7S9hjfGsLneA1PLZxXtSU5X+u1atahfx6dnnbHiN
j30ci2VsJTLxWZl5CJaiUdjgg8nyyuPXXaTU1Z1Q9OCjzaM7ztDe-kfz6zP18lQ4Q6BB3Wtw
hh8ETWd+JkFMBr4GVfEkV4cpy+mZHUpk6U8U8B7FGs0nyUVyggnjEK3MwS2y2Gj0C8+cbggF
RBHW0BoXvZHOCWU+LmfKM+hO-Oplvd9f7DYA9PUAkColOTw-5i8uHTOjAZmIaOFuIjeJF9Ex
snwpXmWngeEoOekNRRNq8oOS4XePK8hlJaSAFki7RqtDK5DYmHlN2Pcn18jaBJi2c0wgUXmc
xdb7LP-SFz5BcKEwhm9bT3FDGYMYciMZg1gnveu9JLWtI53bvbdhLmylsSncS0+xhxNTqTDi
VT8QDyuoiH0Kwi1si7pNZj94u69g8SgMjeJB9ZP7zDAyTEREeEYQT6kveih0YvWv0i4-PNzP
Mr7wq83vcsvzZmvd5-uHFL6Tfw6jsMexP6--OHl9Apapc6lmFi1jdHdtkrNLYudOoEBl1nh8
AhtOCe4uuOqfF8u5EFmQYsg5LXgfPUaw4E9HVgXoPjDXFNVKoj7qdUKSFNPtnC4GP5IUprK7
TH2USwWfCP5qFHyFtkrpuR8yz4ApMwfa7mhgQGwfv+Jx6DhZaeGTQHY3QWa-v+JwW+Zjm9cl
3BowmtZSIXSp0j0FihbRJRQUz9e6VM7e3ApkburIpi8qKSKrZjiFvB4hbdVj0PZEFcQtAPzC
uEtR9T0d1Ur-K5Fcz0WmldiT2E4e3q1pn3apPQreX-R1NhJEK5pag5c2eqpNjYll+eQ8ctKt
iFGvafimRaiMghOmIFKPDhiY9KdeA8WwAKeDXoxvngUplhP3oCEPZsG+-aVOLYPV0b7l++Lf
+dR0py1QMFWL9mtdUXv3puFEv40OJVdMPy1smmUCJUSIFCrXrGYNbRJvUAQI--I0Tm4zGAfi
sWE5jTpv2uLgnHgf+N-7yc6Lyva5JFeKN4aMdl5I0sLRcbWNd5Qok3HQsNhoaLK0-lC0RDKU
ZHIvk5NQ26cYNLz+CuSerWT9aXsgO2jAi-61i0kY+FiUfC-VSC-VUKQTw-E4mV9VjXGiEuYg
qI5NIruPP4tiFPtNjuwmI45F3MbmUcTT0bTm8RZHbOflFFLpR1ZU8D5WqS3WFsu3M95fB80f
9uW9LRRmdrUC+1LyLAodT9FfHZ8Qf1QlSiZSww52qKFsOc5j9N+vLcj5y+O83yXUdQIt-j3l
GMhf4tewkDTkf2Rt0U6KBzHrV48xw0P8606mhyB3jv4rXuRu1WZyCde-BjeKAHEzaC0JFOaT
l1036UmhanXuxmOgFUtWRDtf1A0gwr-l89lwf9eW0yxLlEv83n1F8ucdRIVMpjFujPumUgDZ
1HiEAORjIa0W3+eP3qyP66Yjc+aWYN5SPB+7Abc6-oGbkVIwKrqmBxyYiCqmkfZu5nlY8Vjv
-pFXb6myCr3gqlwPMlB13yoD0I7oRzUhm43sm1tnWZWEDLVuV-e9YnXQ-tPAMegeoD94S2T5
csOGLfbEK6av2IILP3+oCZTpfqnx-t4AT5-ED7UjS39fBFRdA93vyrhYMhbX+oaK+x8TCZuT
v9zTcMQCR553oETBbMZxTjzR+1VZtwDCmIz0wFqerQ7m+QFZ05fnQ65fQCmHhynRNHTbtMeO
vDe0+m9DDZ6jQ+EYGB84+HdvhnrZJ+8FliHVEnRkDRfV2rdIfd4HrserywK-CfcY-oILVxzM
AdiuSq3QRjtdKGeGueuYlpJsggb78yAJ7XkwnVOlYUV14AlQSXECTHCaHlDsfym75T5983RZ
XrlW4LhAxhKuqjMwpyqMjWzcyBPrFN7wDWSiIjRz0J9qvWIvpqnhwYI91KtVmZt5mHZYhGtO
cSy25cYESeuT9a3hys7l8WiccYuT8Oemz4gKRTcT3zJP4TKP0me9eVk38rmNRoZHzvZkiYYM
***** END OF BLOCK 1 *****



*XX3402-013859-271197--72--85-29910-------D_RAS.ZIP--2-OF--4
RPKSLuhwwiR0VmL3ffdL47eqAnHxtUmpwzDvg3Bb05Rkcv+mJzYWF5Kw9Lt7hyTdKJxF2aJj
Sugwb7gbeNNXdrJ7Z40l7NNgYKF5FrY-GLtbYvmw596YZq5CrNAT4i1mpB8zC-sXDJTD4yme
DLLAuRD5b1tpn8QDyGXRoY96duiBEfCo0jcEf1OVKYpV0uChiwbwMfCIJdOD23lUMjcs7dF7
xo7AT1h3m3lQ-T5BNBrYsPj8kbddwhb5xT82Hae8fJumKT2mqH7z6MzVZhytwbei13LJ6prZ
6IKUFxVSNb59RDwXgDW5s31agNS4g9WWWEHThBA2IFevD0z-hX0YIlBByKRLtSU4bXtZs08M
D4TUrohU7Pojcjk3BGoo0oQ+5aq6CZTDAYA1JsypIdqfzt0eN9Nwm1XMUP0QrhhdO1N38pXH
ebm7LlPw2ZO5l7+Zu58pey9e52sPCBEgcxgsbDty59uA0dz1Lvqiy3qhnCWKHxRVbQALhj9j
kC49KjZ7z95RkD9fiPFGrCovijFInHeQswg+MICsz3OiTD9ckj-Bz169DrLYHrcxozTtxr1k
WMgjCCl9ojfn6xbXTTrdO7xqN5eSswogysAlhDcnpz54gmj1vUzB-ZV5V33mMyWNFjzHn+2C
4YTfWf09mK-USfClswnwYH2QBXBt9A8abaBT+eg1U9ZanldMNZwDCl3VDQCqbT5ABwSALyl+
1nihmMN+r-orSqBd9+bqFcHFRky3DZgBw3O2xQoDJgyQxFrHdsCO5mpzf6KRpK5XHusS8g1S
OEnEl8JcPgZBD4QmBiYUlUT14VcLnKvGOQ+BVovDI7EdsfcuhwGrVVusiyLMciZ3bCEdABnA
4L+lzJPtHfEq5nUHipojYewMzWSvBzDATolA5vlAbMYWHb8KMifo9NxvKGDifNPDydlHQKQp
L1KMsh6GHj6Lqta-H8tXqSCuBiJtTeGNSgXZn9pmPDD0QLvKsncOrB+lyhhkLEpiMBY01ZUT
StxIr924BzIgQBDuU07C1WqCtorkh5KRFlJrqWGTDzPIg0rW75ztqTnIsdsGHcsiZLwtvTvG
ZTn3AoQCO8E79i6YTvYmjDvIwAnN+892l1CPlniKz4LWaqrAWfWC9YvspXzJgJFQJniDhC3A
kibwlTKQbs1BKKxcwTTXRNnY9lDvNxiNOWlEltrKAlzD2QNsPDGil9YfsWFziR1vZkvrJfMv
WqFXOqF094r1bKboQUadRaXMFVhCXWzwp05xpAfbWSEjs0sTn19QEsNk7VuIFHeQt0zoR0DB
YzsAIUcArnVSJnDSdKaPbX32bCHV6cvv0wk04xEz4zaL2CohUuJccxxjgBy7t0z4N5k3nXoq
DRhEemE3RmfP1uqC+FtWn0J6S+K8wPIsCFzpSXEzs2lcXmwbQXsmT5zO-squZeQ-WfUn7OzU
oEE9gcDdXGmOs-hkvnFqE3K0e8vHb4xD7LwNSAu6HuCuR18i6wxPnyktZnO2ZnsToHTpCAZT
FYPDQtcXhcUvpiDu7WGnZXlx8jb904cYsx7g4ZT2GTs0clWHsRUN19FE2GTtmw+Oad+27wAy
FJmMBBKLv6csHPJ9Nm2i+cOC58-2b8PQdHWRIYKQKfwIJhhGjvktIb-ESctUDOEpc6XfpCAp
NajREYL0RHLtcMXoKBQrsGFzsJIp1HGEgZapcwTdupp6i+DfQi6pwrZOhkCTTp1+hiXZXFmL
17md2B6guXghi9QpCylIjvktIzDTVAs6015pEILQClqTDVgF5OtVj9R5CZmp94jWwqqb4OQC
7y4uCVmJgJIjPsxpi75lYSjpkjLpi7AabC3tZiYpsWFzUEVjkafAJlp3UtDwtMB10lvPbteO
gY10eTvG037kOXvWQar3eT23wxWMrQLGVXhHhZq8y97hj1AZjZXXrTnnf8j1PTTDgyBaL7hz
bdrcQBjxvCmo0RTiNqRjR9Xhwy5gfJuy6UwqsgvowrMfHj6LQyGCDnJ3ELbPFj6Lf+RVdK3V
f6SeHZpRWPXuDZoNhpj5uwdy1IbRgUrj2ug9Kb0GjzFv3niiIxx7zY6DcS7EJl+kK8YAXvlW
co92bPPUWaqJ+WjW75xlcFraPJYQE0LWi3Id8S6YTmbmR6a1JBwUby6jjEys8nIPH4evbUdC
wdTSe8whZCesnd4wc9PxWMjKVvdJaY6Oc39lEX3DhsUoxOs0J9PgM9JWE3Xu++NlyWodjbAY
yEnauVsIAVR4vySNDFZRm23M+dv66v93DpoggTDRXI-hZ63tCBua5AZhDbNDARtTqcsDQv5R
579ToDJJomd7+Qc9umj1jYFSuIc9nqMr+mLDQK0Rt2pqqL5c83ixVUxteJXFcsdkcTNDwvze
CAZl9WlrO5tgr3aFU2egaL4rgTmyHIg4jsbHMkJ62OUXqlnumd+GI56Qb32UsmRKbh-bXGB8
XaCtNQ3gO0dG0TV4NRL3pHxiNhSL6V7ELa0vPhBaH+psdU9t9hsMZxWqjDQi+RydE41LxNml
orB+ez6GERemDx6+RJ4X-imckD6x3+G-tYqNXfnfGrRTSQXEV2Y7S0nPwKDD9Mcrr2FeYT4Y
2IW9C4bt7+3Duw-Wi07DAPxLUSfC19vzU+UkvfaxkKJTnVwGI0q3kSKU2RnCQAReNGg-7Qzl
VsUnzn4-MCJ15qpqZ1q5vMdWUQ8KZWC603JEZZvO50Z+uagB8p67KDAQXc3kRxambRtFxbw-
q2AdTx8w1J4+lmdk02XRb38-7zLtG7LO9k8-A9s2D8r7iCC6PqegEZZ1wqcT1B3fX+15hNW1
ENYn0Mb5ifEPn85P-NvESUdr5rgU97Ohlh-LUN9bX+rLOcagoagvRNw4Bo04AxDiSNxQ3GY-
CkeEFoQhIU6e8qy88iS5+dS+idVXXci+VT6CfJvxXKrbF3jay8CFueQpc3kQXoNEnZINj8Jq
C34n3NHIIAGn-IHfW4zJ2LTAJWSpzFclafQ-7QxV4qtEPosommYNm5O22QcTaEqfvqPcbiNK
xmRSu-s5uxj1Ko9qwUGzUbYLdXT3jGkdLjOyLt8yp6rjfzSN08U-sU-XyDpjtSPrmqUFkayf
Y3maS8w0ySgejA5TzUuxfzD1SL9sGz+rqgB6sLURN9jR5EygvBSDiS1LS6oo15dspkxeLvVE
ZJuy3WnMZSKoHPtR4wfmsj7lj2NIkUq0SPG8Qfm4ihO4RurpwG6VIfO7xz5gGJR8oKAvY+rt
G2k8zYpWmwKbV5yJa5qW+sr3Fj2vqA2-iHsUwkCmoBmbcFZsLFlTN3z4Y2Nbdny7SBSGQUCI
zVjU-wK5sVumwY2jqG1AuehDo1fpPsULRXgbET53PBKYyih6VgYwK2ZrvUKDirBjQKyge9Db
MSMgZpaMexl3Ozmmzs5scJx8Kbu4LeF5ooWVkER+R2sI+mA9+vmJIZOcHIxfoniL8eoWLFHT
3+ppDTdUwbIiT9pxNA00mVVTYHyHXZu1lWND3Z4kuexK52QS-llgsjbXY9JfFwZnvVqhUthj
NsFtngC+-glP4d5mtE2Wgadg-3RFF6Cj4VjlFOHFc6gajLjX-RFl81WFlnB7dzOY8niIvYsq
yFMvtEMvzKodrnl6pCtnSbmEI9fszlMYOVfQBIUo+fQ4WMN9ZrQ92hhjP4s72XLknY30Vxkt
GCX+XkYGCjmiEO9arWwP78EM6MQ66ZnKOBF93HvzWGJS+WEI8XoA3x-KX3-w9UQF03cWIHrk
q31mhcMXxFauXmsI3DdE-AA8XDwdUmPNc7ZyhuqEfTVQmWMEv56FtlzUQazCwJEFOOe8hCip
dry+Gxktlsd2eY1QnEIH0egJQ6leDXFTsfjDplaaUrTsQfQnsYKFur+tcZnUGsZxzgI+ReIF
8LteZzR8l0UvimEdYsZD-47fTILLW2pLuVuR0QFgoRZbTp1d2X9bDEEYUPVOb+3lDwe0upIs
b8y3utI3set6D+vHCpltLh0zzIGj+N9MCB2F4oh6s0JhFLka2hBPWMRgkGrw3AGR6t5MjpTo
6-Br7K8DLMNaljDoMNq50zRS6XvF2MwmaPkUDhAFMqnbt7ERHWnymFQUtbwDUzthX9e+LNYM
j6sGxh9zuyu8ShiqUT1nzULr7-hnb0-9UQ3OVqJfUkP6AWABdfsJQWlp+ZEvYCoauOwTXtH2
crWGHfGBfQiHMz4yizh6mVFpj2hI7OMslqDXkasgZljErqORN05zR3Mz4lDX5mxXw0EEcor7
vWfthBta8VRnZMZKJNmctgXh53lP79jAaVF0ZnEfNIKNhxH6E69-thlcm3nDDy1qnPZooKlz
zzjwx5dCCxdMaIZTFubymbWZIqshLZ1ODCncZIc+93kjpF5QYyruF5okaMx5wzYQ0PzDgoTL
LHbnMKPQE4ua8aoWUc1xT6EVLG6cA3hModT56YiqgTGuwcgW-BzDUn7PqEPtyiNSHoWd8zUA
5s7EgEz8s3zHv5enJ2AymCG5gVIoUtRvddJQ68ay0tvDLu345uPbfqfns5TOZ07AtIpr8P8J
i9ixb9yPjfatoSPVYqJzlLaqZ1pjwcgoHtP-dgiYyVZGnHnClHdeb-Bqd7eV-poRBERnlhNn
Zo+q2CjIQMS8DzCZzQJhwiH-6J98M8x3uJ-4YR8XChf6xdF+HGEijltQ6UL54MZ6kN54M5Ia
JBvc5dBWWp6DwHF7kCyUvO8uE4F-K1udWxFmJUfeylwg2RiYHEjjZ0GqWwAuuthowTzEWTEN
xSCAJ3zrxisupup1XgvzY3jTOaQFqOLo3Ub8kOA5SPLjAVDChcmN-vvn4qaBzVKhFpHedZkf
OpSO4TvP9YpbCY4yhGRYAipEcu4wJe7t7LwfNOACGtcdu6tfGMQVlv31JECrwbWnAVO3tUpu
IAGPy15vwLmunDB+pxECqiG0g-wwwUGDCC1meSUkZegQgiIn3jff-JRm33XY0SOs1JyuK7uK
2HaIEUsM6RQD5LZ0ClGsHI6K-Fmf4uZLEmOvHPYSrAUHpuL0jVtmFkD5rWeTOHVUZ44t1gn6
2tDojvm47wJSRXfNBYASdWDL-llt+XggB-hkFlT5saPe7hMY7iHucLbr-o8i5tdrTq-OXP83
giRPEusPBj827MYkZoDqvCWrhd5DYgpjEusLCT72deWkKz1bLczBNQ9Gtaxm9r6dFwAtmkIa
bCCrzhdNADVOFqHgMwpOEesTabR16CHucLb1egJeJEHVzixYYuUm47jR+gM530fFhPUaMdCh
5V8numuSgXnLRIMUaRtGpmi-WXlEy++eN21Z+vBj1uXkNUueRqFKBOG9uNZCYhOxVQxN-vhG
HRfQDLgjLBIRduSW2tfJpToasrptzjoCGrIUFZu6ZDjcQgWTYppasUpnjdZMeUBlUCBMWb+Q
LFvUS7SNl0ssskaHYCc5tXmu2Z621KsfnglW42rgh18A7eHuUHZg23624qsf1VgAclgvTYCK
qoOe4rHE4ht6oKA0hFWoV4wr3az6wGQlZid+55-Pk382vyXmUBh0oonsLROJl5NPREtYhLum
uUphuc71w0qQQeXGY0O3y+k3biFjR9pTdUyfEDKVR7rbw+AwWfQWHq9NHX8StSIN3aaIK4PG
kgQY9XPHuPF8Mzd3jwpHfHtaekl0I98jI5s0IegaAFFQjcfnXHvvY4oyedPopHlPnAGvDxP9
LNvMqusOTeH0gtGbAu5LvKBv1rqFTAdIobdJq4jfaUKYZ3bhuvMeki0yS-3dJYVsRRPZvj9x
tTlOxcO87s+qoXUlSmpipj5m7ZgIQT2mgjhgL4tVGhLExiRTl-bGNiYHsYvLv7K+Sj5xI6OR
XeHcFAnV5QA6z-EzkD7dL42fx37K8ZX7zg2e4Ye6PU4BxwIi0IqPhwzN3jqfMybenzdX6fic
yf86AvYcTDjwY8UkdebSOlk3uaZ8mDjI0c7ZB1IKALUyECTcm6oH+M2axGXf69heQVmaXwdl
BStNxBTg6x9POPye8+rYK8a4XC5ryq-wYCtom0z-1-GWFF7MSsmtszS3OuTbX13xyRfdmfod
***** END OF BLOCK 2 *****



*XX3402-013859-271197--72--85-33425-------D_RAS.ZIP--3-OF--4
fSN83LzO5OJXjpcYrWeCvPQVLud+WLEa8dA4US+0SuNvTYq-lD8CGXtlZDsNlhAKhSBKvr32
1Go9MHFo-2o51KYr1GlA7Wj6+nMT1TrhxC1+aLq4FEwTSl4+P1n+U0-0E5dh1bpWDjM8xnU6
pSpavqLuADCNbSlq0vij7vKP2xiVWSr5V90sTNkEUFbxV9R2Mx0-47sl46QN4ZfaMBNm9KOC
-dRwfx5EBFPs6u2Fri2PqA5dBkMq-twztt-X7ACJwYahftob55h-FZrs-3nkFjhENHm3H-eF
rmG5MBmYBaK0ZBdQpWjrAbMYVOAcxLxe-SYiwK2zapXWLVJ7IXqkm5Id877etADmDp-9+kEI
++++0++GIaAVXh1gqzA8++-S9+++1++++3FZQrF4Pr7h9b-VQxJOrKzPC-7z9x1zUEQQM5jD
eorig+yPh5jfC2YP6-y4bJul86e39B4qff6cY3EGRv5zywqEZ2W7YWprvy2i1uohnUm5AwDT
TAV3ZYXmG6KwNblvzjfJupQzz21aRAgY7NAccY8EmSm4G8+UCKRf5asJmL759gCb78PYXb2e
NI9Sl3jxuNQYdnn6eDkN8FLp9+prt1aF4t96jt0nvoSsIN77mZRVFD396OVszMeEXoYKgqQl
7bSkRPWaw4al2lxYYg8bOFc8UMzSwH1T7-2yMdbY1-Tl+D1TNF8aP+oTte2McwG3X8SG6wLJ
WnGTdamfDeY1mppCYT-llPRc0T8KF9XFw-33Xb07Y3H68xUdcS8ADBsaEZukZrCxh7HNCyeg
LVFGggkiHXYB7QLpLQjeJNn6pfIpnlQodN4YQPbyXfAWPqsw0w2bPTiW7JcZdwjoUu1wDhlG
D2msd8ZRaQ57blaD4mjmFHcwe9FRQ3WQ-R1UTNWhWvmtDQgZebP5MVEp1yC2eMBN5GNWZoKy
OUgNmY6obgAqYoUaHlEW6TBCycFDkMM7mof5zGiVntNroKJ+CBSItHiSf1QGpivUGZWiCQr+
23oijEGrRHVQOLvOC+9QesX4-OTpI7eaGTFZi8-NH1ZkD0nz1EQNhT2s2ROTeEewzWlJFDJb
oG5Ebvs8u7sgxZvqN5+0SPc-tKUjhKm6xHz8sgWXpCDe08zMQBj1ZDDY0M72wzxCNjcfWGZU
5EzJ-G3zuBIMr7mLZk7U3BqiHu6Z3IjMdV8YjfL6+GIIj1u359wOQ1qfM3Mh7hgwdJiOGQK7
Hrvzutlw3plSrzq-rpN3dWsjoLRz+NvCpYA-LnFq05E7fh3nEXZbQCdPZeoVhMnCW8NKCVgZ
0+3MaL+SvXuR-A5dmQZbkZM2sc+PkscOpt807DmEf9FowiNbQY9YVaPagdQ2-BABLZqYAZce
XX47lUEq8Xordu767Ha154CSU7qIiJ7-DO200EQ1Ela3UWd1IB-ODk8-YwJowRh1HfANsz8g
T3nmsU6cEr7M9CKIHAW+unHqq5+7U-fLaZk4IGzdIl7FXv52KxUmJVFBRgpbm3dqpigY8UaO
z7AopGGWKkPEaBr35Y23yZ2a2QNGIk7M4EkEKV6sI7i+SmOHpQtLk43YY7ImFRMaM2slGlnW
toXJlXsBorENFZwCGcUAMOgEVMBJ3XwcGd4HrB0rGNllVgVnI3GiuHeASthYLlMtPLBkEos8
Z2EUONiQGEzvU4YmxdnGSCp3v7ni1FLTJovMSA7QILjDtFxZlWaUAcKWhBDfaUEjrkf+egjb
5wA2mrogk9O+FxHr2p8IIfN6-eQ0iUt-bSesMfeIAO5GVY5ZGdB3LQu4qExTM7NtG4NIUasU
llHeUtYV+-1F32o7hqnBgbgesFvsdsT3BNsSgZSaGEMetvY0Pf+50ZJlsT2vOrt6+VsQg60W
6NBS3c-GtK85Lu-gu1E0-+0qTN2WwxlcoC1e7IxsanDBCe4Ok1R3BtlDim1wAV3FRm7l3WqX
fYeIW0cH0ti7nxr8-FfLuj0k6Ga9YRSjPDq37MWV4Kv3ycmUpxOIbtDK6gJgJ8xIY1N4gvPL
54xf7MSdbc8e5keicEICdWk3IWkfociocDK8sX1DbCeXytHHA3Q3471tBRVMenWewRP8tI0J
d1KnKiAxCWmxydueX3gK8t3wdNIBXK4nMZjpsTIJKXvKpRydfTvEEOdsldP+I9xMDxNwsfNB
kJIK9W3Vc4KiEv1piO4cKdVq0eQ-0FvdWrF8D8SLPWvNDWSsYFFYHpBeeZNnh2ybbsDsSE3K
IPu0zlxKkxfVh+qBuHe7m5RMftuP23F9ZJK5KN8CWTfb3vjhi7EtRVkkOgGhIxK0K2h5uVJp
XN0cnD40edsGmJmiaBbvvhZa2gT1IfqLns5sqX--0xABF7jOu8G3EYSYzKuZR+L26mycGxEO
2nIW0olSEv1Mg4Qn1VgCuUsVen+-OQ3UpCC8xFgHi+02q8KMNViKoGJXLlHr29fuC8Ie2Xkz
ipRNrzvxdqbPs8VXxFZYB+u39Bp54dQyaK3bC4m4puSqoDYw4XKPEwxhreN55PDDw8L0FpV6
5++vqDRiE1yExRsYevfB3V4b370wsA9Y0zuS3LmBEp73SNqYeH8JbFmALL0l+sHFa7VKK2q1
9LppcNrfLoQntgYmiYB0ai4cPiXQwv250VpSwqKIs1nqY9e3i6HfgMTR7H2I2Pym+eeaX9+b
m7MsAgwl0V1BZdGH1SIo0688qdKCRDS8P2k49ydjA96kcHuVumlkELkvwpI5qier3DTNNN3m
U4Rrazn-o60XK0kow8epDVXUhZ+Pk4Y45hqQfe05q7Xb8cmABtqYsgPDWLa4tmjD18RfpYCB
VB4iK2g3qJKZC+XgcZOjPRHolqs-qWfbj4aaC1IhkgbcVrnc5ewZ0nUeUAzIMBllaax4FTOs
GG+n71GB0Ll6pVa1WVg+cLmvwhCDJVDBVSxcGaUu6sL+kS+elDdsa1471q9gMs1zdlx5Zhbl
Zro6XUBl88DgyOf84J25LvRUCLptAvaxzb+zhMmzCAKoCMYbkJ7PkuacC4MmtorZaZ0BxXHU
T2M4t4wYOhuu3Ymwp-Pf+SI5Vy6JXiz3tT9aaodrK5jPcOvyBMjERQ3Z8AD8JcrMuuvH3WaZ
yF1A-5NGrbW4TVseAI4VgMefRBxlXEuKAJe7cr7UbvQ1ZSpKiKs09VUfrvHkNZikBmpKdjXz
nqxZq7O+MIeobRphu+5k8bSiJnp6iUvLEAaqJgQaK-QbJrY16BhO6NhiaoXRCXnzVbjjaqIz
0im7pZsjdWdhamxvOqaZL34RrYudoh53R2H-6JpvjVBnWyXKxiYhyTvIwSDJWrYNv3OjPUAo
x+62I5lUYA-xUyMmhEbf+Fqxri-xyrmVAH2sB50ck7mcCJ3xH3G6ifYDBTX6huyrJyhCKpxZ
cDM-VNx4r4Z1VMKcxxV39eiyFI2Y0Zdlne3in-eQrMTzEpA4VLZhhdb2IDvPQICBeP2Fza2i
lfpaHDo+NfXVcFdIqW6Eztnvvw-yXKFF9CqsErnJPwIScPcO5GOfno6gKdfHOQRIecqJ5zS6
xGO1US2oIo6H-Ue9FrIthi7hWnlHk8+NKYnzuSGnKwzvETpb7WnCPYTJ85pSyvh6Cgbnp6nb
+uD1-LgNuhb1M-2ysOgqY2QVK6E8JNI4Xgw0YA+4zln+rRGWHMGBegfxvi8rayb1zQT7zDva
zVq-XS17fpS9ykSwNHSLw95xdjKg-e0+j4Qs2cSeJQK3PYZivjzlxy1xvKmAkYahuQKi4RiD
7HIj5KCmr1bWdCdnH4QEEBh1cIZ7Rp0bvj+WalSJI9ACEzEVltpj09vc4q3X-0G3vSzkRqzC
YCOW4h82KSm6qcNN+Ir79W+D59sD-AaN2+Z25AVnN6aQFgZepnUEiUyDKTIMdT6ZNwyOw9xH
3FstxnVmwY4uFlabduS1heNL7s33Xy7IdGhjt3OvmIFRNJxMsnPreiNuznObeW+uTYaW4fOP
90zk-sGUc-8ePzE+15C38M3YxBZQQZkRX6yvtpIy3PeQQimXvSiQF-jqe1aboyZfDi4DDbp2
RTOoxXTaRsQgzjGsnqWopmyUScBiLnUhZFuIDn9-VDoAxF203eRPxcGBkkGIrP400B-OkOwv
MGsFpe0hUvwytafbCKTx-iTtbj745pPybr2Iz+yMxVxEGkA23+++++U+oZ7X6OVEXGf1-+++
ZUg+++k+++-INLBoFaxmPGtYNaq3JYpnsnEMJin2Rft8mw9gn7v2fSkkOEg9ErQMO7eqqwsY
PGMqqxoPGeko4an7Omh7kqaNsQ8Fbw4BuxssQiEbw0Qs3wZmzB4smmJKdDRx5ibxjag+tqko
Q2th-yljzx62k-aSvJjCBDER552nyJPvSAcpIrRMc1pd5fDElS53VB4cqFcHSlJlv+wkbHT4
N2+cwQZD40FGBZxtq9H4YIrcXJXpIA+7csMpuhdEEfRu5g4IbqBmAyDuMOKdzZwHZwzoppfX
X35SuH4DVKNfsZoHuf8ZUqxtAntEOhezxTXT7T8loFvMo2MoUXMCmJHdlvRcUjOEr46j4cf9
owZAyu2VUF86BX0QDVdXnsVz1y6buv+Wrunz1KfeEXgJ6t3zNbLbbBbWeJPue5RDcHD12MPH
CNr65MV01B202EyBDEkNxJNkGTUAebR2wB8-nnfvY6JkHcKpojr19tIkaQ9FNLRsrXbdxm47
AelCPby08-k9IWMk6C7klbbkT4xjiJlqT167KQGaj1BVzhuGo0wyRz3W1kJ2j5kjF73MRKPQ
huu3hut13BE-g7kyWTUliqps2HyZD0EsIU3UlE2+ZGqoBsYdx3x-so72kBeEZcD4Jx9rKgKw
cg8RYlzB1n8cS+A+onaSQwtcSwnd0pn4MxrXoFubVhsydLATmV-8x17CY57yK20yFvgZ1bgV
FVn9wtLmxZhESC1fHS8Koc3M8aKYKYfue6VvXvIZHYxRkXQtjruMgm2p38BtGeLnLGiXpZDe
bHlsEZlrLcFg5UVbPhy2UMoxDC5MnSWJeTIzBi7PzlZY5BJpPXGxgTRxV2CNO5ZLTNHQTbxx
yrOKu38S0baE-laW83e8YAi1T7O+R2d+pj6dW0J+ih48Hj66gkHVioq2RWkA6svsD5eSkhE3
X-rj8NlV5YRz-p8U9Bi9rVE-BYEVwdKyzeTmtbNmYMgGPkcB4AEe7RvI0htAkIj0u6EUvvsT
hOC5SOhGcMGlKa-AIFD4aWAXegZjSR5hFsJbfhNo5yTmo-8sAoFjg9aHIpRPSS-W80XUrErU
pZdA+6F4tKaim+1ER2P67GkCxGM9i5n3U9b7LJwJH7B0Td8OdWvZcGwIHB3ctXuBB8oi8xe3
eAarKeIhpt3c6e5cMJ53eBcWZ6lO534t98YJ5KGLFgPiSm91TZxY3DDQjVQN8LBR57s92ww1
FKhdVEEjsnKZD7k57OFaGfeJsdPIvutcRUjQMtEeobx+jc1fjsBBogRl-ISl6VGH-AJlkwkJ
wZeVY4QIOKKHLScZkQiqhyVZ+6IP77JQTpD7SZJHyHW4gRMCrudYWG91B94KIMyznWf+3SoC
U2meSM6LN66V3oS7QChzVKa4z90kcSfF+r9+4a5YLcbNk4eT2lSfYWvoQZsnuh6gmSGpW2Ms
M04L8HT+Dai7ZCilM-J8QmVXzOK458iGKCirp3w5xOt5PeUjacxdQREHLlnKsaagSbTr3eEV
oysHWbAdoZuDRz1ZEKTTS99PylES5-ty-QQfS66Ksi7kk29ACH2STSDuObZ2+Vlq8CPTtf98
8jPg2NN4rCmTflvibph87lsJJX-LCSe3fdp19dYJHcGRmqO3s1qwGaSHhp5UnG4jYzYzI2g-
+VI93+++++U+bK+q6P4T8Oe3++++lk++++g++++++++++E+U+A0-+++++37VQpFZQrEiN5-m
I2g-+VI93+++++U+8sIp6KyDYh3Q+E++P+A+++g++++++++++++U+A0-fU+++37VQpFZQrEi
QaJnI2g-+VI93+++++U+t3FX6I16Z9PM++++A+2+++Y++++++++++E+U+A0-Ak6++2FTIY3H
***** END OF BLOCK 3 *****



*XX3402-013859-271197--72--85-43964-------D_RAS.ZIP--4-OF--4
9YZCFZ-9+E6J0lE++++6+AJIMm4SD45uMU6++2k2+++8++++++++++2+6+1+UH61++-mNK3Y
PKIiR5VoI2g-+VI93+++++U+lp-X6LeSkJyM5U++8e++++Q++++++++++E+U+A0-j+I++37V
QmtkMLBEGk203EgI++++0++GIaAVXh1gqzA8++-S9+++1++++++++++-+0++k63t7+++J4Jn
R2NjQaoiQ43nI2g-+VI93+++++U+oZ7X6OVEXGf1-+++ZUg+++k++++++++++E+U+A0-ZWw+
+3FZQrF4Pr7h9aFaPJ-9-EM+++++-k+5+6c-++01B+++++++
***** END OF BLOCK 4 *****


