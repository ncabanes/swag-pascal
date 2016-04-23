unit cheat;

interface

uses crt;

type PValue=^TValue;
     TValue=object
       { Encrypted value }
       value:integer;
       { Unsigned key }
       key:integer;
       { Signed key }
       key2:integer;
       { Init }
       constructor init(v:integer);
       { Done }
       destructor done;
       { Get value }
       function get:integer;
       { Set value }
       procedure put(x:integer);
       { Re-encrypt }
       procedure encrypt;
       end;

implementation

constructor TValue.init(v:integer);
begin
 { Set value }
 value:=v;
 { No key }
 key:=0;
 { No key }
 key2:=0;
 { Encrypt }
 encrypt;
end;

destructor TValue.done;
begin
 { Nothing to dispose of }
end;

function TValue.get:integer;
var temp:integer;
begin
 { Decrypt value and store temporarily }
 temp:=value xor (key xor key2);
 { Re-encrypt }
 encrypt;
 { Return value }
 get:=temp;
end;

procedure TValue.put(x:integer);
begin
 { Set new value }
 value:=x xor (key xor key2);
 { Re-encrypt }
 encrypt;
end;

procedure TValue.encrypt;
var temp:integer;
begin
 { Decode }
 temp:=value xor (key xor key2);
 { Random unsigned key }
 key:=random(32000);
 { Random signed key }
 key2:=random(64000)-32000;
 { Encrypt }
 value:=temp xor (key xor key2);
end;

end.
{ ------------------  CUT  -------------------}

CHEAT
Unit Documentation

by Emil Mikulic

CHEAT is a something that I've been trying to get around to for
quite a while. It's a simple, reasonably fool-proof anti-cheat measure.
It is used to encrypt important values in games or programs from
pesky memory-meddling programs and Cheat Makers (i.e. GW).

Here's the definition of the PValue object:

type PValue=^TValue;
     TValue=object
       { Encrypted value }
       value:integer;
       { Unsigned key }
       key:integer;
       { Signed key }
       key2:integer;
       { Init }
       constructor init(v:integer);
       { Done }
       destructor done;
       { Get value }
       function get:integer;
       { Set value }
       procedure put(x:integer);
       { Re-encrypt }
       procedure encrypt;
       end;

You use TValue.Init to initialise a value.
Here's an example:

var money,lives:PValue;
begin
 money:=new(PValue,Init(100)); { Give player a hundred bucks }

 ...


You don't need to use TValue.Done when disposing of your PValue
because it doesn't have anything to dismantle.

To get the decrypted the value, use TValue.Get - ex:

 ...

 writeln('You have exactly ',money^.Get,' bucks on you.');

 ...

To set the value use TValue.put - ex:

 ...

 writeln('Sold for $20');
 money^.Put(Money^.Get-20);
 
 ...

If you want more control, you can use TValue.Encrypt to
re-encrypt the data, the value remains but the encrypted value
and the keys change.

That's it.
Emil Mikulic, 1997.

