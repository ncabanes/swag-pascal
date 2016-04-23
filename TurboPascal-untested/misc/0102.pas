{
 >Can anyone give me an idea of how to use a config file in my programs.
 >Such as an easy one, I am writing a program for my BBS in which this
 >program will Copy files to another directory.  I know I could put the
 >directory from and to in the code itself, but what I want to accomplish
 >is to use a Configuration file to read the from directory and to
 >directory.  This is so the program can be used anywhere. Can someone
 >please help me with this?

I posted a unit I wrote a day or so ago which can be modified to do this.
Here it is again (extensively modified to support an ASCII configuration
file):

Notes: Change the CFGKEYS constants to the keywords you want your program
to recognize (remember to change the CONFIGOPTIONS constant also).

}

Unit CFG_DEF;

Interface uses Dos;  { Dos unit is needed for FindFirst }

Const

CONFIGFILE = 'YOURFILE.CFG';
CONFIGOPTIONS = 5;
CFGKEYS : array[1..CONFIGOPTIONS] of string = ('YOUR',
                                               'CONFIG',
                                               'OPTIONS',
                                               'GO',
                                               'HERE');

Procedure Read_Cfg_File;

Implementation {----------------------------------------------}

Function Findfile(searchkey : string) : boolean;
 var srec : searchrec;
begin
 findfirst(searchkey,anyfile, srec);
 FindFile := (doserror = 0);
end;

Function Uppercase(st : string) : string;
 var loop : byte;
begin
 for loop := 1 to length(st) do st[loop] := upcase(st[loop]);
 uppercase := st;
end;

Procedure Read_Cfg_File;
 var f :text; i, j, loop : byte; line, key, command : string;
     Result_Table : array[1..CONFIGOPTIONS] of boolean;
begin
fillchar(Result_Table,sizeof(Result_Table),false);
command := #0;
line := #0;
key := #0;

{$I-}
assign(f,CONFIGFILE);
reset(f);
{$I+}
{CheckError(IOResult,CFGFILE);  <--- Add your own error checking here as
                                     my CheckError procedure is not included
                                     in this snippet. }
 while not EOF(f) do begin {while}
 readln(f,line);

 if (copy(line,1,1) <> #59) and
    (copy(line,1,1) <> #32) then begin  { ignore lines preceeded with a
                                         comment delimiter - usually #59
                                         (IE: ';')}
   j := pos(#32,line);

   if j = 0 then j := length(line)+1;
     key := copy(line,1,j-1);
     delete(line,1,j);
   i := pos(#59,line);

   if i = 0 then i := length(line)+1;

   command := copy(line,1,i-1);
   i := pos(#32,command);
   if i <> 0 then delete(command,i,length(command)-(i-1));

     for loop := 1 to CONFIGOPTIONS do begin {loop}
       if Uppercase(key) = CFGKEYS[loop] then begin {if}
         Result_Table[loop] := true;
         case loop of {case}
            1 : begin
                end;
            2 : begin
                end;
            3 : begin
                end;
            4 : begin
                end;
            5 : begin
                end;
             end; {case}
          end; {if}
       end; {loop}
    end; {if}
 end; {while}
close(f);
end; {proc}

end. {unit}
