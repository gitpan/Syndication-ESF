use Test::More tests => 11;

use Syndication::ESF;

my $esf = Syndication::ESF->new;

ok( defined $esf, "new() returned something" );
ok( $esf->isa( 'Syndication::ESF' ), "it's the right class" );

my $data;
open( FILE, 't/test.esf' );
{
	local $/;
	$data = <FILE>;
}
close( FILE );

$esf->parse( $data );

is( scalar @{ $esf->{ items } }, 7, 'parse( $data ) - correct number of items' );
test_fields( $esf );

$esf = Syndication::ESF->new;

$esf->parsefile( 't/test.esf' );

is( scalar @{ $esf->{ items } }, 7, "parsefile( 't/test.esf' ) - correct number of items" );
test_fields( $esf );

my $data2 = $esf->as_string;

is ( length( $data2 ), 579, 'astring()' );

sub test_fields {
	my $esf = shift;

	is( $esf->channel( 'title' ), 'Aquarionics', "channel( 'title' )" );
	is( $esf->channel( 'contact' ), 'aquarion@aquarionics.com (Aquarion)', "channel( 'contact' )" );
	is( $esf->channel( 'link' ), 'http://www.aquarionics.com/', "channel( 'link' )" );
}