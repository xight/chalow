# chalow - CHAngeLog On the Web - convert ChangeLog to HTML files

ChangeLog を HTML に変換するツール

# インストール

chalow自体のインストールは不要ですが、以下のPerlモジュールが必要です。
CPANから入手してインストールしておいてください。

* Jcode
* HTML::Template

# まずは、やってみよう!

このファイルのあるディレクトリで、以下のコマンドを実行してみて下さい。

'''
% ./chalow -o sample ChangeLog
'''

これにより、./ChangeLog という ChangeLog 形式の日記ファイルが、
sample ディレクトリ以下の複数の HTML ファイルに変換されました。

'''
% ls sample/*.html
sample/2001-12.html  ...  sample/index.html
'''

sample/index.html を Web ブラウザで見てみましょう。

また、以下のコマンドを実行すると、CSS を使った Web 日記になります。

'''
./chalow -o sample -c cl.conf ChangeLog
'''


# 概要

ChangeLog の記述内容から、「インデックスページ」「月ページ」
「日ページ」を作成し、「出力先ディレクトリ」に出力する。

インデックスページ (index.html) とは、日記タイトル、各月ページへのリン
ク、最近数日分の記述が含まれるページ。

月ページ (例: 2001-11.html) とは、ファイル名は、"年-月.html" というフォー
マット。その月の全記述が含まれるぺージ。

日ページとは、"年-月-日.html" というファイル名で出力される、一日ごとの
内容のページ。オプションで日ページを出力するように選択できる。

出力先ディレクトリとは、ChangeLog から変換された HTML ファイルが出力さ
れる先。デフォルトでは現在のディレクトリ。


# 使い方

'''
usage: chalow [options] <file> [file]...
    -n, --top-n=NUM             write NUM days to "index.html"
    -o, --output-dir=DIR        directory to output
    -c, --configure-file=FILE   configure file (default "cl.conf")
    -s, --stop-date             date to stop processing
    -u, --update-by-size        overwrite only if sizes are different
    -C, --css=FILE              css file
    -8, --utf8                  utf8 mode
    -q, --quiet                 quiet mode
'''

-n で、「インデックスページ」に最近の何日分を載せるか指定できる。
-o で、「出力先ディレクトリ」を指定する。存在しないディレクトリを指定
   してはいけない。
-c で、「ユーザ設定ファイル」を指定する。指定しないとデフォルトの設定。
-s で、処理停止日付 ($stop_date) を指定する。この日付まで処理する。
   未指定なら最後まで処理する。 (例: --stop-date "2002-01-01")
-C で、chalow: CSS ファイルをコマンドラインから指定できる。
-u を指定すると、出力先ファイルとサイズが異なる場合のみ上書き出力する。
-8 を指定すると、UTF8での出力になる。ChangeLog, cl.conf はUTF8を仮定。
-q を指定すると、変換作業進捗情報を標準出力に出力しなくなる。


実行例:

- カレントディレクトリに HTML ファイルを出力する
'''
% ./chalow ChangeLog
'''

- インデックスページに最近 2 日分だけ出力する
'''
% ./chalow -n 2 -o sample sample/ChangeLog
'''

- ユーザ設定ファイルを使う
'''
% ./chalow -c cl.conf -o ~/www/tools/chalow/cl ChangeLog
'''


# ユーザ設定ファイル

ユーザ設定ファイル ("-c" で指定する) では以下の項目などを指定できる。
詳細は、添付されている cl.conf (サンプル) を参照されたい。

- 日記の名前、URL
- インデックスページ (index.html) で最近何日分を表示するか
- インデックスページのテンプレート (※5)
- 月ページのテンプレート (※5)
- 自動文字列置換 (※6) 
- CSS ファイル
- 月ページに表示する日付の順番 (降順 or 昇順) の調整
- タブによるインデントをなくすか
- アイテムヘッダーのフォーマットをどうするか
- 表示するとき引用記号 ('>' or '|') を消すか
- item header に h3 タグを足すか (※7)
- item header の先頭の "*" にアンカーをつけるか
- 日ページ (2003-10-01.html 等) を出力するか
- RSS ファイルを出力するか
- ...

※5 インデックスページと月ページの HTML テンプレートは 
$index_page_template, $month_page_template
で設定する。詳しくは cl.conf のコメントを参照されたい。

※6 「自動文字列置換」は、ChangeLog 中の文字列を任意の文字列に変換して
いときに用いる。要するに perl のプログラムを書いておくと HTML への変換
のときに適用してくれるというわけ。

  例: "NAISTO" を "<a href="http://nais.to/">NAISTO</a>" に、
  "google" を "<a href="http://www.google.com/">google</a>" 
  に変換する。
	$auto_replace = '
	s!(NAISTO)!<a href="http://nais.to/">$1</a>!g;
	s!(\sgoogle\s)!<a href="http://www.google.com/">$1</a>!g;
	';

※7 tDiary のテーマ (CSS ファイル) をそのまま使うために必要。
tDiary のテーマを使うには以下のような設定を行うと良い。
- $item_header_style = 1 or 2 (イメージアンカーを使うとき)
- $use_h3_for_item_header = 1
- $css_file = "tDiaryのテーマのCSSファイル.css"
- $item_template で h3 で header を囲む。

# ChangeLog の特殊な記法

一部 Hiki の記法と共通にしています。

- 秘密の項目: ChangeLog には記したいが、Web 日記として公開するときには
  削りたい項目は、以下のように「項目の見出し」の先頭に "p:" を付ける。
  (p は private の意味)

	* p:秘密メモ: YTがまたやらかした。しょうもないやつだ。


- 日付で参照リンク: "[YYYY-MM-DD]" という文字列は、自動的に過去の項目
  への参照リンクへ変換される。"[YYYY-MM-DD-I]" という風にアイテム 
  No. も指定できる。

	先日[2001-12-01]、どこかへ行った。
	↓
	先日<a href="2001-12.html#2001-12-01">[2001-12-01]</a>、
	どこかへ行った。


- 任意の URL へのリンク

  「単語|URL」を 2 つの半角カギカッコで囲むとを任意の URL へのリンク
  になります。例： 
	[[Yahoo!|http://www.yahoo.co.jp/]]
	
  このとき URL の末尾が jpg,jpeg,png,gif だと IMG タグに展開されます。
  （指定した単語がALTに設定される）。例：
	[[図|image/gazou.png]]
	
  「単語」の末尾が jpg,jpeg,png,gif だとクリック可能な IMG タグに展
  開されます。IMG が URL へのリンクになります。例：
	[[image/gazou.png|http://nais.to/~yto/]]

  また、URL っぽいものがあると勝手にリンクがはられます。例：
	http://www.yahoo.co.jp/

  長い URL は、バックスラッシュ('\')で途中改行することができる。下記の
  例のように変換される。

	http://example.com/123456789012345678901234567890\
	123456789012345678901234567890.html
	↓
	<a href="http://example.com/...0.html>http://example.com/...890
	123456789012345678901234567890.html</a>


- 引用 (citation): タブの後に "|" か ">" が来る行は引用とみなし、
  blockquote で囲まれる。

	> 引用
	> 引用
	> 引用
		> これは引用ではない

	| 引用
	| 引用
	 | これは引用ではない

  または、">>" と "<<" で囲まれた領域が blockquote で囲まれる。
	       
	>>
	引用
	引用
	引用
	<<


- 文字修飾の記法

  「'」2個ではさんだ部分は強調されます。「'」3個ではさんだ部分はさら
  に強調されます。「=」2個ではさんだ部分は取消線になります。例：

	==ABC==  ''ABC''  '''ABC'''

- 水平線の記法

  マイナス記号「-」を行の先頭のタブの後から 4 つ書くと水平線になりま
  す。例：
	あはは
	----
	いひひ


- 表(table)の記法

  以下のように記述します。
	||項目1-1||項目1-2||項目1-3
	||項目2-1||項目2-2||項目2-3


- 「続きを読む」の表記

  '====' と記述すると「Read More...」というリンクができ item page へ
  ジャンプします。 
  item page を出すようにしたとき($page_mode=2)のみ機能します。


- プラグイン機能

  「{{」と「}}」で囲むとプラグイン (関数) を呼び出すことができ
  ます。

  例: {{google_seach('海老名 映画館')}}

  プラグインは cl.conf に足して置けば使えます。


- カテゴリ機能

  item header でカテゴリを指定すると、カテゴリ別ページに出力されます。
  カテゴリの指定の仕方：
	* タイトル [カテゴリ名][カテゴリ名][カテゴリ名]...: ...

  例：
	* ウヒョの購入方法 [KnowHow]: まずはコンビニへ行って...
	* うまい！[酒][コンビニ]: 昨日、コンビニで見つけた...

  カテゴリを指定すると、自動的にそのカテゴリのページが生成されます。
  カテゴリページのファイル名は「cat_[カテゴリ名].html」のようになります。

- 日々のメッセージ埋め込み

  日付エントリの上と下にその日のメッセージを表示することができます。
  以下のような item を書きます。
  item の中の HTML タグはエスケープされません。

	* message-top:
	<p>美食家の末は乞食 --- ベンジャミン・フランクリン</p>
	
	* message-bottom:
	<span style="font-size:small">♪ Jeith Jarrett / La Scala</span>


- エスケープ
  以下の記法でHTMLを直書きすることができます。
	[literal]...[/literal], [sic]...[/sic], [esc]...[/esc]


- ソース
  ソースの表示は [src]...[/src] を使います。
  内部ではエンティティ置換とpre囲みを行います。


- ChangeLogの末尾
  行頭が「__DATA__」で始まる行があると、それ以降の記述は無視されます。
  タブが入っていれば大丈夫です。


# 注意

ChengaLog ファイルの日付行は、以下のフォーマットでなければならない。

	2001-11-21  YAMASHITA Tatsuo  <yto@example.com>
	or
	2001-11-21 (Wed)  YAMASHITA Tatsuo  <yto@example.com>

曜日入り日付フォーマットについては、
<http://namazu.org/~satoru/diary/?200301b&to=200301151#200301151>
を参照されたい。

以下のフォーマットはサポートしていない。

	Sat Mar 14 08:48:56 1998  YAMASHITA Tatsuo  <yto@example.com>

しかし、パッケージに含まれている clweek.pl で日付フォーマッ
トの変換ができる。
使い方: 

'''
% ./clweek.pl ChangeLog > ChangeLog-new
'''

# LICENSE

* [無償・無保証・著作権放棄](http://lifehacks.ta2o.net/byebye-copyright.html)
