
[Vincent Croquette]  Use :

const
	MAXPCSIZE = 255;

var
	pcUserName : PChar;
Begin
	StrAlloc(pcUserName, MAXPCSIZE) ;
	Try
		GetUserName(pcUserName, MAXPCSIZE);
		ShowMessage(StrPas(pcUserName);
	Finally
		StrDispose(pcUserName);
	End;
End;
