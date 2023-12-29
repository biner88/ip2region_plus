import 'package:ip2region_plus/ip2region_plus.dart';

// 完全基于文件的查询
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
// 缓存 VectorIndex 索引
// void main() {
//   String dbFile = "ip2region.xdb";
//   IP2RegionPlus searcher;
//   try {
//     var vIndex = IP2RegionPlus.loadVectorIndexFromFile(dbFile)
//     searcher = IP2RegionPlus.newWithVectorIndex(dbFile, vIndex);
//     Map region = searcher.search('8.8.8.132');
//     print(region);
//   } catch (e) {
//     print("failed to create searcher with '$dbFile': $e");
//     return;
//   }
// }
//缓存整个 xdb 数据
// void main() {
//   String dbFile = "ip2region.xdb";
//   IP2RegionPlus searcher;
//   var cBuff = IP2RegionPlus.loadContentFromFile(dbFile);
//   if (cBuff == null) {
//     print("failed to load content buffer from $dbFile");
//     return;
//   }
//   try {
//     searcher = IP2RegionPlus.newWithBuffer(cBuff);
//     Map region = searcher.search('8.8.8.132');
//     print(region);
//   } catch (e) {
//     print(e);
//     return;
//   }
// }
