
Unit UnArc;
{$O+}


interface

Type
  UnCompressFileProc  = Procedure (ArcP:string);
  UnCompressFileProc2 = Procedure;
  UnCompressFileProc3 = Procedure (command,param:string);

Procedure LoadArchiveDef(fn:string);

Function UnCompressFile(  filepath    : String;
                          PreStats    : UnCompressFileProc;
                          ExecProc    : UnCompressFileProc3;
                          PreExec,
                          PostExec    : UnCompressFileProc2;
                        var
                          broken,
                          Sfx         : boolean;
                          errorstring : String):boolean;

Function CompressType:string;

function Compress(Destpath,SourcePath: String;
                          ExecProc    : UnCompressFileProc3;
                          PreExec,
                          PostExec    : UnCompressFileProc2;
                          var errstr:string ):boolean;


implementation

Uses Dos,Etc;

Const NumOfIDBytes = 20;

type
     ByteUsed = record Used: boolean;Val : byte; end;
     ToArcDefType = ^ArcDefType;
     ArcDefType = record
       Next     : ToArcDefType;
       Sfx      : boolean;
       ProgID   : String[3];
       Prog     : String[12];
       Param    : String[20];
       IDBlock  : array[1..NumOfIDBytes] of ByteUsed;
     end;

     ReCompressType = Record
       ProgID : String[3];
       Prog   : String[12];
       Param  : String[20];
       end;


Var ArcDefRoot: ToArcDefType;
    ArcP      : string[3];
    ReComp    : RecompressType;

function compresstype:string;
  begin
  compresstype := recomp.progid;
  end;


Procedure LoadArchiveDef(fn:string);
  type bt = array[1..2048] of byte;
  Var Cur: ToArcDefType;
      ADF: text;
      cl : string;
      b  : ^bt;

  procedure ProcessLine;
    var hdr:string[20];
        i  : byte;

    procedure Seek(a:char); begin cl:=copy(cl,pos(a,cl)+1,length(cl)); { seek to " } end;

    procedure Clean(a:char); begin cl:=copy(cl,pos(a,cl)+1,length(cl)) end;

    begin
    cl:=rtrim(ltrim(cl));
    if cl[1]<>';' then
      begin
      hdr:=upcasestr(copy(cl,1,pos(':',cl)));

      if copy(hdr,1,2)=copy('UN:',1,2) then {'UN'}
        begin
        if cur=nil then
             begin
             new(cur);
             cur^.next:=nil;
             ArcDefRoot:=Cur;
             end
          else
            begin
            new(cur^.next);
            cur:=cur^.next;
            cur^.next:=nil;
            end;

        Seek('"');
        Cur^.ProgID:=copy(cl,1,pos('"',cl)-1);
        Clean('"');

        Seek('"');
        Cur^.Prog:=Copy(cl,1,pos('"',cl)-1);
        clean('"');

        Seek('"');
        Cur^.Param:=copy(cl,1,pos('"',cl)-1);
        Clean('"');

        For i:=1 to NumOfIDBytes do Cur^.IDBlock[i].Used:=false;

        For i:=1 to NumOfIDBytes do
         begin
         seek('$');
         if length(cl)>0 then
           begin
           if copy(cl,1,2)<>'--' then
             begin
             Cur^.IDBlock[i].Val:=Hex2Byte(copy(cl,1,2));
             Cur^.IDBlock[i].used:=true;
             end
           else Cur^.IDblock[i].used:=false;
           delete(cl,1,2);
           end;
         end;

        if hdr='UNSFX:' then Cur^.SFX:=true else Cur^.SFX:=false;
        end
      else
       if HDR='TOARC:' then
        begin
        seek('"');
        ReComp.ProgID:=copy(cl,1,pos('"',cl)-1);
        clean('"');

        Seek('"');
        ReComp.Prog:=copy(cl,1,pos('"',cl)-1);
        Clean('"');

        seek('"');
        ReComp.Param:=copy(cl,1,pos('"',cl)-1);
        clean('"');

        end;

     end;
    end;

  begin
  new(b);
  ArcDefRoot := nil;
  cur:=ArcDefRoot;

  Assign(adf,fn);
  reset(adf);
  settextbuf(adf,b^,sizeof(b^));

  readln(adf,cl);
  processline;

  while not eof(adf) do
     begin
     Readln(adf,cl);
     processline;
     end;

  close(adf);
  Dispose(b);
  end;

  function Compress(Destpath,SourcePath: String;
                          ExecProc    : UnCompressFileProc3;
                          PreExec,
                          PostExec    : UnCompressFileProc2;
                          var errstr:string ):boolean;
    var
     Dir   : DirStr;
     Name  : NameStr;
     Ext   : ExtStr;
     a     : byte;
     f     : file;
     runstr: string;
     runparmr:string;
     runparmd:string;
     derror: integer;

    begin
    Compress := TRUE;

    runstr:=FSearch(ReComp.Prog,GetEnv('PATH'));

    if runstr='' then
     begin
     errstr:='Could not find '+recomp.prog+' in PATH';
     compress := false;
     exit;
     end;

    runparmr:=ReComp.Param+' '+destpath+' '+sourcepath;

    PreExec;

    Execproc(RunStr, RunParmR);

    postexec;

   derror:=dosexitcode;

  if not ((derror)=0) then
    begin
    errstr:='Device Error or Low Mem';
    compress := false;
    exit;
    end

    end;


Function UnCompressFile(  filepath    : String;
                          PreStats    : UnCompressFileProc;
                          ExecProc    : UnCompressFileProc3;
                          PreExec,
                          PostExec    : UnCompressFileProc2;
                        var
                          broken,
                          Sfx         : boolean;
                          errorstring : String):boolean;

  var tempfile :file;
      uncompstr:string;
      p        :string;
      bffr     :array[1..NumOfIDBytes] of byte;
      derror   :integer;

  var tts:string;

  Procedure WhichFormat;
    var cur      : ToArcDefType;

    function match:boolean;
     var i:byte;
     begin
     for i:=1 to NumOfIDBytes do
      if Cur^.IDBlock[i].Used then
       begin
       if not (bffr[i]=Cur^.IDBlock[i].Val) then
         begin
         Match:=False;
         Exit;
         end;
       end;
     Match:=true;
     end;

    begin

    { set uncompstr to '' for unrecognized compression }

    UnCompStr:='';

    Cur:=ArcDefRoot;

    while cur<>nil do
      begin
      if Match then begin
       UnCompStr:=Cur^.Prog;
       Sfx:=Cur^.Sfx;
       ArcP:=Cur^.ProgID;
       P:=Cur^.param;
       end;

      Cur:=Cur^.Next;
      end;
    end;

  var SizeToRead:word;

  begin

  errorstring:= '';

  assign(tempfile,filepath);
  reset(tempfile,1);

  if filesize(tempfile)<sizeof(bffr) then
      begin
      fillchar(bffr,sizeof(bffr),#0);
      sizetoread:=filesize(tempfile)-1;
      end
  else SizeToRead:=Sizeof(Bffr);

  blockread(tempfile,bffr,sizetoread);
  close(tempfile);

  Sfx:=false;

  WhichFormat;

  if UnCompStr='' then
     begin
     Broken:=False;
     errorstring :=  'Unknown Format';
     UnCompressFile:=False;
     Exit;
     end;


   uncompstr:=FSearch(UnCompStr,GetEnv('PATH'));

   if uncompstr='' then
     begin
     broken := false;
     ErrorString := 'Can''t Find UN-ARCHIVER for: '+ArcP;
     UnCompressFile := false;
     exit;
     end;

  PreStats (ArcP);

  tts:=fexpand('.\TEMP$$.$$');

  mkdir(tts);
  chdir( tts );

  PreExec;

  ExecProc(uncompstr,p+' '+filepath+' *.*');

  PostExec;

  derror:=dosexitcode;

  if not (hi(derror)=0) then
    begin
    ErrorString := 'Device Error - ^C or Low Memory';
    broken := false;
    UnCompressFile := false;
    exit;
    end;

  UnCompressFile := DError=0;

  Broken:=Not (DError=0);

  chdir( fexpand ('..') );

  end;



begin
 ArcDefRoot := nil;

end.
