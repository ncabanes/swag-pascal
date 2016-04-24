(*
  Category: SWAG Title: MAIL/QWK/HUDSON FILE ROUTINES
  Original name: 0010.PAS
  Description: FIDO Nodelist
  Author: LUCAS NEALAN
  Date: 11-02-93  05:42
*)

{
LUCAS NEALAN

> Does anyone have any code/specs (in Pascal preferred) of how to
> manipulate the Version 6 FidoNet NodeList??
}

Type
  nodeflags =  { NODELIST.DAT status flags }
    (hub,      { node is a net hub }
     host,     { node is a net host }
     region,   { node is region coord }
     zone,     { node is a zone coord }
     cm,       { runs continuous mail }
     ores1,    { reserved For Opus }
     ores2,    { reserved For Opus }
     ores3,    { reserved For Opus }
     ores4,    { reserved For Opus }
     ores5,    { reserved For Opus }
     nores1,   { reserved For non-Opus }
     nores2,   { reserved For non-Opus }
     nores3,   { reserved For non-Opus }
     nores4,   { reserved For non-Opus }
     nores5,   { reserved For non-Opus }
     nores6    { reserved For non-Opus }
    );

  modemTypes = { NODELIST.DAT modem Type flags }
    (hst,      { node Uses a USRobotics HST modem }
     pep,      { node Uses a Telebit PEP modem }
     v32,      { node Uses a V.32 modem }
     v32b,     { node Uses a V.32bis modem }
     h96       { node Uses a Hayes Express96 modem }
    );

  nodedatarec = Record { NODELIST.DAT : Version 6 nodelist data }
    net      : Integer;               { net number }
    node     : Integer;               { node number }
    cost     : Integer;               { cost per minute to call }
    name     : Array [0..33] of Byte; { node name }
    phone    : Array [0..39] of Byte; { phone number }
    city     : Array [0..29] of Byte; { city and state }
    passWord : Array [0..7] of Byte;  { passWord }
    Realcost : Integer;               { phone company's Charge }
    hubnode  : Integer;               { node # of this node's hub (0=none) }
    rate     : Byte;                  { actual bps rate divided by 300 }
    modem    : set of modemTypes;     { modem Type codes }
    flags    : set of nodeflags;      { set of flags }
    res      : Array [1..2] of Byte;  { RESERVED }
  end;

  nodeindexrec = Record { NODELIST.IDX : Version 6 nodelist index }
    node : Integer;       { node number }
    net  : Integer;        { net number }
  end;


