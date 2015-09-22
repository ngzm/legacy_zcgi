#!/usr/bin/perl
###################################################################

# =================================================================
#
#   □□□ 最初にご確認ください □□□
#
#   本スクリプトはフリーソフトです。著作権は放棄していません。
#   非営利目的で使用される場合に限り、自由に使用、カスタマイズ、
#   再配布可能です。
#
#   尚、このスクリプトを使用したいかなる損害に対して、著作者は
#   一切その責を負いません。
#
# =================================================================
#
#	============== Zumin - ゲストブック１号 =============
#	===============      管理者ツール     ===============
#
#   zg1admp.cgi
#
#   Copyright(c) 2001-  Zumin., All rights reserved.
#
#   Email : mailto:webmaster@zumin.cside9.com
#   URL   : http://zumin.cside9.com/zumin/
#
# =================================================================
#   更新履歴：
#   Date.       Ver.    Note.
#   2001.05.02  0.0.1   初版
#   2001.05.09  0.0.2   APPライブラリを整理しzg1core.pmを追加
#   2001.05.11  0.0.3   返信処理拡張
#   2001.05.12  0.0.4   １件削除、全クリア処理サポート
#   2001.05.17  0.0.5   投稿ログ保存形式を一般的な形に変更
#   2001.05.19  1.0.1   リリース第１版
#   2001.05.23  1.0.2   ログ登録処理若干効率化
#   2001.05.24  1.0.3   返信ログ登録処理若干効率化
#   2001.05.26  1.0.4   デモ用、機能削減追加
#   2001.05.28  1.0.5   暗号処理（簡易版）追加
#   2001.06.15  1.0.6   クッキー有効期限を指定可能にする
#   2001.06.15  1.0.7   訪問者のプロファイルをクッキーに記憶（60日）
#   2002.05.25  1.0.8   名前、E-MAIL、HP-NAME、URL入力テキストサイズ拡大
#   2002.09.28  1.1.0   HTTPヘッダにキャッシュしない指示を追加
#   2002.10.05  1.2.0   ログダウンロードのCSVファイルのカンマや改行などを
#                       含むデータのときにフォーマットが壊れていた不具合
#                       に対応
#   2002.10.14  1.3.0   管理者ツールに投稿ログ検索機能追加
#   2003.01.25  1.3.1   アイコン表示数制限数を10から30に増加
# =================================================================
# zg1adm Version
$MajiorVer  = "zg1adm_v1";
$MiniorVer  = "31";
$CurrentVer = "${MajiorVer}\.${MiniorVer}";


###################################################################
#
#	Use Library
#
###################################################################
use	lib	"lib";
use		userdef;
use		zg1adm;
use		zg1core;


###################################################################
#
#	Start Running Script
#
###################################################################

# 初期処理
unless (&zGuestInit()) {
	&PrintHeader();
	&PrintError();
	&PrintFooter();
	&ZguestExit();
}

# パラメータ取得
my $p = &GetParam();

# 管理者認証
unless (&AuthAdmin($p)) {
	# 認証できないときはパスワード入力フォームへ
	&PrintHeader();
	&PrintError();
	&PrintPasswdForm();
	&PrintFooter();
	&ZguestExit();
}

# 返信データ保存
if ($p->{command} eq 'res') {
	&PostRes($p);

	# GETMethod処理にリダイレクト
	&RedirectGetMethod($MyCGI);
}

# 編集データ更新
elsif ($p->{command} eq 'edit') {
	&PostEdit($p);

	# GETMethod処理にリダイレクト
	&RedirectGetMethod($MyCGI);
}

# データ削除
elsif ($p->{command} eq 'delete') {
	&DoDelete($p);

	# GETMethod処理にリダイレクト
	&RedirectGetMethod($MyCGI);
}

# データ全削除
elsif ($p->{command} eq 'allclear') {
	&DoAllClear($p);
}

# 終了処理
&ZguestExit();


###################################################################
#
#	返信メッセージ登録処理
#
###################################################################
sub PostRes
{
	my ($p) = @_;

	$DispLinktoTop = 1;

	# 入力項目チェック
	unless (&CheckData($p)) {
		&PrintHeader();
		&PrintError(); 
		&PrintForm($p);
		&PrintFooter();
		&ZguestExit();
	}

	# 処理ロック
	&LockBoardFile();

	# 掲示板ログファイルに保存
	unless (&InsertData($p)) {
		&PrintHeader();
		&PrintError(); 
		&PrintForm($p);
		&PrintFooter();
		&ZguestExit();
	}

	# ロック解除
	&UnlockBoardFile();
}

###################################################################
#
#	投稿メッセージ編集データ更新処理
#
###################################################################
sub PostEdit
{
	my ($p) = @_;

	$DispLinktoTop = 1;

	if ($DemoUse) { &SorryButDemo($p); &ZguestExit(); }

	# 入力項目チェック
	unless (&CheckData($p)) {
		&PrintHeader();
		&PrintError(); 
		&PrintForm($p);
		&PrintFooter();
		&ZguestExit();
	}

	# 処理ロック
	&LockBoardFile();

	# 掲示板ログファイルに保存
	unless (&UpdateData($p)) {
		&PrintHeader();
		&PrintError(); 
		&PrintForm($p);
		&PrintFooter();
		&ZguestExit();
	}

	# ロック解除
	&UnlockBoardFile();
}

###################################################################
#
#	投稿ログ1件削除処理
#
###################################################################
sub DoDelete
{
	my ($p) = @_;

	if ($DemoUse) { &SorryButDemo($p); &ZguestExit(); }

	# 処理ロック
	&LockBoardFile();

	# パラメータで指定された投稿ログを削除する。
	&DeleteData($p);

	# ロック解除
	&UnlockBoardFile();
}

###################################################################
#
#	投稿ログ全クリア処理
#
###################################################################
sub DoAllClear
{
	my ($p) = @_;

	if ($DemoUse) { &SorryButDemo($p); &ZguestExit(); }

	# 処理ロック
	&LockBoardFile();

	# 投稿ログ全クリア。
	&AllClearData($p);

	# ロック解除
	&UnlockBoardFile();

	# HTML ヘッダ書き出し
	&PrintHeader($p->{cookie});

	print "<h2>全ての投稿データを削除しました！</h2>\n";

	# HTMLフッタ書き出し
	&PrintFooter();
}
