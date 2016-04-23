unit CmdLin;
(*
   This unit will process command line flags, (/N -N)
        a) as present or absent (Is_Param)
        b) with an integer (eg. /N54 /X-76) (Param_Int)
        c) with a real number (eg /J-987.65) (Param_Real)
        d) with strings, including delimited strings with embedded spaces
           ( eg. /X"This is the story!" /YFred)

      Routines are included to count and return the parameters that
      aren't flags (Non_Flag_Count), and to return them without
      counting the flag parameters (Non_Flag_Param).

      So ( /X76 Filename.txt /N"My name is Fred." George ) would count
      two non-flag params, #1 = filename.txt and #2 = george.

      This is completely public domain, all I want in return for your use
      is appreciation.  If you improve this unit, please let me know.
      Some possible improvements would be to allow embedded strings in
      non-flag parameters.  I haven't done this because I haven't needed
      it.


      Jim Walsh      CIS:72571,173

*)

INTERFACE

  function Is_Param(flag:Char) : Boolean;
  { Responds yes if the flag (ie N) is found in the command line (ie /N or -N) }

  function Param_Int(flag:Char) : LongInt;
  { Returns the integer value after the parameter, ie -M100, or -M-123 }

  function Param_Real(flag:Char) : Real;
  { Returns the Real value after the parameter, ie -X654.87, or -x-3.14159 }

  function Param_Text(flag:Char) : String;
  { Returns the string after the parameter, ie -MHello -> 'Hello',            }
  {  -m"This is it, baby" -> 'This is it, baby', valid string delims='' "" [] }

  function Non_Flag_Param(index:integer) : string;
  { Returns the indexth parameter, not preceded with a flag delimeter }
  { /X Text.txt /Y876.76 /G"Yes sir!" MeisterBrau /?                  }
  { For this command line 'Text.txt' is Non Flag Param #1,            }
  {    and 'MeisterBrau is #2.                                        }
  { NB: Delimeted Non flag parameters (eg "Meister Brau")             }
  {  not currently supported.                                         }

  function Non_Flag_Count : integer;
  { Returns the number of non-flag type parameters }


IMPLEMENTATION
const
  flag_delims   : Set of Char = ['/','-'];
  no_of_string_delims = 3;
type
  string_delim_type = Array[1..3] of record
                                       start, stop : char
                                     end;
const
  string_delims : string_delim_type = ((start:#39; stop:#39),
                                       (start:#34; stop:#34),
                                       (start:'['; stop:']'));


function LowerCaseChar(c:char):char;
begin
  if (c>='A') and (c<='Z') Then LowerCaseChar:=Char(Ord(c)+$20)
                           Else LowerCaseChar:=c;
end;


{----------------------------------------------------------------------------}
  function WhereFlagOccurs(flag:Char) : integer;
  {  returns the index number of the paramter where the flag occurs  }
  {  if the flag is never found, it returns 0                        }
  var
    ti1      : integer;
    finished : boolean;
    paramcnt : integer;
    ts1      : string;
  begin
    flag:=LowerCaseChar(flag);
    finished:=false;
    ti1:=1;
    paramcnt:=ParamCount;
    While Not(finished) Do begin
      If ti1>paramcnt Then begin
        finished:=true;
        ti1:=0;
      end Else begin
        ts1:=ParamStr(ti1);
        If (ts1[1] In flag_delims) AND (LowerCaseChar(ts1[2])=flag) Then finished:=true;
      end;
      If Not(finished) Then Inc(ti1);
    end; {While}
    WhereFlagOccurs:=ti1;
  end;

{----------------------------------------------------------------------------}
  function Is_Param(flag:Char) : Boolean;
  begin
    If WhereFlagOccurs(flag)=0 Then Is_Param:=false Else Is_Param:=true;
  end;

{----------------------------------------------------------------------------}
  function Param_Int(flag:Char) : LongInt;
  var
    param_loc : integer;
    result    : longint;
    ts1       : string;
    ti1       : integer;
  begin
    param_loc:=WhereFlagOccurs(flag);
    If param_loc=0 Then result:=0
    Else begin
      ts1:=ParamStr(param_loc);     { Get the string }
      ts1:=Copy(ts1,3,255);         { Get rid of the delim and the flag }
      Val(ts1,result,ti1);          { Make the value }
      If ti1<>0 Then result:=0;     { Make sure there is no error }
    end; {If/Else}
    Param_Int:=result
  end;

{----------------------------------------------------------------------------}
  function Param_Real(flag:Char) : Real;
  var
    param_loc : integer;
    result    : real;
    ts1       : string;
    ti1       : integer;
  begin
    param_loc:=WhereFlagOccurs(flag);
    If param_loc=0 Then result:=0.0
    Else begin
      ts1:=ParamStr(param_loc);     { Get the string }
      ts1:=Copy(ts1,3,255);         { Get rid of the delim and the flag }
      Val(ts1,result,ti1);          { Make the value }
      If ti1<>0 Then result:=0.0;   { Make sure there is no error }
    end; {If/Else}
    Param_Real:=result;
  end;

{----------------------------------------------------------------------}
  function Which_String_Delim(S:string) : byte;
  { Returns the index of the strings first character in the array
    of string_delims, if the first char of S isn't a delim it returns 0 }
  var
    tc1 : char;
    tb1 : byte;
    finished : boolean;
    result   : byte;
  begin
    tc1:=S[1];
    tb1:=1;
    finished:=false;
    While Not(finished) Do begin
      If tb1>no_of_string_delims Then begin
        result:=0;
        finished:=true;
      end Else begin
        If tc1=string_delims[tb1].start Then begin
          result:=tb1;
          finished:=true;
        end;
      end;
      If Not(finished) Then Inc(tb1);
    end; {While}
    Which_String_Delim:=result;
  end; {function Which_String}

{-------------------------------------------------------------------------}
  function Param_Text(flag:Char) : String;
  var
    param_loc : integer;
    param_cnt : integer;
    result    : string;
    ts1       : string;
    ti1       : integer;
    s_delim   : byte;          { This should be 0(no string), 1', 2", 3[ }
    finished  : boolean;
  begin
    param_loc:=WhereFlagOccurs(flag);
    If param_loc=0 Then result:=''
    Else begin
      ts1:=ParamStr(param_loc);     { Get the string }
      ts1:=Copy(ts1,3,255);         { Get rid of the delim and the flag }
      { See if the first char of ts1 is one of the string_delims }
      s_delim:=Which_String_Delim(ts1);
      If s_delim=0 Then result:=ts1
      Else begin
        result:=Copy(ts1,2,255);    { Drop the s_delim }
        finished:=false;
        param_cnt:=ParamCount;
        While Not(finished) Do begin
          Inc(param_loc);
          If param_loc>param_cnt Then finished:=true
          Else begin
            ts1:=ParamStr(param_loc);
            If ts1[Length(ts1)]=string_delims[s_delim].stop Then finished:=true;
            result:=result+' '+ts1;
          end; { If/Else }
        end; { While }
        result[0]:=Char(Length(result)-1);      { Drop the last delimeter }
      end; { If/Else a delimited string }
    end; { If/Else the flag is found }
    Param_Text:=result;
  end;

{---------------------------------------------------------------------------}
  function Non_Flag_Param(index:integer) : string;
  var
    param_cnt : integer;
    ti1       : integer;
    ts1       : string;
    finished  : boolean;
    cur_index : integer;
  begin
    param_cnt:=ParamCount;
    cur_index:=0;
    ti1:=0;
    finished:=false;
    While Not(finished) Do begin
      Inc(ti1);
      IF cur_index>param_cnt Then begin
        ts1:='';
        finished:=true;
      end Else begin
        ts1:=ParamStr(ti1);
        If Not(ts1[1] IN flag_delims) Then begin
          Inc(cur_index);
          If cur_index=index Then finished:=true;
        end;
      end; {If/Else}
    end; {While}
    Non_Flag_Param:=ts1;
  end;

{---------------------------------------------------------------------------}
  function Non_Flag_Count : integer;
  var
    param_cnt : integer;
    result    : integer;
    ti1       : integer;
    ts1       : string;
  begin
    param_cnt:=ParamCount;
    result:=0;
    ti1:=0;
    For ti1:=1 To param_cnt Do begin
      ts1:=ParamStr(ti1);
      If Not(ts1[1] IN flag_delims) Then begin
        Inc(result);
      end;
    end; {For}
    Non_Flag_Count:=result;
  end;




END.
