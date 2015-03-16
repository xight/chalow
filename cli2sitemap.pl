#!/usr/bin/perl
use strict;
my %hash;
while (<>) {
	$hash{$1} = $hash{$2} = $hash{$3} = 1
	if (/^<a href=\"(((\d+-\d+)-\d+)-\d+)/);
}
my $xml;
foreach (sort keys %hash) {
	my $p		= (length($_) == 7) ? 0.1 : ((length($_) == 10) ? 0.4 : "1.0");
	my $freq	= (length($_) == 7) ? "monthly" : ((length($_) == 10) ? "monthly" : "daily");
	# print qq($p $freq\n);
	$xml .= << "URL"
	<url>
		<loc>http://memo.xight.org/$_</loc>
		<changefreq>$freq</changefreq>
		<priority>$p</priority>
	</url>
URL
}
print << "XML"
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.google.com/schemas/sitemap/0.84">
	<url>
		<loc>http://memo.xight.org/</loc>
		<changefreq>daily</changefreq>
		<priority>1.0</priority>
	</url>
$xml
</urlset>
XML
	;
