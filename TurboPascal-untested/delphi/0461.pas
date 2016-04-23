unit Binasc;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

type
  TBinAsc = class(TComponent)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
    procedure BinToAsc(fnSource, fnDest: String);
    procedure AscToBin(fnSource, fnDest: String);
  end;

procedure Register;

implementation

procedure TBinAsc.BinToAsc(fnSource, fnDest: String);
var
  Src, Dst: File;
  OneChar: Char;
  S: String;
  Hex: Array[0..1] of Char;
  NumRead, NumWritten: Integer;
begin
  AssignFile(Src, fnSource);
  ReSet(Src, 1);
  AssignFile(Dst, fnDest);
  ReWrite(Dst, 1);
  repeat
    BlockRead(Src, OneChar, SizeOf(OneChar), NumRead);
    S:=IntToHex(Integer(OneChar), 2);
    StrPCopy(Hex, S);
    BlockWrite(Dst, Hex, SizeOf(Hex), NumWritten);
  until (NumRead = 0);
  System.CloseFile(Dst);
  System.CloseFile(Src);
end;

procedure TBinAsc.AscToBin(fnSource, fnDest: String);
var
  Src, Dst: File;
  OneChar: Char;
  S: String;
  I: Integer;
  Hex: Array[0..1] of Char;
  NumRead, NumWritten: Integer;
begin
  AssignFile(Src, fnSource);
  ReSet(Src, 1);
  AssignFile(Dst, fnDest);
  ReWrite(Dst, 1);
  repeat
    BlockRead(Src, Hex, SizeOf(Hex), NumRead);
    OneChar:=Chr(StrToInt('$'+Copy(StrPas(Hex), 1, 2)));
    BlockWrite(Dst, OneChar, SizeOf(OneChar), NumWritten);
  until (NumRead = 0);
  System.CloseFile(Dst);
  System.CloseFile(Src);
end;

procedure Register;
begin
  RegisterComponents('Samples', [TBinAsc]);
end;

end.

{ -----------------------   DCR UNIT FOR THIS UNIT ----------------- }
{ the following contains additional files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members.

{ ------------------            CUT              ----------------------}


*XX3402-001657-290997--72--85-62871------BINASC.DCR--1-OF--1
zk6+J277HY3HEk+k24U4+++c++++4++++-U++++-++U++++++2+0++++++++++++++++++++
+E++++++++++U+++U++++60++6++++0++6++U6+++A1+k+0+U6++++1z++1z++++zzw+zk++
+Dw+zk1zzk++zzzz+Dw+++1z+Dw+zzw++Dzzzk1zlVU+4AMM+-X44++MlVU+4AMM+-X44++M
lVU+4AMM+-X44++MlVU+4AMM+-X44++MV-++4Dzz+-X44++M+++++AMM+++++++MlVU+4AMM
+-U+++++lVU++++++-X44++ElVU+zwMM++144++++++++AMM+-X44+++lVU++AMM++++++++
lVU+4AMM++144++MlVU+46EE+-Xzzk+MlVU+4++++-U++++MlVU+4++++-X44++M++++4+++
+-X44++M++++2AMM+Dy+2++MlVU++AMM++144++MlVU++AMM+-X44+++lVU++AMM+-X44+++
lVU+4AMM+-W22++Mzzw+4AMM+-U++++M++++4AMM+-U++++MlVU+4++++-U++++MlVU+4+++
+-144+1zlVU+4AMM++144+++lVU+4AMM++144++MlVU++AMM++144++MlVU++AMM+-X44++E
V-++4Dzz+-X44++M++++4++++-X44++M++++4AMM+-U++++M++++4AMM+-U++++ElVU+zs+E
+-X44+++lVU+4AMM+++++++M++++4AMM++144++MlVU++++++-U++++MlVU+26EE+-Xzzk+M
lVU+4AMM+-X44++MlVU+4AMM+-X44++MlVU+4AMM+-X44++MlVU+2AMM+Dz44++MlVU+4AMM
+-X44++MlVU+4AMM+-X44++MlVU+4AMM+-X44++MlVU+4AMM+-W22++Mzzw+26EE+-022++E
V-++26EE+-022++EV-++26EE+-022++EV-++26EE+-144+1zlVU+zwMM+Dzzzk1zzzw+zzzz
+Dzzzk1zzzw+zzzz+Dzzzk1zzzw+zzzz+-Xzzk+EV-++4Dzz+-X44++MlVU+4AMM+-X44++M
lVU+4AMM+-X44++MlVU+4AMM+-X44++ElVU+zs+E+-X44++ElVU+4AMM+-X44++TlVU+5k+T
+-X44++MlVU++AMM++1s+++MlVU+46EE+-Xzzk+MlVU+46+E+-X44++MlVU+4++T+-z44++M
lVU++AMM+-X44+++lVU+2AMM+Dz44++MlVU+46+E+-W+2++MlVU+5wMM+-w+5k+MlVU+4AMM
+-Xs+++MlVU+4AMM+-022++Mzzw+2AMM+-0+2++MlVU+4AMM+-U+5k+TlVU+4AMM++144++M
lVU+4AMM+-144+1zU-++sAMM+-X44++ElVU+4AMM+-z44++MlVU+4++T+-X44++My+++4AMM
++Q5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-EQ5
-kI5-kQA1+k5-kQ5-kY70EQ5-kQ5-EQ5-kI5-kQA-kQA-kQ50EQ5-kY5-kQ5-kI3-EQ5-kQA
-kQA-kQ50EQ5-kQ5-kQ5-kI5-EQ5-kQA1+k5-kQ50EQ5-kQ5-kQ5-kQ3-kQ5-kQA-kQA-kQ5
0EQ5-kY5-kQ5-kQ3-kQ5-kQA1+k5-kQ5-kY70EQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5
-kQ51kwD1kwD1kwD1kwD1kwD1kwD1kw5-kQ50+U60+U60+U60+U60+U60+U60+U5-kQ5-kQ5
-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ+-kQ++++5
-kQ5++Q5++++-kQ5-kQ5-kQ+-k+5-kQ+-kQ5++Q+-kQ5++Q5-kQ5-kQ+-k+5-kQ+-kQ5++Q+
-kQ5++Q5-kQ5-kQ+-k+5-kQ+-kQ5++Q+-kQ5++Q5-kQ5-kQ+-k+5-kQ+-kQ5++Q+-kQ5++Q5
-kQ5-kQ+-k+5-kQ+-kQ5++Q+-kQ5++Q5-kQ5++++-k+5-kQ+-k++++Q+-kQ5++Q5-kQ5-kQ+
-kQ++++5-kQ5++Q5++++-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5
-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-kQ5-k++
***** END OF BLOCK 1 *****

