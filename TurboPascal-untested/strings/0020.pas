(*
===========================================================================
 BBS: Canada Remote Systems
Date: 06-25-93 (13:52)             Number: 25767
From: GUY MCLOUGHLIN               Refer#: NONE
  To: CHRIS PRIEDE                  Recvd: NO
Subj: STRING CENTERING ROUTINES      Conf: (552) R-TP
---------------------------------------------------------------------------

  Hi, Chris:

CP>Ideally such function should be written in assembly, but since this
CP>is Pascal conference and I've flooded it with my assembly code enough
CP>lately, we will use plain Turbo Pascal.

  Try running this program using your routine and the one I posted,
  you might notice something "funny" about the ouput displayed. <g>
*)

{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X+}
{$M 1024,0,0}

program DemoStringRoutines;

USES Crt;

  function FCenter(S: string; W: byte): string;
  var
    SpaceCnt: byte;
  begin
    if Length(S) < W then
      begin
        SpaceCnt := (W - Length(S)) div 2;
        Move(S[1], S[1+SpaceCnt], Length(S));
        FillChar(S[1], SpaceCnt, '-');
        S[0] := Chr(Length(S) + SpaceCnt);
      end;
    FCenter := S;
  end;

              (* Set these constants according to your needs.         *)
  const
    BlankChar   = '-';
    ScreenWidth = 80;

    (***** Create video-display string with input string centered.    *)
    (*                                                                *)
    function CenterVidStr({input} InText : string) : {output} string;
    var
      InsertPos : byte;
      TempStr   : string;
    begin
              (* Initialize TempStr.                                  *)
      TempStr[0] := chr(ScreenWidth);
      fillchar(TempStr[1], ScreenWidth, BlankChar);

              (* Calculate string insertion position.                 *)
      InsertPos := succ((ScreenWidth - length(InText)) div 2);

              (* Insert text in the center of TempStr.                *)
      move(InText[1], TempStr[InsertPos], length(InText));

              (* Return function result.                              *)
      CenterVidStr := TempStr

    end;      (* CenterVidStr.                                        *)

var
  TempStr : string;

BEGIN
  Clrscr;
  fillchar(TempStr[1], 30, 'X');
  TempStr[0] := #30;
  writeln(FCenter(TempStr, 80));
  writeln(CenterVidStr(TempStr))
END.

  ...I tried timing these two routines on my PC (Recently upgraded
  to a 386dx-40 AMD motherboard), and here are the results:

 Compiler │ Length │ Your routine │ My routine │ Ratio
──────────┼────────┼──────────────┼────────────┼────────
 TP 7     │   30   │    0.03167   │   0.04043  │ 1.28
──────────┼────────┼──────────────┼────────────┼────────
 PASCAL+  │   30   │    0.02037   │   0.01959  │ 0.96

 *** Both functions were called in a loop 1000 times on each run,
     result was discarded ($X+ directive).

 For curiosity sake I'll post the StonyBrook PASCAL+ machine-code
 listing in the next message.
                               - Guy
---
 ■ DeLuxe²/386 1.25 #5060 ■
