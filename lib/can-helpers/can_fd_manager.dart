import 'dart:ffi' as ffi; // For calloc
import 'package:ffi/ffi.dart';

final libc = ffi.DynamicLibrary.open('libc.so.6');

// FFI bindings
typedef SocketC = ffi.Int32 Function(
    ffi.Int32 domain, ffi.Int32 type, ffi.Int32 protocol);
typedef SocketDart = int Function(int domain, int type, int protocol);

typedef BindC = ffi.Int32 Function(
    ffi.Int32 sockfd, ffi.Pointer addr, ffi.Uint32 addrlen);
typedef BindDart = int Function(int sockfd, ffi.Pointer addr, int addrlen);

typedef SetSockOptC = ffi.Int32 Function(ffi.Int32 sockfd, ffi.Int32 level,
    ffi.Int32 optname, ffi.Pointer optval, ffi.Uint32 optlen);
typedef SetSockOptDart = int Function(
    int sockfd, int level, int optname, ffi.Pointer optval, int optlen);

typedef ReadC = ffi.Int32 Function(
    ffi.Int32 fd, ffi.Pointer buf, ffi.Uint32 count);
typedef ReadDart = int Function(int fd, ffi.Pointer buf, int count);

// Function to send a CAN frame
typedef WriteC = ffi.Int32 Function(
    ffi.Int32 fd, ffi.Pointer buf, ffi.Uint32 count);
typedef WriteDart = int Function(int fd, ffi.Pointer buf, int count);

// FFI binding for if_nametoindex
typedef IfNametoindexC = ffi.Uint32 Function(ffi.Pointer<Utf8> ifname);
typedef IfNametoindexDart = int Function(ffi.Pointer<Utf8> ifname);

// Constants (these might vary based on your system's headers)
const AF_CAN = 29;
const SOCK_RAW = 3;
const CAN_RAW = 1;
const SOL_CAN_RAW = 101;
const CAN_RAW_FD_FRAMES = 5;
const SOCK_NONBLOCK = 2048;

// Structures
sealed class CanFrame extends ffi.Struct {
  @ffi.Uint32()
  external int canId;

  @ffi.Uint8()
  external int canDlc;

  @ffi.Array(64) // Assuming a CAN frame can have up to 8 data bytes
  external ffi.Array<ffi.Uint8> data;
}

// Structures
sealed class CanFdFrame extends ffi.Struct {
  @ffi.Uint32()
  external int canId;

  @ffi.Uint8()
  external int len;

  @ffi.Uint8()
  external int flags;

  @ffi.Uint8()
  external int res0;

  @ffi.Uint8()
  external int res1;

  @ffi.Array(64) // Assuming a CAN frame can have up to 8 data bytes
  external ffi.Array<ffi.Uint8> data;
}

base class SockAddrCan extends ffi.Struct {
  @ffi.Int16()
  external int canFamily;

  @ffi.Int32()
  external int canIfindex;
}

class CanFdManager {
  // Load if_nametoindex function
  final ifNametoindex =
      libc.lookupFunction<IfNametoindexC, IfNametoindexDart>('if_nametoindex');

// Load system calls
  final socket = libc.lookupFunction<SocketC, SocketDart>('socket');
  final bind = libc.lookupFunction<BindC, BindDart>('bind');
  final setSockOpt =
      libc.lookupFunction<SetSockOptC, SetSockOptDart>('setsockopt');
  final read = libc.lookupFunction<ReadC, ReadDart>('read');
  final write = libc.lookupFunction<WriteC, WriteDart>('write');
}
