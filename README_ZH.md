# Ip2region_plus

ip2region_plus - 是 `dart` 语言的实现。可以在 dart 或 flutter 下使用。

ip2region - 是一个离线IP地址定位库和IP定位数据管理框架，10微秒级别的查询效率，提供了众多主流编程语言的 `xdb` 数据生成和查询客户端实现。其他语言版本请查看 [lionsoul2014/ip2region](https://github.com/lionsoul2014/ip2region)

[English](README.md) | [中文](README_ZH.md) 

## 

本扩展未提供ip2region.xdb文件，请到[ip2region.xdb](https://github.com/lionsoul2014/ip2region/tree/master/data)这里下载。怎么更新也请参考此库说明。

## Useage

### 完全基于文件的查询

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

### 缓存 VectorIndex 索引

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

### 缓存整个 xdb 数据

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

```dart
dart run example/main.dart
//{region: 美国|0|0|0|Level3, ioCount: 8, took: 2392}
```
