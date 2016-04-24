(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0085.PAS
  Description: Detection of WILDCARDS
  Author: ALLEN WALKER
  Date: 11-26-94  05:08
*)

{
Here's a little routine I wrote that checks to see if S1=S2, with wildcards (?
or *)...  IE, Wildcard('TURBO.PAS','T?R*.?AS') will return TRUE.

Let me know if you find it useful...

Released for SWAG...
}

Function Wildcard(S1,S2:String):Boolean;
Var STmp1 : String[8];
    STmp2 : String[3];
    SS1, SS2 : String[12];
    I : Integer;
begin
  STmp1:=Copy(S1,1,Pos('.',S1+'.'))+'????????';
  If (Pos('.',S1)>1) then STmp2:=Copy(S1,Pos('.',S1)+1,3)+'???' else
STmp2:='???';  For I:=1 to 8 do If STmp1[I]='*' then For I:=I to 8 do
STmp1[I]:='?';  For I:=1 to 3 do If STmp2[I]='*' then For I:=I to 3 do
STmp2[I]:='?';  SS1:=STmp1+'.'+STmp2;
  STmp1:=Copy(S2,1,Pos('.',S2+'.'))+'????????';
  If (Pos('.',S2)>1) then STmp2:=Copy(S2,Pos('.',S2)+1,3)+'???' else
STmp2:='???';  For I:=1 to 8 do If STmp1[I]='*' then For I:=I to 8 do
STmp1[I]:='?';  For I:=1 to 3 do If STmp2[I]='*' then For I:=I to 3 do
STmp2[I]:='?';  SS2:=STmp1+'.'+STmp2; WildCard:=False;
  For I:=1 to 12 do If (UpCase(SS1[I])<>UpCase(SS2[I])) and (SS2[I]<>'?') then
Exit;  WildCard:=True;
end;


--- GoldED 2.40
 * Origin: Crazy Train BBS (604)383-2201  (1:340/88)
SEEN-BY: 340/1 49 60 67 88 211 396/1 3615/50 51
PATH: 340/88 1 3615/50
                                                  
{SWAG=???.SWG,JORGEN OLSSON,Wild cards}
MSGID: 2:205/201@fidonet 94931c10
REPLY: 1:249/153.0 2ea83a7a
PID: GE 1.01+
Hello, John!

 > I'm looking for some sort of function to return that:
 > SOMEFILE.TXT = SOM*.TX?

 > Function WildCompare(str1,st2: String): boolean;

Hope you'll find this one useful to you. Not very beautiful (this message
editor is obviously not made for writing pascal source :)), but it works.

---cut---

FUNCTION WildComp(wild,name:string):boolean;
BEGIN
   WildComp:=FALSE;
   if name = '' then exit;
   CASE wild[1] of
      '*' : BEGIN
              if name[1]='.' then exit;
              if length(wild)=1 then WildComp:=TRUE;
              if (length(wild) > 1) and (wild[2]='.') and (length(name) > 0)
              then WildComp:=WildComp(copy(wild,3,length(wild)-2),
                   copy(name,pos('.',name)+1,length(name)-pos('.',name)));
            END;

       '?': BEGIN
              if ord(wild[0])=1
                 then WildComp:=TRUE
                 else WildComp:=WildComp(copy(wild,2,length(wild)-1),
                                         copy(name,2,length(name)-1));
            END;

       ELSE if name[1] = wild[1]
                 then if length(wild) > 1
                      then WildComp:=WildComp(copy(wild,2,length(wild)-1),
                                              copy(name,2,length(name)-1))
                      else if (length(name)=1)
                           and (length(wild)=1)
                           then WildComp:=TRUE
                 else WildComp:=FALSE;
   END;
END;

