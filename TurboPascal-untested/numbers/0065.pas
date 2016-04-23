
{
 I'll give a little program to demonstrate testing bits of a word for
 being set or clear.  The BitIsSet function can be coded a little more
 efficiently, but I suspect you want clarity, not programming tricks.
}

Program BitExample;
var
  testword : word;
  i        : word;

(*
  Function BitIsSet. Given 'Wd', a word, and 'Bit', a bit number from
  0 through 15, return true if the bit number of the word is
  set, else return false.
*)
function BitIsSet(Wd:word; Bit:byte): boolean;
  begin
    if ((Wd shr Bit) and $01) <> 0 then
      BitIsSet := true
     else
      BitIsSet := false;
  end; {bitisset}

begin {program}
  testword := $805F;
  for i := 0 to 15 do
    begin
      if BitIsSet(testword,i) then
        writeln( 'Testword bit ',i:2,' is set.' )
       else
        writeln( 'Testword bit ',i:2,' is clear.' )
    end;
end. {program bitexample}
