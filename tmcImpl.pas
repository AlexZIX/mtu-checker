unit tmcImpl;

interface

uses IdTCPServer, System.SysUtils, IdContext, IdGlobal, IdTCPClient,
     IdUDPServer, IdSocketHandle, IdUDPClient;

type
  TMsgProc = procedure(Msg: String);

  TMTUChecker = class
  private
    tcpListener: TIdTCPServer;
    tcpClient: TIdTCPClient;
    udpListener: TIdUDPServer;
    udpClient: TIdUDPClient;
    FOnMsg: TMsgProc;
    FPort: UInt16;
    FUseUDP: Boolean;
    // TCP Client
    FFirstPacketSize, FLastPacketSize, FStep: UInt32;
    FHost: String;

    // TCP Server
    procedure OnExecute(AContext: TIdContext);

    // UDP Server
    procedure OnUDPRead(AThread: TIdUDPListenerThread; const AData: TIdBytes;
      ABinding: TIdSocketHandle);

    // TCP Client
    procedure OnConnected(Sender: TObject);
  public
    procedure StartServer;

    procedure SendRandomData;

    procedure PrintMsg(Msg: String);

    constructor Create(OnMsg: TMsgProc);
    destructor Destroy; override;

    property Port: UInt16 read FPort write FPort;
    property UseUDP: Boolean read FUSeUDP write FUseUDP;

    property FirstPacketSize: UInt32 read FFirstPacketSize write FFirstPacketSize;
    property LastPacketSize: UInt32 read FLastPacketSize write FLastPacketSize;
    property Step: UInt32 read FStep write FStep;
    property Host: String read FHost write FHost;
  end;

implementation

{ TMC }

constructor TMTUChecker.Create(OnMsg: TMsgProc);
begin
  FOnMsg := OnMsg;
  FUseUDP := False;
end;

destructor TMTUChecker.Destroy;
begin
  if Assigned(tcpListener) then
  begin
    tcpListener.Active := False;
    FreeAndNil(tcpListener);
  end;

  if Assigned(udpListener) then
  begin
    udpListener.Active := False;
    FreeAndNil(udpListener);
  end;

  if Assigned(tcpClient) then
  begin
    tcpClient.Disconnect;
    FreeAndNil(tcpClient);
  end;

  inherited;
end;

procedure TMTUChecker.OnConnected(Sender: TObject);
var i: UInt32;
    outBytes: TIdBytes;
begin
  PrintMsg('Connected to server');

  i := FFirstPacketSize;
  while i <= FLastPacketSize do
  begin
    SetLength(outBytes, i);
    if (Sender is TIdTCPClient) then
      tcpClient.Socket.Write(outBytes)
    else
      udpClient.SendBuffer(outBytes);

    PrintMsg('Bytes sent to server: ' + IntToStr(i));

    i := i + FStep;
  end;
end;

procedure TMTUChecker.OnExecute(AContext: TIdContext);
var inBytes: TIdBytes;
begin
  // Read received data
  AContext.Connection.IOHandler.ReadBytes(inBytes, -1, False);

  if Length(inBytes) > 0 then
    PrintMsg('New packet received. IP: ' + AContext.Binding.PeerIP + '. Size: ' + IntToStr(Length(inBytes)));
end;

procedure TMTUChecker.OnUDPRead(AThread: TIdUDPListenerThread;
  const AData: TIdBytes; ABinding: TIdSocketHandle);
begin
  PrintMsg('New packet received. IP: ' + ABinding.PeerIP + '. Size: ' + IntToStr(Length(AData)));
end;

procedure TMTUChecker.PrintMsg(Msg: String);
begin
  if Assigned(FOnMsg) then
    FOnMsg(Msg);
end;

procedure TMTUChecker.SendRandomData;
begin
  if FUseUDP then
  begin
    udpClient := TIdUDPClient.Create(nil);
    udpClient.OnConnected := OnConnected;
    udpClient.Host := FHost;
    udpClient.Port := FPort;
    udpClient.Active := True;
    udpClient.Connect;
  end else
  begin
    tcpClient := TIdTCPClient.Create(nil);
    tcpClient.OnConnected := OnConnected;
    tcpClient.Host := FHost;
    tcpClient.Port := FPort;
    tcpClient.Connect;
  end;
end;

procedure TMTUChecker.StartServer;
var Protocol: String;
begin
  if FUseUDP then
  begin
    udpListener := TIdUDPServer.Create(nil);
    udpListener.DefaultPort := FPort;
    udpListener.OnUDPRead := OnUDPRead;
    udpListener.ThreadedEvent := True;
    udpListener.Active := True;

    Protocol := 'UDP';
  end else
  begin
    tcpListener := TIdTCPServer.Create(nil);
    tcpListener.OnExecute := OnExecute;
    tcpListener.DefaultPort := FPort;
    tcpListener.Active := True;

    Protocol := 'TCP';
  end;

  PrintMsg('TMC Server Started at port ' + IntToStr(FPort) + ' (' + Protocol + ')');
end;

end.
