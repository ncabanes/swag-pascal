(*
  Category: SWAG Title: RECORD RELATED ROUTINES
  Original name: 0005.PAS
  Description: RECSORT.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:55
*)

{
 ... would anyone know how-to sort a Record With 5 thing in it one of
 which is "NAME"...I want to sort each Record in the Array by name and
 can't figure it out....my Array name is LabelS and my Record name is
 SofT...
}

{ Note: this program will not work on its own,
as there is no data file }

Program sort_Records;

Type
  index_Type = 1..100;
  soft_Type = Record
                name,
                street,
                city: String[20];
                state: String[2];
                zip: Integer
              end; { Record }
  Labels_Type = Array[index_Type] of soft_Type;

Var
  Labels: Labels_Type; { an Array of Records }
  index,
  count: index_Type;
  f: Text; { a File on disk holding your Records, we assume 100 }

{ ******************************************** }
Procedure get_Records(Var f: Text;
                      Var Labels: Labels_Type); Var
  counter: index_Type;

begin { get_Records }
  For counter := 1 to 100 do
    begin
      With Labels[counter] do
        readln(f, name, street, city, state, zip);
    end;
end;  { get_Records }

{ ******************************************** }
Procedure sort_em(Var Labels: Labels_Type);

Var
  temp: soft_Type;    { a Single Record }
  counter,
  counter2,
  min_index: Integer;

begin { sort_em }
  For counter := 1 to 99 do { 99 not 100 }
    begin
      min_index := counter;
      For counter2 := counter + 1 to 100 do
        if Labels[counter2].name < Labels[counter].name
          then
            min_index := counter;
      temp := Labels[min_index];
      Labels[min_index] := Labels[counter];
      Labels[counter] := temp
    end;
end;  { sort_em }

{ ******************************************** }

Procedure Write_Labels(Var Labels: Labels_Type;
                       Var f: Text);
Var
  counter: index_Type;

begin { Write_Labels }
  For counter := 1 to 100 do
    begin
      With Labels[counter] do
        Writeln(f, name, street, city, state, zip);
    end;
end;  { Write_Labels }

{ ******************************************** }

begin { main }
  assign(f, 'DATAFile.DAT'); { or whatever it is on your disk }
  reset(f);
  get_Records(f, Labels);
  sort_em(Labels);
  reWrite(f);
  Write_Labels(Labels, f);
  close(f)
end. { main }
