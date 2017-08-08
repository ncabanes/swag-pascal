(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0009.PAS
  Description: SCROLLER.PAS
  Author: ERIC MILLER
  Date: 05-28-93  13:58
*)

{
ERIC MILLER
read a Text File and scroll
}

Uses
  Crt;

Const
  MaxLine   = 200;
  MaxLength = 80;

Var
  Lines       : Array [1..MaxLine] of String[MaxLength];
  OldLine,
  L,
  CurrentLine,
  NumLines    : Word;
  TextFile    : Text;
  Key         : Char;
  Redraw,
  Done        : Boolean;

begin
  ClrScr;
  Assign(TextFile, 'SCROLLER.PAS');
  Reset(TextFile);
  NumLines := 0;
  While not EOF(TextFile) and (NumLines < MaxLine) DO
  begin
    Inc(NumLines);
    Readln(TextFile, Lines[NumLines]);
  end;
  Close(TextFile);

{
 Well...that handles getting the File into memory...but
 to scroll through using Up/Down & PgUp PgDn is a lot harder,
 but not incredibly difficult.
}
  Done := False;
  Redraw := True;
  CurrentLine := 1;

  While not Done DO
  begin
    if Redraw then
    begin
      GotoXY(1,1);
      For L := CurrentLine to CurrentLine + 22 DO
          Write(Lines[L], ' ':(80-Length(Lines[L])));
      Redraw := False;
    end;
    Key := ReadKey;
    Case Key of
      #0:
        begin { cursor/page keys }
          OldLine := CurrentLine;
          Key := ReadKey;

          Case Key of
            #72: { up  }
              if CurrentLine > 1 then
                Dec(CurrentLine);
            #80: { down  }
              if CurrentLine < (NumLines-22) then
                Inc(CurrentLine);
            #73: { page up  }
              if CurrentLine > 23 then
                Dec(CurrentLine, 23)
              else
                CurrentLine := 1;
            #81: { page down }
               if CurrentLine < (NumLines-44) then
                 Inc(CurrentLine, 23)
               else
                 CurrentLine := NumLines-22;
          end;

          if CurrentLine <> OldLine then
            Redraw := True;
        end;

      #27: Done := True;

    end; {Case}
  end; {begin}
end. {Program}

{
That should work For scrolling through the lines. Sorry
'bout not commenting the code alot; it is almost self-explanatory
though.  But it works!  You could optimize it For larger Files
by using an Array of Pointers to Strings.  But enough For now.
}
