{
  $Project$
  $Workfile$
  $Revision$
  $DateUTC$
  $Id$

  This file is part of the Indy (Internet Direct) project, and is offered
  under the dual-licensing agreement described on the Indy website.
  (http://www.indyproject.org/)

  Copyright:
   (c) 1993-2005, Chad Z. Hower and the Indy Pit Crew. All rights reserved.


  $Log$


   Rev 1.8    10/26/2004 8:20:04 PM  JPMugaas
 Fixed some oversights with conversion.  OOPS!!!


   Rev 1.7    07/06/2004 21:31:24  CCostelloe
 Kylix 3 changes


   Rev 1.6    4/18/04 10:43:24 PM  RLebeau
 Fixed syntax error


   Rev 1.5    4/18/04 10:29:58 PM  RLebeau
 Renamed Int64Parts structure to TIdInt64Parts


   Rev 1.4    4/18/04 2:47:46 PM  RLebeau
 Conversion support for Int64 values


   Rev 1.3    2004.03.07 11:45:28 AM  czhower
 Flushbuffer fix + other minor ones found


   Rev 1.2    3/6/2004 5:16:34 PM  JPMugaas
 Bug 67 fixes.  Do not write to const values.


   Rev 1.1    3/6/2004 4:23:52 PM  JPMugaas
 Error #62 fix.  This seems to work in my tests.


   Rev 1.0    2004.02.03 3:14:48 PM  czhower
 Move and updates


   Rev 1.33    2/1/2004 6:10:56 PM  JPMugaas
 GetSockOpt.


   Rev 1.32    2/1/2004 3:28:36 AM  JPMugaas
 Changed WSGetLocalAddress to GetLocalAddress and moved into IdStack since
 that will work the same in the DotNET as elsewhere.  This is required to
 reenable IPWatch.


   Rev 1.31    1/31/2004 1:12:48 PM  JPMugaas
 Minor stack changes required as DotNET does support getting all IP addresses
 just like the other stacks.


   Rev 1.30    12/4/2003 3:14:52 PM  BGooijen
 Added HostByAddress


   Rev 1.29    1/3/2004 12:38:56 AM  BGooijen
 Added function SupportsIPv6


   Rev 1.28    12/31/2003 9:52:02 PM  BGooijen
 Added IPv6 support


   Rev 1.27    10/26/2003 05:33:14 PM  JPMugaas
 LocalAddresses should work.


   Rev 1.26    10/26/2003 5:04:28 PM  BGooijen
 UDP Server and Client


   Rev 1.25    10/26/2003 09:10:26 AM  JPMugaas
 Calls necessary for IPMulticasting.


   Rev 1.24    10/22/2003 04:40:52 PM  JPMugaas
 Should compile with some restored functionality.  Still not finished.


   Rev 1.23    10/21/2003 11:04:20 PM  BGooijen
 Fixed name collision


   Rev 1.22    10/21/2003 01:20:02 PM  JPMugaas
 Restore GWindowsStack because it was needed by SuperCore.


   Rev 1.21    10/21/2003 06:24:28 AM  JPMugaas
 BSD Stack now have a global variable for refercing by platform specific
 things.  Removed corresponding var from Windows stack.


   Rev 1.20    10/19/2003 5:21:32 PM  BGooijen
 SetSocketOption


   Rev 1.19    2003.10.11 5:51:16 PM  czhower
 -VCL fixes for servers
 -Chain suport for servers (Super core)
 -Scheduler upgrades
 -Full yarn support


   Rev 1.18    2003.10.02 8:01:08 PM  czhower
 .Net


   Rev 1.17    2003.10.02 12:44:44 PM  czhower
 Fix for Bind, Connect


   Rev 1.16    2003.10.02 10:16:32 AM  czhower
 .Net


   Rev 1.15    2003.10.01 9:11:26 PM  czhower
 .Net


   Rev 1.14    2003.10.01 12:30:08 PM  czhower
 .Net


   Rev 1.12    10/1/2003 12:14:12 AM  BGooijen
 DotNet: removing CheckForSocketError


   Rev 1.11    2003.10.01 1:12:40 AM  czhower
 .Net


   Rev 1.10    2003.09.30 1:23:04 PM  czhower
 Stack split for DotNet


   Rev 1.9    9/8/2003 02:13:10 PM  JPMugaas
 SupportsIP6 function added for determining if IPv6 is installed on a system.


   Rev 1.8    2003.07.14 1:57:24 PM  czhower
 -First set of IOCP fixes.
 -Fixed a threadsafe problem with the stack class.


   Rev 1.7    7/1/2003 05:20:44 PM  JPMugaas
 Minor optimizations.  Illiminated some unnecessary string operations.


   Rev 1.5    7/1/2003 03:39:58 PM  JPMugaas
 Started numeric IP function API calls for more efficiency.


   Rev 1.4    7/1/2003 12:46:06 AM  JPMugaas
 Preliminary stack functions taking an IP address numerical structure instead
 of a string.


    Rev 1.3    5/19/2003 6:00:28 PM  BGooijen
  TIdStackWindows.WSGetHostByAddr raised an ERangeError when the last number in
  the ip>127


    Rev 1.2    5/10/2003 4:01:28 PM  BGooijen


   Rev 1.1    2003.05.09 10:59:28 PM  czhower


   Rev 1.0    11/13/2002 08:59:38 AM  JPMugaas
}
unit IdStackWindows;

interface

{$I IdCompilerDefines.inc}

uses
  Classes,
  IdGlobal, IdException, IdStackBSDBase, IdStackConsts, IdWinsock2, IdStack,
  SysUtils, 
  Windows;

type
  EIdIPv6Unavailable = class(EIdException);

  TIdSocketListWindows = class(TIdSocketList)
  protected
    FFDSet: TFDSet;
    //
    class function FDSelect(AReadSet: PFDSet; AWriteSet: PFDSet; AExceptSet: PFDSet;
     const ATimeout: Integer = IdTimeoutInfinite): Boolean;
    function GetItem(AIndex: Integer): TIdStackSocketHandle; override;
  public
    procedure Add(AHandle: TIdStackSocketHandle); override;
    procedure Remove(AHandle: TIdStackSocketHandle); override;
    function Count: Integer; override;
    procedure Clear; override;
    function Clone: TIdSocketList; override;
    function ContainsSocket(AHandle: TIdStackSocketHandle): boolean; override;
    procedure GetFDSet(var VSet: TFDSet);
    procedure SetFDSet(var VSet: TFDSet);
    class function Select(AReadList: TIdSocketList; AWriteList: TIdSocketList;
     AExceptList: TIdSocketList; const ATimeout: Integer = IdTimeoutInfinite): Boolean; override;
    function SelectRead(const ATimeout: Integer = IdTimeoutInfinite): Boolean; override;
    function SelectReadList(var VSocketList: TIdSocketList;
      const ATimeout: Integer = IdTimeoutInfinite): Boolean; override;
  end;

  TIdStackWindows = class(TIdStackBSDBase)
  protected
     procedure WSQuerryIPv6Route(ASocket: TIdStackSocketHandle;
       const AIP: String; const APort : Word; var VSource; var VDest);
    procedure WriteChecksumIPv6(s : TIdStackSocketHandle; var VBuffer : TIdBytes;
      const AOffset : Integer; const AIP : String; const APort : TIdPort);
    function HostByName(const AHostName: string;
      const AIPVersion: TIdIPVersion = ID_DEFAULT_IP_VERSION): string; override;
    procedure PopulateLocalAddresses; override;
    function ReadHostName: string; override;
    function WSCloseSocket(ASocket: TIdStackSocketHandle): Integer; override;
    function WSRecv(ASocket: TIdStackSocketHandle; var ABuffer;
      const ABufferLength, AFlags: Integer): Integer; override;
    function WSSend(ASocket: TIdStackSocketHandle; const ABuffer;
      const ABufferLength, AFlags: Integer): Integer; override;
    function WSShutdown(ASocket: TIdStackSocketHandle; AHow: Integer): Integer; override;
  public
    function Accept(ASocket: TIdStackSocketHandle; var VIP: string; var VPort: TIdPort;
      var VIPVersion: TIdIPVersion): TIdStackSocketHandle; override;
    function HostToNetwork(AValue: Word): Word; override;
    function HostToNetwork(AValue: LongWord): LongWord; override;
    function HostToNetwork(AValue: Int64): Int64; override;
    procedure Listen(ASocket: TIdStackSocketHandle; ABackLog: Integer); override;
    function NetworkToHost(AValue: Word): Word; override;
    function NetworkToHost(AValue: LongWord): LongWord; override;
    function NetworkToHost(AValue: Int64): Int64; override;
    procedure SetBlocking(ASocket: TIdStackSocketHandle; const ABlocking: Boolean); override;
    function WouldBlock(const AResult: Integer): Boolean; override;
    //
    function HostByAddress(const AAddress: string;
      const AIPVersion: TIdIPVersion = ID_DEFAULT_IP_VERSION): string; override;

    function WSGetServByName(const AServiceName: string): TIdPort; override;
    function WSGetServByPort(const APortNumber: TIdPort): TStrings; override;

    function RecvFrom(const ASocket: TIdStackSocketHandle; var VBuffer;
     const ALength, AFlags: Integer; var VIP: string; var VPort: TIdPort;
     AIPVersion: TIdIPVersion = ID_DEFAULT_IP_VERSION): Integer; override;
   function ReceiveMsg(ASocket: TIdStackSocketHandle; var VBuffer: TIdBytes;
      APkt : TIdPacketInfo; const AIPVersion: TIdIPVersion = ID_DEFAULT_IP_VERSION): LongWord; override;

    procedure WSSendTo(ASocket: TIdStackSocketHandle; const ABuffer;
      const ABufferLength, AFlags: Integer; const AIP: string; const APort: TIdPort; AIPVersion: TIdIPVersion = ID_DEFAULT_IP_VERSION); override;

    function WSSocket(AFamily, AStruct, AProtocol: Integer;
     const AOverlapped: Boolean = False): TIdStackSocketHandle; override;
    function WSTranslateSocketErrorMsg(const AErr: integer): string; override;
    function WSGetLastError: Integer; override;
    procedure WSGetSockOpt(ASocket: TIdStackSocketHandle; Alevel, AOptname: Integer; AOptval: PChar; var AOptlen: Integer); override;
    //
    procedure Bind(ASocket: TIdStackSocketHandle; const AIP: string;
     const APort: TIdPort; const AIPVersion: TIdIPVersion = ID_DEFAULT_IP_VERSION); override;
    procedure Connect(const ASocket: TIdStackSocketHandle; const AIP: string;
     const APort: TIdPort; const AIPVersion: TIdIPVersion = ID_DEFAULT_IP_VERSION); override;
    constructor Create; override;
    destructor Destroy; override;
    procedure Disconnect(ASocket: TIdStackSocketHandle); override;
    procedure GetPeerName(ASocket: TIdStackSocketHandle; var VIP: string;
     var VPort: TIdPort; var VIPVersion: TIdIPVersion); override;
    procedure GetSocketName(ASocket: TIdStackSocketHandle; var VIP: string;
     var VPort: TIdPort; var VIPVersion: TIdIPVersion); override;
    procedure GetSocketOption(ASocket: TIdStackSocketHandle;
      ALevel: TIdSocketOptionLevel; AOptName: TIdSocketOption;
      out AOptVal: Integer); override;
    procedure SetSocketOption(ASocket: TIdStackSocketHandle;
      ALevel: TIdSocketProtocol; AOptName: TIdSocketOption;
      AOptVal: Integer); overload; override;
    procedure SetSocketOption( const ASocket: TIdStackSocketHandle; const Alevel, Aoptname: Integer; Aoptval: PChar; const Aoptlen: Integer ); overload; override;
    function IOControl(const s:  TIdStackSocketHandle; const cmd: LongWord; var arg: LongWord): Integer; override;
    function SupportsIPv6:boolean; override;
    function CheckIPVersionSupport(const AIPVersion: TIdIPVersion): boolean; override;
    procedure WriteChecksum(s : TIdStackSocketHandle;
       var VBuffer : TIdBytes;
      const AOffset : Integer;
      const AIP : String;
      const APort : TIdPort;
      const AIPVersion: TIdIPVersion = ID_DEFAULT_IP_VERSION); override;
  end;

var
//This is for the Win32-only package (SuperCore)
  GWindowsStack : TIdStackWindows = nil;

implementation

uses
  IdResourceStrings, IdWship6;

type
  TGetFileSizeEx = function (hFile : THandle; var lpFileSize : LARGE_INTEGER) : BOOL; stdcall;

const
  SIZE_HOSTNAME = 250;

var
  GStarted: Boolean = False;
  GetFileSizeEx : TGetFileSizeEx = nil;

constructor TIdStackWindows.Create;
begin
  inherited Create;
  if not GStarted then begin
    try
      InitializeWinSock;
        IdWship6.InitLibrary;
    except
      on E: Exception do begin
        raise EIdStackInitializationFailed.Create(E.Message);
      end;
    end;
    GStarted := True;
  end;

  GWindowsStack := Self;
end;

destructor TIdStackWindows.Destroy;
begin
  //DLL Unloading and Cleanup is done at finalization
  inherited Destroy;
end;

function TIdStackWindows.Accept(ASocket: TIdStackSocketHandle;
  var VIP: string; var VPort: TIdPort; var VIPVersion: TIdIPVersion): TIdStackSocketHandle;
var
  i: Integer;
  LAddr: TSockAddrIn6;
begin
  i := SIZE_TSOCKADDRIN6;
  Result := IdWinsock2.Accept(ASocket, Pointer(@LAddr), @i);
  if Result <> INVALID_SOCKET then begin
    case LAddr.sin6_family of
      Id_PF_INET4: begin
        VIP := TranslateTInAddrToString(TSockAddr(Pointer(@LAddr)^).sin_addr, Id_IPv4);
        VPort := Ntohs(TSockAddr(Pointer(@LAddr)^).sin_port);
        VIPVersion := Id_IPv4;
      end;
      Id_PF_INET6: begin
        VIP := TranslateTInAddrToString(LAddr.sin6_addr, Id_IPv6);
        VPort := Ntohs(LAddr.sin6_port);
        VIPVersion := Id_IPv6;
      end;
      else begin
        CloseSocket(Result);
        Result := INVALID_SOCKET;
        IPVersionUnsupported;
      end;
    end;
  end;
end;

procedure TIdStackWindows.Bind(ASocket: TIdStackSocketHandle;
  const AIP: string; const APort: TIdPort;
  const AIPVersion: TIdIPVersion = ID_DEFAULT_IP_VERSION);
var
  LAddr: TSockAddrIn;
  Addr6: TSockAddrIn6;
begin
  case AIPVersion of
    Id_IPv4: begin
      LAddr.sin_family := Id_PF_INET4;
      if AIP = '' then begin
        LAddr.sin_addr.s_addr := INADDR_ANY;
      end else begin
        TranslateStringToTInAddr(AIP, LAddr.sin_addr, Id_IPv4);
      end;
      LAddr.sin_port := HToNS(APort);
      CheckForSocketError(IdWinsock2.Bind(ASocket, @LAddr, SIZE_TSOCKADDRIN));
    end;
    Id_IPv6: begin
      Addr6.sin6_family := Id_PF_INET6;
      Addr6.sin6_scope_id := 0;
      Addr6.sin6_flowinfo := 0;
      if Length(AIP) = 0 then begin
        FillChar(Addr6.sin6_addr, 16, 0);
      end else begin
        TranslateStringToTInAddr(AIP, Addr6.sin6_addr, Id_IPv6);
      end;
      Addr6.sin6_port := HToNs(APort);
      CheckForSocketError(IdWinsock2.Bind(ASocket, psockaddr(@addr6), SIZE_TSOCKADDRIN6));
    end;
    else begin
      IPVersionUnsupported;
    end;
  end;
end;

function TIdStackWindows.WSCloseSocket(ASocket: TIdStackSocketHandle): Integer;
begin
  Result := CloseSocket(ASocket);
end;

function TIdStackWindows.HostByAddress(const AAddress: string;
  const AIPVersion: TIdIPVersion = ID_DEFAULT_IP_VERSION): string;
var
  Host: PHostEnt;
  {$IFNDEF WINCE}
  LAddr: u_long;
  {$ENDIF}

  {$IFDEF UNICODE}
  Hints: TAddrInfoW;
  LAddrInfo: pAddrInfoW;
  {$ELSE}
  Hints: TAddrInfo;
  LAddrInfo: pAddrInfo;
  {$ENDIF}
  RetVal: Integer;
begin
  //GetHostByName and GetHostByAddr may not be availble in future versions
  //of Windows CE.  Those functions are depreciated in favor of the new
  //getaddrinfo and getname functions even in Windows so they should be used
  //when available anyway.
  //We do have to use the depreciated functions in Windows NT 4.0, probably
  //Windows 2000, and of course Win9x so fall to our old code in these cases.  
  {$IFNDEF WINCE}
  if not GIdIPv6FuncsAvailable then
  begin
    case AIPVersion of
    Id_IPv4:
      begin
        LAddr := inet_addr(PChar(AAddress));
        Host := GetHostByAddr(@LAddr, SIZE_TADDRINFO, AF_INET);
        if Host = nil then begin
          CheckForSocketError(SOCKET_ERROR);
        end else begin
          Result := Host^.h_name;
        end;
      end;
    Id_IPv6: begin
        raise EIdIPv6Unavailable.Create(RSIPv6Unavailable);
      end;
    else 
      IPVersionUnsupported;
    end;
    Exit;
  end;
  {$ENDIF}
  if (AIPVersion <> Id_IPv4) and (AIPVersion <> Id_IPv6) then begin
    IPVersionUnsupported;
  end;
  FillChar(Hints,sizeof(Hints), 0);
  Hints.ai_family := IdIPFamily[AIPVersion];
  Hints.ai_socktype := Integer(SOCK_STREAM);
  Hints.ai_flags := AI_CANONNAME;
  LAddrInfo := nil;
  RetVal := getaddrinfo({$IFDEF UNICODE}PWideChar{$ELSE}pchar{$ENDIF}(AAddress), nil, @Hints, @LAddrInfo);
  try
    if RetVal<>0 then
      RaiseSocketError(gaiErrorToWsaError(RetVal))
    else begin
      setlength(result,NI_MAXHOST);
      getnameinfo(LAddrInfo.ai_addr, LAddrInfo.ai_addrlen, Pointer(result), NI_MAXHOST, nil, 0, NI_NAMEREQD);
      Result := PChar(Result);
    end;
  finally
    FreeAddrInfo(LAddrInfo);
  end;
end;

function TIdStackWindows.ReadHostName: string;
begin
  SetLength(Result, SIZE_HOSTNAME);
  GetHostName(PChar(Result), SIZE_HOSTNAME);
  Result := String(PChar(Result));
end;

procedure TIdStackWindows.Listen(ASocket: TIdStackSocketHandle; ABackLog: Integer);
begin
  CheckForSocketError(IdWinsock2.Listen(ASocket, ABacklog));
end;

function TIdStackWindows.WSRecv(ASocket: TIdStackSocketHandle; var ABuffer;
  const ABufferLength, AFlags: Integer) : Integer;
begin
  Result := Recv(ASocket, ABuffer, ABufferLength, AFlags);
end;

function TIdStackWindows.RecvFrom(const ASocket: TIdStackSocketHandle;
  var VBuffer; const ALength, AFlags: Integer; var VIP: string;
  var VPort: TIdPort; AIPVersion: TIdIPVersion = ID_DEFAULT_IP_VERSION ): Integer;
var
  iSize: integer;
  Addr4: TSockAddrIn;
  Addr6: TSockAddrIn6;
begin
  case AIPVersion of
    Id_IPv4: begin
      iSize := SIZE_TSOCKADDRIN;
      Result := IdWinsock2.RecvFrom(ASocket, VBuffer, ALength, AFlags, @Addr4, @iSize);
      VIP :=  TranslateTInAddrToString(Addr4.sin_addr,Id_IPv4);
      VPort := NToHs(Addr4.sin_port);
    end;
    Id_IPv6: begin
      iSize := SIZE_TSOCKADDRIN6;
      Result := IdWinsock2.RecvFrom(ASocket, VBuffer, ALength, AFlags, PSockAddr(@Addr6), @iSize);
      VIP := TranslateTInAddrToString(Addr6.sin6_addr, Id_IPv6);
      VPort := NToHs(Addr6.sin6_port);
    end;
    else begin
      Result := 0; // avoid warning
      IPVersionUnsupported;
    end;
  end;
end;

function TIdStackWindows.WSSend(ASocket: TIdStackSocketHandle;
  const ABuffer; const ABufferLength, AFlags: Integer): Integer;
begin
  Result := CheckForSocketError(IdWinsock2.Send(ASocket, ABuffer, ABufferLength, AFlags));
end;

procedure TIdStackWindows.WSSendTo(ASocket: TIdStackSocketHandle;
  const ABuffer; const ABufferLength, AFlags: Integer; const AIP: string;
  const APort: TIdPort; AIPVersion: TIdIPVersion = ID_DEFAULT_IP_VERSION);
var
  Addr4: TSockAddrIn;
  Addr6: TSockAddrIn6;
  LBytesOut: integer;
begin
  case AIPVersion of
    Id_IPv4: begin
      FillChar(Addr4, SizeOf(Addr4), 0);
      with Addr4 do begin
        sin_family := Id_PF_INET4;
        TranslateStringToTInAddr(AIP, sin_addr, Id_IPv4);
        sin_port := HToNs(APort);
      end;
      LBytesOut := IdWinsock2.SendTo(ASocket, ABuffer, ABufferLength, AFlags, @Addr4, SIZE_TSOCKADDRIN);
    end;
    Id_IPv6: begin
      FillChar(Addr6, SizeOf(Addr6), 0);
      with Addr6 do
      begin
        sin6_family := Id_PF_INET6;
        TranslateStringToTInAddr(AIP, sin6_addr, Id_IPv6);
        sin6_port := HToNs(APort);
      end;
      LBytesOut := IdWinsock2.SendTo(ASocket, ABuffer, ABufferLength, AFlags, PSockAddr(@Addr6), SIZE_TSOCKADDRIN6);
    end;
    else begin
      LBytesOut := 0; // avoid warning
      IPVersionUnsupported;
    end;
  end;
  if LBytesOut = Id_SOCKET_ERROR then begin
    if WSGetLastError() = Id_WSAEMSGSIZE then begin
      raise EIdPackageSizeTooBig.Create(RSPackageSizeTooBig);
    end else begin
      RaiseLastSocketError;
    end;
  end else if LBytesOut <> ABufferLength then begin
    raise EIdNotAllBytesSent.Create(RSNotAllBytesSent);
  end;
end;

procedure TIdStackWindows.SetSocketOption(ASocket: TIdStackSocketHandle;
  ALevel: TIdSocketProtocol; AOptName: TIdSocketOption; AOptVal: Integer);
begin
  CheckForSocketError(SetSockOpt(ASocket, ALevel, AOptName, PChar(@AOptVal), SIZE_INTEGER));
end;

function TIdStackWindows.WSGetLastError: Integer;
begin
  Result := WSAGetLastError;
end;

function TIdStackWindows.WSSocket(AFamily, AStruct, AProtocol: Integer;
 const AOverlapped: Boolean = False): TIdStackSocketHandle;
begin
  if AOverlapped then begin
    Result := WSASocket(AFamily, AStruct, AProtocol,nil,0,WSA_FLAG_OVERLAPPED);
  end else begin
    Result := IdWinsock2.Socket(AFamily, AStruct, AProtocol);
  end;
end;

function TIdStackWindows.WSGetServByName(const AServiceName: string): TIdPort;
var
  ps: PServEnt;
begin
  ps := GetServByName(PChar(AServiceName), nil);
  if ps <> nil then begin
    Result := Ntohs(ps^.s_port);
  end else begin
    try
      Result := IndyStrToInt(AServiceName);
    except
      on EConvertError do begin
        raise EIdInvalidServiceName.CreateFmt(RSInvalidServiceName, [AServiceName]);
      end;
    end;
  end;
end;

function TIdStackWindows.WSGetServByPort(const APortNumber: TIdPort): TStrings;
{$IFNDEF VCL6ORABOVE}
type
  PPCharArray = ^TPCharArray;
  TPCharArray = packed array[0..(MaxLongint div SizeOf(PChar))-1] of PChar;
{$ENDIF}
var
  ps: PServEnt;
  i: integer;
  p: PPCharArray;
begin
  Result := TStringList.Create;
  try
    ps := GetServByPort(HToNs(APortNumber), nil);
    if ps <> nil then
    begin
      Result.Add(ps^.s_name);
      i := 0;
      p := Pointer(ps^.s_aliases);
      while p[i] <> nil do
      begin
        Result.Add(p[i]);
        Inc(i);
      end;
    end;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

function TIdStackWindows.HostToNetwork(AValue: Word): Word;
begin
  Result := HToNs(AValue);
end;

function TIdStackWindows.NetworkToHost(AValue: Word): Word;
begin
  Result := NToHs(AValue);
end;

function TIdStackWindows.HostToNetwork(AValue: LongWord): LongWord;
begin
  Result := HToNL(AValue);
end;

function TIdStackWindows.NetworkToHost(AValue: LongWord): LongWord;
begin
  Result := NToHL(AValue);
end;

function TIdStackWindows.HostToNetwork(AValue: Int64): Int64;
var
  LParts: TIdInt64Parts;
  L: LongWord;
begin
  LParts.QuadPart := AValue;
  L := HToNL(LParts.HighPart);
  LParts.HighPart := HToNL(LParts.LowPart);
  LParts.LowPart := L;
  Result := LParts.QuadPart;
end;

function TIdStackWindows.NetworkToHost(AValue: Int64): Int64;
var
  LParts: TIdInt64Parts;
  L: LongWord;
begin
  LParts.QuadPart := AValue;
  L := NToHL(LParts.HighPart);
  LParts.HighPart := NToHL(LParts.LowPart);
  LParts.LowPart := L;
  Result := LParts.QuadPart;
end;

procedure TIdStackWindows.PopulateLocalAddresses;
  {$IFNDEF WINCE}
type
  TaPInAddr = Array[0..250] of PInAddr;
  PaPInAddr = ^TaPInAddr;
  {$ENDIF}
var
  {$IFNDEF WINCE}
  i: integer;
  AHost: PHostEnt;
  PAdrPtr: PaPInAddr;
  {$ENDIF}

  {$IFDEF UNICODE}
  Hints:TAddrInfoW;
  LAddrInfo:pAddrInfoW;
  {$ELSE}
  Hints:TAddrInfo;
  LAddrInfo:pAddrInfo;
  {$ENDIF}
  RetVal:integer;  
begin
  {$IFNDEF WINCE}
  if not GIdIPv6FuncsAvailable then
  begin
    AHost := GetHostByName(PChar(HostName));
    if AHost = nil then begin
      CheckForSocketError(SOCKET_ERROR);
    end else begin
      PAdrPtr := PAPInAddr(AHost^.h_address_list);
      i := 0;
      while PAdrPtr^[i] <> nil do begin
        FLocalAddresses.Add(TranslateTInAddrToString(PAdrPtr^[I]^,Id_IPv4)); //BGO FIX
        Inc(I);
      end;
    end;
    Exit;
  end;
  {$ENDIF}
  ZeroMemory(@Hints, SIZE_TADDRINFO);
  Hints.ai_family := Id_PF_INET4;
  Hints.ai_socktype := SOCK_STREAM;
  LAddrInfo := nil;
  RetVal := getaddrinfo({$IFDEF UNICODE}PWideChar{$ELSE}pchar{$ENDIF}(HostName), nil, @Hints, @LAddrInfo);
  try
    if RetVal <> 0 then begin
      RaiseSocketError(gaiErrorToWsaError(RetVal));
    end;
    while  LAddrInfo <> nil do
    begin
      FLocalAddresses.Add(TranslateTInAddrToString(LAddrInfo^.ai_addr^.sin_addr,Id_IPv4));
      LAddrInfo := LAddrInfo^.ai_next;
    end;
  finally
    freeaddrinfo(LAddrInfo);
  end;
end;

{ TIdStackVersionWinsock }

function TIdStackWindows.WSShutdown(ASocket: TIdStackSocketHandle; AHow: Integer): Integer;
begin
  Result := Shutdown(ASocket, AHow);
end;

procedure TIdStackWindows.GetSocketName(ASocket: TIdStackSocketHandle;
  var VIP: string; var VPort: TIdPort; var VIPVersion: TIdIPVersion);
var
  i: Integer;
  LAddr: TSockAddrIn6;
begin
  i := SIZE_TSOCKADDRIN6;
  CheckForSocketError(GetSockName(ASocket, PSockAddr(Pointer(@LAddr)), i));
  case LAddr.sin6_family of
    Id_PF_INET4: begin
      VIP := TranslateTInAddrToString(TSockAddr(Pointer(@LAddr)^).sin_addr,Id_IPv4);
      VPort := Ntohs(TSockAddr(Pointer(@LAddr)^).sin_port);
      VIPVersion := Id_IPv4;
    end;
    Id_PF_INET6: begin
      VIP := TranslateTInAddrToString(LAddr.sin6_addr, Id_IPv6);
      VPort := Ntohs(LAddr.sin6_port);
      VIPVersion := Id_IPv6;
    end;
    else begin
      IPVersionUnsupported;
    end;
  end;
end;

procedure TIdStackWindows.WSGetSockOpt(ASocket: TIdStackSocketHandle; Alevel, AOptname: Integer; AOptval: PChar; var AOptlen: Integer);
begin
  CheckForSocketError(GetSockOpt(ASocket, ALevel, AOptname, AOptval, AOptlen));
end;

{ TIdSocketListWindows }

procedure TIdSocketListWindows.Add(AHandle: TIdStackSocketHandle);
begin
  Lock; try
    if FFDSet.fd_count >= FD_SETSIZE then begin
      raise EIdStackSetSizeExceeded.Create(RSSetSizeExceeded);
    end;
    FFDSet.fd_array[FFDSet.fd_count] := AHandle;
    Inc(FFDSet.fd_count);
  finally Unlock; end;
end;

procedure TIdSocketListWindows.Clear;
begin
  Lock; try
    fd_zero(FFDSet);
  finally Unlock; end;
end;

function TIdSocketListWindows.ContainsSocket(AHandle: TIdStackSocketHandle): Boolean;
begin
  Lock; try
    Result := fd_isset(AHandle, FFDSet);
  finally Unlock; end;
end;

function TIdSocketListWindows.Count: Integer;
begin
  Lock; try
    Result := FFDSet.fd_count;
  finally Unlock; end;
end;

function TIdSocketListWindows.GetItem(AIndex: Integer): TIdStackSocketHandle;
begin
  Result := 0;
  Lock; try
    //We can't redefine AIndex to be a LongWord because the libc Interface
    //and DotNET define it as a LongInt.  OS/2 defines it as a Word.
    if (AIndex >= 0) and (u_int(AIndex) < FFDSet.fd_count) then begin
      Result := FFDSet.fd_array[AIndex];
    end else begin
      raise EIdStackSetSizeExceeded.Create(RSSetSizeExceeded);
    end;
  finally Unlock; end;
end;

procedure TIdSocketListWindows.Remove(AHandle: TIdStackSocketHandle);
var
  i: Integer;
begin
  Lock; try
{
IMPORTANT!!!

Sometimes, there may not be a member of the FDSET.  If you attempt to "remove"
an item, the for loop would execute once.
}
    if FFDSet.fd_count > 0 then
    begin
      for i:= 0 to FFDSet.fd_count - 1 do begin
        if FFDSet.fd_array[i] = AHandle then begin
          dec(FFDSet.fd_count);
          FFDSet.fd_array[i] := FFDSet.fd_array[FFDSet.fd_count];
          FFDSet.fd_array[FFDSet.fd_count] := 0; //extra purity
          Break;
        end;//if found
      end;
    end;
  finally Unlock; end;
end;

function TIdStackWindows.WSTranslateSocketErrorMsg(const AErr: integer): string;
begin
  case AErr of
    wsahost_not_found: Result := RSStackHOST_NOT_FOUND;
  else
    Result :=  inherited WSTranslateSocketErrorMsg(AErr);
    EXIT;
  end;
  Result := IndyFormat(RSStackError, [AErr, Result]);
end;

function TIdSocketListWindows.SelectRead(const ATimeout: Integer): Boolean;
var
  LSet: TFDSet;
begin
  // Windows updates this structure on return, so we need to copy it each time we need it
  GetFDSet(LSet);
  FDSelect(@LSet, nil, nil, ATimeout);
  Result := LSet.fd_count > 0;
end;

class function TIdSocketListWindows.FDSelect(AReadSet, AWriteSet,
 AExceptSet: PFDSet; const ATimeout: Integer): Boolean;
var
  LRes: Integer;
  LTime: TTimeVal;
  LTimePtr: PTimeVal;
begin
  if ATimeout = IdTimeoutInfinite then begin
    LTimePtr := nil;
  end else begin
    LTime.tv_sec := ATimeout div 1000;
    LTime.tv_usec := (ATimeout mod 1000) * 1000;
    LTimePtr := @LTime;
  end;
  LRes := IdWinsock2.Select(0, AReadSet, AWriteSet, AExceptSet, LTimePtr);
  //TODO: Remove this cast
  Result := GBSDStack.CheckForSocketError(LRes) > 0;
end;

function TIdSocketListWindows.SelectReadList(var VSocketList: TIdSocketList; const ATimeout: Integer): Boolean;
var
  LSet: TFDSet;
begin
  // Windows updates this structure on return, so we need to copy it each time we need it
  GetFDSet(LSet);
  FDSelect(@LSet, nil, nil, ATimeout);
  Result := LSet.fd_count > 0;
  if Result then begin
    if VSocketList = nil then begin
      VSocketList := TIdSocketList.CreateSocketList;
    end;
    TIdSocketListWindows(VSocketList).SetFDSet(LSet);
  end;
end;

class function TIdSocketListWindows.Select(AReadList, AWriteList,
  AExceptList: TIdSocketList; const ATimeout: Integer): Boolean;
var
  LReadSet: TFDSet;
  LWriteSet: TFDSet;
  LExceptSet: TFDSet;
  LPReadSet: PFDSet;
  LPWriteSet: PFDSet;
  LPExceptSet: PFDSet;

  procedure ReadSet(AList: TIdSocketList; var ASet: TFDSet; var APSet: PFDSet);
  begin
    if AList <> nil then begin
      TIdSocketListWindows(AList).GetFDSet(ASet);
      APSet := @ASet;
    end else begin
      APSet := nil;
    end;
  end;

begin
  ReadSet(AReadList, LReadSet, LPReadSet);
  ReadSet(AWriteList, LWriteSet, LPWriteSet);
  ReadSet(AExceptList, LExceptSet, LPExceptSet);
  //
  Result := FDSelect(LPReadSet, LPWriteSet, LPExceptSet, ATimeout);
  //
  if AReadList <> nil then begin
    TIdSocketListWindows(AReadList).SetFDSet(LReadSet);
  end;
  if AWriteList <> nil then begin
    TIdSocketListWindows(AWriteList).SetFDSet(LWriteSet);
  end;
  if AExceptList <> nil then begin
    TIdSocketListWindows(AExceptList).SetFDSet(LExceptSet);
  end;
end;

procedure TIdSocketListWindows.SetFDSet(var VSet: TFDSet);
begin
  Lock; try
    FFDSet := VSet;
  finally Unlock; end;
end;

procedure TIdSocketListWindows.GetFDSet(var VSet: TFDSet);
begin
  Lock; try
    VSet := FFDSet;
  finally Unlock; end;
end;

procedure TIdStackWindows.SetBlocking(ASocket: TIdStackSocketHandle;
 const ABlocking: Boolean);
var
  LValue: LongWord;
begin
  LValue := LongWord(not ABlocking);
  CheckForSocketError(ioctlsocket(ASocket, FIONBIO, LValue));
end;

function TIdSocketListWindows.Clone: TIdSocketList;
begin
  Result := TIdSocketListWindows.Create;
  Lock; try
    TIdSocketListWindows(Result).SetFDSet(FFDSet);
  finally Unlock; end;
end;

function TIdStackWindows.WouldBlock(const AResult: Integer): Boolean;
begin
  Result := CheckForSocketError(AResult, [WSAEWOULDBLOCK]) <> 0;
end;

function TIdStackWindows.HostByName(const AHostName: string;
  const AIPVersion: TIdIPVersion = ID_DEFAULT_IP_VERSION): string;
var
  LPa: PChar;
  LSa: TInAddr;
   {$IFNDEF WINCE}
  LHost: PHostEnt;
  {$ENDIF}
  Hints:TAddrInfo;
  {$IFDEF UNICODE}
  LAddrInfo:pAddrInfoW;
  {$ELSE}
  LAddrInfo:pAddrInfo;
  {$ENDIF}
  RetVal:integer;
begin
  //GetHostByName and GetHostByAddr may not be availble in future versions
  //of Windows CE.  Those functions are depreciated in favor of the new
  //getaddrinfo and getname functions even in Windows so they should be used
  //when available anyway.
  //We do have to use the depreciated functions in Windows NT 4.0, probably
  //Windows 2000, and of course Win9x so fall to our old code in these cases.
  {$IFNDEF WINCE}
  if not GIdIPv6FuncsAvailable then
  begin
    case AIPVersion of
    Id_IPv4:
      begin
        LHost := IdWinsock2.GetHostByName(PChar(AHostName));
        if LHost = nil then begin
          RaiseLastSocketError;
        end else begin
          LPa := LHost^.h_address_list^;
          LSa.S_un_b.s_b1 := Ord(LPa[0]);
          LSa.S_un_b.s_b2 := Ord(LPa[1]);
          LSa.S_un_b.s_b3 := Ord(LPa[2]);
          LSa.S_un_b.s_b4 := Ord(LPa[3]);
          Result := TranslateTInAddrToString(LSa,Id_IPv4);
        end;
      end;
    Id_IPv6: begin
        raise EIdIPv6Unavailable.Create(RSIPv6Unavailable);
      end;
    else 
      IPVersionUnsupported;
    end;
    Exit;
  end;
  {$ENDIF}
  if (AIPVersion <> Id_IPv4) and (AIPVersion <> Id_IPv6) then begin
    IPVersionUnsupported;
  end;
  ZeroMemory(@Hints, SIZE_TADDRINFO);
  Hints.ai_family := IdIPFamily[AIPVersion];
  Hints.ai_socktype := SOCK_STREAM;
  LAddrInfo := nil;
  RetVal := getaddrinfo({$IFDEF UNICODE}PWideChar{$ELSE}pchar{$ENDIF}(AHostName), nil, @Hints, @LAddrInfo);
  try
    if RetVal <> 0 then begin
      RaiseSocketError(gaiErrorToWsaError(RetVal));
    end;
    if AIPVersion = Id_IPv4 then
      Result := TranslateTInAddrToString(LAddrInfo^.ai_addr^.sin_addr, AIPVersion)
    else
      Result := TranslateTInAddrToString(LAddrInfo^.ai_addr^.sin_zero, AIPVersion);
  finally
    freeaddrinfo(LAddrInfo);
  end;
end;

procedure TIdStackWindows.Connect(const ASocket: TIdStackSocketHandle;
 const AIP: string; const APort: TIdPort;
 const AIPVersion: TIdIPVersion = ID_DEFAULT_IP_VERSION);
var
  LAddr: TSockAddrIn;
  Addr6: TSockAddrIn6;
begin
  case AIPVersion of
    Id_IPv4: begin
      LAddr.sin_family := Id_PF_INET4;
      TranslateStringToTInAddr(AIP, LAddr.sin_addr, Id_IPv4);
      LAddr.sin_port := HToNS(APort);
      CheckForSocketError(IdWinsock2.Connect(ASocket, @LAddr, SIZE_TSOCKADDRIN));
    end;
    Id_IPv6: begin
      Addr6.sin6_flowinfo:=0;
      Addr6.sin6_scope_id:=0;
      Addr6.sin6_family := Id_PF_INET6;
      TranslateStringToTInAddr(AIP, Addr6.sin6_addr, Id_IPv6);
      Addr6.sin6_port := HToNs(APort);
      CheckForSocketError(IdWinsock2.Connect(ASocket, psockaddr(@Addr6), SIZE_TSOCKADDRIN6));
    end;
    else begin
      IPVersionUnsupported;
    end;
  end;
end;

procedure TIdStackWindows.GetPeerName(ASocket: TIdStackSocketHandle;
 var VIP: string; var VPort: TIdPort; var VIPVersion: TIdIPVersion);
var
  i: Integer;
  LAddr: TSockAddrIn6;
begin
  i := SIZE_TSOCKADDRIN6;
  CheckForSocketError(IdWinsock2.GetPeerName(ASocket, PSockAddr(Pointer(@LAddr)), i));
  case LAddr.sin6_family of
    Id_PF_INET4: begin
      VIP := TranslateTInAddrToString(TSockAddr(Pointer(@LAddr)^).sin_addr,Id_IPv4);
      VPort := Ntohs(TSockAddr(Pointer(@LAddr)^).sin_port);
      VIPVersion := Id_IPv4;
    end;
    Id_PF_INET6: begin
      VIP := TranslateTInAddrToString(LAddr.sin6_addr, Id_IPv6);
      VPort := Ntohs(LAddr.sin6_port);
      VIPVersion := Id_IPv6;
    end;
    else begin
      IPVersionUnsupported;
    end;
  end;
end;

procedure TIdStackWindows.Disconnect(ASocket: TIdStackSocketHandle);
begin
  // Windows uses Id_SD_Send, Linux should use Id_SD_Both
  WSShutdown(ASocket, Id_SD_Send);
  // SO_LINGER is false - socket may take a little while to actually close after this
  WSCloseSocket(ASocket);
end;

procedure TIdStackWindows.SetSocketOption(
  const ASocket: TIdStackSocketHandle; const Alevel, Aoptname: Integer;
  Aoptval: PChar; const Aoptlen: Integer);
begin
  CheckForSocketError( setsockopt(ASocket,ALevel,Aoptname,Aoptval,Aoptlen ));
end;

procedure TIdStackWindows.GetSocketOption(ASocket: TIdStackSocketHandle;
  ALevel: TIdSocketOptionLevel; AOptName: TIdSocketOption;
  out AOptVal: Integer);
var LP : PAnsiChar;
  LLen : Integer;
  LBuf : Integer;
begin
  LP := Addr(LBuf);
  LLen := SIZE_INTEGER;
  WSGetSockOpt(ASocket, ALevel, AOptName, LP, LLen);
  AOptVal := LBuf;
end;

function TIdStackWindows.SupportsIPv6:boolean; 
{
based on
http://groups.google.com/groups?q=Winsock2+Delphi+protocol&hl=en&lr=&ie=UTF-8&oe=utf-8&selm=3cebe697_2%40dnews&rnum=9
}
var
  LLen : LongWord;
  LPInfo, LPCurPtr : LPWSAProtocol_Info;
  LCount : Integer;
  i : Integer;
begin
  Result := False;
  LLen:=0;
  IdWinsock2.WSAEnumProtocols(nil,nil,LLen);
  GetMem(LPInfo,LLen);
  try
    LCount := IdWinsock2.WSAEnumProtocols(nil,LPInfo,LLen);
    if LCount <> SOCKET_ERROR then
    begin
      LPCurPtr := LPInfo;
      for i := 0 to LCount-1 do
      begin
        Result := (LPCurPtr^.iAddressFamily=PF_INET6);
        if Result then
        begin
          Break;
        end;
        Inc(LPCurPtr);
      end;
    end;
  finally
    FreeMem(LPInfo);
  end;
end;

function TIdStackWindows.IOControl(const s: TIdStackSocketHandle;
  const cmd: LongWord; var arg: LongWord): Integer;
begin
  Result := IdWinsock2.ioctlsocket(s, cmd, arg);
end;

procedure TIdStackWindows.WSQuerryIPv6Route(ASocket: TIdStackSocketHandle;
  const AIP: String; const APort: TIdPort; var VSource; var VDest);
var
  Llocalif : SOCKADDR_STORAGE;
  LPLocalIP : PSOCKADDR_IN6;
  LAddr6 : TSockAddrIn6;
  Bytes : LongWord;
begin
//  EIdIPv6Unavailable.IfFalse(GIdIPv6FuncsAvailable, RSIPv6Unavailable);
  //make our LAddrInfo structure
  FillChar(LAddr6, SizeOf(LAddr6), 0);
  LAddr6.sin6_family := AF_INET6;
  TranslateStringToTInAddr(AIP, LAddr6.sin6_addr, Id_IPv6);
  Move(LAddr6.sin6_addr, VDest, SizeOf(in6_addr));
  LAddr6.sin6_port := HToNs(APort);
  LPLocalIP := PSockAddr_in6(@Llocalif);
  // Find out which local interface for the destination
  CheckForSocketError( WSAIoctl(ASocket, SIO_ROUTING_INTERFACE_QUERY,
    @LAddr6, LongWord(SizeOf(TSockAddrIn6)), @Llocalif,
    LongWord(SizeOf(Llocalif)), @Bytes, nil, nil));
  Move( LPLocalIP^.sin6_addr, VSource, SizeOf(in6_addr));
end;

procedure TIdStackWindows.WriteChecksum(s: TIdStackSocketHandle;
  var VBuffer: TIdBytes; const AOffset: Integer; const AIP: String;
  const APort: TIdPort; const AIPVersion: TIdIPVersion);
begin
  case AIPVersion of
    Id_IPv4 : CopyTIdWord(HostToLittleEndian(CalcCheckSum(VBuffer)), VBuffer, AOffset);
    Id_IPv6 : WriteChecksumIPv6(s, VBuffer, AOffset, AIP, APort);
  else
    IPVersionUnsupported;
  end;
end;

procedure TIdStackWindows.WriteChecksumIPv6(s: TIdStackSocketHandle;
  var VBuffer: TIdBytes; const AOffset: Integer; const AIP: String;
  const APort: TIdPort);
var 
  LSource : TIdIn6Addr;
  LDest : TIdIn6Addr;
  LTmp : TIdBytes;
  LIdx : Integer;
  LC : LongWord;
  LW : Word;
{
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                                                               |
   +                                                               +
   |                                                               |
   +                         Source Address                        +
   |                                                               |
   +                                                               +
   |                                                               |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                                                               |
   +                                                               +
   |                                                               |
   +                      Destination Address                      +
   |                                                               |
   +                                                               +
   |                                                               |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                   Upper-Layer Packet Length                   |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                      zero                     |  Next Header  |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
}
begin

  WSQuerryIPv6Route(s, AIP, APort, LSource, LDest);
  SetLength(LTmp, Length(VBuffer)+40);

  //16
  Move(LSource, LTmp[0], SIZE_TSOCKADDRIN6);
  LIdx := SIZE_TSOCKADDRIN6;
  //32
  Move(LDest, LTmp[LIdx], SIZE_TSOCKADDRIN6);
  Inc(LIdx, SIZE_TSOCKADDRIN6);
  //use a word so you don't wind up using the wrong network byte order function
  LC := LongWord(Length(VBuffer));
  CopyTIdLongWord(GStack.HostToNetwork(LC), LTmp, LIdx);
  Inc(LIdx, 4);
  //36
  //zero the next three bytes
  FillChar(LTmp[LIdx], 3, 0);
  Inc(LIdx, 3);
  //next header (protocol type determines it
  LTmp[LIdx] := Id_IPPROTO_ICMPV6; // Id_IPPROTO_ICMP6;
  Inc(LIdx);
  //zero our checksum feild for now
  VBuffer[2] := 0;
  VBuffer[3] := 0;
  //combine the two
  CopyTIdBytes(VBuffer, 0, LTmp, LIdx, Length(VBuffer));
  LW := CalcCheckSum(LTmp);

  CopyTIdWord(HostToLittleEndian(LW), VBuffer, AOffset);
end;

function TIdStackWindows.ReceiveMsg(ASocket: TIdStackSocketHandle; var VBuffer : TIdBytes;
  APkt: TIdPacketInfo; const AIPVersion: TIdIPVersion): LongWord;
var
  LIP : String;
  LPort : TIdPort;
  {Windows CE does not have WSARecvMsg}
   {$IFNDEF WINCE}
  LSize: PtrUInt;
  LAddr4: TSockAddrIn;
  LAddr6: TSockAddrIn6;
  LMsg : TWSAMSG;
  LMsgBuf : TWSABUF;
  LControl : TIdBytes;
  LCurCmsg : LPWSACMSGHDR;   //for iterating through the control buffer
  LCurPt : PInPktInfo;
  LCurPt6 : PIn6PktInfo;
  {$ENDIF}
begin
  {$IFNDEF WINCE}
  //This runs only on WIndowsXP or later
  // XP 5.1 at least, Vista 6.0
  if ((Win32MajorVersion = 5) and (Win32MinorVersion > 0)) or
     (Win32MajorVersion > 5) then
  begin
    //we call the macro twice because we specified two possible structures.
    //Id_IPV6_HOPLIMIT and Id_IPV6_PKTINFO
    LSize := WSA_CMSG_LEN(WSA_CMSG_LEN(Length(VBuffer)));
    SetLength(LControl, LSize);

    LMsgBuf.len := Length(VBuffer); // Length(VMsgData);
    LMsgBuf.buf := @VBuffer[0]; // @VMsgData[0];

    FillChar(LMsg, SIZE_TWSAMSG, 0);

    LMsg.lpBuffers := @LMsgBuf;
    LMsg.dwBufferCount := 1;

    LMsg.Control.Len := LSize;
    LMsg.Control.buf := @LControl[0];

    case AIPVersion of
      Id_IPv4:
        begin
          LMsg.name :=  @LAddr4;
          LMsg.namelen := SIZE_TSOCKADDRIN; //SizeOf(LAddr4);

          CheckForSocketError(WSARecvMsg(ASocket,@LMsg,Result,nil,nil));
          APkt.SourceIP := TranslateTInAddrToString(LAddr4.sin_addr, Id_IPv4);

          APkt.SourcePort := NToHs(LAddr4.sin_port);
        end;
      Id_IPv6:
        begin
          LMsg.name := PSOCKADDR(@LAddr6);
          LMsg.namelen := SIZE_TSOCKADDRIN6;
          CheckForSocketError(WSARecvMsg(ASocket, @LMsg, Result, nil, nil));
          APkt.SourceIP := TranslateTInAddrToString(LAddr6.sin6_addr, Id_IPv6);
          APkt.SourcePort := NToHs(LAddr6.sin6_port);
        end;
      else begin
        Result := 0; // avoid warning
        IPVersionUnsupported;
      end;
    end;
    LCurCmsg := nil;
    repeat
      LCurCmsg := WSA_CMSG_NXTHDR(@LMsg, LCurCmsg);
      if LCurCmsg = nil then begin
        break;
      end;
      case LCurCmsg^.cmsg_type of
        IP_PKTINFO :     //done this way because IPV6_PKTINF and  IP_PKTINFO
        //are both 19
        begin
          if AIPVersion = Id_IPv4 then
          begin
            LCurPt := PInPktInfo(WSA_CMSG_DATA(LCurCmsg));
            APkt.DestIP := TranslateTInAddrToString(LCurPt^.ipi_addr, Id_IPv4);
            APkt.DestIF := LCurPt^.ipi_ifindex;
          end;
          if AIPVersion = Id_IPv6 then
          begin
            LCurPt6 := PIn6PktInfo(WSA_CMSG_DATA(LCurCmsg));
            APkt.DestIP := TranslateTInAddrToString(LCurPt6^.ipi6_addr, Id_IPv6);
            APkt.DestIF := LCurPt6^.ipi6_ifindex;
          end;
        end;
        Id_IPV6_HOPLIMIT :
        begin
          APkt.TTL := WSA_CMSG_DATA(LCurCmsg)^;
        end;
      end;
    until False;
  end else
  begin
  {$ENDIF}
    Result := RecvFrom(ASocket, VBuffer, Length(VBuffer), 0, LIP, LPort, AIPVersion);
    APkt.SourceIP := LIP;
    APkt.SourcePort := LPort;
  {$IFNDEF WINCE}
  end;
  {$ENDIF}
end;

function TIdStackWindows.CheckIPVersionSupport(const AIPVersion: TIdIPVersion): Boolean;
var
  LTmpSocket: TIdStackSocketHandle;
begin
  LTmpSocket := WSSocket(IdIPFamily[AIPVersion], Id_SOCK_STREAM, Id_IPPROTO_IP);
  Result := LTmpSocket <> Id_INVALID_SOCKET;
  if Result then begin
    WSCloseSocket(LTmpSocket);
  end;
end;

{$IFNDEF WINCE}
function ServeFile(ASocket: TIdStackSocketHandle; const AFileName: string): Int64;
var
  LFileHandle: THandle;
  LINT : _LARGE_INTEGER;
{
This is somewhat messy but I wanted to do things this way to support Int64
file sizes.
}
begin
  Result := 0;
  LFileHandle := CreateFile(PChar(AFileName), GENERIC_READ, FILE_SHARE_READ, nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN, 0);
  try
    if TransmitFile(ASocket, LFileHandle, 0, 0, nil, nil, 0) then begin
      if Assigned(GetFileSizeEx) then
      begin
        GetFileSizeEx(LFileHandle, LINT);
        Result := LINT.QuadPart;
      end else
      begin
        Result := GetFileSize(LFileHandle, nil);
      end;
    end;
  finally CloseHandle(LFileHandle); end;
end;
{$ENDIF}

initialization
  GSocketListClass := TIdSocketListWindows;
  // Check if we are running under windows NT
  {$IFNDEF WINCE}
  if Win32Platform = VER_PLATFORM_WIN32_NT then begin
    GetFileSizeEx := Windows.GetProcAddress( GetModuleHandle(PChar('Kernel32.dll')), PChar('GetFileSizeEx'));
    GServeFileProc := ServeFile;
  end;
  {$ENDIF}
finalization
  if GStarted then begin
    IdWship6.CloseLibrary;
    UninitializeWinSock;

  end;

end.
