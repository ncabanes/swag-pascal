(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0024.PAS
  Description: Multiple DOS Calls
  Author: FRANK DIACHEYSN
  Date: 08-24-94  13:45
*)

{
  Coded By Frank Diacheysn Of Gemini Software

  FUNCTION MASSEXEC

  Input......: DOS Command Line(s)
             :
             :
             :
             :

  Output.....: Logical
             :        TRUE  = No Errors During Execution
             :        FALSE = Error Occured During Execution
             :
             :

  Example....: IF MASSEXEC('DIR,PAUSE') THEN
             :   WriteLn('No Errors!')
             : ELSE
             :   WriteLn('DOS Error Occured!');
             :

  Description: Execute One Or More DOS Program Calls
             : (Seperate Calls With A Comma)
             :
             :
             :

}
FUNCTION MASSEXEC( S:STRING ):BOOLEAN;
{$M $4000,0,0}
VAR nCount : INTEGER;
VAR ExS    : STRING;
VAR Ch     : CHAR;
BEGIN
  REPEAT
    nCount := 0;
    ExS := '';
    REPEAT
      Inc(nCount);
      Ch := S[nCount];
      IF Ch <> ',' THEN
        ExS := ExS + Ch;
    UNTIL (Ch = ',') OR (nCount = Length(S));
    IF POS(',',S)=0 THEN
      S := ''
    ELSE
      DELETE(S,1,POS(',',S));
    SWAPVECTORS;
    EXEC( GETENV('COMSPEC'), '/C '+ ExS );
    SWAPVECTORS;
    MASSEXEC := DOSERROR = 0;
  UNTIL S = '';
END;

