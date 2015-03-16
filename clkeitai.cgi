#!/usr/bin/env perl
# $Id: clkeitai.cgi,v 1.4 2004/06/04 13:08:30 yto Exp $
# clkeitai.cgi - chalow �ˤ�� HTML �����줿�ڡ����򥱡������Ǹ���

# �����ƥ����ɽ�� - ���󥫡��ʤɤϤʤ��������ƥ���ɽ���ؤΥ������ѡ�
# �����ƥ���ɽ�� - ���󥫡�����

use strict;

use Jcode;

use CGI;
my $q = new CGI;

# �������ä�ɽ���Ǥ������Х���
# ���֤�3k ���Ȼפ�������������Τ�;͵�򸫤�Τ��褤���ȡ�
my $page_size_max = 2500;	


print "Content-type: text/html; charset=Shift_JIS\n\n";
print qq(<html><head><title>CHALOW Keitai</title>
<meta http-equiv="Content-Type" content="text/html; charset=Shift_JIS"></head>);

if (defined $q->param('date')) {
    my $date = $q->param('date');
    if ($date =~ /^\d{4}-\d\d-\d\d$/) {
	# �����ƥस��ʤ��ƥ���ȥ����ꤷ�Ƥ����Ȥ����н�
	print "<body>Candidates: \n";
	for (my $i = 1; $i < 10; $i++) {
	    print qq(<a href="clkeitai.cgi?date=$date-$i">$date-$i</a>, );
	}
	print "...</body></html>\n";
	exit;
    }
    output_an_item($date);
} else {

    my $from = $q->param('from') || 1;
    output_simple_list($from);
}

### �����ƥ���ɽ��
sub output_an_item {
    my ($ymdi) = @_;
    my ($ymd, $ym) = ($ymdi =~ /^((\d{4}-\d\d)-\d\d)/);

    my $fn;
    if (-e "$ymd.html") {
	$fn = "$ymd.html";
    } elsif (-e "$ym.html") {
	$fn = "$ym.html";
    } else {
	print "<body>No Entry $ymdi</body></html>\n";
    }
	 
    open(F, "< $fn") or die "Can't open $fn : $!\n";
    binmode(F);
    my $all = join('', <F>);
    close(F);

    my $outstr = "no match";
    while ($all =~ m|start:$ymdi -->(.*?)<!-- end:$ymdi|smg) {
	my $new = $1;
	$new =~ s|<!--.+?-->||gsm;

	$new =~ s|<div class="itemauthor">.*?</div>||gsm; # ���Ҽ�̾����
	$new =~ s|</?p>||gsm;
	$new =~ s|</?pre.*?>||gsm;
	$new =~ s|</?div.*?>||gsm;
	$new =~ s|</?span.*?>||gsm;
	$new =~ s|<a name="$ymdi".+?>(.+?)</a>|$1|g; # �إå��Τ����
	$new =~ s|\[<a href="cat.+?">(.+?)</a>\]|[$1]|g; # ���ƥ���Τ����

	# img �ν���
	$new =~ s|(<a.+>)(<img.+>)(</a>)|$1&lt;>$3 $2 |gsm;
	$new =~ s|<img\s*src="(.+?\.([^\.]+?))"\s*alt="(.+?)".*?>|
	    qq(<a href="$1">[$3($2)]</a>)|exg;

	# inside ref
	$new =~ s|<a\shref="[\d\-]+.html\#([\d\-]+)">|
	    qq(<a href="clkeitai.cgi?date=$1">)|gxe;

	$new =~ s!^(<.+?>|)\t!$1!gsm; # ��Ƭ�Υ��֤����ν���

	$outstr = $new;
	last;
    }

    if (length($outstr) > $page_size_max) {
	$outstr = substr($outstr, 0, $page_size_max);
	$outstr =~ s|<[^>]*$||;
	$outstr =~ s|([\x00-\x7f]([\x80-\xff]{2})*)[\x80-\xff]$|$1|;
	$outstr .= "\n\n[Ĺ���Τǰʹ߾�ά���ޤ���]\n";
    }

    $outstr = jcode($outstr)->sjis;
    print "<body>$ymdi<p>$outstr</p></body></html>\n";
}

### �����ƥ����ɽ��
# anchor �Ȥ��ʤ���ʸ��������������ƥ���ɽ���ؤΥ�󥯤��ꡣ
sub output_simple_list {
    my ($from) = @_;
    my $outstr = "";
    my $len = 0;
    my $last = 0;
    my $fn = "cl.itemlist";
    open(F, "< $fn") or die "Can't open $fn : $!\n";
    binmode(F);
    while (<F>) {
#	print "$from $.\n";
	if ($from <= $.) {
	    my ($d, $c) = (/^(.+?)\t(.+)$/);

	    $d =~ s|^.*?\[(\d{4}-\d\d-\d\d-\d+)\].*?$|
		qq(<a href="clkeitai.cgi?date=$1">$1</a>)|ex;
	    #$d =~ s/<.+?>//g;

	    $c =~ s/<.+?>//g;

	    my $URLCHARS = "[-_.!~*'a-zA-Z0-9;/?:@&=+,%\#\$]";
	    my $URLDELIM = "\\\\\\n[\\t ]+";
	    $c =~ s{(s?https?|ftp)://($URLCHARS+)}{$1://...}gm;
	    
	    my $new = "$d<br>$c<hr>\n";

	    if (length($new) > $page_size_max) { # a item > max
		$new =~ s/<br>.*$/<br>(�礭�����ʤΤ���ɽ��)<hr>\n/;
	    }

	    if ($len + length($new) > $page_size_max) {
		$last = $.;
		last;
	    }
	    $len += length($new);
	    $outstr .= $new;
	}
    }
    close(F);
    $outstr = jcode($outstr)->sjis;
    print << "HTML"
<body>
$outstr
<a href="clkeitai.cgi?from=$last">&lt;&lt;</a>
</body></html>
HTML
    ;
}
