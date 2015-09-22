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
#	============= Zumin - ゲストブック１号 ==============
#	============  管理者ツール App Library  =============
#
#   zg1adm.pm
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


###################################################################
#
#	Use Library
#
###################################################################
use		zcgi;


###################################################################
#
#	Define Globals 固定値
#
###################################################################

# CGI名称
$MyCGI  = "zg1adm.cgi";
$MyCGIp = "zg1admp.cgi";

# GUEST BOOK CGIへのURL
$GuestCgiUrl = 'zguest1.cgi';

# ゲストブックトップへのリンクを表示するかどうかのフラグ
# サブメニューの時に表示する。
$DispLinktoTop = 0;

# クッキー名称
$MyCookieName = 'ZG1ADM';


# デモ用（普通は 0 固定）
$DemoUse = 0;


###################################################################
#
#	管理者認証
#
###################################################################
sub AuthAdmin
{
	my ($p) = @_;

	# クッキー取得
	my $c = &GetCookie($MyCookieName);

	# クッキーの管理者IDからパスワード取得
	my $passwd = &DeCrypt($c->{id}, $CriptKey);

	# パラメータで入力されたパスワードがある場合
	# そのパスワードの方が優先
	if ($p->{passwd}) { $passwd = $p->{passwd}; }

	# 管理者認証
	if ($passwd eq '') {
		# 新規アクセスの場合
		push(@ErrorMessage, '管理者認証が必要です。');
		return 0;

	} elsif ($passwd ne $AdminPasswd) {
		# 認証失敗した場合
		push(@ErrorMessage, 'パスワードが間違っていませんか？');
		return 0;
	}

	# パスワードフォーム経由の場合は、次回から
	# いちいち入力しなくて済むようにクッキーを
	# 設定する。
	if ($p->{passwd} eq $passwd) {
		my $id = &EnCrypt($passwd, $CriptKey);
		if ($id ne ''){
			my $c = {};
			$c->{id} = $id;
			$c->{zuminapp} = 'zg1adm';

			# クッキー生成しパラメータハッシュに突っ込んでおく。
			$p->{cookie} = &SetCookie($MyCookieName, $c, 30);
		}
	}

	return 1;
}

###################################################################
#
#	HTML ヘッダ書き出し
#
###################################################################
sub PrintHeader
{
	my ($cookie) = @_;

	# サーバー日本語文字コード取得
	my $saver_jcode = &GetSaverEncode();

	# HTTP ヘッダ
	print "Pragma: no-cache\n";
	print "Cache-Control: no-cache\n";
	print "Content-Type: text/html; charset=$saver_jcode\n";

	# Cookieの設定要求があれば Cookie 発行
	print "$cookie\n"  if ($cookie ne '');
	print "\n";

	# HTTP ヘッダ
	print "<html>\n";
	print "<head>\n";
	print "<title>Zcounter Admin Tool [ FOR $CurrentVer ]</title>\n";
	print "</head>\n";

	# HTTP 本体
	print "<body bgcolor=\"#FFFFFF\">\n";
	print "<center>\n";
	print "<table width=\"95%\" bgcolor=\"BBBBFF\" " .
				"border=\"0\" cellpadding=\"3\" cellspacing=\"3\">\n";
	print "<tr><td align=\"center\">\n";
	print "[ <a href=\"$MyCGI\">戻る</a> ]\n" if ($DispLinktoTop);
	print "[ <a href=\"$HomeURL\">ホーム</a> ]\n";
	print "[ <a href=\"$GuestCgiUrl\">ゲストブック</a> ]\n";
	print "</td></tr></table>\n";
	print "<p>\n";
	print "<h2>GEUST BOOK 管理</h2>\n";
	print "<p>\n";
}

###################################################################
#
#	HTML フッタ書き出し
#
###################################################################
sub PrintFooter
{
	my $zuminURL  = 'http://zumin.cside9.com/zumin/';

	# Copyright
	print "<table width=\"95%\" bgcolor=\"BBBBFF\" border=\"0\" cellpadding=\"3\" cellspacing=\"3\">\n";
	print "<tr><td align=\"center\">\n";
	print "<address>CGI Script $CurrentVer &copy; <a href=\"$zuminURL\" target=\"zumin\">ZUMIN</a></address>\n";
	print "</td></tr></table>\n";

	print "</center>\n";

	# HTML END
	print "</body>\n";
	print "</html>\n";
}

###################################################################
#
#	エラー時HTML表示処理
#
###################################################################
sub PrintError
{
	print "<div><strong><font color=\"#FF0000\">\n";
	foreach (@ErrorMessage) { print "$_<br>\n"; }
	print "</font></strong></div>\n";
	print "<p>\n";
}

###################################################################
#
#	パスワード入力フォーム書き出し
#
###################################################################
sub PrintPasswdForm
{
	print "<p>\n";
	print "認証パスワードを入力してください。\n";
	print "<form action=\"$MyCGI\" method=\"POST\">\n";
	print "\t<input type=\"password\" name=\"passwd\" maxlength=\"16\">\n";
	print "\t<input type=\"submit\" value=\"送信\">\n";
	print "</form>\n";
}

###################################################################
#
#	投稿ログデータ一覧書き出し
#
###################################################################
sub PrintLogList
{
	my ($p) = @_;

	# 投稿ログデータの読み込み
	my %logdata = &GetLogData($p);
	my $total   = $MessageDispCount2;

	if ($total == 0) {
		print "<font color=\"#FF0000\"><h3>投稿データはありません</h3></font>\n";
		return;
	}

	# 最大ページ数
	my $pagemax = int(($total - 1) / $LogDisplayCount) + 1;

	# 表示ページ
	my $page = ($p->{page} < 1) ? 1 : $p->{page};

	# 表示する投稿ログ件数範囲、ページ数の調整
	my $disp_low = ($page - 1) * $LogDisplayCount + 1;
	if ($disp_low > $total) {
		$page = $pagemax;
		$disp_low = ($page - 1) * $LogDisplayCount + 1;
	}
	my $disp_high = $disp_low + $LogDisplayCount;

	# -------------------------------
	#	処理ボタン類の表示
	# -------------------------------

	# コマンドボタン
	print "<p><br>\n";
	&PrintCommandButton($p);
	print "<p>\n";

	# ページボタン
	&PrintPageButton($page, $pagemax, $p);
	print "<p>\n";

	# -------------------------------
	#	書き込みされたログの表示
	# -------------------------------
	my $cur_serial;
	my $pre_serial;
	my $lineno = 0;
	my @sorted_keys = sort LogKeyCmpare keys %logdata;
	my $data_max = @sorted_keys - 1;

	for my $i (0 .. $data_max) {
		my $k = $sorted_keys[$i];
		my $d = $logdata{$k};

		# 投稿に対するレスでなければログ番号カウントアップ
		## unless ($d->{resnumber}) { $lineno++; }
		if ($cur_serial ne $d->{serial}) { $lineno++; }
		$cur_serial = $d->{serial};

		# 投稿ログ番号チェック
		if ($lineno < $disp_low)   { next; }
		if ($lineno >= $disp_high) { last; }

		# -------------------------------
		#	投稿ログ一件分出力
		# -------------------------------

		# 直前に表示したデータとシリアル番号が異なる場合はテーブルの開始
		if ($pre_serial ne $d->{serial}) {
			print "<table border=\"0\" width=\"94%\" cellpadding=\"8\" cellspacing=\"0\" bgcolor=\"#BBCCCC\">\n";
			print "<tr>\n";
			print "<td>\n";
		}
		# 直前に表示したデータとシリアル番号が同じ場合はテーブルの継続
		else {
			print "<tr>\n";
			print "<td align=\"right\">\n";
		}
		# 書き込まれた投稿ログリスト一件分出力
		&PrintLogDetail($d, 1);

		print "</td>\n";
		print "</tr>\n";

		# -------------------------------
		#	投稿ログ１件毎コマンド
		# -------------------------------
		if ($p->{command} ne "search") {

			if ($pre_serial ne $d->{serial}) {
				print "<tr>\n";
				print "<td>\n";
			} else {
				print "<tr>\n";
				print "<td align=\"right\">\n";
			}

			# 投稿ログ１件毎のコマンドボタン
			&PrintDataCommandButton($d);

			print "</td>\n";
			print "</tr>\n";
		}

		# 次データのシリアル番号を取得する
		# 次データとシリアル番号が異なる場合はテーブルの終了
		my ($next_serial, $r);
		if ($i < $data_max) { ($next_serial, $r) = split(/:/, $sorted_keys[$i+1]); }
		if ($next_serial ne $d->{serial}) {
			print "</table>\n";
			print "<p>\n";
		}

		# 現在のシリアル番号待避
		$pre_serial = $d->{serial};
	}

	# ページボタン
	&PrintPageButton($page, $pagemax, $p);
	print "<p>\n";
}

###################################################################
#
#	一件分の投稿ログデータ詳細書き出し
#
###################################################################
sub PrintLogDetail
{
	my ($p) = @_;
	my $serial    = $p->{serial};
	my $resnumber = $p->{resnumber};
	my $delkey    = $p->{delkey}	unless($DemoUse);
	my $deleted   = ($p->{deleted} == 1) ? '非表示' : '表示';
	my $date      = $p->{date};
	my $time      = $p->{time};
	my $ip        = $p->{ip}		unless($DemoUse);
	my $host      = $p->{host}		unless($DemoUse);
	my $subject   = &Cdata($p->{subject});
	my $name      = &Cdata($p->{name});
	my $email     = &Cdata($p->{email});
	my $hpname    = &Cdata($p->{hpname});
	my $url       = &Cdata($p->{url});
	my $body      = $p->{body};
	my $fgcol     = $p->{fgcol};
	my $icon      = $p->{icon};
	my $sex       = ($p->{sex} == 1) ? '女' : '男';

	# 本文の改行コード、Cdata変換
	$body =~ s/<br>/\n/g;
	$body =  &Cdata($body);
	$body =~ s/\n/<br>/g;

	# 書き込まれた投稿ログ一件分出力
	print "<table border=\"1\" width=\"85%\" cellpadding=\"7\" cellspacing=\"0\" bgcolor=\"#FFFFE8\">\n";
	print "<tr><td>\n";

	# シリアル、レス番号
	print "\t<strong>SerialNo.</strong>$serial <strong>ResNo.</strong>$resnumber \n";

	print "</td></tr>\n";
	print "<tr><td>\n";

	# アクセス時間
	print "\t<strong>Time:</strong>$date $time \n";

	# IP、HOST
	print "\t<strong>Address:</strong>$ip <strong>Host:</strong>$host \n";

	print "</td></tr>\n";
	print "<tr><td>\n";

	# 名前、性別
	print "\t<strong>Name:</strong>$name [$sex] \n";

	# email
	print "\t<strong>Email:</strong>$email \n";

	print "</td></tr>\n";
	print "<tr><td>\n";

	# HomePage
	print "\t<strong>HomePage:</strong>$url $hpname \n";

	# アイコン番号、表示色
	print "\t<strong>Icon:</strong>$icon <strong>Color:</strong>$fgcol \n";

	# 削除キー
	print "\t<strong>DeleteKey:</strong>$delkey \n";

	print "</td></tr>\n";
	print "<tr><td>\n";

	# タイトル
	print "\t<strong>Title:</strong>$subject \n";

	print "</td></tr>\n";
	print "<tr><td>\n";

	# メッセージ本体
	my $col = ($fgcol > 0 && $fgcol <= @UserLogColor) ? $UserLogColor[$fgcol - 1] : '#000000';
	if ($p->{deleted}) {
		print "\t<font color=\"$col\"><s>$body</s></font>\n";
	} else {
		print "\t<font color=\"$col\">$body</font>\n";
	}
	print "</td></tr>\n";
	print "</table>\n";
}

###################################################################
#
#	投稿ログ一覧に表示するコマンド群出力
#
###################################################################
sub PrintCommandButton
{
	my ($p) = @_;

	print "<table width=\"70%\" border=\"0\" cellpadding=\"1\" cellspacing=\"1\">\n";

	# 検索処理
	print "<tr><td colspan=\"2\" align=\"center\">\n";
	print "<form method=\"GET\" action=\"$MyCGI\">\n";
	print "\t<input type=\"hidden\" name=\"command\" value=\"search\">\n";
	print "\t<input type=\"radio\" name=\"taisyo\" value=\"name\"";
	if ($p->{command} eq "search" && $p->{taisyo} eq "name") {
		print " checked=\"checked\"";
	}
	print ">投稿者名\n";
	print "\t<input type=\"radio\" name=\"taisyo\" value=\"body\"";
	if ($p->{command} eq "search" && $p->{taisyo} eq "body") {
		print " checked=\"checked\"";
	}
	print ">投稿記事\n";
	print "\tから \n";
	if ($p->{command} eq "search") {
		print "\t<input type=\"text\" name=\"search_key\" value=\"$p->{search_key}\" size=\"32\" maxlength=\"64\">";
	} else {
		print "\t<input type=\"text\" name=\"search_key\" size=\"32\" maxlength=\"64\">";
	}
	print "\t<input type=\"submit\" value=\"を検索\">\n";
	print "</form>\n";
	print "</td></tr>\n";

	# 全件ダウンロード
	print "<tr><td align=\"right\">\n";
	print "<form method=\"GET\" action=\"$MyCGI\">\n";
	print "\t<input type=\"hidden\" name=\"command\" value=\"download\">\n";
	print "\t<input type=\"submit\" value=\"全ての投稿をダウンロード\">\n";
	print "</form>\n";
	print "</td>\n";

	# 全件削除
	print "<td align=\"left\">\n";
	print "<form method=\"POST\" action=\"$MyCGIp\">\n";
	print "\t<input type=\"hidden\" name=\"command\" value=\"allclear\">\n";
	print "\t<input type=\"submit\" value=\"全ての投稿をクリア\" ",
	"onClick=\"return confirm(
	'全ての投稿を削除ますが、宜しいですか？（シリアル番号は継続します）')\">\n";
	print "</form>\n";
	print "</td></tr>\n";

	print "</table>\n";
}

###################################################################
#
#	投稿ログ一覧リストに表示するページング出力
#
###################################################################
sub PrintPageButton
{
	my ($cur_page, $pagemax, $p) = @_;

	print "<table width=\"94%\" border=\"0\" cellpadding=\"1\" cellspacing=\"1\">\n";
	print "<tr>\n";
	print "<td width=\"10%\" align=\"right\"><strong>Page: </strong></td>\n";
	print "<td align=\"left\">";
	for (my $i = 1; $i <= $pagemax ; $i++) {
		if ($i == $cur_page) {
			print "<strong>&nbsp;${i}&nbsp;</strong>";
		} else {
			my $url;
			if ($p->{command} eq "search") {
				my $search_key = &URLEncode($p->{search_key});
				$url = "$MyCGI?command=search&taisyo=$p->{taisyo}&search_key=$search_key&page=$i";
			} else {
				$url = "$MyCGI?page=$i";
			}
			print "<a href=\"$url\">&nbsp;${i}&nbsp;</a>";
		}
	}
	print "</td>\n";
	print "</tr>\n";
	print "</table>\n";
}

###################################################################
#
#	投稿ログ一覧の各投稿データ毎コマンドボタン出力
#
###################################################################
sub PrintDataCommandButton
{
	my ($p) = @_;
	my $serial    = $p->{serial};
	my $resnumber = $p->{resnumber};

	print "<table border=\"0\" cellpadding=\"1\" cellspacing=\"1\">\n";
	print "<tr>\n";

	if ($resnumber == 0) {
		print "<td>\n";
		print "<form method=\"GET\" action=\"$MyCGI\">\n";
		print "\t<input type=\"hidden\" name=\"command\" value=\"res\">\n";
		print "\t<input type=\"hidden\" name=\"serial\" value=\"$serial\">\n";
		print "\t<input type=\"hidden\" name=\"resnumber\" value=\"$resnumber\">\n";
		print "\t<input type=\"submit\" value=\"返信\">\n";
		print "</form>\n";
		print "</td>\n";
	}

	print "<td>\n";
	print "<form method=\"GET\" action=\"$MyCGI\">\n";
	print "\t<input type=\"hidden\" name=\"command\" value=\"edit\">\n";
	print "\t<input type=\"hidden\" name=\"serial\" value=\"$serial\">\n";
	print "\t<input type=\"hidden\" name=\"resnumber\" value=\"$resnumber\">\n";
	print "\t<input type=\"submit\" value=\"編集\">\n";
	print "</form>\n";
	print "</td>\n";

	print "<td>\n";
	print "<form method=\"POST\" action=\"$MyCGIp\">\n";
	print "\t<input type=\"hidden\" name=\"command\" value=\"delete\">\n";
	print "\t<input type=\"hidden\" name=\"serial\" value=\"$serial\">\n";
	print "\t<input type=\"hidden\" name=\"resnumber\" value=\"$resnumber\">\n";
	print "<input type=\"submit\" value=\"削除\" ",
			"onClick=\"return confirm('本当に削除しても宜しいですか？')\">\n";
	print "</form>\n";
	print "</td>\n";

	print "</tr>\n";
	print "</table>\n";
}

###################################################################
#
#	メッセージ入力フォーム出力
#
###################################################################
sub PrintForm
{
	my ($g) = @_;
	my $command   = $g->{command};
	my $serial    = $g->{serial};
	my $resnumber = $g->{resnumber};
	my $delkey    = $g->{delkey};
	my $subject   = &Cdata($g->{subject});
	my $name      = &Cdata($g->{name});
	my $email     = &Cdata($g->{email});
	my $hpname    = &Cdata($g->{hpname});
	my $url       = ($g->{url} ne '') ? &Cdata($g->{url}) : 'http://';
	my $body      = &Cdata($g->{body});
	my $sex       = ($g->{sex} == 1)  ? 1 : 0;
	my $icon      = ($g->{icon} > 0)  ? $g->{icon}  : 1;
	my $fgcol     = ($g->{fgcol} > 0) ? $g->{fgcol} : 1;

	# 入力フォーム出力
	print "<table border=\"0\" cellpadding=\"3\" cellspacing=\"3\">\n";
	print "<form method=\"POST\" action=\"$MyCGIp\">\n";
	print "<input type=\"hidden\" name=\"command\" value=\"$command\">\n";
	print "<input type=\"hidden\" name=\"serial\" value=\"$serial\">\n";
	print "<input type=\"hidden\" name=\"resnumber\" value=\"$resnumber\">\n";

	# 名前
	print "<tr>\n";
	print "<th align=\"right\" nowrap>お名前</th>\n";

	print "\t<td>\n";
	print "\t\t<input type=\"text\" name=\"name\" size=\"30\" " .
									"value=\"$name\" maxlength=\"80\">\n";
	# 性別
	print "\t\t&nbsp;&nbsp\n";
	print "\t\t<input type=\"radio\" name=\"sex\" value=\"0\"";
	unless ($sex == 1) {	print " checked";	}
	print "><font color=\"#0000FF\">♂</font>\n";
	print "\t\t<input type=\"radio\" name=\"sex\" value=\"1\"";
	if ($sex == 1) {	print " checked";	}
	print "><font color=\"#FF0000\">♀</font>\n";

	print "\t</td>\n";
	print "</tr>\n";

	# E-Mail
	print "<tr>\n";
	print "\t<th align=\"right\" nowrap>E-MAIL</th>\n";
	print "\t<td><input type=\"text\" name=\"email\" size=\"58\" " .
								"value=\"$email\" maxlength=\"100\"></td>\n";
	print "</tr>\n";

	# HP-NAME
	print "<tr>\n";
	print "\t<th align=\"right\" nowrap>HP-NAME</th>\n";
	print "\t<td><input type=\"text\" name=\"hpname\" size=\"58\" " .
								"value=\"$hpname\" maxlength=\"100\"></td>\n";
	print "</tr>\n";

	# URL
	print "<tr>\n";
	print "\t<th align=\"right\" nowrap>URL</th>\n";
	print "\t<td><input type=\"text\" name=\"url\" size=\"58\" " .
								"value=\"$url\" maxlength=\"100\"></td>\n";
	print "</tr>\n";

	# アイコン
	my $icon_cnt = @UserLogIcon;
	if ($icon_cnt > 0) {
		print "<tr>\n";
		print "\t<th align=\"right\" nowrap>好きなアイコン</th>\n";
		print "\t<td>\n";
		for my $i (1 .. $icon_cnt) {
			my $src = $UserLogIcon[$i - 1];
			print "\t\t<input type=\"radio\" name=\"icon\" value=\"$i\"";
			print " checked" if ($icon == $i);
			print "><img src=\"$src\">\n";
			print "\t\t<br>\n" if (($i % 5) == 0 && $i < $icon_cnt);
		}
		print "\t</td>\n";
		print "</tr>\n";
	}

	# 文字色
	if (@UserLogColor > 0) {
		print "<tr>\n";
		print "\t<th align=\"right\" nowrap>文字の色</th>\n";
		print "\t<td nowrap>\n";
		for my $i (1 .. @UserLogColor) {
			my $col = $UserLogColor[$i - 1];
			print "\t\t<input type=\"radio\" name=\"fgcol\" value=\"$i\"";
			print " checked" if ($fgcol == $i);
			print "><font color=\"$col\">● </font>\n";
		}
		print "\t</td>\n";
		print "</tr>\n";
	}

	# タイトル
	print "<tr>\n";
	print "\t<th align=\"right\" nowrap>タイトル</th>\n";
	if ($command eq 'res') {
		print "\t<td>\n";
		print "\t<input type=\"hidden\" name=\"subject\" value=\"$subject\">\n";
		print "\t<strong>$subject</strong>\n";
		print "\t</td>\n";
	} else {
		print "\t<td><input type=\"text\" name=\"subject\" size=\"50\" " .
									"value=\"$subject\" maxlength=\"50\"></td>\n";
	}
	print "</tr>\n";

	# メッセージ本文
	print "<tr>\n";
	print "\t<td colspan=\"2\">\n";
	print "\t<textarea cols=\"70\" rows=\"8\" name=\"body\">$body</textarea>\n";
	print "\t</td>\n";
	print "</tr>\n";

	# 削除キーボタン
	print "<tr>\n";
	print "\t<td colspan=\"2\" align=\"right\">\n";
	print "\t削除キー";
	print "<input type=\"text\" name=\"delkey\" size=\"8\" " .
									"value=\"$delkey\" maxlength=\"8\">\n";
	print "\t</td>\n";
	print "</tr>\n";

	# 送信ボタン
	print "<tr>\n";
	print "\t<td colspan=\"2\" align=\"center\">\n";
	print "\t<input type=\"submit\" value=\"送信\">\n";
	print "\t<input type=\"reset\"  value=\"リセット\">\n";
	print "\t</td>\n";
	print "</tr>\n";

	print "</form>\n";
	print "</table>\n";
	print "<p>\n";
}

###################################################################
#
#	投稿ログファイルダウンロード
#
###################################################################
sub DownloadData
{
	my ($p) = @_;

	# HTTP ヘッダ出力
	# Content-Disposition: HTTPヘッダを出力する。
	print "Content-Type: text/comma-separated-values; charset=Shift_JIS\n";
	print "Content-Disposition: inline; filename=\"zguest.csv\"\n";
	print "\n";

	# 投稿ログデータの読み込み
	my %logdata = &GetLogData();

	# 投稿ログデータループ
	foreach my $key (sort LogKeyCmpare keys %logdata) {

		my $d = $logdata{$key};
		my @data = (
				$d->{serial},
				$d->{resnumber},
				$d->{date},
				$d->{time},
				$d->{ip},
				$d->{host},
				$d->{delkey},
				$d->{deleted},
				$d->{name},
				$d->{sex},
				$d->{email},
				$d->{hpname},
				$d->{url},
				$d->{fgcol},
				$d->{icon},
				$d->{subject},
				$d->{body},
			);

		# CSV形式に変換
		my $line = join ',', map {(s/"/""/g or /[\r\n,]/) ? qq("$_") : $_} @data;

		# Shift_JIS に変換する。
		$line = &ConvStr($line, $SJIS);

		# 投稿ログデータ出力
		print "$line\n";
	}

	return 1;
}

###################################################################
#
#	デモ版ごめんなさいメッセージ出力
#
###################################################################
sub SorryButDemo
{
	my ($p) = @_;
	&PrintHeader($p->{cookie});
	print "<h2>デモ版なので動きません。ごめんなさい。</h2>\n";
	&PrintFooter();
}

###################################################################
1
