
From: stidolph@magnet.com (David Stidolph)

There are many times when you need to compare two strings, but want to
use wild cards in the match - all last names that begin with 'St', etc.
The following is a piece of code I got from Sean Stanley in Tallahassee
Florida in C. I translated it into Delphi an am uploading it here for
all to use. I have not tested it extensivly, but the original function
has been tested quite thoughly.

--------------------------------------------------------------------------------

{
  This function takes two strings and compares them.  The first string
  can be anything, but should not contain pattern characters (* or ?).
  The pattern string can have as many of these pattern characters as you want.
  For example: MatchStrings('David Stidolph','*St*') would return True.

  Orignal code by Sean Stanley in C
  Rewritten in Delphi by David Stidolph
}
function MatchStrings(source, pattern: String): Boolean;
var
  pSource: Array [0..255] of Char;
  pPattern: Array [0..255] of Char;

  function MatchPattern(element, pattern: PChar): Boolean;

    function IsPatternWild(pattern: PChar): Boolean;
    var
      t: Integer;
    begin
      Result := StrScan(pattern,'*') <> nil;
      if not Result then Result := StrScan(pattern,'?') <> nil;
    end;

  begin
    if 0 = StrComp(pattern,'*') then
      Result := True
    else if (element^ = Chr(0)) and (pattern^ <> Chr(0)) then
      Result := False
    else if element^ = Chr(0) then
      Result := True
    else begin
      case pattern^ of
      '*': if MatchPattern(element,@pattern[1]) then
             Result := True
           else
             Result := MatchPattern(@element[1],pattern);
      '?': Result := MatchPattern(@element[1],@pattern[1]);
      else
        if element^ = pattern^ then
          Result := MatchPattern(@element[1],@pattern[1])
        else
          Result := False;
      end;
    end;
  end;

begin
  StrPCopy(pSource,source);
  StrPCopy(pPattern,pattern);
  Result := MatchPattern(pSource,pPattern);
end;
