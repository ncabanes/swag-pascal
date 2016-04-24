(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0393.PAS
  Description: RE: Get Network Username
  Author: VINCENT CROQUETTE
  Date: 01-02-98  07:34
*)


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
