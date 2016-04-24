(*
  Category: SWAG Title: ANSI CONTROL & OUTPUT
  Original name: 0033.PAS
  Description: Pascal ANSI Engine
  Author: SCOTT EARNEST & BEN KIMBALL
  Date: 11-26-94  05:07
*)

program FastANSI;

{$R-,S-,B-,A-,F-,Q-,V-}

{FAST!  Buffered ANSI viewer--almost good enough for someone who wants to
 view ANSI files without ever loading ANSI.SYS.

 Plusses:
   - Don't hafta load ANSI.SYS
   - SAFE:  Beeps if there's a key-redefine, and won't change the screen
            mode
   - Almost as fast as the real thing--the difference is probably not even
     noticed on a fast computer, except for with HUGE files.

 Minuses:
   - Takes up more disk space (but doesn't everything?  :-)
   - Still not as fast as the real thing.
   - Currently the code is a bit sloppy and probably hard to read
     (I can read it, but then I helped write it. . . .)
     * I've since given cleaner formatting to the code, but it's still
       a bit tough to read, and isn't fully commented.  The style is
       pretty dirty, and optimization could help it a lot.

 Yes, one of my *next* plans for this thing is to optimize, organize, and
 comment the source

 Coauthored by:  Ben Kimball (Kzinti@Platte.UNK.edu)
                 Scott Earnest (scott@whiplash.pc.cc.cmu.edu)
}

uses CRT, DOS;

const
  IBMColor : array [0 .. 7] of byte =
    (0,4,2,6,1,5,3,7);
  Tone = 2500;
  Duration = 250;
  buflen = 2047;

var  {EEEEK!--it's possible not all of these are used. . . .}
  ch, lastch, inqchar : char;
  f : file;
  Fileinfo : searchrec;
  bytesread : word;
  bufloc : word;
  ANSIbuf : array [0 .. buflen] of byte;
  FName : string[80];
  commandfetch, numsread : boolean;
  ANSIParam : array[1 .. 16] of string;
  index, ANSIPcount, loop, semicount : byte;
  blink, reverse, bold : boolean;
  tmpx, tmpy,
  savecurx, savecury,
  fgcolor, bgcolor : byte;
  vidpage : byte absolute $0000:0462;
  ncols : byte absolute $0000:$044a;
  nrows : byte;
  numbytes : longint;

function value(st : string) : integer;

Var
  dummy,v : integer;

begin
  val (st,v,dummy);
  value := v;
end;

procedure outchar (ch : char);

var
  xp, yp : byte;
  mp : word;

begin
  xp := WhereX;
  yp := WhereY;
  case ch of
    #13 : exit;
    #10 : xp := ncols;
  else
    begin
      mp := ((yp-1)*ncols+xp-1)*2;
      mem[SegB800:mp] := ord(ch);
      mem[SegB800:mp+1] := textattr;
    end
  end;
  inc(xp);
  if xp > ncols then
    begin
      xp := 1;
      inc(yp);
    end;
  GotoXY (xp,yp);
end;

procedure inchar (var ch : char);

begin
  if bufloc = 0 then
    BlockRead (f,ANSIbuf,buflen+1,bytesread);
  ch := chr(ANSIbuf[bufloc]);
  inc (bufloc);
  inc (numbytes);
  if (bufloc >= bytesread) then
    bufloc := 0;
end;

procedure execcode;

begin
  Case Ch of
    'H','f' : {Cursor Position}
              begin
                case semicount of
                  0 : case ANSIPcount of
                        0 : GotoXY(1,1);
                      else
                        GotoXY(1,Value(ANSIParam[1]));
                      end;
                  1 : if value(ANSIParam[1]) = 0 then
                        GotoXY(Value(ANSIParam[2]),1)
                      else
                        GotoXY(Value(ANSIParam[2]),Value(ANSIParam[1]));
                end;
              end;

        'A' : {Cursor Up}
              if ANSIPcount < 1 then
                begin
                  if WhereY > 1 then
                    GotoXY(WhereX, WhereY - 1)
                end
              else
                if WhereY - Value(ANSIParam[1]) < 1 then
                  GotoXY(WhereX, 1)
                else
                  GotoXY(WhereX, WhereY - Value(ANSIParam[1]));

        'B' : {Cursor Down}
              if ANSIPcount < 1 then
                begin
                  if WhereY < nrows then
                    GotoXY(WhereX, WhereY + 1)
                end
              else
                if WhereY + Value(ANSIParam[1]) > nrows then
                  GotoXY(WhereX, nrows)
                else
                  GotoXY(WhereX, WhereY + Value(ANSIParam[1]));

        'C' : {Cursor Forward}
              if ANSIPCount < 1 then
                begin
                  if WhereX < ncols then
                    GotoXY(WhereX + 1, WhereY)
                end
              else
                if WhereX + Value(ANSIParam[1]) > ncols then
                  GotoXY(ncols, WhereY)
                else
                  GotoXY(WhereX + Value(ANSIParam[1]), WhereY);

        'D' : {Cursor Backward}
              if ANSIPcount < 1 then
                begin
                  if WhereX > 1 then
                    GotoXY(WhereX - 1, WhereY)
                end
              else
                if WhereX - Value(ANSIParam[1]) < 1 then
                  GotoXY(1, WhereY)
                else
                  GotoXY(WhereX - Value(ANSIParam[1]), WhereY);

        'p' : {Key-redefine}
              begin
                Sound (Tone);
                Delay (Duration);
                NoSound;
              end;

        's' : {Save Cursor Position}
              begin
                SaveCurX := WhereX;
                SaveCurY := WhereY;
              end;

        'u' : {Restore Cursor Position}
              GotoXY(SaveCurX, SaveCurY);

        'J' : {Erase Display (if ESC[2J ) }
              ClrScr;

        'K' : {Erase Line}
              ClrEol;

        'm' : {Set Graphics Mode}
              for Loop := 1 to AnsiPCount do
                case value(ANSIParam[Loop]) of
                         0 : {All Attributes Off}
                             begin
                               Blink   := false;
                               Reverse := false;
                               Bold    := false;
                               TextAttr := $07;
                               FGColor := 7;
                               BGColor := 0;
                             end;
                         1 : {Bold On}
                             begin
                               Bold := true;
                               TextAttr := (TextAttr or $08);
                             end;
                         4 : {Underscore - ignored};
                         5 : {Blink On}
                             begin
                               TextAttr := (TextAttr or $80);
                               Blink := true;
                             end;
                         7 : {Reverse Video}
                             begin
                               Reverse := true;
                               if FGColor > 7 then
                                 FGColor := 8
                               else FGColor := 0;
                               BGColor := 7;
                               TextColor(FGColor);
                               TextBackGround(BGColor);
                             end;

                  30 .. 37 : {Foreground}
                             begin
                               FGColor := IBMColor[Value(ANSIParam[Loop]) - 30];
                               TextAttr := BGColor * 16 + FGColor;
                               if blink then TextAttr := TextAttr or $80;
                               if bold then TextAttr := TextAttr or $08;
                             end;

                  40 .. 47 : {Background}
                             begin
                               BGColor := IBMColor[Value(ANSIParam[Loop]) - 40];
                               TextAttr := BGColor * 16 + FGColor;
                               if blink then TextAttr := TextAttr or $80;
                               if bold then TextAttr := TextAttr or $08;
                             end;
                end; {Case}

  end; {Case}
end;

procedure readANSIdata;

begin
  inchar (ch);
  case ch of
    '0' .. '9' : begin
                   ANSIParam[ANSIPcount] := ANSIParam[ANSIPcount] + ch;
                   numsread := true;
                 end;
           '"' : repeat
                   inchar (inqchar);
                 until inqchar = '"';
           ';' : begin
                   inc(ANSIPcount);
                   inc(semicount);
                 end;
  else
    begin
      if not numsread then ANSIPCount := 0;
      execcode;
      commandfetch := false;
    end;
  end;
  lastch := ch;
end;

procedure parseANSI;

begin
  fillchar (ANSIParam, sizeof(ANSIParam), 0);
  ANSIPcount := 1;
  semicount := 0;
  commandfetch := true;
  numsread := false;
  repeat
    readANSIdata;
  until not commandfetch;
end;

begin
  nrows := mem[$0000:$0484] + 1;
  TextAttr := $0f;
  semicount := 0;
  SaveCurX   := 1;
  SaveCurY   := 1;
  Bold       := false;
  Blink      := false;
  Reverse    := false;
  ANSIPcount := 0; {No Params}
  FGColor    := 7; {Light Grey}
  BGColor    := 0; {Black}
  numsread := false;
  commandfetch := false;
  bufloc := 0;
  numbytes := 0;
  bytesread := 0;
  fillchar (ANSIbuf, sizeof(ANSIbuf), 0);
  if ParamStr(1) = '' then
    begin
      write ('Enter Filename: ');
      readln (FName);
    end
  else
    FName := ParamStr(1);
  findfirst (FName, AnyFile, fileinfo);
  if fileinfo.name = '' then
    begin
      writeln ('File not found.');
      halt;
    end;
  assign (F, FName);
  reset (F,1);
  clrscr;
  while (numbytes < fileinfo.size) do
    begin
      inchar (ch);
      if ch = #27 then
        begin
          lastch := ch;
          inchar (ch);
          if ch <> '[' then
            begin
              outchar (lastch);
              outchar (ch);
            end
          else {parse}
            parseANSI;
        end
      else
        outchar (ch);
    end;
  readln;
  close (f);
end.

