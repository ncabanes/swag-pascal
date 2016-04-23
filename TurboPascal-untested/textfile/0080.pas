
unit TextObjs;
interface
Uses Dos;

Type OpenHowT = (ForceNewF,OpenExistF,AppendF);

type TextObj = Object
  Constructor Init(FN:string;FileMode:byte;BufSize:longint;OH:OpenHowT);
  Procedure Readln(var s:string);
  Procedure Writeln(s:string);
  Procedure Write(s:string);
  { some procedures,etc left out }
  Destructor Done;
  private { internal to object }
   F: text;
   BufP: Pointer;
   BufferSize: longint;
  end;

implementation

Constructor TextObj.Init(FN:string;FileMode:byte;BufSize:longint;
              oh:openhowT);
 begin
 BufferSize:=BufSize;
 GetMem(BufP,BufferSize);  { filemode isn't used here }
 {$I-}
 assign(F,fn);
 case OH of
   ForceNewF: Rewrite(f);
   OpenExistF: Reset(f);
   AppendF: Append(f)
   end;
 SetTextBuf(f,BufP^,BufferSize)
 end;

Procedure   TextObj.Readln(var s:string);
 begin System.Readln(f,s) end;

Procedure   TextObj.Writeln(s:string);
 begin System.Writeln(f,s) end;

Procedure   TextObj.Write(s:string);
 begin System.Write(f,s) end;

Destructor  TextObj.Done;
 begin
 Close(f);
 FreeMem(BufP,BufferSize)
 end;

end.



