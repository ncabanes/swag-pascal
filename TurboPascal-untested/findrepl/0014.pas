   SYMBOL TABLE

   All Compilers and interpreters must maintain a data structure
   called the SYMBOL TABLE. This is where all the inFormation about
   the Programs symbols are kept. Maintaining a well-organized
   symbol table is a skill all Compiler Writers must master.

   As a Compiler parses a source Program, it relies on the symbol
   table to provide inFormation about each identifier (such as
   Variables and Constants) - it must be able to access and update
   inFormation about each identifier and do so quickly - otherwise
   the process is slowed or produces incorrect results.

   No matter what inFormation is kept, or how the table is organized
   certain operations are fundamental to a symbol tables operation.

   You ENTER inFormation about about an identifier into the table by
   *creating* and entry.

   You SEARCH the table to look up an identifier's entry and make
   available the inFormation in that entry.

   You UPDATE the entry to modify stored inFormation.

   There can be only one entry per identifier in the symbol table,
   so you must first search the table beFore making a new entry.

   TABLE ORGANIZATION

   There are many different ways to handle symbol tables: Arrays,
   linked lists, hash tables...but since the most common operations
   perFormed on a symbol table are searching it For existing entries
   it makes perfect sense to implement it as a BINARY TREE.

   Each NODE in the TREE contains and entry, and points to two other
   nodes. The *values* of the nodes on the subtree to the left are
   always LESS than the parent node, While the subtree to the right
   is always MORE than the parent. This makes searching sorted
   binary trees very efficient.

   Inserting new nodes is as easy as searching the tree: if the
   value you want to insert is LESS than the current node, search
   the node to the left. If it is MORE, search the tree to the right.
   Keep doing this recursively Until an empty node is found, then
   insert the value into that node.

   NITTY-GRITTY

   Now that we've covered some background on the table, here's a
   recap on the symbol table Type defs. For those that missed them
   in the first message, or didn't save them:

Type
   sptr = ^String; { useful For minimum-size allocation }

   DEFN_KEY = (UNDEFINED,
               Const_DEFN, Type_DEFN, Var_DEFN, FIELD_DEFN,
               VALPARM_DEFN, VarPARM_DEFN,
               PROG_DEFN, PROC_DEFN, FUNC_DEFN
              );

   ROUTINE_KEY = (rkDECLARED, rkForWARD,
                  rkREAD, rkREADLN, rkWrite, rkWriteLN,
                  rkABS, rkARCTAN, rkCHR, rkCOS, rkEOF, rkEOLN,
                  rkEXP, rkLN, rkODD, rkORD, rkPRED, rkROUND,
                  rkSIN, rkSQR, rkSQRT, rkSUCC, rkTRUNC
                 );

   RTN_BLOCK = Record               {info about routine declarations}
      key              :ROUTINE_KEY;
      parm_count,
      total_parm_size,
      total_local_size :Word;
      parms, locals,
      local_symtab     :SYMTAB_PTR; {symbol tables of routine}
      code_segment     :sptr;       {interpreter}
   end;

   DTA_BLOCK = Record
      offset     :Word;
      Record_idp :SYMTAB_PTR;
   end;

   INFO_REC = Record
      Case Byte of
        0:(Constant :VALUE);     { literal value }
        1:(routine  :RTN_BLOCK); { identifier is routine }
        2:(data     :DTA_BLOCK); { identifier is data }
   end;

   DEFN_REC = Record
      key  :DEFN_KEY; { what is identifier? }
      info :INFO_REC; { stuff about identifier }
   end;

   SYMTAB_PTR  = ^SYMTAB_NODE;
   SYMTAB_NODE = Record          {actual tree node}
      left, right   :SYMTAB_PTR; {Pointers to left and right subtrees}
      next          :SYMTAB_PTR; {For chaining a node}
      name          :sptr;       {identifier name String}
      level,                     {nesting level}
      co_index      :Integer;    {code Label index}
      defn          :DEFN_REC;   {definition info}
   end; { Record }

   EXCERCISE #1

   Implement a symbol table SEARCH routine, and a symbol table ENTER
   routine. Both routines must accept a Pointer to the root of the
   tree, and the name of the identifier you are working With, and
   must return a Pointer to the node that was found in the search
   routine, or enters in the enter routine. If no node was found, or
   entered, the routines must return NIL.

   The resulting symbol table should be a sorted tree.



│   Implement a symbol table SEARCH routine, and a symbol table ENTER
│   routine. Both routines must accept a Pointer to the root of the
│   tree, and the name of the identifier you are working with, and
│   must return a Pointer to the node that was found in the search
│   routine, or enters in the enter routine. If no node was found, or
│   entered, the routines must return NIL.
│   The resulting symbol table should be a sorted tree.



Function Enter(root: SymTab_Ptr; PidStr: spstr): SymTab_Ptr;
{ - inserts a new indetifier String PidStr in the symol table. }
{ - nil is returned if duplicate identifier is found.          }
Var
  Ptemp: SymTab_Ptr;
begin
  if (root <> nil) then    { not a terminal node }
    if (PidStr = root^.name) then
      begin
        Enter := nil;
        Exit
      end
    else    { recursive insertion calls to either left or right sub-tree }
      if (PidStr > root^.name) then
        Enter(root^.right, PidStr)
      else
        Enter(root^.left, PidStr)
  else { a terminal node }
    begin
      new(Ptemp);     { create a new tree leaf node }
      Ptemp^.name := PidStr;
      Ptemp^.left := nil;
      Ptemp^.right := nil
    end
end; { Enter }


Function Search(root: SymTab_Ptr; PidStr: spstr): SymTab_Ptr;
{ - search For a certain identifier String PidStr in the symbol table. }
{ - returns nil if search faild.                                       }
begin
  While (root <> nil) and (PidStr <> root^.name) do
    if (PidStr > root^.name) then     { search the right sub-tree }
      root := root^.right
    else
      if (PidStr < root^.name) then
        root := root^.left;           { search the left sub-tree  }
   Search := root                     { return the node           }
end;

{===========================================================================}

Comment:
     What made you choose BINARY trees over AVL trees?  With binary trees,
     the structure may become degenerate (unbalanced) and, the routines for
     searching and insertion becomes inefficient.

>Comment:
>     What made you choose BINARY trees over AVL trees?  With binary trees,
>     the structure may become degenerate (unbalanced) and, the routines for
>     searching and insertion becomes inefficient.

   Glad you could join us!

   I chose a binary tree because it's simple and easy to Write, also
   a degenerate tree isn't much of a concern, simply because it's
   intended to hold only identifiers and Constants, not every
   statement. :)

   As long as it sorts the data as it inserts, it will work. This
   isn't, after all, a graduate "course". The intention is to teach
   people how compilers work and show interested parties how to
   understand and Write their own, if they're interested. This is
   YOUR compiler you're writing, if you want to implement an AVL
   tree, go ahead!

>Function Search(root: SymTab_Ptr; PidStr: spstr): SymTab_Ptr;

   This works. It's efficient and does the job.

>Function Enter(root: SymTab_Ptr; PidStr: spstr): SymTab_Ptr;

>    else    { recursive insertion calls to either left or right sub-tree }
>      if (PidStr > root^.name) then
>        Enter(root^.right, PidStr)
>      else
>        Enter(root^.left, PidStr)

   Note: recursive calls shouldn't be necessary in this Function.
   You can search the table the same way you did With Search, and
   you don't run the risk of running out of stack space. Procedure
   calls can also be exensive, slowing down the Program too much
   especially if a lot of symbols are searched.

>  else { a terminal node }
>    begin
>      new(Ptemp);     { create a new tree leaf node }
>      Ptemp^.name := PidStr;
>      Ptemp^.left := nil;
>      Ptemp^.right := nil
>    end
>end; { Enter }

   Please note that there is a lot of data that will be have to
   added to this section over time, as an identifier could be
   ANYTHING from a ConstANT to a Program identifier.

   That isn't too important right now, as we're just getting started
   on the symbol table but suggest you add the following lines, for
   use later:

   Ptemp^.info     := NIL;
   Ptemp^.defn.key := UNDEFINED;
   Ptemp^.level    := 0;     {recursion level}
   Ptemp^.Label_index := 0;  {Label # to be used in code output}
