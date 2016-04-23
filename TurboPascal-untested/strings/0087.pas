{
 JS> I, remember way back which could be a while I saw a basic routine
 JS> that would convert numbers to their written form like 120= one
 JS> hundred and twenty. If anyone has such a routine it would be
 JS> appreciated..


 This was quite a challenge..I did find a bug so have a look at the
 test. To really put this to the test you'd have to get it to return
 every single number (0-64K) and observe the output.


{Returns the written format of any number between 0-65535}
{ Could be useful in a checkbook program }

USES Crt;

{----------------------------------------------------}
FUNCTION LZ(Num:Word; Times:Byte; Ch:Char):String;
VAR S:String;
BEGIN
 Str(Num,S); WHILE Length(S)<Times DO S:=Ch+S; LZ:=S;
END;
{------------------------------------------------}
FUNCTION Convert(Num:Word):String;
CONST
 Hu='hundred'; Th='thousand';
 Units:Array[0..9] OF String[5]=   {60 bytes}
 ('','one','two','three','four','five','six','seven','eight','nine');
 Tens:Array[0..9] OF String[7]=    {80 bytes}
 ('','ten,','twenty','thirty','fourty','fifty','sixty','seventy','eighty',
 'ninety');
 Ones:Array[0..9] OF String[9]=    {100 bytes}
 ('','eleven','twelve','thirteen','fourteen','fifteen','sixteen',
  'seventeen','eighteen','nineteen');
VAR S1,S2:String; X:Byte;
BEGIN
 S1:=LZ(Num,5,' '); S2:='';
 FOR Num:=Length(S1) DOWNTO 1 DO
  IF S1[Num]<>' ' THEN
   BEGIN
    X:=Ord(S1[Num])-48;
    CASE Num OF
     1: S2:=Tens[X]+' '+S2;
     2: IF S1[1]='1' THEN
         BEGIN
          S2:=Ones[X]+' '+Th+' '+S2; Break;
         END ELSE S2:=Units[X]+' '+Th+' '+S2;
     3: IF S1[3]='0' THEN
         BEGIN
          IF (S1[2]<>'0') AND (S1[1]<>' ') THEN S2:='and '+S2;
         END ELSE
          IF S1[4]<>'0' THEN S2:=Units[X]+' '+Hu+' and '+S2
           ELSE S2:=Units[X]+' '+Hu;
     4: S2:=Tens[X]+' '+S2;
     5: IF S1[4]='1' THEN
         BEGIN
          S2:=Ones[X]; Break;
         END ELSE S2:=Units[X];
    END;
   END; Convert:=S2;
END;
{------------------------------------------------}
BEGIN
 ClrScr;
 Writeln(Convert(23452));     {ok}
 Writeln(Convert(60201));    {Bug!}
 Writeln(Convert(9900));      {ok}
 Writeln(Convert(534));       {ok}
 Writeln(Convert(18770));     {ok}
 Writeln(Convert(4));         {ok}
END.
