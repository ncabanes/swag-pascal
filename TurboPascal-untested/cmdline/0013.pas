{
From: dissel@nunic.nu.edu (David S. Issel)

Someone was looking for command line parsing in turbo pascal.

This is a unit that I wrote years ago.

To use it, simply put the USES CMDLINE; in your program.

Example1:  If you entered:  MYPROG /x/y/z="this is a test"

TurboPascal would respond:  ParamStr(x) Contents
                            =========== =================
                            1           /x/y/z="this
                            2           is
                            3           a
                            4           test"

My unit would respond:      1           /X
                            2           /Y
                            3           /Z=this is a test


Example2:  If you entered:  MYPROG file1,file2,file3

TurboPascal would respond:  ParamStr(x) Contents
                            =========== =================
                            1           file1,file2,file3

My unit would respond:      1           FILE1
                            2           FILE2
                            3           FILE3

My unit replaces the ParamCount variable and ParamStr() function.
The original TurboPascal routines are retained as System.ParamCount and
System.ParamStr()

Try it, you'll like it... (I swear!)


-------- cut here ------------- cmdline.pas ---------------------
}
Unit CMDLINE;  { Written by David S. Issel, 1989 }
 
Interface  { public }
 
Var ParamCount:integer;
 
Function ParamStr(Param:word):string;
 
Implementation  { private }
 
Var
  ParamArray:array[1..62] of string[127];
 
Function ParamStr;
  begin
    if Param<=ParamCount
      then ParamStr:=ParamArray[Param]
      else ParamStr:='';
  end;
 
Procedure SetupParamArray;
  var
    Index:word;
    WorkStr:string;
  procedure TxfrString;
    var
      SrchChar:string;
    begin
      SrchChar:=WorkStr[Index];
      Inc(Index);
      while (Index<=Length(WorkStr)) and (WorkStr[Index]<>SrchChar) do
        begin
          ParamArray[ParamCount]:=ParamArray[ParamCount]+WorkStr[Index];
          Inc(Index);
        end;
      if Index<=Length(WorkStr)
        then Inc(Index);
    end;
  begin
    ParamCount:=0;
    if System.ParamCount<1 then Exit;
    WorkStr:=System.ParamStr(1);
    if System.ParamCount>1
      then for Index:=2 to System.ParamCount do 
              WorkStr:=WorkStr+' '+System.ParamStr(Index);
    Index:=1;
    repeat
      Inc(ParamCount);
      ParamArray[ParamCount]:='';
      if (WorkStr[Index]=#34) or (WorkStr[Index]=#39)
        then TxfrString
        else
          begin
            if WorkStr[Index]<>','
              then ParamArray[ParamCount]:=ParamArray[ParamCount]+
                                           Upcase(WorkStr[Index]);
            Inc(Index);
            if Index<=Length(WorkStr)
              then
                begin
                  while (Index<=Length(WorkStr)) and (WorkStr[Index]<>#47)
                      and (WorkStr[Index]<>#32) and (WorkStr[Index]<>#34)
                      and (WorkStr[Index]<>#39) and (WorkStr[Index]<>#44)
                    do
                      begin
                        ParamArray[ParamCount]:=ParamArray[ParamCount]+
                                                Upcase(WorkStr[Index]);
                        Inc(Index);
                      end;
                  if (Index<=Length(WorkStr)) and ((WorkStr[Index]=#34)
                      or (WorkStr[Index]=#39))
                    then TxfrString;
                end;
          end;
      while (Index<=Length(WorkStr)) and (WorkStr[Index]=#32) do
        Inc(Index);
    until Index>Length(WorkStr);
  end;
 
begin  { Initialization Code }
  SetupParamArray;
end.
  
