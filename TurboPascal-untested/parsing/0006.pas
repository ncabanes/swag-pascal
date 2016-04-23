{===========================================================================
 BBS: Canada Remote Systems
From: RYAN THOMPSON
Subj: RE: COMMAND LINE PARSING

>>> Quoting from Chet Kress to Frans Van Duinen about Command Line Parsing

CK>  FVD>I want to pass to my BP 7 program a few parameters, one of which
CK>  FVD>has embedded (or even trailing) blanks.  The naive approach of
CK>  FVD>PROCFAX  PROCFAX.CFG \PCB\MAIN\MSGS58  "FAX MAIL" does not work.
CK>  FVD>Currently  I pick up FAX and MAIL as two parameters and
CK>  FVD>string, but I want to allow multiple embedded/trailing blanks.

  Here's a set of routines to do just what you want.

  Parameters      Returns the number of parameters on the command line.  Does
                   not include switches.
  Parameter(n)    Returns the nth parameter, ignoring switches and passing
                   strings in quotes as " or ' followed by the entire string
                   including any imbedded spaces.
  SwitchThere(x)  Returns True if the switch specified by the character
                   passed is present on the command line.
  SwitchData(x)   Returns the data following the switch character if the
                   switch character specified is present on the command line.
  SwitchNum(x)    Returns the position on the command line of the switch
                   specified.  Skips parameters. }


  Function SwitchNum(S : String) : Integer;
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
    Begin
      SwitchThere:= not (SwitchNum(S) = 0);
    End;


  Function SwitchData(S : String) : String;
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

{
  For example, the command line:

TESTPRG /C INPUT.DAT /X67 "first one"

        Parameters  returns  2
      Parameter(1)  returns  INPUT.DAT
      Parameter(2)  returns  "first one
  SwitchThere('F')  returns  false
   SwitchData('X')  returns  67

  Notice that in quoted parameters, the first quote is returned- this allows
you to check for " vs. ', which you could use as the difference between case
sensitive and non-case-sensitive.  A simple Delete(S,1,1) can remove it from
the string for use. }
