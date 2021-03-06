unit parserThreadUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Xml.VerySimple, settingsHelper, addresses, Vcl.Dialogs,
  eventQueue, PriorityQueue, math, netmsg, inputer, log, parserThreadHelper;

type
  TParserThread = class(TThread)
    packetID: integer;
    FPacketQueue: array of TPacket;
  public
    function insert(packet: TPacket): integer;
    procedure delete( index: integer );
    function pop( index: integer = -1 ): TPacket;
  protected
    procedure Execute; override;
  end;

var
  m_skipTiles: word;

implementation

uses
  unit1;


function TParserThread.insert(packet: TPacket): integer;
var
  res: integer;
begin

  SetLength(FPacketQueue, length(FPacketQueue) + 1);
  res := length(FPacketQueue) - 1;

  FPacketQueue[res].buf := packet.buf;
  FPacketQueue[res].len := packet.len;

  result := res;
end;

procedure TParserThread.delete( index: integer );
var
  i: integer;
begin

  // je�eli podajemy z�� warto�� wtedy exit    --Si le damos el valor como un � � salga
  if index >= length(FPacketQueue) then exit;
  //if index < 0 then exit;

  // przesuwamy wszystkie obiekty by m�c skr�ci� tablice --mover todos los objetos a ser capaz de acortar las juntas
  if index = High(FPacketQueue) then
    SetLength(FPacketQueue, length(FPacketQueue) - 1)
  else
  begin
    for i := index to High(FPacketQueue) - 1 do
      FPacketQueue[i] := FPacketQueue[i + 1];
    SetLength(FPacketQueue, length(FPacketQueue) - 1);
  end;

end;

function TParserThread.pop( index: integer = -1 ): TPacket;
var
  id: integer;
begin

  if index > -1 then
  begin
    result := FPacketQueue[index];
    delete( index );
    exit;
  end;

  result.len := 0;
  id := 0;
  if length(FPacketQueue) > 0 then
  begin
    result := FPacketQueue[id];
    delete(id);
  end;

end;

procedure TParserThread.Execute;
var
  packet: TNetMsg;
  loc: TLocation;
  i,j: Integer;
  xmlNode: TXmlNode;
  subPacket: TPacket;
begin
  packet := TNetMsg.Create;

  while not Terminated do
  begin
    subPacket := pop();
    if subPacket.len > 0 then
    begin
      packet.LoadPacket(subPacket);

      while not (packet.isEOP) do
      begin
        //showmessage(packet.toString);
        packetID := packet.GetByte();
        if not GUI.Player.OnLine then break;

        case NewInPacketId(packetID) of

          NewInPacketId.inOUTFIT:
            begin
              readOUTFIT( packet );
            end;

          NewInPacketId.inMESSAGE:
            begin
              readMESSAGE( packet );    //este nos interesa no?
            end;

          NewInPacketId.inPING:
            begin
              readPING( packet );
            end;

          NewInPacketId.inWAIT:
            begin
              readWAIT( packet );
            end;

          NewInPacketId.inBUDDYDATA:
            begin
              readBUDDYDATA( packet );
            end;

          NewInPacketId.inCREATUREPARTY:
            begin
              readCREATUREPARTY( packet );
            end;

          NewInPacketId.inQUESTLOG:
            begin
              readQUESTLOG( packet );
            end;

          NewInPacketId.inFIELDDATA:
            begin
              readFIELDDATA( packet );
            end;

          NewInPacketId.inCLOSECONTAINER:
            begin
              readCLOSECONTAINER( packet );
            end;

          NewInPacketId.inLEFTROW:
            begin
              readLEFTROW( packet );
            end;

          NewInPacketId.inFULLMAP:
            begin
              readFULLMAP( packet );
            end;

          NewInPacketId.inMISSILEEFFECT:
            begin
              readMISSILEEFFECT( packet );
            end;

          NewInPacketId.inSPELLGROUPDELAY:
            begin
              readSPELLGROUPDELAY( packet );
            end;

          NewInPacketId.inBOTTOMROW:
            begin
              readBOTTOMROW( packet );
            end;

          NewInPacketId.inLOGINERROR:
            begin
              readLOGINERROR( packet );
            end;

          NewInPacketId.inQUESTLINE:
            begin
              readQUESTLINE( packet );
            end;

          NewInPacketId.inCREATURESKULL:
            begin
              readCREATURESKULL( packet );
            end;

          NewInPacketId.inTRAPPERS:
            begin
              readTRAPPERS( packet );
            end;

          NewInPacketId.inBUDDYLOGIN:
            begin
              readBUDDYLOGIN( packet );
            end;

          NewInPacketId.inSNAPBACK:
            begin
              readSNAPBACK( packet );
            end;

          NewInPacketId.inOBJECTINFO:
            begin
              readOBJECTINFO( packet );
            end;

          NewInPacketId.inCHANNELS:
            begin
              readCHANNELS( packet );
            end;

          NewInPacketId.inOPENCHANNEL:
            begin
              readOPENCHANNEL( packet );
            end;

          NewInPacketId.inTOPFLOOR:
            begin
              readTOPFLOOR( packet );
            end;

          NewInPacketId.inPRIVATECHANNEL:
            begin
              readPRIVATECHANNEL( packet );
            end;

          NewInPacketId.inLOGINWAIT:
            begin
              readLOGINWAIT( packet );
            end;

          NewInPacketId.inCREATEONMAP:
            begin
              readCREATEONMAP( packet );
            end;

          NewInPacketId.inCHALLENGE:
            begin
              readCHALLENGE( packet );
            end;

          NewInPacketId.inCONTAINER:
            begin
              readCONTAINER( packet );
            end;

          NewInPacketId.inNPCOFFER:
            begin
              readNPCOFFER( packet );
            end;

          NewInPacketId.inBUDDYLOGOUT:
            begin
              readBUDDYLOGOUT( packet );
            end;

          NewInPacketId.inMARKETBROWSE:
            begin
              readMARKETBROWSE( packet );
            end;

          NewInPacketId.inMARKETLEAVE:
            begin
              readMARKETLEAVE( packet );
            end;

          NewInPacketId.inCOUNTEROFFER:
            begin
              readCOUNTEROFFER( packet );
            end;

          NewInPacketId.inMARKETENTER:
            begin
              readMARKETENTER( packet );
            end;

          NewInPacketId.inCREATURESPEED:
            begin
              readCREATURESPEED( packet );
            end;

          NewInPacketId.inMARKCREATURE:
            begin
              readMARKCREATURE( packet );
            end;

          NewInPacketId.inSPELLDELAY:
            begin
              readSPELLDELAY( packet );
            end;

          NewInPacketId.inDELETEONMAP:
            begin
              readDELETEONMAP( packet );
            end;

          NewInPacketId.inCREATUREOUTFIT:
            begin
              readCREATUREOUTFIT( packet );
            end;

          NewInPacketId.inAMBIENTE:
            begin
              readAMBIENTE( packet );
            end;

          NewInPacketId.inPLAYERSKILLS:
            begin
              readPLAYERSKILLS( packet );
            end;

          NewInPacketId.inCREATUREUNPASS:
            begin
              readCREATUREUNPASS( packet );
            end;

          NewInPacketId.inDELETEINCONTAINER:
            begin
              readDELETEINCONTAINER( packet );
            end;

          NewInPacketId.inCREATEINCONTAINER:
            begin
              readCREATEINCONTAINER( packet );
            end;

          NewInPacketId.inCREATUREHEALTH:
            begin
              readCREATUREHEALTH( packet );
            end;

          NewInPacketId.inINITGAME:
            begin
              readINITGAME( packet );
            end;

          NewInPacketId.inTOPROW:
            begin
              readTOPROW( packet );
            end;

          NewInPacketId.inBOTTOMFLOOR:
            begin
              readBOTTOMFLOOR( packet );
            end;

          NewInPacketId.inPLAYERDATA:
            begin
              readPLAYERDATA( packet );
            end;

          NewInPacketId.inCREATURELIGHT:
            begin
              readCREATURELIGHT( packet );
            end;

          NewInPacketId.inTUTORIALHINT:
            begin
              readTUTORIALHINT( packet );
            end;

          NewInPacketId.inPLAYERGOODS:
            begin
              readPLAYERGOODS( packet );
            end;

          NewInPacketId.inPLAYERINVENTORY:
            begin
              readPLAYERINVENTORY( packet );
            end;

          NewInPacketId.inMOVECREATURE:
            begin
              readMOVECREATURE( packet );
            end;

          NewInPacketId.inEDITLIST:
            begin
              readEDITLIST( packet );
            end;

          NewInPacketId.inCLOSETRADE:
            begin
              readCLOSETRADE( packet );
            end;

          NewInPacketId.inSETINVENTORY:
            begin
              readSETINVENTORY( packet );
            end;

          NewInPacketId.inCHANGEONMAP:
            begin
              readCHANGEONMAP( packet );
            end;

          NewInPacketId.inDEAD:
            begin
              readDEAD( packet );
            end;

          NewInPacketId.inCHANGEINCONTAINER:
            begin
              readCHANGEINCONTAINER( packet );
            end;

          NewInPacketId.inDELETEINVENTORY:
            begin
              readDELETEINVENTORY( packet );
            end;

          NewInPacketId.inLOGINADVICE:
            begin
              readLOGINADVICE( packet );
            end;

          NewInPacketId.inCHANNELEVENT:
            begin
              readCHANNELEVENT( packet );
            end;

          NewInPacketId.inMARKETDETAIL:
            begin
              readMARKETDETAIL( packet );
            end;

          NewInPacketId.inTALK:
            begin
              readTALK( packet );
            end;

          NewInPacketId.inCLOSENPCTRADE:
            begin
              readCLOSENPCTRADE( packet );
            end;

          NewInPacketId.inRIGHTROW:
            begin
              readRIGHTROW( packet );
            end;

          NewInPacketId.inGRAPHICALEFFECT:
            begin
              readGRAPHICALEFFECT( packet );
            end;

          NewInPacketId.inEDITTEXT:
            begin
              readEDITTEXT( packet );
            end;

          NewInPacketId.inOPENOWNCHANNEL:
            begin
              readOPENOWNCHANNEL( packet );
            end;

          NewInPacketId.inCLEARTARGET:
            begin
              readCLEARTARGET( packet );
            end;

          NewInPacketId.inCLOSECHANNEL:
            begin
              readCLOSECHANNEL( packet );
            end;

          NewInPacketId.inAUTOMAPFLAG:
            begin
              readAUTOMAPFLAG( packet );
            end;

          NewInPacketId.inOWNOFFER:
            begin
              readOWNOFFER( packet );
            end;

          NewInPacketId.inPLAYERSTATE:
            begin
              readPLAYERSTATE( packet );
            end

        else
          begin
            break;
          end;

        end;
      end;
    end;
    sleep(1);
  end;

end;

end.
