(*
  Category: SWAG Title: PARSING/TOKENIZING ROUTINES
  Original name: 0003.PAS
  Description: Command Line Parsing
  Author: RYAN THOMPSON
  Date: 08-17-93  08:50
*)

===========================================================================
 BBS: Canada Remote Systems
Date: 08-10-93 (01:00)             Number: 33744
From: RYAN THOMPSON                Refer#: NONE
  To: TERRY GRANT @ 912/701         Recvd: NO  
Subj: RE: COMMAND LINE PARSING       Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
>>> Quoting message from Terry Grant @ 912/701 to All
>>> Original sent 07 Aug 93  20:36:00 about Command Line Parsing

TG> Hello All!
TG>
TG>  After working on this for awhile, I thought mabe someone else could help
TG> me out a little here. All I need this to do is Parse the command line for
TG> seven parameters,
TG>
TG> The BaudRate     (/B),
TG> :
TG> and Overlay Size (/O).
TG>
TG>  My Main problem here is, it will SEE the command line, But WILL NOT allow
TG> me to use anything AFTER the Switch ? Like /B2400 !

  Sure thing!  I once wrote a unit which among other things has some neat
parsing for the command line.  Here's a snippet:

{- Top -}

  Function SwitchNum(S : String) : Integer;
           { If a switch character specified exists, return which position }
           { it is in on the command line.  Used internally. }
    Var
      Temp : String;
      X,
      Y : Integer;
    Begin
      Temp:= '';
      X:= ParamCount;
      Y:= 0;
      while (X > 0) and (Y = 0) do begin
        Temp:= ParamStr(X);
        if (Temp[1] = '/') or (Temp[1] = '-') then
          if UpCase(Temp[2]) = UpString(S) then Y:= X;
        Dec(X);
      end;
      SwitchNum:= Y;
    End;


  Function SwitchThere(S : String) : Boolean;
           { Returns TRUE if a switch of the character specified exists. }
    Begin
      If SwitchNum(S) = 0 then SwitchThere:= False
      else SwitchThere:= True;
    End;


  Function SwitchData(S : String) : String;
           { Return the data following a switch: /B2400 returns 2400. }
    Var
      Temp : String;
    Begin
      If SwitchNum(S) > 0 then begin
        Temp:= ParamStr(SwitchNum(S));
        Delete(Temp, 1, 2);
      end
      else Temp:= '';
      SwitchData:= Temp;
    End;


  Function Parameter(N : Byte) : String;
           { Returns the Nth command line parameter.  Parameters in quotes }
           { are returned with the spaces in between:  /D Test "One Two" }
           { Returns >Test< for Parameter(1) and >"One Two< for Parameter(2) }
           { This allows you to, if you like, see what type of quote was }
           { used, for perhaps literal vs. translate to ALL CAPS. }
    Var
      X,
      Count : Byte;
      Parm,
      Temp : String;
    Begin
      X:= 0;
      Count:= 0;
      Parm:= '';
      If ParamCount > 0 then repeat
        Inc(X);
        Temp:= ParamStr(X);
        If (Temp[1] = '"') or (Temp[1] = '''') then begin
          Parm:= Temp;
          If X < ParamCount then repeat
            Inc(X);
            Parm:= Parm + ' ' + ParamStr(X);
          until (Parm[Length(Parm)] = '"') or
                (Parm[Length(Parm)] = '''') or (X = ParamCount);
          Inc(Count);
        end
        else if (Temp[1] <> '/') and (Temp[1] <> '-')
        then begin
          Inc(Count);
          Parm:= Temp;
        end;
      until (X = ParamCount) or (Count = N);
      If Count = N then Parameter:= Parm
      else Parameter:= '';
    End;


  Function Parameters : Byte;
           { Return the number of non-switch parameters on the command line. }
    Var
      X : Byte;
    Begin
      X:= 0;
      If ParamCount > 0 then begin
        Repeat
          Inc(X)
        Until Parameter(X) = '';
        Parameters:= X - 1;
      end
      else Parameters:= 0;
    End;

{- Fin -}

  A few examples:

  If SwitchThere('?') then DisplayHelp;
  If SwitchThere('B') then BaudString:= SwitchData('B');
  If Parameters < 1 then begin WriteLn('Too few parms'); Halt; end;
  For X:= 1 to Parameters do
  begin
    Param[X]:= Parameter(X);
  end;

  Sample command lines:

  TESTPROG /D /F TEST /B2400 "This is a test" /M-

  Parameters returns 2,
  Parameter(1) returns TEST
  Parameter(2) returns "This is a test
  SwitchThere('L') returns False
  SwitchData('M') returns -
  SwitchData('G') returns null.

  I hope this helps you out!  It could be optimized a lot by simply reading
all of the parameters into an array in your initialization code, to eliminate
all of the redundant parsing, but I don't think that parsing time for a few
hundred characters at most is a limiting factor of any sort.  ;-)

bye
Ryan

--- Renegade v07-17 Beta

