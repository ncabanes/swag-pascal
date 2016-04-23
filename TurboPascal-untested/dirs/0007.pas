{ DIRDEMO.PAS
  Author: Trevor Carlsen. Released into the public domain 1989
                          Last modification 1992.
  Demonstrates in a very simple way how to display a directory in a screen
  Window and scroll backwards or Forwards.  }

Uses
  Dos,
  Crt,
  keyinput;

Type
  str3    = String[3];
  str6    = String[6];
  str16   = String[16];
  sType   = (_name,_ext,_date,_size);
  DirRec  = Record
              name  : NameStr;
              ext   : ExtStr;
              size  : str6;
              date  : str16;
              Lsize,
              Ldate : LongInt;
              dir   : Boolean;
            end;

Const
  maxdir       = 1000;     { maximum number of directory entries }
  months : Array[1..12] of str3 =
           ('Jan','Feb','Mar','Apr','May','Jun',
            'Jul','Aug','Sep','Oct','Nov','Dec');
  WinX1 = 14; WinX2 = 1;
  WinY1 = 65; WinY2 = 23;
  LtGrayOnBlue      = $17;
  BlueOnLtGray      = $71;
  page              = 22;
  maxlines : Word   = page;

Type
  DataArr           = Array[1..maxdir] of DirRec;

Var
  DirEntry          : DataArr;
  x, numb           : Integer;
  path              : DirStr;
  key               : Byte;
  finished          : Boolean;
  OldAttr           : Byte;

Procedure quicksort(Var s; left,right : Word; SortType: sType);
  Var
    data      : DataArr Absolute s;
    pivotStr,
    tempStr   : String;
    pivotLong,
    tempLong  : LongInt;
    lower,
    upper,
    middle    : Word;

  Procedure swap(Var a,b);
    Var x : DirRec Absolute a;
        y : DirRec Absolute b;
        t : DirRec;
    begin
      t := x;
      x := y;
      y := t;
    end;

  begin
    lower := left;
    upper := right;
    middle:= (left + right) div 2;
    Case SortType of
      _name: pivotStr   := data[middle].name;
      _ext : pivotStr   := data[middle].ext;
      _size: pivotLong  := data[middle].Lsize;
      _date: pivotLong  := data[middle].Ldate;
    end; { Case SortType }
    Repeat
      Case SortType of
        _name: begin
                 While data[lower].name < pivotStr do inc(lower);
                 While pivotStr < data[upper].name do dec(upper);
               end;
        _ext : begin
                 While data[lower].ext < pivotStr do inc(lower);
                 While pivotStr < data[upper].ext do dec(upper);
               end;
        _size: begin
                 While data[lower].Lsize < pivotLong do inc(lower);
                 While pivotLong < data[upper].Lsize do dec(upper);
               end;
        _date: begin
                 While data[lower].Ldate < pivotLong do inc(lower);
                 While pivotLong < data[upper].Ldate do dec(upper);
               end;
      end; { Case SortType }
      if lower <= upper then begin
        swap(data[lower],data[upper]);
        inc(lower);
        dec(upper);
       end;
    Until lower > upper;
    if left < upper then quicksort(data,left,upper,SortType);
    if lower < right then quicksort(data,lower,right,SortType);
  end; { quicksort }

Function Form(st : String; len : Byte): String;
  { Replaces spaces in a numeric String With zeroes  }
  Var
    x : Byte ;
  begin
    Form := st;
    For x := 1 to len do
      if st[x] = ' ' then
        Form[x] := '0'
  end;

Procedure ReadDir(Var count : Integer);
  { Reads the current directory and places in the main Array }
  Var
    DirInfo    : SearchRec;

  Procedure CreateRecord;
    Var
      Dt : DateTime;
      st : str6;
    begin
      With DirEntry[count] do begin
        FSplit(DirInfo.name,path,name,ext);             { Split File name up }
        if ext[1] = '.' then                                { get rid of dot }
          ext := copy(ext,2,3);
        name[0] := #8;  ext[0] := #3; { Force to a set length For Formatting }
        Lsize := DirInfo.size;
        Ldate := DirInfo.time;
        str(DirInfo.size:6,size);
        UnPackTime(DirInfo.time,Dt);
        date := '';
        str(Dt.day:2,st);
        date := st + '-' + months[Dt.month] + '-';
        str((Dt.year-1900):2,st);
        date := date + st + #255#255;
        str(Dt.hour:2,st);
        date := date + st + ':';
        str(Dt.Min:2,st);
        date := date + st;
        date := Form(date,length(date));
        dir := DirInfo.attr and Directory = Directory;
      end; { With }
    end; { CreateRecord }

  begin { ReadDir }
    count := 0;         { For keeping a Record of the number of entries read }
    FillChar(DirEntry,sizeof(DirEntry),32);           { initialize the Array }
    FindFirst('*.*',AnyFile,DirInfo);
    While (DosError = 0) and (count < maxdir) do begin
      inc(count);
      CreateRecord;
      FindNext(DirInfo);
    end; { While }
    if count < page then
      maxlines := count;
    quicksort(DirEntry,1,count,_name);
  end; { ReadDir }

Procedure DisplayDirectory(n : Integer);
  Var
    x,y : Integer;
  begin
    y := 1;
    For x := n to n + maxlines do
      With DirEntry[x] do begin
        GotoXY(4,y);inc(y);
        Write(name,'  ');
        Write(ext,' ');
        if dir then Write('<DIR>')
        else Write('     ');
        Write(size:8,date:18);
      end; { With }
  end; { DisplayDirectory }

begin { main }
  ClrScr;
  GotoXY(5,24);
  OldAttr  := TextAttr;
  TextAttr := BlueOnLtGray;
  Write(' F1=Sort by name F2=Sort by extension F3=Sort by size F4=Sort by date ');
  GotoXY(5,25);
  Write('   Use arrow keys to scroll through directory display - <ESC> quits   ');
  TextAttr := LtGrayOnBlue;
  Window(WinX1,WinX2,WinY1,WinY2);  { make the Window }
  ClrScr;
  HiddenCursor;
  ReadDir(numb);
  x := 1; finished := False;
  Repeat
    DisplayDirectory(x); { display maxlines Files }
      Case KeyWord of
      F1 {name} : begin
                    x := 1;
                    quicksort(DirEntry,1,numb,_name);
                  end;
      F2 {ext}  : begin
                    x := 1;
                    quicksort(DirEntry,1,numb,_ext);
                  end;
      F3 {size} : begin
                    x := 1;
                    quicksort(DirEntry,1,numb,_size);
                  end;
      F4 {date} : begin
                    x := 1;
                    quicksort(DirEntry,1,numb,_date);
                  end;
      home      : x := 1;
      endKey    : x := numb - maxlines;
      UpArrow   : if x > 1 then
                    dec(x);
      DownArrow : if x < (numb - maxlines) then
                    inc(x);
      PageDn    : if (x + page) > (numb - maxlines) then
                    x := numb - maxlines
                  else inc(x,page);
      PageUp    : if (x - page) > 0 then
                    dec(x,page)
                  else x := 1;
      escape    : finished := True
      end; { Case }
  Until finished;
  NormalCursor;
  TextAttr := OldAttr;
  ClrScr;
end.

