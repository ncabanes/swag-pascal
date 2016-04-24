(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0147.PAS
  Description: Manage Program Icons
  Author: ANDY COOPER
  Date: 08-30-96  09:35
*)

unit ProgIcon;

{Please feel free to use these routines as you wish, provided you keep the comments with my name in}
{Any comments or problems then contact me, Andy Cooper - 100622.1041@COMPUSERVE.COM}


interface

uses
  DdeMan;

{First parameter is a ddeClientConv that has already been created on the calling form}
function CreateProgManGroup(DDEClient : TDdeClientConv; strGroup : string) : Boolean;
function CreateProgManItem(DDEClient : TDdeClientConv; strGroup, strItem, strFile : string) : Boolean;

implementation


function CreateProgManGroup(DDEClient : TDdeClientConv; strGroup : string) : Boolean;
{By Andy Cooper - 100622.1041@COMPUSERVE.COM}
var
  pstrCmd : array[0..255] of char;
begin
  try
    StrPCopy (pstrCmd, Format('[CreateGroup(%s)]', [strGroup]) + #13#10);
    Result := DDEClient.ExecuteMacro(pstrCmd, False);
  except
    Result := False;
  end; {try}
end;

function CreateProgManItem(DDEClient : TDdeClientConv; strGroup, strItem, strFile : string) : Boolean;
{By Andy Cooper - 100622.1041@COMPUSERVE.COM}
var
  pstrCmd : array[0..255] of char;
begin
  try
    StrPCopy (pstrCmd, Format('[ShowGroup(%s, 1)]', [strGroup]) + #13#10);
    DDEClient.ExecuteMacro(pstrCmd, False);
    StrPCopy (pstrCmd, Format('[ReplaceItem(%s)]', [strItem]) + #13#10);
    DDEClient.ExecuteMacro(pstrCmd, False);
    StrPCopy (pstrCmd, Format('[AddItem(%s,%s' + ',,)]', [strFile,strItem]) + #13#10);
    Result := DDEClient.ExecuteMacro(pstrCmd, False);
    StrPCopy (pstrCmd, Format('[ShowGroup(%s, 1)]', [strGroup]) + #13#10);
    DDEClient.ExecuteMacro(pstrCmd, False);
  except
    Result := False;
  end; {try}
end;

end.

