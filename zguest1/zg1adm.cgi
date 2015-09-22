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
#   zg1adm.cgi
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

# 返信用フォーム出力
if ($p->{command} eq 'res') {
	&GetResForm($p);
}

# 編集フォーム出力
elsif ($p->{command} eq 'edit') {
	&GetEditForm($p);
}

# 投稿ログ検索
elsif ($p->{command} eq 'search') {
	&DoSearch($p);
}

# 投稿ログダウンロード
elsif ($p->{command} eq 'download') {
	&DoDownload($p);
}

# 投稿ログ一覧表示、トップメニュー
else {
	&GetLogList($p);
}

# 終了処理
&ZguestExit();


###################################################################
#
#	返信用フォーム出力
#
###################################################################
sub GetResForm
{
	my ($p) = @_;

	$DispLinktoTop = 1;

	# HTML ヘッダ書き出し
	&PrintHeader($p->{cookie});

	# 対象データ取得
	my $d = &GetLog($p);
	if ($d eq '') {
		&PrintError();
		&PrintFooter();
		&ZguestExit();
	}
	print "<hr width=\"90%\" size=\"2\" noshade>\n";
	print "<h3>オリジナルメッセージ</h3>\n";
	&PrintLogDetail($d, 1);
	print "<p>\n";

	print "<hr width=\"90%\" size=\"1\" noshade>\n";
	print "<p>\n";

	print "<h3>返信フォーム</h3>\n";
	$p->{subject} = "Re: $d->{subject}";
	$p->{name}    = $AdminUserName;
	$p->{email}   = $AdminUserEmail;
	$p->{hpname}  = $AdminUserHpName;
	$p->{url}     = $AdminUserHpURL;
	$p->{sex}     = $AdminUserSex;
	$p->{icon}    = 1;
	$p->{fgcol}   = 1;
	$p->{body}    = $d->{body};

	# 本文の改行復活と返信記号（>）挿入
	$p->{body} =~ s/<br>/\n> /g;
	$p->{body} = "> $p->{body}\n";

	# 返信用フォーム書き出し
	&PrintForm($p);

	# HTMLフッタ書き出し
	&PrintFooter();
}

###################################################################
#
#	編集フォーム出力
#
###################################################################
sub GetEditForm
{
	my ($p) = @_;

	$DispLinktoTop = 1;

	# HTML ヘッダ書き出し
	&PrintHeader($p->{cookie});

	# 対象データ取得
	my $d = &GetLog($p);
	if ($d eq '') {
		&PrintError();
		&PrintFooter();
		&ZguestExit();
	}
	$d->{command} = $p->{command};

	# 本文の改行復活
	$d->{body} =~ s/<br>/\n/g;

	print "<hr width=\"90%\" size=\"2\" noshade>\n";
	print "<h3>投稿メッセージ編集</h3>\n";

	# 編集フォーム書き出し
	&PrintForm($d);

	# HTMLフッタ書き出し
	&PrintFooter();
}

###################################################################
#
#	投稿ログ検索
#
###################################################################
sub DoSearch
{
	my ($p) = @_;

	$DispLinktoTop = 1;

	# HTML ヘッダ書き出し
	&PrintHeader($p->{cookie});

	my $ng = 0;
	if ($p->{taisyo} eq '') {
		print "<h3>検索する対象（投稿者名、投稿記事）を選択してください</h3>\n";
		$ng = 1;
	}
	if ($p->{search_key} eq '') {
		print "<h3>検索する文字列を入力してください</h3>\n";
		$ng = 1;
	}
	if (!$ng) {
		# 投稿ログデータの検索と書き出し
		&PrintLogList($p);
	}

	# HTMLフッタ書き出し
	&PrintFooter();
}

###################################################################
#
#	投稿ログダウンロード
#
###################################################################
sub DoDownload
{
	my ($p) = @_;

	$DispLinktoTop = 1;

	if ($DemoUse) { &SorryButDemo($p); return; }

	# 投稿ログファイルダウンロード
	unless (&DownloadData($p)) {
		&PrintHeader($p->{cookie});
		&PrintError();
		&PrintFooter();
	}
}

###################################################################
#
#	投稿ログ一覧表示、トップメニュー
#
###################################################################
sub GetLogList
{
	my ($p) = @_;

	# HTML ヘッダ書き出し
	&PrintHeader($p->{cookie});

	# 投稿ログデータ書き出し
	&PrintLogList($p);

	# HTMLフッタ書き出し
	&PrintFooter();
}
