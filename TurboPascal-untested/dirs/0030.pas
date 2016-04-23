{
  Next in this continuing series of code: the actual directry
  object.
}

Unit Dirs;
{
  A directory management object from a concept originally by Allan
  Holub, as discussed in Byte Dec/93 (Vol 18, No 13, page 213)

  Turbo Pascal code by Larry Hadley, tested using BP7.
}
INTERFACE

Uses Sort, DOS;

TYPE
   pSortSR = ^oSortSR;
   oSortSR = OBJECT(oSortTree)
      procedure   DeleteNode(var Node); virtual;
   end;

   callbackproc = procedure(name :string; lev :integer);

   prec  = ^searchrec;

   pentry = ^entry;
   entry  = record
      fil          :prec;
      next, last   :pentry;
   end;

   pdir  = ^dir;
   dir   = record
      flist  :pentry;
      count  :word;
      path   :string[80];
   end;

   pDirectry = ^Directry;
   Directry  = OBJECT
      dirroot   :pdir;

      constructor Init(path, filespec :string; attribute :byte);
      destructor  Done;

      procedure   Load(path, filespec :string; attribute :byte);
      procedure   Sort;
      procedure   Print;
   END;

CONST
   NotDir  = ReadOnly+Hidden+SysFile+VolumeID+Archive;
   dosattr : array[0..8] of char = '.rhsvdaxx';

procedure TraverseTree(root :string; pcallproc :pointer; do_depth :boolean);

IMPLEMENTATION

var
   treeroot :pSortSR; { sorting tree object }

procedure disposelist(ls :pentry);
var
   lso :pentry;
begin
   while ls<>NIL do
   begin
      dispose(ls^.fil);
      lso := ls;
      ls := ls^.next;
      dispose(lso);
   end;
end;

{ Define oSortSR.DeleteNode method so object knows how to dispose of
  individual data pointers in the event that "Done" is called before
  tree is empty. }
procedure   oSortSR.DeleteNode(var Node);
var
   pNode :pRec ABSOLUTE Node;
begin
   dispose(pNode);
end;

constructor Directry.Init(path, filespec :string; attribute :byte);
var
   pathspec :string;
   node     :pentry;
   i        :word;
BEGIN
   FillChar(Self, SizeOf(Self), #0);
   Load(path, filespec, attribute); { scan specified directory }
   if dirroot^.count=0 then         { if no files were found, abort }
   begin
      if dirroot<>NIL then
      begin
         disposelist(dirroot^.flist);
         dispose(dirroot);
      end;
      FAIL;
   end;
 { the following code expands the pathspec to a full qualified path }
   pathspec := dirroot^.path+'\';
   node := dirroot^.flist;
   while ((node^.fil^.name='.') or (node^.fil^.name='..')) and
         (node^.next<>NIL) do
      node := node^.next;
   if node^.fil^.name='..' then
      pathspec := pathspec+'.'
   else
      pathspec := pathspec+node^.fil^.name;
   pathspec := FExpand(pathspec);
   i := Length(pathspec);
   repeat
      Dec(i);
   until (i=0) or (pathspec[i]='\');
   if i>0 then
   begin
      Delete(pathspec, i, Length(pathspec));
      dirroot^.path := pathspec;
   end;
END;

destructor  Directry.Done;
begin
   if dirroot<>NIL then
   begin
      disposelist(dirroot^.flist);
      dispose(dirroot);
   end;
end;

procedure   Directry.Load(path, filespec :string; attribute :byte);
{ scan a specified directory with a specified wildcard and attribute
  byte }
var
   count   : word;
   pstr    : pathstr;
   dstr    : dirstr;
   srec    : SearchRec;
   dirx    : pdir;
   firstfl, thisfl, lastfl  : pentry;
begin
   count := 0;
   New(firstfl);
   with firstfl^ do
   begin
      next := NIL; last := NIL; New(fil);
   end;
   thisfl := firstfl; lastfl := firstfl;
   dstr  := path;
   if path = '' then dstr := '.';
   if dstr[Length(dstr)]<>'\' then dstr := dstr+'\';
   if filespec = '' then filespec := '*.*';
   pstr := dstr+filespec;

   FindFirst(pstr, attribute, srec);
   while DosError=0 do { while new files are found... }
   begin
      if srec.attr = (srec.attr and attribute) then
 { make sure the attribute byte matches our required atttribute mask }
      begin
         if count>0 then
 { if this is NOT first file found, link in new node }
         begin
            New(thisfl);
            lastfl^.next := thisfl;
            thisfl^.last := lastfl;
            thisfl^.next := NIL;
            New(thisfl^.fil);
            lastfl := thisfl;
         end;
         thisfl^.fil^ := srec;
         Inc(count);
      end;
      FindNext(srec);
   end;
 { construct root node }
   New(dirx);
   with dirx^ do
      flist := firstfl;
   dirx^.path  := path;  { path specifier for directory list }
   dirx^.count := count; { number of files in the list }

   if dirroot=NIL then
      dirroot := dirx
   else
   begin
      disposelist(dirroot^.flist);
      dispose(dirroot);
      dirroot := dirx;
   end;
end;

{ The following function is the far-local function needed for the
  SORT method (which uses the sort unit posted earlier)
  Note that this is hard-coded to sort by filename, then extension.
  I plan to rewrite this later to allow user-selectable sort
  parameters and ordering. }
function Comp(d1, d2 :pointer):integer; far;
   var
      data1 :pRec ABSOLUTE d1;
      data2 :pRec ABSOLUTE d2;
      name1, name2, ext1, ext2  :string;
   begin
 { This assures that the '.' and '..' dirs will always be the first
   listed. }
      if (data1^.name='.') or (data1^.name='..') then
      begin
         Comp := -1;
         EXIT;
      end;
      if (data2^.name='.') or (data2^.name='..') then
      begin
         Comp := 1;
         EXIT;
      end;
      with data1^ do
      begin
         name1 := Copy(name, 1, Pos('.', name)-1);
         ext1  := Copy(name, Pos('.', name)+1, 3);
      end;
      with data2^ do
      begin
         name2 := Copy(name, 1, Pos('.', name)-1);
         ext2  := Copy(name, Pos('.', name)+1, 3);
      end;
      if name1=name2 then
 { If filename portion is equal, use extension to resolve tie }
      begin
         if ext1=ext2 then
 { There should be NO equal filenames, but handle anyways for
   completeness... }
            Comp := 0
         else
            if ext1>ext2 then
               Comp := 1
            else
               Comp := -1;
      end
      else
         if name1>name2 then
            Comp := 1
         else
            Comp := -1;
   end;

{ Sort method uses the sort unit to sort the collected directory
  entries. }
procedure   Directry.Sort;
var
   s1, s2 :string;
   p1     :pentry;

 { This local procedure keeps code more readable }
   procedure UpdatePtr(var prev :pentry; NewEntry :pointer);
   begin
      if NewEntry<>NIL then { check to see if tree is empty }
      begin
         New(prev^.next);
         prev^.next^.fil  := NewEntry;
         prev^.next^.last := prev;
         prev := prev^.next;
         prev^.next := NIL;
      end
      else
         prev := prev^.next;
       { tree is empty, flag "done" with NIL pointer }
   end;

begin
   p1 := dirroot^.flist;
   New(treeroot, Init(Comp));
{ Create a sort tree, point to our COMP function }
   while p1<>NIL do
{ Go through our linked list and insert the items into the sorting
  tree, dispose of original nodes as we go. }
   begin
      if p1^.last<>NIL then
         dispose(p1^.last);
      treeroot^.InsertNode(p1^.fil);
      if p1^.next=NIL then
      begin
         dispose(p1);
         p1 := NIL;
      end
      else
         p1 := p1^.next;
   end;
{ Reconstruct directory list from sorted tree }
   New(dirroot^.flist);
   with dirroot^ do
   begin
      flist^.next := NIL;
      flist^.last := NIL;
      flist^.fil := treeroot^.ReadLeftNode;
   end;
   if dirroot^.flist^.fil<>NIL then
   begin
      p1 := dirroot^.flist;
      while p1<>NIL do
         UpdatePtr(p1, treeroot^.ReadLeftNode);
   end;
{ We're done with sorting tree... }
   dispose(treeroot, Done);
end;

procedure   Directry.Print;
{ currently prints the entire list, may modify this later to allow
  selective printing }
var
   s, s1 :string;
   e     :pentry;
   dt    :DateTime;
   dbg   :byte;

   procedure DoDateEle(var sb :string; de :word);
   begin
      Str(de, sb);
      if Length(sb)=1 then { Add leading 0's}
         sb := '0'+sb;
   end;

begin
   if dirroot=NIL then EXIT; { make sure empty dirs aren't attempted }
   e := dirroot^.flist;
   while e<>NIL do
   begin
      s := '';
      with e^.fil^ do
      begin
         dbg := 1;
         repeat
            case dbg of { parse attribute bits }
              1: s := s+dosattr[(attr and $01)];
              2: s := s+dosattr[(attr and $02)];
              3: if (attr and $04) = $04 then
                    s := s+dosattr[3]
                 else
                    s := s+dosattr[0];
              4: if (attr and $08) = $08 then
                    s := s+dosattr[4]
                 else
                    s := s+dosattr[0];
              5: if (attr and $10) = $10 then
                    s := s+dosattr[5]
                 else
                    s := s+dosattr[0];
              6: if (attr and $20) = $20 then
                    s := s+dosattr[6]
                 else
                    s := s+dosattr[0];
              else
                 s := s+dosattr[0];
            end;
            Inc(dbg);
         until dbg>8;
         s := s+' ';
   { Kludge to make sure that extremely large files (>=100MB) don't
     overflow size field... }
         if size<100000000 then
            Str(size:8, s1)
         else
         begin
            Str((size div 1000):7, s1); { decimal kilobytes }
            s1 := s1+'k';
         end;
         s := s+s1+' ';
   { Format date/time fields }
         UnpackTime(Time, dt);
         {month}
         DoDateEle(s1, dt.month); s := s+s1+'/';
         {day}
         DoDateEle(s1, dt.day);   s := s+s1+'/';
         {year}
         DoDateEle(s1, dt.year);  s := s+s1+' ';
         {hour}
         DoDateEle(s1, dt.hour);  s := s+s1+':';
         {minutes}
         DoDateEle(s1, dt.min);   s := s+s1+':';
         {seconds}
         DoDateEle(s1, dt.sec);   s := s+s1+' - ';
         s := s+dirroot^.path+'\'+name;
      end;
      Writeln(s); s := '';
      e := e^.next;
   end;
   Writeln; Writeln('  ', dirroot^.count, ' files found.'); Writeln;
end;

{ If TraverseTree is not given a callback procedure, this one is
  used. }
procedure   DefaultCallback(name :string; lev :integer); far;
var
   s :string;
const
   spaces = '                                               ';
begin
   s := Copy(spaces, 1, lev*4); s := s+name;
   Writeln(s);
end;

{ TraverseTree is untested as yet, rest of code (above) works fine.
  Note that TraverseTree is NOT a member method of DIRECTRY. Read
  the BYTE Dec/93 article for a clarification of why it is good
  that it not be a member.}
procedure TraverseTree(root :string; pcallproc :pointer; do_depth :boolean);
var
   level    :integer;
   fullpath :string;
   rootdir  :pdir;
const
   callproc : callbackproc = DefaultCallBack;

 { Actual recursive procedure to scan down directory structure
   using the DIRECTRY object. }
   procedure Tree(newroot :string; callee :callbackproc; do_last :boolean);
   var
      subdirs  :pdirectry;
      direntry :pentry;

      Procedure DoDir;
      begin
         New(subdirs, Init(newroot, '*.*', NotDir));
         if subdirs<>NIL then
         begin
            subdirs^.sort;
            direntry := subdirs^.dirroot^.flist;
            while direntry<>NIL do
            begin
               fullpath := newroot+'\'+direntry^.fil^.name;
               callee(newroot, level);
               direntry := direntry^.next;
            end;
            dispose(subdirs, done);
         end;
      end;

   begin
      if not(do_last) then
         DoDir;

      New(subdirs, Init(newroot, '*.*', directory));

      if subdirs<>NIL then
      begin
         subdirs^.sort;
         direntry := subdirs^.dirroot^.flist;
         while direntry<>NIL do
         begin
            Inc(level);
            fullpath := newroot+'\'+direntry^.fil^.name;
            Tree(fullpath, callee, do_last);
            dec(level);
            direntry := direntry^.next;
         end;
         dispose(subdirs, done);
      end;

      if do_last then
         DoDir;
   end;

begin
   level := 0;

   if pcallproc<>NIL then
      callproc := callbackproc(pcallproc^);

   root := fexpand(root);
   if root[Length(root)]='\' then
      Delete(root, Length(root), 1);

   if not(do_depth) then
      callproc(root, level);

   Tree(root, callproc, do_depth);

   if do_depth then
      callproc(root, level);
end;

END.
