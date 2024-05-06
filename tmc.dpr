program tmc;

uses
  System.SysUtils,
  tmcImpl in 'tmcImpl.pas';

procedure WriteMsg(Msg: String);
begin
  WriteLn(Msg);
end;

procedure PrintHelp;
begin
  WriteLn('Usage: tmc [OPTIONS]');
  WriteLn('Possible options:');
  WriteLn('-s - server mode');
  WriteLn('-c - client mode');
  WriteLn('-u - use UDP instead of TCP. Default: use TCP');
  WriteLn('-p - port (both modes). Default: 2233');
  WriteLn('-h host - specify host for connection (client mode). Default: 127.0.0.1');
  WriteLn('');
  WriteLn('Send one packet of specified size');
  WriteLn('-m size (bytes) - send one packet of specified size (client mode)');
  WriteLn('');
  WriteLn('Send set of packets from size x to size y with step z');
  WriteLn('-x size (bytes) - size of 1st packet for random generator (client mode)');
  WriteLn('-y size (bytes) - size of last packet for random generator');
  WriteLn('-z step (bytes) - increment step for random generator');
end;

var Port: UInt16;
    S: String;
    tmChecker: TMTUChecker;
begin
  try
    if ParamCount = 0 then
    begin
      PrintHelp;
      exit;
    end;

    tmChecker := TMTUChecker.Create(WriteMsg);
    try
      if FindCmdLineSwitch('p', S, False, [clstValueNextParam]) then
        Port := StrToInt(S)
      else
        Port := 2233;
      tmChecker.Port := Port;

      if FindCmdLineSwitch('u') then
        tmChecker.UseUDP := True;

      if FindCmdLineSwitch('s') then
      begin
        if FindCmdLineSwitch('c') then
          raise Exception.Create('Choose server or client mode - not boths');

        tmChecker.StartServer;

        while true do
          Sleep(0);
      end else
      begin
        if FindCmdLineSwitch('h', S, False, [clstValueNextParam]) then
          tmChecker.Host := S
        else
          tmChecker.Host := '127.0.0.1';

        if FindCmdLineSwitch('x', S, False, [clstValueNextParam]) then
          tmChecker.FirstPacketSize := StrToUInt(S)
        else
          tmChecker.FirstPacketSize := 1000;

        if FindCmdLineSwitch('y', S, False, [clstValueNextParam]) then
          tmChecker.LastPacketSize := StrToUInt(S)
        else
          tmChecker.LastPacketSize := 2500;

        if FindCmdLineSwitch('z', S, False, [clstValueNextParam]) then
          tmChecker.Step := StrToUInt(S)
        else
          tmChecker.Step := 10;

        if FindCmdLineSwitch('z', S, False, [clstValueNextParam]) then
          tmChecker.Step := StrToUInt(S)
        else
          tmChecker.Step := 10;

        if FindCmdLineSwitch('m', S, False, [clstValueNextParam]) then
        begin
          tmChecker.FirstPacketSize := StrToUInt(S);
          tmChecker.LastPacketSize := tmChecker.FirstPacketSize;
        end;

        tmChecker.SendRandomData;
      end;
    finally
      tmChecker.Free;
    end;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
    end;
  end;
end.
