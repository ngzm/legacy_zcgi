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
#	=============== Zumin - ゲストブック１号 ===============
#	===============     POST METHOD 処理     ===============
#
#   zguest1p.cgi
#
#   Copyright(c) 2001-  Zumin., All rights reserved.
#
#   Email : mailto:webmaster@zumin.cside9.com
#   URL   : http://zumin.cside9.com/zumin/
#
# =================================================================
#   更新履歴：
#   Date.       Ver.    Note.
#   2001.04.23  0.0.1   新規作成
#   2001.04.27  0.0.2   初期不具合修正
#   2001.04.28  0.0.3   アイコン表示機能整備
#   2001.04.28  0.0.4   投稿ログ削除機能追加
#   2001.05.01  0.0.5   URL文字をアンカーに変更する処理追加
#   2001.05.09  0.0.6   APPライブラリを整理しzg1core.pmを追加
#   2001.05.12  0.0.7   投稿ログ表示ブラッシュアップ
#   2001.05.17  0.0.8   投稿ログ保存形式を一般的な形に変更
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
# zguest1p Version
$MajiorVer  = "zguest1p_v1";
$MiniorVer  = "31";
$CurrentVer = "${MajiorVer}\.${MiniorVer}";


###################################################################
#
#	Use Library
#
###################################################################
use	lib	"lib";
use		userdef;
use		zguest1;
use		zg1core;


###################################################################
#
#	Start Running Script
#
#	POST 処理
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

# 投稿メッセージ削除処理
if ($p->{command} eq 'delete') {
	DoDelete($p);
}

# 返信メッセージ登録処理
elsif ($p->{command} eq 'res') {
	DoResponce($p);
}

# 投稿メッセージ登録処理
else{
	DoPost($p);
}

# Exit
&ZguestExit();


###################################################################
#
#	投稿メッセージ削除処理
#
###################################################################
sub DoDelete
{
	my ($p) = @_;

	$DispLinktoTop = 1;

	# 入力項目チェック
	unless (&CheckUndispData($p)) {
		&PrintHeader();
		&PrintError(); 
		&PrintFooter();
		&ZguestExit();
	}

	# 処理ロック
	&LockBoardFile();

	# 投稿データを非表示にする。
	# 本当は、削除まではしない。実際に削除できるのは管理者のみ。
	unless (&UndispData($p)) {
		&PrintHeader();
		&PrintError(); 
		&PrintFooter();
		&ZguestExit();
	}

	# ロック解除
	&UnlockBoardFile();

	# GETMethod処理にリダイレクト
	&RedirectGetMethod($MyCGI);
}

###################################################################
#
#	返信メッセージ登録処理
#
###################################################################
sub DoResponce
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

	# ユーザープロファイルクッキー情報生成
	my $c;
	$c->{name}   = $p->{name};
	$c->{sex}    = $p->{sex};
	$c->{email}  = $p->{email};
	$c->{hpname} = $p->{hpname};
	$c->{url}    = $p->{url};

	# GETMethod処理にリダイレクト
	&RedirectGetMethod($MyCGI, $c);
}

###################################################################
#
#	投稿メッセージ登録処理
#
###################################################################
sub DoPost
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

	# ユーザープロファイルクッキー情報生成
	my $c;
	$c->{name}   = $p->{name};
	$c->{sex}    = $p->{sex};
	$c->{email}  = $p->{email};
	$c->{hpname} = $p->{hpname};
	$c->{url}    = $p->{url};

	# GETMethod処理にリダイレクト
	&RedirectGetMethod($MyCGI, $c);
}
