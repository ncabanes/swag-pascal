
I need to check if a Table exists.  I was doing it this way, when the=20
app was strictly local, but now I'm networking it...

Here is your order ...

Function GetAliasDir(const stAliasName : String) : String;
var AliamsParams : TStrings;
Begin
	AliamsParams := TStringList.Create;
  Try
  	Session.GetAliasParams(stAliasName, AliamsParams);
    Result := AliamsParams.Values['PATH'];
  Finally
		AliamsParams.Free;
  End;
End;
