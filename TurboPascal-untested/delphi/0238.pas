

{
JustOne v1.1 - A Delphi Component
By: Steven L. Keyser
    email: 71214,3117@compuserve.com

JustOne v1.1 - Added the ABOUT property
 (1/14/96)	 - Eliminated the AllowMultInst property
             - Eliminated the EXECUTE	property
             - Added JUSTONE.HLP
             - Added JUSTONE.KWF

             Notes: The ABOUT property was added simply as a learning
             exercise.  The EXECUTE property was removed due to an
             improvement in the component's design.  With special
             thanks to Russ Chinoy, the JustOne component no
             longer requires any code to be added to the user's
             application.  Dropping the JustOne component onto the startup
             form is all that is required now to make JustOne work for you.

JustOne v1.0 - The basic stuff.
 (Oct '95)

    Purpose:	JustOne is a component which makes it easy to limit the
    number of your application's instances to just one.  If a second
    instance of your application starts, the first instance is brought
    to the front and given the focus (or restored if it was minimized
    to an icon).  The second instance then halts.

    Credit where credit is due...

    Some of the source code for this component came from a Help file
    I downloaded from the Delphi Forum on CompuServe (LDELPHI.ZIP).  This
    Help file, called Lloyd's Delphi Notes (Lloyd Linklater), lists many
    tips on using Delphi.  One of the items addressed is how to add code
    to your application which will allow just one instance to run.  In the
    Help file, that code is further credited to Pat Ritchey.

    I took that snippet of code and put it into an easily re-usable
    component.

    Additional ideas came from Russ Chinoy (RC Software) on a way to
    have JustOne perform its function without the user having to put
    any code into their application.

    JustOne is released as Freeware.  If you use it, you do so at your
    own risk.  Feel free to modify this source code to suit your own
    purposes.  If you enhance JustOne, I'd like to see your work.
}
unit Justone;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DsgnIntf;

type
	TMyDataType = record
	Name : string;
end;

type
  TJustOne = class(TComponent)
  private
    FAbout:	string;
  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    procedure GoToPreviousInstance;
    procedure ShowAbout;
  published
    property About: string read FAbout write FAbout stored False;
	end;

procedure Register;

type
  PHWND = ^HWND;
  function EnumFunc(Wnd:HWND; TargetWindow:PHWND): boolean; export;

implementation

{########################################################################}
type
  TAboutProperty = class(TPropertyEditor)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
    function GetValue:string; override;
  end;

{########################################################################}
procedure TAboutProperty.Edit;
{Invoke the about dialog when clicking on ... in the Object Inspector}
begin
  TJustOne(GetComponent(0)).ShowAbout;
end;

{########################################################################}
function TAboutProperty.GetAttributes: TPropertyAttributes;
{Make settings for just displaying a string in the ABOUT property in the
Object Inspector}
begin
  GetAttributes := [paDialog, paReadOnly];
end;

{########################################################################}
function TAboutProperty.GetValue: String;
{Text in the Object Inspector for the ABOUT property}
begin
  GetValue := '(About)';
end;

{########################################################################}
procedure TJustOne.ShowAbout;
var
	msg: string;
const
	carriage_return = chr(13);
  copyright_symbol = chr(169);
begin
	msg := 'JustOne  v1.1';
  AppendStr(msg, carriage_return);
  AppendStr(msg, 'A Freeware component');
  AppendStr(msg, carriage_return);
  AppendStr(msg, carriage_return);
  AppendStr(msg, 'Copyright ');
  AppendStr(msg, copyright_symbol);
  AppendStr(msg, ' 1995, 1996 by Steven L. Keyser');
  AppendStr(msg, carriage_return);
  AppendStr(msg, 'e-mail 71214.3117@compuserve.com');
  AppendStr(msg, carriage_return);
  ShowMessage(msg);
end;

{########################################################################}
procedure Register;
{If you want, replace 'SLicK' with whichever component page you want
JustOne to show up on.}
begin
  RegisterComponents('SLicK', [TJustOne]);
  RegisterPropertyEditor(TypeInfo(String), TJustOne, 'About',
  	TAboutProperty);
end;

{########################################################################}
function EnumFunc(Wnd:HWND; TargetWindow:PHWND): boolean;
var
  ClassName : array[0..30] of char;
begin
  result := TRUE;
  if GetWindowWord(Wnd,GWW_HINSTANCE) = hPrevInst then
     begin
       GetClassName(Wnd,ClassName,30);
       if StrIComp(ClassName,'TApplication') = 0 then
         begin
           TargetWindow^ := Wnd;
           result := FALSE;
         end;
     end;
end;

{########################################################################}
procedure TJustOne.GotoPreviousInstance;
var
  PrevInstWnd : HWND;
begin
  PrevInstWnd := 0;
  EnumWindows(@EnumFunc,longint(@PrevInstWnd));

  if PrevInstWnd <> 0 then
   	if IsIconic(PrevInstWnd) then
      ShowWindow(PrevInstWnd,SW_RESTORE)
   	else
      BringWindowToTop(PrevInstWnd);
end;

{########################################################################}
constructor TJustOne.Create(AOwner:TComponent);
begin
	inherited Create(AOwner);
	if hPrevInst <> 0 then
    begin
      GotoPreviousInstance;
      halt;
    end;
end;

{########################################################################}
destructor TJustOne.Destroy;
begin
  inherited Destroy;
end;

{########################################################################}
end.

{ the following contains addition files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members.

{ ------------------            CUT              ----------------------}

*XX3402-010809-180597--72--85-23579-----JUSTONE.ZIP--1-OF--3
I2g1--E++U+6+2Vt9m+hRtapiE+++5c4+++9++++GZJHJ2xCFGt2Ep9hXnoCkX+AVJwvI2N4
Xg162JVM440Ur63Xx0URScxat-+QcWAGHkdBofysXO+XIdyR5ryCP2T5G2yrOrct5v5Tr3T+
1g0qKF5KA1f2w-KpZx6umh6Rlie9IUfeeJ+x0WlOhCVzJ9opWXl5ZaJpd8p1OrQMAuXSYe-S
pYOVk5tWJA113+b7-SuteAn+l+nEk5jCezCnP3rOhWGvDal4QNZyf7OvaADq5GSH8IvljQ3v
ihtH5q9mXQzE-p-9+kEI++6+0+-6SGwUzS1gXW28+++E2k++0k+++2dJIpFDHYIiF2BJpJVx
P3DL3HzLTiztCRyVe2pd3tme63d-WYgzEXxkgWGC6I-GYV1O9GAaj0N4WNrOns5U2h64I+62
7f300aipOVIPUeVzg88qqi-pclrhVZEBOIfvFsKeJICXe7CaTeV8szrCTQyCknNdoWNBSy5s
rDBlnnrrr5DiDKpRPNiTw5p0bPHEgxjnNwzbwax2DufzK8zrRfceZ06eQvDCCyumSPiIIEet
uBzyViHj0N4VCsFLD+DeXpZC81huqlYRQxhs6z0LofRzxioH8oEiDLyCJyJWdngnJXpfYUYn
3XK6jXXsdPqAefIA7YmXXyW-6WwMy8TeM9KNYRs2ITJoiTXGNfN5ceq1zEOMCndLkDgAgnYS
uk9nwux0chlafXAGWL+rOruriEDSARBHqlhC77XrlREn6aEfBgH1zHoFbjrdlzh2VwqgXILB
S6kLDrbl-492H1IMWzS-QnYs8TPNxicWsRtMBrVzySVhQQ8SKdTcXeuCaYwHjTYCoGEnLTah
ukPfkaOMTPwiPZ+uXTU61jhLEfUoV2+s+LAfuwBxVYto5Q7TmZ0sx3MCKJDIKCmuEJvm9ZBY
TCh+2LbL8L8WHSbYxWkE9CplvLHhKRYXZcAryxb5ICFELYZKiXy2zcUKfBYGGtfu+dUuv98L
JfHOi-2q1LxN0PUTO2j7IwXanYZj-FLZxEWlouJsuck2sXLsF3YNx3mSuPGhxq2q1NHt1P5K
K5DQ46X2YcbJoMENXbMNdPcDyWwW+9OypoaHQmv3qx6Hqmsx8hKLECYJBOBIuGURRVKeIY5M
nWt+K-bgOB+ko90xje7jA9cXm90so7S1xgU3ZNmsH+eLqVleLpwrtiPHwI968Mhm29O-yaWm
9tWARcbw8h0ZCEOS3Llsf0ZsgdVPN+r8zu96L2KhAX6cWrsXPUtiJavEvH7l4i1o9WIrQKme
ahni6WZxFHafS1mLlJ9kb3-aDnhlfgW7oovw38JyOwEg9Ej-YYzJbICusYXD8YdVUq5Ka4Mw
gWJd4cbGgaMcDesKC6fHmZLpgVBY84sAxmOBof7Bo6adRncuaIfEtDVSpGuI3eDruFcB8l1l
zZXsZBckJrX32M8ZPH+GmJtHdBDAt2JtlY3pQCuAuLyMcSN77fiUoLZcLtwvUtBqgOkyhvgj
oGocnFlKDuq8setkD-v-FPEtPdX7S5E8SJ66pExIIR6JulyAFvdvnAq7kPshgJuKbO9ABgYN
VPECPNb4lhiXKmjmN8vMSSYiO+r5ikoHxxzKqDM8HMcs-rBqyqqOaNmXRqVifvnzy66F5ojy
a5O10aYqeQc-ryRAdcKGNcyGaVrPQxdDhHbvti7qxdrDVQp31FT3H7cZv88xYQzhOJdBozOc
2OwcEC4Gj1Yyof8q1Xiqv-Y3bXY9bQgiF8VBiw07TD7rYyBtdsCP5Jl30MafeI1SJ045Ly9A
wnbo2UTPpyGHB02jYAScHC9joOX2RqASsr7UzccRe+1BAKgLPx+ms0TUFsDoNcbof-tqys3P
UDQ-9sHywNk9i6em9lwQa5rlveGQZwsab-RCcNmL1TKFTR2Ua5r7EAmyM+dZLWsINzP3wZ5C
GzJvmfn8GDFZrjhwyKjOKZePphRLBhSog8ALNNZpM9ENPsXvBcJfO0j6Pd08si20uMLx82jb
8Jk+0TkBMeT89PBTjg6rr-XCt00dd5nb9b7l4Vu-cOBU3WgZJ5k9SK4gW5DcJT-zFbaYeDB6
8mUULS2wCEji9v-KuGoSmjDEPNkStw4vk4gL3iRQWNyE5xTi6vWT5wJZ4O0RfVdYKWoGeUvN
Ksz81S6p0S5OPQFpjlvposEfg+pvPQTBgEZZzmH45FVjlPULyUZQ+2YIvrNQ+XgkPklnXh+R
KVAh+rFc9w1iemWJYpXb95qYwJfb8Jfs68pKEjEbJlApifQ1Rh0PyW5EFyVyxkioKnx43QIH
o5YNJxUdXAzFftErsTx1RDnC3C-Nk0v+24+rM-Xk5C-tk+VU1nqty6HITwup5h+2C28Pxow+
buGXUtBGJhYyEKieXtBSRMcOCwzEuPqHS3FSYn84Pvk-E0qhelo5DYipepubPOigfDkHSZW0
RixSWHxHqyUruWOuBvwHS0hhI5hc2b1VvYC67wSm+r5jFBlE3cXV3OI5i-SlX65DgRk7G04S
8S-b+PgkrUIw-1k2j-gkX3UD+nw5S-vwts35+5gkrUCw3vP4+MRUyn1KDM6fwlXCN+7k54T0
Q+9bwl9cZm-v4PdwFXz5qNo0NXUBC+CM-9k4CNzRunX9Bn+yHszUEfUiFWZ+ez2QXZ6PDILQ
Swxy0kHx3vtgcyT7XaMPhom3qWjZBXiNJgTiVatyfTyHvuMqkbAHDOgsqxGrXLquXGsCOJcv
LrEoxhh1jrO4vvqjo0LIufj-RBryM7d7nl7dvltAic1JqWwCtKbhDKb8uVQuMT1t-jmJTZ2s
jwMLX-j4xb1Qw5L3yjelNBHAewowd1tlOe5Djr9ZUojtxm5TZY3TWqYA435TqYdTcn4MAC6y
MpZTCB9fSxVzjzy-mVJyzwDJP0U7oM-FWS2Zj-PGaT5nZ9spuoqKYf9zHpMqf4f9qYVLctoj
ZlGm3RwUSUg53dkSqnUnDXFxOzgqSyQEEhHQbcC9gcFhwbQ5drtMXoAgDnEpwdZjMzivkKx3
SW-jqnRGz0VSxSFxcAS5DcPJQhgX5gB8iKr0OmI91kHnY1W9lpFAdzr-PnTzMDndaMIRuxvL
NBvsfP5UH4PRwO2NNnwXEnBYyh61AssRgk1XPJt7LRQnTBsp5-kSmWBH5zZAZwnoE33ucA-j
BQzauwUez7WZgkmz7N4Qu1aAbMlQp+s2hEAPxTTSnqCHQuN9BRJNIPitb3dfyjhv6ppVAl89
AXpeQHil3fWAy1IDK7QoPXM0pUT+Gs4bBCsA+hNJs+S+fqbQB+GgfnJiIU6KSPX30JUuQ-pk
0L+6i3bk0lykCcJgQOkZO3alViI1bUxQdL2f39+aiBiWoKe-lYY5xd9h3nR1SN1vLT6OgOud
rDmAKW5NAcpOr4Mh-SMatn38KJDGztFpJPNK8SgOwHtGZWvMztFJ6hXzZ3IaqDyIhJmkrmaf
Gf1T8EgCQ6jq9zlAmLLNnp720rtOpKHnOzUzUs0tVwo5bxitKu5bZzdYQTBpCyWJk1gQSdyY
WyV5Z4zpMBu9YWt-dq5HNlntKktxkO2jCzET79q6fXfodt7SHbxnu8wZTHxdkePnVHrzRcQi
ZzE4KifETYQSQCUu2PAgl9o7TBtT8Sndxfu4RPaTUDIHbDAx004TGmLGXf5ToLj6oJh7D3yX
JQ+Qfpfk4EQFflocyYNON2oJg1qeRgDTVO0fj4ljhBchaxBwWzxToyCUeqEyX+sn9cHSBOlz
4r+nYaAFg6v1KU5ASTkstsj0SU4fn0BPPKZzAQu5qqszbvCoHr6RnZiTlnujjmdgBzDx5J-9
+kEI++6+0+-6SGwU0-k9azgQ+++BBk++0k+++2dJIpFDHYIiG2lEvLdtM7HJiTRnrdZA7XBN
7U2G+U2C0F+06In03UVYHm0EY027CocaAqwmEmMnkmm26A6Y29Oec3G9haKUOjJWPOqUSChG
p8ehIh0KihM3o9fE8fPKGeLazgvvnWG-vxvjuyrLSxgzyg8HgnzPSQtnbbDCZ8nJo3e7e+xT
kWmWSiGf+JF7lDcMoFuuVEvHLLG2Xh9Xx+hubRuVrt8F1K3dP-EPmuOl6ZPCOhZONaBShdZp
gprg-bM9itIRMjSkyxUlxWDq35i-bKCzMFTMlynrv2zgGq1KGMZGWdEeXN8mdAbGB8Z68dBe
d0LGAaaBN7LgYZDeYBN9EKaHh2LeYLeZrF7ZyqFzkCCH8Mzn7cTAzGHP+YuDCvSAvDOmMA1V
wJ43dwDfQQhi8O+r-FhZrkONJrXQ+Sg2QfTJwY+-NJjQUT5YdofNtLIs8s53tbBu3tdsBLZw
r0s5fAt19hbC5OC71uKEoyoDK3qi0aX37wiRJdwg9GWYaZPStEbm4bSfdqNAApx6ELyUrWoj
L5eWgOZyQJJScaKMSG7ryiCwT74ZmK3mydTutsOKmHuRzqiaJGOfrGvPBJfuUjlKZxxX7JSb
hQhjRRh1JezLtPFNyonIsjA2qlk-awZXZqqolCOHxLNbs4QKqSqkYhgaRwXmFay4mrc8Qx3B
LdwbovMQWabxa3eRtDA5KXqyJhxEHsS4r3CMmyggh5bQTqbKgYdmijI-nvfrm4hpmFE6m3uL
PDLft-f92j98jY1LI7yQmjACAszPDjOS7LtNtXwlyNrXCfkjIB-rDEKgiPv++TNBthCGoqzO
Y7xbpZ-ydsCQBYSboyLe74T++SpoSR-xedNc+Y-PZ0BdGPhdia7czFwdLlzgX72FiO14e5HM
L34zi8ZeFFAxCsJcQoLHWjeuAUgxZs30BJdcn2XY3WojPqeceW9588JEKRNIFdDIjCWxL4Eh
1dzJ9zj7-CGP4pQqBZLJoIout7je9HIJR257BhKeW9sl5eKK1XDxQEOFlo-uUVUy+mJFN3e2
gFYcXXcRY3Ko0rZ3-Gn2omYepg2E1-F9A221lNBWDNUg+yYcc41o-RptcZHX3eK+klcEuE6M
cw1HubH7iK7wk049SVgaru+eeKeA1icqE2qhEFyOTE6zf+746RiXy4D76V14IsAnM5D6LEed
iWs1tATo-rnCZe+eEmlpKc5AE5tbVxTJ3FoTFpuLJP-v3ERuG09OMwUegDjYcBzOsY716Xec
0ms+KgCcn+tyEA5ekUepihgJ4h3Qty1aU397qnkwsC2BEPyTJnWQPYwLbxVEkFgxfE4lpb6s
n7Xv5JOToxr45Isz3yOjK5z+ntJdsCX4bKuP8sUpVEkEcthD3YMhkp26-U6F-bHItVaM0Y3I
h8doVQkUPO+2ueQiug0+I5e2-p5X2BCEF6As4KEHgMG-uhGf9+ZungVYWs30Smdj-YcblHT-
WI2u87mfHelTzEO8JgGHK6T0KEVAOjccKFF2j3KKLPkJvYacIX+e0yzY4x0J4wd0oo9JGo2d
BE2s7qvZmin9j5wCSGTKvY-xkCdjnyKk4KvpwlfigA8PUUxrfa-Ke-os3BS36GomL6aDcwHV
m89pTUzosp12wr-kurAfIu6bkPCGUio-uvg4VhsYfBqZ4EOLQDR9TnNfYGNEV5Ii3UddG8gg
0MYaxnRIS9lRDWQQ7jwyntsx6lRzNj8K9huMJtirGCvmmnuODdFcwZ-GxvdsWblf+DYIeLJE
d6Gh8J6Zj7HWdtGqyk2rWGOKG-ODrob0adQvrTNGHyT2Uiat2iLfnKOnpdmTaxZ-JeQvAuR8
X-g-W6wWa0MmT4Nc7cII8Eu4B9G1AjIVUNXo6GqKJExcBbBC91C4V5SwbVDB2Aq7IJPC+P6-
7XsuZ33dTWkIkkd9unRUmrD8IaSdWPv5V18Z0BAWgo1E5LthuBxYqaHdCRx55l5hvXZD3tPe
CBCNdEGnNWU5MHPSmZY7cuqR1hbBqJHA1aQvKK2iwEtfiynbnZ0+kzGuS0fdLQuC-47-Rn1I
oE61w9FC7C2jgzqQfN1wrAGiwGUqlv3dBd0HNOvAt4mqQmnK+RZnCQhewHapvXMn-RYWhd8h
AkKN7NSrCOIBuwkgqCel-GJz1gpW+HTrBni0ACIECo1-IFNOgQMwnvn4qy3o5r7qP79hRtag
***** END OF BLOCK 1 *****



*XX3402-010809-180597--72--85-37606-----JUSTONE.ZIP--2-OF--3
HpDpoiTByOOJn3Rbmhf5iiIBPtYcynejpVbs2PYxjUufrgIvrlz9sNX9+oxWLq0Ht92p-SsI
QfaCoJ3H3Ygdjasgax+n3ajH7-NbVhYO1CWl1CwMWlrQLpMYkQqoSisPewlXEaEeu2YdMYVG
I1BUCrqMCvKB73FLusHhH0f1rr2IgGJFfsnY-RfEUVKNog4S4YpZG3STgiqQxfYZYlRkhhYV
ARSMn5I0KEm4D0ZaosJJA3ZM2-wLActdGMax8PCbFwdYPXbxL59EzlRyG4doRcHUrfbRNvpI
eWxVxKZG0G8pRqPNTFvjw7Gj81Qnt+huCOjhiAG4kowr7SQnnXfHDaTmqDfYtKgmSrr-v-Pd
agmuN7jb4iM9YUoF44TRPGMDxkHLGfBQ5eqbrNAWr7CH9InlyiEBHYxkJdiod4QViFR7vU8z
NzYGDenVJcY5Iceg-IhWuuHsn3qGkyc8m9ykboha6s7Iy5X85ibfbRPeQiTwbePQzNaviZjY
EgaSnPD6a8VN2P7AmemYWAIf0bh+elN4DO3Nz2GX6xyV4KbpYQm1rXOTpRthmOlbaz9mwbuS
FPR-OOy7KF+8ImOUI0WhC5GoE9AU2B8LXBCNEr3XatdR5ejxwwnNf5npQYpmHKJJmN-+v-sq
V8vHK3oyqLe1jSjLvBbA99NdhsPrRg1FjMesGkzTaEmRPPBWQQVyjvJB7atrKZqSBetjwKlw
Kf6XQbXaT25bXooRHjxwLYUV2KMtNLzhq8RmrhJsqepR9p8gZhgEMfFDoaPLoDn3xEpJqPm3
-kA-Xzg09rCJrHyqZrKvtODHT0OtkvD-lc7grdBqA9jJNcLaGAeuGGhjZ4r-EBRgtfNjo2tX
AqDQdi+lTz+CHJSftcTOuiQo4LYJ5x-2yWLNg3W0jexdeK2pdsSpqruWSMvpgeZguqRIq47h
SIhOZn79ur7KhgjvVyLbJPKPWmHGXdgLRK70xxhoIJRtEfXXW8DgulCKjUoCbJs+f-eCe0uj
QWdWGS3v002NJIQPwmS8ZO4NwqHXGabIYsoliujavTidzvXcRs6W-5dWWQO9AVwSuaMTx1uJ
BKbNAwafvlfWTJ+f-nE3v3LgBZrQ2pXb82cizbNAqNaMAql1jBBSn3MDOQIShRphil0nkSff
4h3U2f5B9Qah5hQB9gyca1vh+XzDof4b7BPP7fhZLzTagSqmvCLyRBpqZzIbadd+ZxRIE6FH
2G6PIdbyRn-2IsHxH+d7Yx9H4eG1Nvin1arNTdPhqu5RBWGKeV512Ok46GF+dcUI2zJoG-Ys
YtuTyO9aYjPFJ4sdOuGaDMt1ajJndHeKiILLj-8b0ZigveGKTwOuHihgtuGpx6eiNc8NJpMg
zHbxNjlp+ZwjFFWtIkzpIc1cPX8i4SitK4FeuDph+JgfyP5zXoySIDC+N2lpiZyTYAJq9KJP
oqCl+vQbpxSbnFeTcZgJKxj-wkw7VBw3HAFiH-JlE0Wq3wveBZrQp9moO7DZdJ9v2ArOwRRK
NNShe8nArdrxPwCixQNqHSMaszXpDsXh518oHRvK4DjywV8LgwLrCGAygO8ynZ7PIpeSJpZF
awCmOmaWh1g3XPqUAILECA3KvTtoRzs0Sup3Bxr8NwlConSmpf8ROBciFUVaIUpEKtskD0ai
xRDYZwgK9OyihPH9LKPSuT2RpfMmqTr9stfPx8nrEdfh6KZxaHSRpPEw7CpbvooDTewuTnNz
GBT1VteAKW2Wr8T+93Uc3c3pZV+pBHHOQ5zucPVjtulCzuBcrgkIkhWdMPv3WjYh13qGPikh
nhsvlvFzKDmy7L51KD5HkvzlQQlenNlovx7VAkibnEsFGpu8G4BKb4Zyo4bz55uekcnsl5CR
fap-wf7mtlh1CMifDPVYqGxjMkRWqTlfHA2V90IzNI5flI7nOnC9KuvrCEDf5eWHTKpHHWp6
zvJVHMlz4JTwb-9n30AYd3JU8Yisg+kKp4JoFk68DILsjR2MLNVJag2lX0UcPGzUnxgWX40d
lR3xGC-w6KFI-vtkM3VQI9RzpMGTPUm8lfPcmB7sdTiTeIxvOhHefmdzeji3Jai6ypYgGyop
J0CWqsUkh39zOi5n6oOOSZwvc5TYrdmuHqxjpIwrJ9lg41bCtzGrTtJHfgEzUd+sxDI+OTOx
8BpW95qZuDJPqeSgpxYnXKZJNFwOv23BVyuAgFDnwEO9A5+dcJHl0TFknD48ZrMOslgFMxNA
1dOReClW7HPf247DpBxeD0BR5b2qvL-OzJhdQFzcUVqPsXUnHeHOmedOms8Oj-KfOWl5VwGC
HlyGMaCIOiSp9YyLzL-sND7WHy0YQO67+IihoxpydovqBSLYbX5uKskRKOa-iIvjov4nVbow
8Jz1upx7BLmPJoYRvljBRaBZSjgYMzh6yonxDDDQcv4gi1j5K4bItRsLxpdOoBqJZC5aBlNy
Yzwa9HayhGbcqnynx72WmzTp1OLeIOowjiudfcRWl04hI9xkt9lkCfjHh2VnSrKiTfIpjIUT
x8QATKAaYL10Z0OQWj13An4DqQ8g3mLYDT6GovOxDSLDleA4Rvh4gmiVFrHR+9UYcdF5o5LQ
-mWhWzqhwzXgtdOsihb25n3AHqU6vh3KaAEde1M4VmyHCDyMorAsqpS5owGTAfUXPdGVQgik
fMMFsZFH5LkktQbVLOnBYBVja1B3L0eA8YjMsTMz82tHC5e398IaFKCX7tGvdcVJ8a4wO4h8
kdmSHGPuxZlVYXE-w9N+qNEIqGSOsahjyS9MFYBqFb5wYgqbF8Qr6sAdouGCADAFcIRr5LUf
oS7OPov2iKX9TYfSagNyLSZyAO3Zx9pdBPKHfoywwI-uGKX2XZmQPEtCSrCzgSM-skW16RtR
bBWEwGePMHpiy9LSBpFuCwMmWwrkJqc0Y5HbrLb-q2+8BQfiLlZiqLYthYACahUgJonmPsk-
ntmGAOK06L4q2+lHWoZlRkM8umS43pneBaulPvwIRhFuh0BjWqAuPIjeAG2kNJ82yyy60sdQ
gGdyCX3ISKaAFGdijaQ-PbPAQqVKTY2cTrfihDnwKNwZoGcWlFoeB0s1LVH1GaVBmQLoGL5D
l9XZfmJBuP+upvYKZiMhB7KyCTlsUazs-Xbj+zrV4836lE3yFxm5X2hKz7x2vrpCB3IoWHIi
Q37XgicLSZQMIZTQLSJStlZeM3z2h75eEtKVDodK06DblO2RZgArT1rSG85s6vaV-+cZIWXd
sHKx5qY1DIYQluwjRRUICBKGZQcKg4LM3RgA7h9mbBHov6U38HHDVZGSOATbeeIfsMOUB1cZ
uhLa1NnAY+VdZ9MpyCAM0ijPwDKxlR3MEtWIoW74HfvXmrqdxwIqtevQCZho4-sRSai8I1ta
vl6njvPkox+ElxPh3pxRhKm1yMp7moH6rQP2CF4x9a-P9p70vgfEuKIHRwsClQKyLPThTBx5
PxMzj9aIjFLTwKn4zEb-BoSY3QswAr9VBDRLYgTRBbhwUZgSYTteSccaiyeR3JIJGthq74EZ
DJRmyoD1CelzX5wgpSDv9DI4ddqPRXGxVgrOQ9gnNqGJutnFjGNVYmbveP6V4LJ-Jy0HX8Ko
GKsSYppI7xDOAMjBPWzD9ahtCMZRCxaoJSQjoEoj0hOrfAC-Dg19TLY4qKQpXZZcRETrXQXF
Q3DyvBYnOvCdr1fRpfsZoTv0t7gGKtkaZnDEtQVi2-f7WGW1tY2NW5mOWIwDBHFxCbrfdeHq
V4RWKh81ATIs+8Gqf2dooslnkmS9IG6E2Me-yVKf8OPp0OSYogPgCGLlooI5HEEXTKhcp+ow
8SMkiXTdcgTjPsZ7mA58gB1wKEKFkuu0xdEMDYYtuvkPmVWysDlLjqQ7QJi4uL2ExuSjJfOk
0+23UP-9SNDaqD2ttqZ4b7aTPq+ZCSQZbJZHZxBn8Y93cJk4M-wQfSl4P67644lC79ZWWo8a
Lk83VKh8ft+U8Y7gJ+9FHVw70SNHMPw2UhXSobs7EdEVHjssyBDtfr+2lz2Tlz+ytJ7-Y-HW
98I6hMwc6UublO2Xmco-2EkiCikwio-88W5RHHrbBG9hIGsEq8F-UV5v9kFHC-hRxdxCXHse
q4V0Vzj8Z8aNrGyM6aZNjq+IWUV4-zx9kNHv5I3BkJN0eUCtxkf-k7Nm9H2Ua2Upec+FkFFN
FUwK14hM2Kl4R3Cm07vTuFTg8Fdw96y937EC5G6YgQnDBlR2fpU2QtFGfYcatWkXSZaXG0N2
ImEHcYIZ2qh6M3DEFGKvOv-Yuf1nF-Sia1eBaWeGoOG6N2cGaPa6N6dcWfAIb5qbDCcG-oa4
l-0pHB3VOcIeKLuzN6egNztemFHF3D5uoIKQzgCYWePS6mb1u5l2Aa7e8eZZ3Nwe4MqCG8MY
mhHlm-FFV9BaecV6dem1uB4mnlWJgpakgPoW2fm81K3eh2PNIzZEL88dSUyNZCivTjlWe67E
kHyQ-cT6wKdVk2XuvcLb1nBZOol4WDqii8bTE7sCQHQfvYf3nOuln6TXDXZlcKiVugUXIUIC
M2tQVmqKCsZ55d5eQ7TiQtBupSfDtS9VdOuFBpfRTcub8aQfhQZwNW2LRIcFfYVtYA7vJ6Cb
kycawIeU6r4-bsV9tL7ToCzUXS9x8Y0F8xn41V1WpPVKliiMi39pmOqBLFoh5dTuci53zMH+
oSH2NMLUXeiM1G8a56fpmdXmTm0f5QXGID359IrdnwOY1xFa1KE5yWf1yaUEVXvwZEOmOapc
IBx-hO4-MTrNY7cZZEEyKqE1k1l3esFJL0yd9iuvCbLRL4hIstxUcVeQ1XSdqxSvmN2134l4
C+NPG2FjFAy2p8-cT9RuTZLAHEkKW+I22pJW+f2U6ic2oiHcWGn8nJGI7cUOD6GVmJYkzEfN
-ny20EOeMyAI8vGeftdeXr8ffFrj2bPZjVuDIGpCgLSXIMVqRNpSePjWRO2TaP-nwT6Un--3
2T33LnRF3DhQXKelmcgLegEmKScLS09rvOX926Q9r6SWVr6TWWcSLIm1zB5zQ0u-ONaOeten
Ncj1BaruznM5zomtC8quDTHpzHQTLgtcBCf1upzlM1fc6F5DDLvpgOV9o32S1lJH2wy4L9kN
saIcyZcswAmYg-7xgQFXyA-1MzFhvZwDfzxuSDrLkyjzlwCfuUb2YjtjSc9bwPgIlFAAzB1W
fz+7zz62TpxDQ3KsI9i7mgjanmyPLrJBUW5-g5dki0+S6BhX2mWu0zFjv06KiL9H3V583Hiv
03juRrsFmoF0--50L94rWk17AbyK2W-NtVQe+N7ZzakZE-9b7WJ02gQAiYZQGCzfdY3DEbzr
HxroFIvRx+jyFuVQzTqj2DYPq8WGtYNyk8SHbc7SBh5+7qvfAW9+6XyPCA520Ig3ou+MJPKT
6wdzCb72HQGz6m681uZr7LqFkuJuGG0mRC920PfuoywOx6L2HkY5TIdtvxux6jz33pwcNN2e
5ycXvKetjpoIHWgRpDNcCR9S3mrrvFqURre+rbxKDbpJyT9zczxUzewiMyn7mrobHmBJmeQj
LlMJy1hEFjtohBmbZ2zqLJ2Sp1zGTjfYuKVN7HPETZLtzwtTwe1jsjwlLRHgHJNC188vmu8S
5juKJIPzb2jYvz+Bu0SeXGzzGFn0Dy9vlrXUTxMjFjcmccoAlQqO1FkCI0BmejB9vFDtjWEC
vzPd2-CQLF8DBKLlBDdYH4a-SIlnaSZoBMql73byJ39OnASMyYfAGJuDCSaR9lSPldmsDDJW
mEAz1WKxK2HBWdCdc2zsORzZ-9eA-t+Yfz5eQ42upNTCBRr7GteHHZXLSkO50y9gTm+qLi3K
iSwH9FydBlTWgYv20C9mHcE4siNJF+LWTZ82-Bc9uZJ7n+LpeYFrEPoeiKxXhV6+52Ae6c9j
XdibD9CnS3SMXEFA+CE-WU-JU0K+Ok3RU4v+5g1BUBg-rk2Q+Hk6S-nkAw-9UBQ+vk6y-jkN
cCg6glF+-a+WM1dU5a+yk+7M1aU4C+-Sk2N+Bq+rs4P++M+V03uukinr5cl5zjoBMPNIx9Yi
***** END OF BLOCK 2 *****


*XX3402-010809-180597--72--85-56784-----JUSTONE.ZIP--3-OF--3
n1drVxbjRe5C3aNrPEmnvyy296-8xDyoAwmGoTRLpsTNqI0MBO1zXk4Ju0RrVxbFRK3qFrCM
hPO2qNphMKNnVhb1U5aCA5gCMun+ArdPa4o3zXXEyEnZPyl+rVpasp1r7j6zE1cPPHh-rxwH
NWPUrPoRwbj1v4I+xo3LTiU0M2Gt14Bq+6wCx3s4HrRVz-k+ENtXuu3zs5c4tHy+hrGFcbwx
uVuyBgkqUwN5sDR9wDgUwfLqA0iLkyl3xBg7aPt0rpLcynnOPUOBJn-a0bXx0Rfwu5gXu4j-
ryx+unFsTEhk7zEXPEunpu4L57H5caz-ZX1v-CL7kDTjU2eojk-QMp+T5kcn5wNDE5vVpX-v
3TUS+4sPwfEdn-s1XaiVguBcTlGwtE5z6w0J09kXE1wDMrw6LQF-xZrhMHMJyjY9uaDFPnzY
O+TjSeF-w1w8ggk+vcy-Qktk7U8KcDtRU+Rx9U34cTo4XDohw5k+Saw-xriMxxi-AkCwZE6C
EKRpsC5fm4w3LpB-xnlk9gQQHCi3nK9A9j1nxZfkUjcop1q1wUfMU6GlXsBb8zegE7gJibU4
R4t3qxiMcz5EflMuSEnmhMCL+j1sEx1N+rU6S9u09TKWryCMAnrmDFX9kCgAoAt3SkdkPYRu
-DoTFPw48r1+nZx5ilioLsFBx01zAyG1cDYwybkBw-PKpar+yEFkdeDhYxMkqkjPDMltO6Bw
lP1zhQ+NE1cJxLQV5E9yFW6z1Cqrcuo4uFwlhUlpvsD45jFNUTdbkQx3h5o85Pk6jQo1566y
DkTBAuXrE6RPI5sKtExVuqj-pyw+uSWbUnlPM1CDcToJm5YGvKPIpo5iXR-V0W+Nwbo6iGO1
pfjEyHeoDMttrkSwtKWv1aCyVrKS17sCcpwVuXw2PkZ6tq3ihuCh-5kQE3odRB+0zBC+MnTU
2ify+-tq+UcVqzqEsKDAnqvc7F2oYX4Llq2jmn3Tnu5yKqXz2D+Cu6u1rDh+PtLk8u1n5B6r
6RSbs5Yyqhu1HDSUrr5kdQAwyI5vBDEz0LULc5k5qgNWX-SoRe1jUy+b3HdM0NtCUxORoDBf
Y0oBz3S7Tc-HoC2exCg1ncb+gF7x7AXt-TUz+LkfEPg+xQL+CF3x0Y-j5TGq1nUmk3AByDkE
TLfE5c-hDUqSTUkNhA0H1Vl9A4MotiAMqhxMfzfRSt4jVTkKu5+NO2m-LLk4Cns6bAi-PlfY
qEkw7n0KUxuf++TmxoALDs-CYw1DiqVT0SV2yEvMMmRsNg0J8zeXvZSE8FRmvsKwDR1jOyXn
8CXx2fkS-CoWwDQ5h-SVT-PoPU2DBsB47rWw3yjvTOlhByFt1TOl5bvUAaVjVxnDEtwTUxSN
YCBio-y4jeacDmjKWw+5raM+Rk9UNe3Lo0w+DpKUQFPZ3Q0t-yK1k5QGzDkQD-R0XmP6TWDs
R25yIw1L8zk6O2l0SnLuTlztN6mx5b7w2nXbUhsPeDgHwXZc5s4qFC1P7jMcd-SUVzj+bljt
ix5b5gnnfIXfkAQmx+w6TZ2y-vevoCxFp7p2rHqUjkWsadj1kl4h70azW6q2yXfwWDA2GTd0
z1EKZzXGAePyA5vUMS7jDlfyUo6WCfopmN7iaYd1H2bSeO2ldOSzCbZ3IDGdKNm8--D73xbx
9sYno5w+I2g1--E++U+6+2Vt9m-xcit+lU+++++U+++9++++GZJHJ2xCFGt9JoPhnf3ikX+E
-a-5ZJ020-jASEJOM6Q--+gAvMmAAQEWq73x+T5qL8EcehJ85Pjwrq9TbLprDJZHsPlcnvTx
SXNSGbJxG5z8ZPhJYgnFZ6OS6jg8lZvmPFpcNnKzT-yeIcNky4lHGOeQ7KodQ54GzTJvp9mK
Wdco3HfziIbLHoGRotLLaVTIcfhlSXfMq20m95aagm88iDnFfvmf1ciXembtBWDSutQp-rTh
+zT6XHov2IJQbUg++++++++++++++++++61zxk7EGk203++I++6+0+-6SGwU9LSNhPY+++-u
-U++0k+++++++++++0++++++++++GZJHJ2xCFGt2Ep7EGk203++I++6+0+-6SGwUzS1gXW28
+++E2k++0k+++++++++++0++++1W++++GZJHJ2xCFGt2EpJEGk203++I++6+0+-6SGwU0-k9
azgQ+++BBk++0k+++++++++++0+++++g0k++GZJHJ2xCFGt6H3-EGk203++I++6+0+-6SGwU
TO9iEAM+++++6+++0k+++++++++++0++++-E8+++GZJHJ2xCFGt9JoNEGkI4++++++E+-+1Y
++++DmY+++++
***** END OF BLOCK 3 *****

