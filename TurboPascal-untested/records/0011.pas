{
 To access record fields in Assembler you should define a Register to the
ofset of the variable s or Record..
Example:
}
Type MyRec = Record
       Hi :Byte;
       Lo :Word;
       S :String[90];
      End;
Var
 Yup :MyRec;
Begin
asM
       Mov     DI, Seg Yup;
       Push    DI;     { Save it just incase folloing code uses DI }
       { do what evr code you wish }
       Pop     DI      { Get back our pointer }
       Mov     [DI+MyRec.Hi], AL;      { Lets say AL was the reg u want }
       Mov     [DI+RyRec.Lo], BX;
       { Ect }
{       ....
Remember, if you enter an assembler rountine that passes a Array of Records
then you must Load AX with the size of Your Record, Take the Array Pointer
Index Times The AX using the MUL instructions then SubTrace the Size of the
Record from the AX which would be the Results fo the multiply and then add
that to the DI for a Total Offset to the correct Record;
Example:
 I want Record # 2
}
Procedure Test( AR:Array[1..4] of MyRec);
 Begin
  ASm
   Mov Di, Offset AR;
   Mov AX, TypeOF(MyRec);      { This generates the Size of the Record }
   MUL AX, 2;                  { I want to times it by 2 }
   SUB AX, TypeOf(MyRec);
   ADD DI,AX;
   { Now the DI pointers to the start of the #2 Record }
{ Of course this Record is on the stack in this example;
 Use a Globel methd or use the VAr in the Parms.
it you use VAR then the Address must be gotten indirectly.
Example:
}  LES  DI, AR;         { THis Loads the Address fo the Array from the STactk
 { Then you go through you same multipy stuff }
