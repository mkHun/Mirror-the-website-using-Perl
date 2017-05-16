#!/usr/bin/perl
use WWW::Mechanize;
use warnings;
use strict;
my $mech = WWW::Mechanize->new();
print "Enter the url: ";
chomp (my $input = <STDIN>);
my ($parent_url,$main_url,$url,$copy_url) = ($input)x4;
my ($URI) = $url=~m/((?:\w+:\/\/)?.+?\/)[^\/]+\/?$/;
$copy_url=~s/((?:\w+:\/\/)?[^\/]+).+/$1/;
my ($parent) = $url=~m/\/([^\/]+)\/?$/;
mkdir $parent;
folder_create($url);
sub folder_create
{
	my $url = shift;
	my $copy_parent = $url;
	$copy_parent=~s/.+?$parent/$parent/igs;
	eval{$mech->get($url);};
	my @cont = split("\n",$mech->content());
	foreach my $cont (@cont)
	{	
		if(($cont=~m/(?|\[DIR\].*?href="([^"]*)"[^>]*>(.+?)<\/a>|<a[^>]*href="([^"]*)"[^>]*>\s*(.+?)\/<\/a>)/) || ($cont=~m/^d.+(?:\d{4}|\d{2}:\d{2})\s+([^\s]+)$/))
		{
			my $folder_name = $2//$1;
			print ">>>$copy_parent/$folder_name\n";
			mkdir "$copy_parent/$folder_name";
		}
		elsif(($cont=~m/<a[^>]*href="([^"]*)"[^>]*>\s*(.+?)\s*<\/a>/is) || ($cont=~m/(?:\d{4}|\d{2}:\d{2})\s+([^\s]+)$/is) )
		{
			my ($filename,$file_url);
			if($2)
			{
				($filename,$file_url) = ($2,$1);
			}
			else
			{
				($filename,$file_url) = ($1) x 2;
			}
			print "***$copy_parent/$filename\n";
			eval{$mech->get ("$url/$file_url",':content_file' => "$copy_parent/$filename")} ;
		}
	}
}

find("$parent/");
sub find{
    my ($s) = @_;
	
    foreach my $ma (glob "\Q$s\E/*")
    {
      if(-d $ma)
      {
	print "$copy_url/$ma\n";
	folder_create("$URI/$ma");
	find($ma)
      }

    }
}


