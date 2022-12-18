# Eitango-Collecting-And-Showing
英単語帳rubyプログラムです．weblioとCambridge Dictionaryから，英単語の日本語訳と英語訳を取得し，データベースに保存，表示します．日本語からの検索にも対応していますが，フルテキスト検索と，weblio検索の２つを用意しています．

## 環境

### 各種パッケージ
* Ruby
* MySQL
* Mroonga

### Ruby Gems
* Active Record
* MySQL2
* Open URI

## 始めるには
最初に，gemをインストールします．`mysql2`を使用するため，`open-ssl`のインストールを予めお願いします．

```
$ bundle install
$ mysql -u root -e "CREATE DATABASE `weblio_dictionary`"
$ mysql -uroot < tango_list_db.sql
$ ruby eitango_translater.rb
```

## モード

### 日本語 &rarr; 英語 (フルテキストなし) &rArr; je
日本語を入力したら，weblio検索による英単語検索結果を出力します．

### 日本語 &rarr; 英語（フルテキスト）&rArr; ft
日本語を入力したら，保存しているレコードの中から，フルテキスト検索を行って，該当する単語を出力します．

### 英語 &rarr; 日本語 &rArr; ej
英単語の日本語の意味を以下のように出力します．

1. DBに保存されているか調べる
2. なかったら，weblioで検索する
3. 得られた結果をDBに保存する
4. 結果を表示

### 英語 &rarr; 英語 &rArr; ee
英単語の英語による意味を以下のように出力します．

1. DBに保存されているか調べる
2. なかったら，Cambridge Dictionaryで検索する
3. 得られた結果をDBに保存する
4. 結果を表示

## DB構造

### Weblio Dictionary 
`webrio_dictionary`というDBで管理します．以下の２つのテーブルがあります．

#### words
プログラムの根幹のテーブルです．単語の情報が保存されています．また，日本語訳に対して，フルテキスト検索エンジンMroongaを使用しています．

|カラム名|内容|備考|
|:--|---|:---|
|id|識別子|Auto Increment|
|word|英単語|英語で保存|
|meaning_j|日本語の意味|日本語で保存|
|meaning_e|英語の意味|英語で保存|
|weblio_html|WeblioページのHTML||
|cambridge_html|Cambidge DictionaryページのHTML||
|weblio_status|WeblioHTMLのステータス||
|cambridge_status|Cambridge Dictionary HTMLのステータス||
|created_at|作成日時|自動挿入|
|updated_at|更新日時|自動挿入|

#### list_pages
本プログラムの実行には，必ずしも必要ありませんが，単語リストを作成するために，今後使用する可能性があります．
|カラム名|内容|備考|
|:---|---|---:|
|id|識別子|Auto Increment|
|words_range|単語リストの範囲||
|html|単語リストのHTML||
|html_status|単語リストHTMLの状況||
|created_at|作成日時|自動挿入|
|updated_at|更新日時|自動挿入|

## その他，留意事項
### 僕からdumpファイルを受け取っている方へ
僕の知り合いで，英単語帳DBを受け取っている方は，以下のようにdumpファイルから，DBにデータを保存してください．巨大ファイルなので，`cat`されないようご注意ください．

```
  zcat weblio_dump.sql.gz > mysql -u root weblio_dictionary 
```
