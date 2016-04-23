UNIT LinkList;

{-------------------------------------------------
          Generic linked list object            -
-------------------------------------------------}

{***************************************************************}
                          INTERFACE
{***************************************************************}

TYPE

    { Generic Linked List Handler Definition }

  NodeValuePtr = ^NodeValue;

  NodeValue = OBJECT
    CONSTRUCTOR Init;
    DESTRUCTOR  Done; VIRTUAL;
  END;

  NodePtr = ^Node;
  Node = RECORD
    Retrieve : NodeValuePtr;
    Next     : NodePtr;
  END;


    { Specific Linked List Handler Definition }

  NodeListPtr = ^NodeList;

  NodeList = OBJECT
    Items : NodePtr;
    CONSTRUCTOR Init;
    DESTRUCTOR Done; VIRTUAL;
    PROCEDURE Add (A_Value : NodeValuePtr);

    (* Iterator Functions *)

    PROCEDURE StartIterator (VAR Ptr : NodePtr);
    PROCEDURE NextValue (VAR Ptr : NodePtr);
    FUNCTION AtEndOfList (Ptr : NodePtr) : Boolean;
  END;

{***************************************************************}
                         IMPLEMENTATION
{***************************************************************}


CONSTRUCTOR NodeValue.Init;
BEGIN
END;

DESTRUCTOR NodeValue.Done;
BEGIN
END;

CONSTRUCTOR NodeList.Init;
BEGIN
  Items := NIL;
END;

DESTRUCTOR NodeList.Done;
    VAR
         Temp : NodePtr;
BEGIN
    WHILE Items <> NIL DO
    BEGIN
         Temp := Items;
         IF Temp^.Retrieve <> NIL THEN
              Dispose (Temp^.Retrieve, Done);
         Items := Items^.Next;
         Dispose (Temp);
    END;
END;

PROCEDURE NodeList.Add (A_Value : NodeValuePtr);
    VAR
         Cell : NodePtr;
         Temp : NodePtr;
BEGIN
    (* Go TO the END OF the linked list. *)
    Cell := Items;
    IF Cell <> NIL THEN
         WHILE Cell^.Next <> NIL DO
              Cell := Cell^.Next;

    New (Temp);
    Temp^.Retrieve := A_Value;
    Temp^.Next := NIL;
    IF Items = NIL
    THEN
         Items := Temp
    ELSE
         Cell^.Next := Temp;
END;

PROCEDURE NodeList.StartIterator (VAR Ptr : NodePtr);
BEGIN
    Ptr := Items;
END;

PROCEDURE NodeList.NextValue (VAR Ptr : NodePtr);
BEGIN
    IF Ptr <> NIL THEN
    Ptr := Ptr^.Next;
END;

FUNCTION NodeList.AtEndOfList (Ptr : NodePtr) : Boolean;
BEGIN
  AtEndOfList := (Ptr = NIL);
END;

END.

{ DEMO PROGRAM }

PROGRAM LL_Demo;

USES LinkList;

{ Turbo Pascal Linked List Object Example }

TYPE

  DataValuePtr = ^DataValue;

  DataValue = OBJECT (NodeValue)
    Value : Real;
    CONSTRUCTOR Init (A_Value : Real);
    FUNCTION TheValue : Real;
  END;

  DataList = OBJECT (NodeList)
    FUNCTION CurrentValue (Ptr : NodePtr) : Real;
    PROCEDURE SetCurrentValue (Ptr : NodePtr; Value : Real);
  END;

VAR
    Itr : NodePtr;
    TestLink : DataList;

{------ Unique methods to create for your linked list type -----}

CONSTRUCTOR DataValue.Init (A_Value : Real);
BEGIN
    Value := A_Value;
END;

FUNCTION DataValue.TheValue : Real;
BEGIN
  TheValue := Value;
END;

FUNCTION DataList.CurrentValue (Ptr : NodePtr) : Real;
BEGIN
  CurrentValue := DataValuePtr (Ptr^.Retrieve)^.TheValue;
END;

PROCEDURE DataList.SetCurrentValue (Ptr : NodePtr; Value : Real);
BEGIN
  DataValuePtr (Ptr^.Retrieve)^.Value := Value;
END;


BEGIN
  TestLink.Init;        {Create the list then add 5 values to it}

  TestLink.Add (New (DataValuePtr, Init (1.0)));
  TestLink.Add (New (DataValuePtr, Init (2.0)));
  TestLink.Add (New (DataValuePtr, Init (3.0)));
  TestLink.Add (New (DataValuePtr, Init (4.0)));
  TestLink.Add (New (DataValuePtr, Init (5.0)));

  TestLink.StartIterator (Itr);      {Display the list on screen}
  WHILE NOT TestLink.AtEndOfList (Itr) DO BEGIN
    Write (TestLink.CurrentValue (Itr) : 5 : 1);
    TestLink.NextValue (Itr);
    END;
  WriteLn;

  TestLink.StartIterator (Itr);  {Change some values in the list}
  TestLink.SetCurrentValue (Itr, 0.0);
  TestLink.NextValue (Itr);
  TestLink.SetCurrentValue (Itr, -1.0);

  TestLink.StartIterator (Itr);       {Redisplay the list values}
  WHILE NOT TestLink.AtEndOfList (Itr) DO BEGIN
    Write (TestLink.CurrentValue (Itr) : 5 : 1);
    TestLink.NextValue (Itr);
  END;
  WriteLn;
  ReadLn;
END.
