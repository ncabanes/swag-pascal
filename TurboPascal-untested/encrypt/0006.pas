{ JL> I'm writing a Program to set and test passWords. I imagine you saw it in
 JL> PASCAL echo. Well, I want to know if there is an easier way to encrypt a
 JL> File then to assign a different Character to each letter. This is the
 JL> only way that I can think of to do this.

 JL> 'A':= '^';
 JL> 'B':= 'q';

What you suggest isn't so much encryption as it is a substitution cypher.  The
following is more of an *encryption*:
}

Function Crypt(S : String) : String;
(* xor can be used to *toggle* values.  In this Case it is toggling  *)
(* Character of the String based on its postion in the String.  This *)
(* ensures that the mask is always known For the pupose of decoding. *)
  Var
    i : Byte;
  begin
    For i := 1 to Length(S) Do
      S[i] := Char(ord(S[i]) xor i);
    Crypt := S;
  end;

Var
  TestS : String;
  TestMask : Byte;

begin
  TestS := 'This is a test 1234567890 !@$%';
  Write('original: ');
  Writeln(TestS);

  TestS := Crypt(TestS);
  Write('Encrypt : ');
  Writeln(TestS);

  TestS := Crypt(TestS);
  Write('Decrypt : ');
  Writeln(TestS);
end.

{Please note that this was a quickie and not fully tested and thereFore
cannot be guaranteed to be perfect.  <grin>  But it ought to give you a
slightly different perspective and help you see alternate approaches to
the problem.
}
