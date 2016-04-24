(*
  Category: SWAG Title: STREAM HANDLING ROUTINES
  Original name: 0001.PAS
  Description: STREAMS1.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:57
*)

{
I have a question about registration of Objects to allow them
to be Put on the TDosStream. I want to Write my own Get Function,
but I don't know the name of Variable or even address which points
to the Array of Records of just registered Objects. I would like
to search For appriopriate Record on my own. Is it possible in TV6.0

Here si an article that was posted some time ago about locating
the tStreamRec suite in memory: I think it is what you want:

> BJ> I am looking For the location of the RegisterTypes
> BJ> Variables. if you make an Register of your Object- where it
> BJ> is stored ? Can I access it through a standard Variable ?
>if you look up the definition of TStreamRec on page 380 of the TVision
>manual a lot may become clearer to your.

  As any Typed Constants (another name could be initialized Variables)
  the tStreamRecs are stored in the DATA segment. The actual content is :
    PStreamRec = ^TStreamRec;
    TStreamRec = Record
      ObjType: Word;
      VmtLink: Word;
      Load: Pointer;
      Store: Pointer;
      Next: Word;      <====== this is the link to a next tStreamRec
    end;
  When registering a View , the Procedure RegisterType simply adds
  the new tStreamRec at the top of a stack by filling in the field
  Next (a Word only) since the segment is always DSEG.
  This Field now points to the offset in DSEG of the
  previously registered view...
  The top of the stack is located in a Word Variable
  which is private to the Objects Unit... No way to get it ???

  The trick is to register an extra dummy view after all your Real
  registrations.
  The private topofStack(???) Variable will now point to the offset of
  the Dummy View, and THE NEXT field of the dummy view will point
  to THE LAST REGISTERED VIEW. This is the beginning of the thread
  were are looking For....
  Just follow back the NEXT Fields Until a value of 0 that indicates
  the end of the stack (i.e; the first registered view )
  The following Program prints out the Stack of all the tSreamRec
  starting from the dummy view back to the tView streamRec which
  is normally the first registered item.
  We are using the technique to avoid the infamous Runtime error 212
    ( registration of an already registered Type ) , quite common
    if you include the registration process in the initialization part
     of Units . Simply Write a Function IsRegistered that take as
     a parameter a tStreamRec and return True if member of the Stack .
     ( code is Really similar to the exemple below )
   Replace any call to RegisterType(MyStreamRec) by
      if not IsRegistered  (MyStreamRec) then RegisterType(MyStreamRec)
---------------------------------------------------------------------------}
Program ShowStreamRecs;
{ (C) P.Pollet National Institute For Applied Sciences (inSA)
  Lyon France 1992  ppollet@cismibm.univ-lyon1.fr }
Uses Drivers,Objects,views,Dialogs,Menus;
Const
  RDummyView: TStreamRec = (
    ObjType: $FFFF;
    VmtLink: 0;
    Load:    NIL;
    Store:   NIL
  );
Function PtrtoStr(P:Pointer):String;
{ convert a Ptr to Hex representation }
Var S:String;
    Param:Array[0..1] of LongInt;
begin
  Param[0]:=Seg(P^);
  Param[1]:=ofs(P^);
  FormatStr(S,'%x:%x',Param);
  PtrtoStr:=S
end;
Function WordtoHex(W:Word):String;
{ convert a Word to Hex representation }
Var S:String;
    Param: LongInt;
begin
  Param:=W;
  FormatStr(S,'%x',Param);
  WordtoHex:=S
end;
Procedure ShowThem;
{ show the stack or the tStreamrec in DSeg }
Var Base:Word;
    Pt:PstreamRec;
      Procedure ShowArec (Var R:tstreamRec);
      { display Info on the tstreamrec R}
      { the Var is only to Pass the Real Address of R
        and not the address of its copy on the stack !!! }
      begin
        With R do
          begin
            Writeln ('AT      =',PtrtoStr(@R)); { gives the address of the StreamRec}
            Writeln ('ObjType =',ObjType);      { what Object is it see TV6 doc}
            Writeln ('VTMLink =',VmTlink);      { offset of VMT table also in DSEG }
            Writeln ('LOAD    =',PtrtoStr(Load)); { address of Load Constructor }
            Writeln ('StoRE   =',PtrtoStr(Store)); { address of store method }
            Writeln ('Next    =',WordtoHex(Next)); { offset in DSEG of next item }
            Writeln;
          end
      end;
begin
  Base:=ofs(RDummyView);    { start at Dummy view }
  Repeat
     Pt:=Ptr(DSeg,Base);    {Real address is DSG:base}
     ShowARec(Pt^);         {Display this tStreamRec }
     Base:=Pt^.Next;        { move to previous item }
   Until Base=0             { Until first reached }
end;
begin
  {Assign(Output,'RegType.log');}
  ReWrite(Output);
  RegisterViews;            { register some from TV }
  RegisterDialogs;
  RegisterMenus;
  RegisterType(RDummyView); { doN'T ForGET the DummyView at Last ! }
  ShowThem;
  Close(Output)
end.
(*
This is a partial print out of the output ...
AT      =86DC:2       { my Dumy View }
ObjType =65535
VTMLink =0
LOAD    =0:0
StoRE   =0:0
Next    =128      <----  { Real offset of the first VIEW }
                      |
AT      =86DC:128 <----  { the last register View }
ObjType =42              { it is tStatusLine  Type =42 }
VTMLink =184
LOAD    =79AB:1A84
StoRE   =79AB:22E9
Next    =11A       <----
                       |
AT      =86DC:11A  <----    { this is  tMenuBox }
ObjType =41
VTMLink =100
LOAD    =79AB:247
StoRE   =79AB:1171
Next    =10C
...................................
  cut to save space
...................................
AT      =86DC:91A     { this is the first registered }
ObjType =1            { tView Type =1 }
VTMLink =1726
LOAD    =7F1C:2C1
StoRE   =7F1C:18FE
Next    =0            {<-----  Next =0 so Last One of the Stack }
Hope it helps you ... Let me know ...

of course With TP7, since you have the sources code, you may
modify the OBjECTS Unit( ?) to move the Typed Constant that points at
the top of the list from the Implementation part of the Unit to the
Interface part....

