//------------------------------------------------------------------------------
// RegExpUnit.Pas			Copyright (C) 1997  Object Dynamics Ltd.
//
// An implementation of regular expression searching for Delphi 2 and later. The
// code is based on that presented by Kernighan & Plauger in their book
// "Software Tools in Pascal" (ISBN 0-201-10342-7). You should consult this book
// for a detailed explanation of how this implementation works, as the code is
// not particularly heavily commented!
//
// 								*** IMPORTANT ***
//
// By using this code, you accept the following conditions:
//
//  	You may use and adapt this code freely, but it remains the
// 	copyright of Object Dynamics Ltd. Any adaptations must retain the
// 	copyright message at the head of this file.
//
//		You use this code at your own risk. Object Dynamics is not responsible
//    for any loss or damage caused by programs using this code.
//
//
// History:
//
//		Version 1.0 Created by Neil Butterworth, September 1997
//       - Fixed problem with .* not matching entire line
//
//------------------------------------------------------------------------------

unit ODRegExpUnit;

interface

//------------------------------------------------------------------------------
// Find
//
// Searches the string "str" from position "start" for the pattern "pat". The
// pattern must have been constructed using one of the two MakePattern functions
// described below.
//
// The function returns the position of the pattern in the string, or zero if
// no match is found. If there is a match, the length of matched characters
// is returned in the "len" parameter.
//
// If the "csense" parameter is false, the case of characters is ignored.
//------------------------------------------------------------------------------

function Find( const str : string; start : integer;
					const pat : string; var len : integer;
               csense : boolean ) : integer;


//------------------------------------------------------------------------------
// MakePattern
//
// Constructs an encoded version of a regular expression, required for input
// as the "pat" parameter of Find, described above.
//
// MakePattern begins construction of the pattern at the position indicated
// by "start" - this should almost always be 1. This extraneous parameter is
// maintained for future Software Tools compatibility.
//------------------------------------------------------------------------------

function MakePattern( const pat : string; start : integer ) : string;

//------------------------------------------------------------------------------
// MakePatternNoRegexp
//
// As above, but treats all regular expression characters as non-special. For
// example:
//
//		MakePattern( '[a-z]') wo
//
// would create apattern that would match the string '[a-z]', rather than
// one that would match a single lower-case character.
//------------------------------------------------------------------------------

function MakePatternNoRegEx( const pat : string; start : integer ) : string;


//------------------------------------------------------------------------------


implementation

uses
	SysUtils;

//------------------------------------------------------------------------------
// The following constants define the symbols used by regular expressions. The
// set used is identical to that used by UNIX programs such as vi and ed, but
// does not include extended regular expressions as used by (for example )nawk.
//------------------------------------------------------------------------------

const
	CLOSURE = '*';					// match zero or more of preceding character
   BOL = '^';                 // beginning of line
	EOL = '$';                 // end of line
	ESCAPE = '\';              // escape next character
   DASH = '-';                // used in [a-z] type expressions
   NEGATE = '^';              // negate next character/range in [a-z] expression
   CCL ='[';                  // intro for [a-z] expressions
   CCLEND = ']';             	// outro for [a-z] expressions
   ANY = '.';                	// match any single character


//------------------------------------------------------------------------------
// These are used for internally encoding expressions
//------------------------------------------------------------------------------

   NCCL = '!';    				// negate [a-z] must not be same as NEGATE!!!
   LITCHAR = '@';           	// quote single literal character
   TAB = char( 9 );           // tab

//------------------------------------------------------------------------------
// Convert a single character to uppercase (if possible)
//------------------------------------------------------------------------------

function ToUpper( c : char ) : char;
begin
	if (( c >= 'a' ) and (c <='z')) then
   	result := char(integer(c) - 32)
   else
   	result := c;
end;

//------------------------------------------------------------------------------
// Compare two characters for equality. If csense is false, the comparison
// ignores case.
//------------------------------------------------------------------------------

function CmpChar( c1, c2 : char; csense : boolean ) : boolean;
begin
	if ( csense ) then
   	result := c1 = c2
   else
   	result := ToUpper(c1) = ToUpper(c2);
end;

//------------------------------------------------------------------------------
// Check if single character is alphanumeric.
//------------------------------------------------------------------------------

function IsAlphaNum( c : char ) : boolean;
begin
	result := ((c>= 'A') and (c<='Z'))
   				or ((c >='a') and (c<='z'))
               or ((c>='0') and (c<='9'));
end;

//------------------------------------------------------------------------------
// Check if index is beyond the last character position in a string.
//------------------------------------------------------------------------------

function AtEnd( const str : string; index : integer ) : boolean;
begin
	result := index > Length( str );
end;

//------------------------------------------------------------------------------
// Expand an escaped character.
//------------------------------------------------------------------------------

function Esc( const s : string; var i : integer ) : char;
begin
	if ( s[i] <> ESCAPE ) then
   	result := s[i]
   else if ( AtEnd( s, i+1 )) then
      result := ESCAPE
   else begin
   	inc( i );
      if ( s[i] = 't' ) then
      	result := TAB
      else
      	result := s[i];
   end;
end;

//------------------------------------------------------------------------------
// Expand a character class in the form c1-c2. For example a-d expands to "abcd".
//------------------------------------------------------------------------------

function ExpandDash( delim : char; const pat : string; var i : integer ) : string;
var
	k : char;
begin
	result := '';
	while( (pat[i] <> delim) and (not AtEnd( pat, i ))) do begin
   	if ( pat[i] = ESCAPE ) then
      	result := result + Esc( pat, i )
      else if ( pat[i] <> DASH ) then
      	result := result + pat[i]
      else if ( AtEnd( pat, i )) then
      	result := result + DASH
      else if ( IsAlphaNum( pat[i-1] )
      		and IsAlphaNum( pat[i+1])
            and ( pat[i-1] <= pat[i+1])) then  begin
      	for k := char(integer(pat[i-1]) + 1) to pat[i+1] do
         	result := result +  k;
         inc( i );
      end
      else
      	result := result + DASH;
      inc( i );
   end;
end;

//------------------------------------------------------------------------------
// Expand character class in form [a-z]
//------------------------------------------------------------------------------

function ExpandCharClass( const c : string; var i : integer ) : string;
var
	countpos : integer;
   tmp : string;
begin
	result := '';
	inc( i );
   if ( c[i] = NEGATE ) then begin
   	result := result + NCCL;
      inc ( i );
   end
   else
   	result := result + CCL;
	result := result + ' ';
   countpos := Length( result );
   tmp := ExpandDash( CCLEND, c, i );
   result[countpos] := char(length(tmp));
   if ( c[i] = CCLEND ) then
   	result := result + tmp
   else
   	result := '';
end;

//------------------------------------------------------------------------------
// Insert a closure symbol at position cpos.
//------------------------------------------------------------------------------

procedure InsertClosure( var pat : string; cpos : integer );
begin
	Insert( CLOSURE, pat, cpos );
end;

//------------------------------------------------------------------------------
// Construct a pattern from an expression. A pattern is an expanded encoding
// of an expression, which the search functions need. This version ignores
// ALL regular expression characters.
//
// The "start" parameter indicates the starting point in the expression. This
// will almost always be 1.
//------------------------------------------------------------------------------

function MakePatternNoRegEx( const pat : string; start : integer ) : string;
var
	i : integer;
begin
	result := '';
   for i := start to length( pat ) do
   	result := result + LITCHAR + pat[i];
end;

//------------------------------------------------------------------------------
// As above, but handles regualr expression characters.
//------------------------------------------------------------------------------

function MakePattern( const pat : string; start : integer ) : string;
var
	p, pstart, i : integer;
begin
	i := start;
   result := '';
	pstart := 0;
  	while( not AtEnd( pat, i ) ) do begin
		if ( pat[i] = ANY ) then begin
			pstart := Length( result ) + 1;
      	result := result + ANY;
      end
      else if ( (pat[i] = BOL) and (i = start )) then begin
      	pstart := Length( result ) + 1;
      	result := result + BOL;
      end
      else if ( (pat[i] =EOL) and AtEnd(pat, i+1 )) then begin
      	pstart := length( result ) + 1;
      	result := result + EOL;
      end
      else if ( pat[i] = CCL ) then begin
      	pstart := length( result ) + 1;
      	result := result + ExpandCharClass( pat, i );
      end
      else if ( ( pat[i] = CLOSURE ) and ( i > start )) then begin
      	p := pstart;
         pstart := length( result ) + 1;
			if ( ( p < 1 ) or (result[p] in [BOL, EOL, CLOSURE]) ) then begin
         	result := '';
            exit;
         end;
         InsertClosure( result, p );
      end
      else begin
			pstart := length( result ) + 1;
      	result := result + LITCHAR + Esc( pat, i );
		end;
      inc( i );
   end;
end;

//------------------------------------------------------------------------------
// Get length of piece of a pattern. For example, the encoded length of the
// expression 'a' is 2, as it is encodeds a LITCHAR followed by an 'a'
//------------------------------------------------------------------------------

function PatSize( const pat : string; n : integer ) : integer;
begin
	if ( pat[n] = LITCHAR ) then
   	result := 2
   else if ( pat[n] in [BOL, EOL, ANY, CLOSURE] ) then
   	result := 1
   else if ( (pat[n] = CCL) or (pat[n] = NCCL)) then
   	result := integer( pat[n+1] ) + 2;
end;

//------------------------------------------------------------------------------
// Find single character in character class.
//------------------------------------------------------------------------------

function LocateChar( c : char; const pat : string; offset : integer;
									csense : boolean ) : boolean;
var
	i : integer;
begin
	result := false;
   i := offset + integer( pat[offset] );
   while( i > offset ) do begin
   	if ( CmpChar(c, pat[i], csense ) ) then begin
      	result := true;
         exit;
      end;
      dec(i );
   end;
end;

//------------------------------------------------------------------------------
// Match a single pattern element against a string.
//------------------------------------------------------------------------------

function MatchOne( const str : string; var i : integer;
							const pat : string; j : integer;
                     csense : boolean ) : boolean;
var
	advance : integer;
begin
	advance := -1;
   if ( AtEnd( str, i ) ) then begin
   	if ( pat[j] = EOL ) then
      	advance := 0;
   end
   else if ( not (pat[j] in [LITCHAR, BOl, EOL, ANY, CCL, NCCL, CLOSURE])) then
   	raise Exception.Create( 'should never happen!' )
   else begin
   	case pat[j] of
      	LITCHAR:
         	if ( CmpChar( str[i], pat[j+1], csense ) ) then
            	advance := 1;
         BOL:
         	if ( i = 1 ) then
            	advance := 0;
         ANY:
         	if ( not AtEnd( str, i ) ) then       //i+1
            	advance := 1;
         EOL:
         	if ( AtEnd( str, i + 1 ) ) then
            	advance := 0;
         CCL:
         	if ( LocateChar( str[i], pat, j+1, csense )) then
            	advance := 1;
         NCCL:
				if ( not AtEnd( str, i + 1 )
            			and( not LocateChar( str[i], pat, j+1, csense) )) then
            	advance := 1;
      end;
   end;

   if ( advance >= 0 ) then begin
   	i := i + advance;
      result := true;
   end
   else
   	result := false;
end;

//------------------------------------------------------------------------------
// Look for a  match of patttern element pat[j] in a string, starting at offset.
//------------------------------------------------------------------------------

function MatchPat( const str : string; offset : integer;
						const pat : string; j : integer;
                  csense : boolean ) : integer;
var
	i, k : integer;
begin
	while( not AtEnd( pat, j ) ) do begin
   	if ( pat[j] = CLOSURE ) then begin
      	j := j + PatSize( pat, j );
         i := offset;
         while( (not AtEnd( str, i ))
         	and ( MatchOne( str, i, pat, j, csense ))) do begin
         	// nothing
         end;
         while( i >= offset ) do begin
         	k := MatchPat( str, i, pat, j + PatSize( pat, j ), csense);
            if ( k > 0 ) then
            	break;
            dec( i );
         end;

         offset := k;
         break;
      end
      else if ( not MatchOne( str, offset, pat, j, csense ) ) then begin
      	offset := 0;
         break;
      end
      else
      	j := j + PatSize( pat, j );
   end;
	result := offset;
end;

//------------------------------------------------------------------------------
// Look for a pattern in a string, returning the position of the pattern
// (or zero if not found, and the length.
//------------------------------------------------------------------------------

function Find( const str : string; start : integer;
							const pat : string;
							var len : integer;
								csense : boolean ) : integer;
var
	i, pos : integer;
begin
	i := start;
   pos := 0;
   result := 0;

   while ( not AtEnd( str, i )) do begin
      len := MatchPat( str, i, pat, 1, csense  );
   	if ( len <> 0 ) then begin
      	len := len - i;
      	result := i;
         exit;
      end;
      inc( i );
   end;
end;

//----------------------------------- eof --------------------------------------

end.
