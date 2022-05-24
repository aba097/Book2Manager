# Book2Manager
Book ver2の管理アプリ

本の登録・削除，ユーザの登録や表示順の修正が可能なアプリ

Book2と対応している
## 本の登録
TextFieldからの入力可能
OpenBDAPIを使用して，ISBNコードから本情報が取得可能
バーコードからISBNコードを読み込むことが可能

## フレームワーク
SwiftyDropBoxを使用

**参考**
- https://www.paveway.info/entry/2018/06/11/pweditor_swift_dropbox_api_preparation
- https://github.com/dropbox/SwiftyDropbox#configure-your-project

# 環境
- Xcode 12.5
- Swift 5.4
