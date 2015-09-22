#!/usr/bin/perl --
#
# For FreeGameSpace
#
###################################################################


###################################################################
#
#	Use Library
#
###################################################################
use CGI;
use strict ;

# '漢字'をサンプルに１６進変換して調べてみる
# '漢字'は、EUCでは、b4,c1,bb,fa である。。
my $SAVER_ENC = 'Shift_JIS';
my @judge = unpack('C*', '漢字');
if ($judge[0] == 0xb4) { $SAVER_ENC = 'EUC-JP'; }

# CGIインスタンス生成
my $query = new CGI;

# ターゲットページのurl取得
my $url = $query->param('url');

print << "EOHTML"
Content-type: text/html; charset=$SAVER_ENC

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/REC-html40/strict.dtd">
<html lang="ja">
<head>
<meta name="author" content="N.ZUMIN">
<meta name="description" content="フリーゲーム 無料ゲーム オンラインゲーム 厳選オンラインゲーム集">
<meta name="keywords" content="フリーゲーム,無料ゲーム,ゲーム集,オンラインゲーム,人気ゲーム,FREE GAME">
<link rel="stylesheet" type="text/css" href="/zumin_game.css" media="screen, projection, print">
<title>フリーゲーム スペース / 年齢認証</title>
</head>
<body>
<div class="center">
フリーゲーム スペース

<h1>◆ 年齢認証ページ ◆</h1>

<img src="danger.gif" alt="danger">

<h3>
このゲームは、一部過激な内容を含みます。
<BR>
このため、１５歳未満の方はプレイできません。
</h3>
<BR>
<h1>
あなたの年齢は？
</h1>
<a href="JavaScript:history.back()"><img src="under15.png" alt="under15"></a>
<a href="JavaScript:location.replace('$url')"><img src="over15.png" alt="over15"></a>

</div>
</body>
</html>
EOHTML
