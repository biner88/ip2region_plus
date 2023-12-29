import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class IP2RegionPlus {
  static const int _headerInfoLength = 256;
  static const int _vectorIndexRows = 256;
  static const int _vectorIndexCols = 256;
  static const int _vectorIndexSize = 8;
  static const int _segmentIndexSize = 14;

  RandomAccessFile? handle;
  Uint8List? header;
  int ioCount = 0;
  Uint8List? vectorIndex;
  Uint8List? contentBuff;

  IP2RegionPlus(String dbFile, Uint8List? vectorIndex, Uint8List? cBuff) {
    if (cBuff != null) {
      this.vectorIndex = null;
      contentBuff = cBuff;
    } else {
      handle = File(dbFile).openSync(mode: FileMode.read);
      if (handle == null) {
        throw Exception("failed to open xdb file '$dbFile'");
      }
      this.vectorIndex = vectorIndex;
    }
  }

  Map<String, dynamic> search(dynamic ip) {
    final startTime = DateTime.now().microsecondsSinceEpoch;
    if (ip is String) {
      int? t = _ip2long(ip);
      if (t == null) {
        throw Exception("invalid ip address '$ip'");
      }
      ip = t;
    }
    String result = '';
    ioCount = 0;

    int il0 = (ip >> 24) & 0xFF;
    int il1 = (ip >> 16) & 0xFF;
    int idx =
        il0 * _vectorIndexCols * _vectorIndexSize + il1 * _vectorIndexSize;
    int? sPtr;
    int? ePtr;

    if (vectorIndex != null) {
      sPtr = _getLong(vectorIndex!, idx);
      ePtr = _getLong(vectorIndex!, idx + 4);
    } else if (contentBuff != null) {
      sPtr = _getLong(contentBuff!, _headerInfoLength + idx);
      ePtr = _getLong(contentBuff!, _headerInfoLength + idx + 4);
    } else {
      Uint8List? buff = _read(_headerInfoLength + idx, 8);
      if (buff == null) {
        throw Exception("failed to _read vector index at $idx");
      }
      sPtr = _getLong(buff, 0);
      ePtr = _getLong(buff, 4);
    }

    int dataLen = 0;
    int? dataPtr;
    int l = 0;
    int h = (ePtr - sPtr) ~/ _segmentIndexSize;

    while (l <= h) {
      int m = (l + h) >> 1;
      int p = sPtr + m * _segmentIndexSize;

      Uint8List? buff = _read(p, _segmentIndexSize);
      if (buff == null) {
        throw Exception("failed to _read segment index at $p");
      }

      int sip = _getLong(buff, 0);

      if (ip < sip) {
        h = m - 1;
      } else {
        int eip = _getLong(buff, 4);
        if (ip > eip) {
          l = m + 1;
        } else {
          dataLen = _getShort(buff, 8);
          dataPtr = _getLong(buff, 10);
          break;
        }
      }
    }

    if (dataPtr != null) {
      Uint8List? buff = _read(dataPtr, dataLen);
      if (buff != null) {
        result = utf8.decode(buff);
      }
    }
    if (handle != null) {
      handle?.closeSync();
    }
    final took = DateTime.now().microsecondsSinceEpoch - startTime;
    return {'region': result, 'ioCount': ioCount, 'took': took};
  }

  Uint8List? _read(int offset, int len) {
    if (contentBuff != null) {
      return contentBuff!.sublist(offset, offset + len);
    }

    handle!.setPositionSync(offset);
    ioCount++;
    Uint8List buff = Uint8List(len);
    int bytesRead = handle!.readIntoSync(buff);
    if (bytesRead != len) {
      return null;
    }

    return buff;
  }

  static int? _ip2long(String ip) {
    InternetAddress? address = InternetAddress.tryParse(ip);
    if (address == null) {
      return null;
    }
    return address.rawAddress.buffer.asByteData().getUint32(0, Endian.big);
  }

  static int _getLong(Uint8List b, int idx) {
    // return b.buffer.asByteData().getUint32(idx, Endian.little);
    int val =
        b[idx] | (b[idx + 1] << 8) | (b[idx + 2] << 16) | (b[idx + 3] << 24);
    return val;
  }

  static int _getShort(Uint8List b, int idx) {
    // return b.buffer.asByteData().getUint16(idx, Endian.little);
    return b[idx] | (b[idx + 1] << 8);
  }

  static Uint8List? loadContentFromFile(String dbFile) {
    File file = File(dbFile);
    if (!file.existsSync()) {
      throw Exception("failed to open xdb file '$dbFile'");
    }
    return file.readAsBytesSync();
  }

  static List<int> loadVectorIndex(RandomAccessFile handle1) {
    handle1.setPositionSync(_headerInfoLength);
    int len = _vectorIndexRows * _vectorIndexCols * _segmentIndexSize;
    List<int> buff = List<int>.filled(len, 0); // Uint8List(len);
    int rLen = handle1.readIntoSync(buff);
    if (rLen != len) {
      return [];
    }
    return buff;
  }

  static List<int> loadVectorIndexFromFile(String dbPath) {
    final handle1 = File(dbPath).openSync(mode: FileMode.read);
    final vIndex = loadVectorIndex(handle1);
    handle1.closeSync();
    return vIndex;
  }

  static IP2RegionPlus newWithFileOnly(String dbFile) {
    return IP2RegionPlus(dbFile, null, null);
  }

  static newWithBuffer(cBuff) {
    if (cBuff.isEmpty) {
      throw Exception('buffer is invalid');
    }
    return IP2RegionPlus('', null, cBuff);
  }

  static newWithVectorIndex(String dbPath, List<int> vectorIndex) {
    if (vectorIndex.isEmpty) {
      throw Exception('vectorIndex is invalid');
    }
    return IP2RegionPlus(dbPath, Uint8List.fromList(vectorIndex), null);
  }
}
