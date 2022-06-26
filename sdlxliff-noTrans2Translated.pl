use strict;
use warnings;
use File::Find::Rule;
use XML::LibXML;
use Encode qw( decode encode );

###########################################################
# Status change process after pseudo translation in Trados.
###########################################################

my $dir = $ARGV[0];

my @files = File::Find::Rule->file->name('*.sdlxliff')->in($dir);
my $bom = decode( 'utf8', pack( "H*", 'efbbbf' ) );

for my $file (@files) {

    print "$file...\n";

    my $parser = XML::LibXML->new();
    my $dom    = $parser->parse_file($file);
    my @seg    = $dom->findnodes('//sdl:seg');
    my $flag   = 0;

    for my $seg (@seg) {
        my $conf = encode( 'utf8', $seg->findvalue('@conf') );

		# If the status is empty, change it to Translated.
		if ( $conf eq '') {
			$seg->setAttribute( 'conf', 'Translated' );
            $flag = 1;
        }
    }

	if ( $flag == 1 ) {
        my $root = $dom->documentElement;
        open my $out, '>:utf8', $file or die $!;
        print {$out} $bom;
        print {$out} qq/<?xml version="1.0" encoding="utf-8"?>/;
        print {$out} $root->toString;
    }

}

system 'pause > nul';
