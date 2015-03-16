#!/usr/bin/env perl
# $Id: cl2moneycsv.pl,v 1.1 2003/07/31 14:36:20 yto Exp $
# ChangeLog ���ǲȷ���!
#  ref. <http://nais.to/~yto/doc/zb/0016.html#kakeibo>
#
# ���ե����ޥå�
# * .+?��ʪ��:
# ^\t[����][���ڡ���][������][���]$
# - ���ڡ�����Ⱦ�ѤǤ����ѤǤ��ɤ���
# - ��ۤ�Ⱦ�ѿ������奫��ޤ�����ƤϤ����ʤ���
#
# �����
# - ���ܸ쥳���ɤ� EUC ����
# - Excel ���ɤ߹��ޤ�������ʸ�������ɤ� Shift-JIS ���Ѵ�����ɬ�פ���
#
# ����������¹���
# 
# $ cat ChangeLog
# 2003-08-02  YAMASHITA Tatsuo  <yto@example.com>
# 
# 	* �Ǥ�����: ������餷�Ƥ���
# 
# 	* p:��ʪ��: 
# 	�� �����ѡ� 1050
# 	�� ����ӥˤǻ��� 380
# 
# 2003-08-01  YAMASHITA Tatsuo  <yto@example.com>
# 
# 	* �Ǥ�����: ���Ǳǲ衣
# 
# 	* p:��ʪ��: 
# 	�� �ե������ȥա��� 525
# 	ͷ �ǲ� 2000
# 	�� ������ 420
# 	�� �����ѡ� 780
# 
# 2003-07-31  YAMASHITA Tatsuo  <yto@example.com>
# 
# 	* �Ǥ�����: ��ë�˽гݤ�����
# 
# 	* p:��ʪ��: 
# 	�� �쥹�ȥ�� 3000
# 	�� ��ë���� 640
# 	�� �ڥ�ȥ��Ģ 550
# 
# $ cl2moneycsv.pl ChangeLog
#           ,  ��,  ��,  ��,  ͷ,  ��,  ��,  ��,  ��,  ¾
# 2003.07.31,3000,   0, 640,   0,   0,   0, 550,   0,   0
# 2003.08.01, 525, 780, 420,2000,   0,   0,   0,   0,   0
# 2003.08.02,   0,1050,   0,   0, 380,   0,   0,   0,   0
# $ cl2moneycsv.pl -m ChangeLog  (������˽���)
#           ,  ��,  ��,  ��,  ͷ,  ��,  ��,  ��,  ��,  ¾
# 2003-07,3000,   0, 640,   0,   0,   0, 550,   0,   0
# 2003-08, 525,1830, 420,2000, 380,   0,   0,   0,   0
# $ cl2moneycsv.pl -m ChangeLog | nkf -s > kaimono.csv

use strict;

### ���ޥ�ɥ饤�����
use Getopt::Long;
Getopt::Long::Configure('bundling');
my ($mon_mode);
GetOptions('m|monthly' => \$mon_mode);

# ���� an item of expendidure
my @lioe = ('��', '��', '��', 'ͷ', '��', '��', '��', '��', '¾');

my $date;	
my $inside_flag = 0;

my %entry = ();
while (<>) {
    if (/^((\d{4}-\d\d)-\d\d)/) { # ���դ򥭡���
	if (defined $mon_mode) {
	    $date = $2;		# = year-month
	} else {
	    $date = $1;		# = year-month-day
	    $date =~ s|-|.|g;	# for Excel
	}
	next;
    } elsif (/��ʪ��:/) {	# �ȷ���ǡ������ҥ֥�å��λϤޤ�
	$inside_flag = 1;
    } elsif ($inside_flag == 1) { # �֥�å���
	if (/^\s*$/ and $inside_flag == 1) { # �֥�å��ν����
	    $inside_flag = 0;
	} elsif (/^\t(.+?)(\s|\xa1\xa1).*(\s|\xa1\xa1)(\d+)$/) {
	    $entry{$date}->{$1} += $4;
	}
    }
}


print " " x 10, ",  ", join(',  ', @lioe), "\n";

foreach my $date (sort keys %entry) {
    print "$date,";
    print join(',', map {sprintf "%4d", $entry{$date}{$_}} @lioe), "\n";
}
