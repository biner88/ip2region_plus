[![pub package](https://img.shields.io/pub/v/ip2region_plus.svg)](https://pub.dev/packages/ip2region_plus)

# Ip2region_plus

ip2region_plus - is a `dart` language implementation. It can be used in dart or flutter。

ip2region - is a offline IP address location library and IP location data management framework, 10 microsecond level query efficiency, provides a variety of mainstream programming language `xdb` data generation and query client implementation. Other language versions please see [lionsoul2014/ip2region](https://github.com/lionsoul2014/ip2region)

[English](README.md) | [中文](README_ZH.md) 

## Install

This extension does not provide ip2region.xdb file, please download it from [ip2region.xdb](https://github.com/lionsoul2014/ip2region/tree/master/data) here. How to update also refer to this library readme.

## Useage

### File-based querying

```dart
import 'package:ip2region_plus/ip2region_plus.dart';

void main() {
  String dbFile = "ip2region.xdb";
  IP2RegionPlus searcher;
  try {
    searcher = IP2RegionPlus.newWithFileOnly(dbFile);
    Map region = searcher.search('8.8.8.8');
    print(region);
  } catch (e) {
    print("failed to create searcher with '$dbFile': $e");
    return;
  }
}
```

### Cache VectorIndex index

```dart
import 'package:ip2region_plus/ip2region_plus.dart';

void main() {
  String dbFile = "ip2region.xdb";
  IP2RegionPlus searcher;
  try {
    var vIndex = IP2RegionPlus.loadVectorIndexFromFile(dbFile);
    searcher = IP2RegionPlus.newWithVectorIndex(dbFile, vIndex);
    Map region = searcher.search('8.8.8.132');
    print(region);
  } catch (e) {
    print("failed to create searcher with '$dbFile': $e");
    return;
  }
}

```

### Cache the entire xdb data

```dart
import 'package:ip2region_plus/ip2region_plus.dart';

void main() {
  String dbFile = "ip2region.xdb";
  IP2RegionPlus searcher;
  var cBuff = IP2RegionPlus.loadContentFromFile(dbFile);
  if (cBuff == null) {
    print("failed to load content buffer from $dbFile");
    return;
  }
  try {
    searcher = IP2RegionPlus.newWithBuffer(cBuff);
    Map region = searcher.search('8.8.8.132');
    print(region);
  } catch (e) {
    print(e);
    return;
  }
}
```

## Example

```shell
dart run example/main.dart
#{region: 美国|0|0|0|Level3, ioCount: 8, took: 2392}
```
