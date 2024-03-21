### バックエンド
`python main.py`を実行

翻訳処理を行う場合は`python deepl.py`を実行

### フロントエンド画面
(https://flutter-ml-app-31e67.web.app/)  にアクセス

もしくは各自の環境で`flutter run`を実行



#### firebaseへのデプロイのやり方(以下任意)
firebase consoleでプロジェクトを作成し、hostingを構築

そしてターミナルで以下のコードを順に実行

```sh
npm install -g firebase-tools
firebase login
firebase init
flutter build web
firebase deploy
```
