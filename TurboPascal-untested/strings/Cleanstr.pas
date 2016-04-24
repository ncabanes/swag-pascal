(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0002.PAS
  Description: CLEANSTR.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:58
*)

Procedure CleanString(Var s:String);
begin
  fillChar(s,sizeof(s),0);
end;
{ I think that I already posted this form once, but here it is again...
 This is the best way, For what the original poster wanted it for- to
 clear out a String to Write to a File.  Method #1 above will overfill
 any subranged String, yours only clears out the current size of the
 String (ie if you had s:String; s := 'a'; then your Procedure would
 only fill the first Character.  The last version merely fills the
 entire String no matter what the size of it is.
-Brian Pape
}
