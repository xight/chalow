#!/usr/bin/env perl
# $Id: add-extent.pl,v 1.3 2003/08/25 11:50:33 yto Exp $
# HTML �� img ������ width �� height ��­��

use strict;
use File::Copy;

# identify ��ư����
my $IDENTIFY = `which identify`;
die "NO identify!" unless ($IDENTIFY =~ /identify$/);
chomp $IDENTIFY;

if (@ARGV == 0) {
    print << "USAGE";
usage: prog <file> [file]...
USAGE
    ;
} else {

    for my $fname (@ARGV) {

	# HTML �ե������쵤���ɤ߹���
	open(IN, $fname) or die;
	my $all = join('', <IN>);
	close(IN);

	# cache �ե�����
	my $cfn = $fname;
	$cfn =~ s!/[^/]*$!!;	# �ѥ�
	$cfn .= "/cache_extent-info";
	my %file_info;
	my $file_info_update_flag = 0;
	if (open(F, $cfn)) {
	    while(<F>) {
		next if (/^\#/ or /^\s*$/);
		my @c = split(/\s/);
		if (@c == 3) {
		    $file_info{$c[0]} = [@c[1..2]];
		}
	    }
	    close(F);
	}

	# img ��������ʬ���������
	my @con = split(/(<img.+?>)/ims, $all);

	next if (scalar(@con) == 1); # img ������̵���ե�����ϲ��⤷�ʤ�

	my $num = 0;
	for (my $i = 0; $i < @con; $i++) {

	    if ($con[$i] =~ /^(<img.+?>)/ims) {
		my $in = $1;

		# width �� height ��ξ�������ꤵ��Ƥ�����ϲ��⤷�ʤ�
		next if ($in =~ /\W((width|height)\W.+?\W){2}/i); # ad hoc

		# width or height ��ä�
		$con[$i] =~ s/\s+(width|height)=[^\s]+//gims;

		# �����ե�����̾����Ф�
		die unless ($in =~ /\ssrc="?(\S+?)"?[\s>]/i);
		my $imgfn = $1;

		# identify �� width �� height �����
		next unless (-e $imgfn);
		my ($w, $h);
		if (defined $file_info{$imgfn}) {
		    ($w, $h) = @{$file_info{$imgfn}};
		} else {
		    ($w, $h) = (`$IDENTIFY $imgfn` =~ /(\d+)x(\d+)/);
		    $file_info{$imgfn} = [$w, $h];
		    $file_info_update_flag = 1;
#		    print join("----", @{$file_info{$imgfn}}),"\n";
		}
		die if $?;

		# img ������� width �� height ���ɲ�
		$con[$i] =~ s|>$| width="$w" height="$h">|ims;
		$num++;
	    }

	    # cache �ե�����ν񤭹���
	    if ($file_info_update_flag and open(F, "> $cfn")) {
		foreach my $f (sort keys %file_info) {
		    print F "$f @{$file_info{$f}}\n";
		}
		close(F);
	    }
	}

	next if ($num == 0);	# �ѹ��ս�ʤ�

	# �ѹ��ս꤬���ä��顢���Υե���������򤷤Ƥ��顢��񤭤���
	copy($fname, "$fname.bak") or die;
	open(OUT, "> $fname") or die;
	print OUT join("", @con);
	close(OUT);
    }

}
