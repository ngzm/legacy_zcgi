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
#   また、本スクリプトは、とほほさん著作 gifcat.pl を使用、再配
#   布しています。こちらの使用上の注意もご確認ください。
#   http://wakusei.cplaza.ne.jp
#
# =================================================================
#
#	=============== Zumin - カウンター２号 ===============
#
#   zcounter2.cgi
#
#   Copyright(c) 2001-  Zumin., All rights reserved.
#
#   Email : mailto:webmaster@zumin.cside9.com
#   URL   : http://zumin.cside9.com/zumin/
#
# =================================================================
#   更新履歴：
#   Date.       Ver.    Note.
#   2001.04.14  0.0.1   新規作成
#   2001.04.15  0.0.2   初期不具合FIX
#   2001.04.18  0.0.3   初期不具合FIX
#   2001.04.20  0.0.4   初期不具合FIX   初回リリース版
#   2001.04.24  0.0.5   カウンターログファイル形式一部変更
#   2001.04.26  0.0.6   管理機能追加に伴う修正
#   2001.04.28  0.0.7   ライブラリ整理
#   2001.05.01  0.0.8   カウンターログファイル形式一部変更
#   2001.05.08  0.0.9   アクセスログファイル形式変更
#   2001.05.08  1.0.1   Ver.1 リリース
#   2001.05.10  1.0.2   カウンター更新処理不具合対応
#   2001.05.10  1.0.3   管理機能表示形式若干修正
#   2001.05.26  1.0.4   デモ用、機能削減追加
#   2001.05.28  1.0.5   暗号処理（簡易版）追加
#   2001.06.15  1.0.6   クッキー有効期限を指定可能にする
#   2001.06.15  1.0.7   ログ項目にUSER-AGENT追加
#   2002.09.28  1.1.0   HTTPヘッダにキャッシュしない指示を追加
# =================================================================
$MajiorVer  = "zcounter2_v1";
$MiniorVer  = "10";
$CurrentVer = "${MajiorVer}\.${MiniorVer}";


###################################################################
#
#	Use Library
#
###################################################################
use	lib	"lib";
use		userdef;
use		zcounter2;


###################################################################
#
#	Start Running Script
#
###################################################################

# 初期処理
&zCounterInit();

# 処理ロック
&LockCounterFile();

# カウンタデータ取得
my $cdata = &LoadCounterData();

# カウンタデータ更新
my $ndata = &UpdateCounterData($cdata);

# カウンターデータ書込み
&SaveCounterData($ndata);

# ログデータ書込み
&AddAccessLogData($ndata);

# ロック解除
&UnlockCounterFile();

# カウンターイメージ出力
&CounterDisp($ndata->{count});

exit;
