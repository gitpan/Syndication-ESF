package Syndication::ESF;

use strict;
use Carp;

$Syndication::ESF::VERSION = '0.02';

# Defines the set of valid fields for a channel and its items
my @channel_fields = qw( title contact link );
my @item_fields    = qw( date title link );

sub new {
	my $class = shift;
	my $self = {
		channel => {},
		items   => []
	};

	bless $self, $class;

	return $self;
}

sub channel {
	my $self = shift;

	# accessor; if there's only one arg
	if ( @_ == 1 ) {
		return $self->{ channel }->{ $_[0] };
	}
	# mutator; if there's more than one arg
	elsif ( @_ > 1 ) {
		my %hash = @_;

		foreach (keys %hash) {
			$self->{ channel }->{ $_ } = $hash{ $_ };
		}	
	}

	return $self->{ channel };
}

sub contact_name {
	my $self = shift;

	my @contact = split( / /, $self->{ channel }->{ contact }, 2 );

	$contact[ 1 ] =~ s/[\(\)]//g;
	return $contact[ 1 ];
}

sub contact_email {
	my $self = shift;

	my @contact = split( / /, $self->{ channel }->{ contact }, 2 );

	return $contact[ 0 ];
}

sub add_item {
	my $self = shift;
	my $hash = { @_ };

	# depending on the mode, add the item to the
	# start or end of the feed
	if ( defined( $hash->{ mode } ) && $hash->{ mode } eq 'insert' ) {
		unshift ( @{ $self->{ items } }, $hash );
	}
	else {
		push ( @{ $self->{ items } }, $hash );
	}

	return $self->{ items };
}

sub parse {
	my $self = shift;
	my $data = shift;

	# boolean to indicate if we're parsing the meta data or the items.
	my $metamode  = 1;

	foreach my $line ( split /\n/, $data ) {
		# skip to the next line if it's a comment
		next if $line =~ /^#/;

		chomp( $line );

		# if it's a blank line, get out of meta-mode.
		if ( $line eq '' ) {
			$metamode = 0;
			next;
		}

		my @data = split /\t/, $line;

		# depending on what mode we're in, insert the channel, or item data.
		if ( $metamode ) {
			$self->{ channel }->{ $data[0] } = $data[1];
		}
		else {
			push @{ $self->{ items } }, { map { $item_fields[$_] => $data[$_] } 0..$#item_fields };
		}
	}
}

sub parsefile {
	my $self = shift;
	my $file = shift;

	my $data;

	if ( not open( FILE, $file ) ) {
		$@ = "File open error ($file): $!";
		return;
	}

	{
		local $/;
		$data = <FILE>;
	}

	close( FILE ) or carp( "File close error ($file): $!" );

	$self->parse( $data );
}

sub as_string {
	my $self = shift;

	my $data;

	# append channel data
	$data .= "$_\t" . $self->{ channel }->{ $_ } . "\n" for @channel_fields;
	$data .= "\n";

	# append item data
	foreach my $item ( @{ $self->{ items } } ) {
		$data .= $item->{ $_ } . "\t" for @item_fields;
		$data =~ s/\t$/\n/;
	}

	return $data;
}

sub save {
	my $self = shift;
	my $file = shift;

	if ( not open( FILE, ">$file" ) ) {
		$@ = "File open error ($file): $!";
		return;
	}

	print FILE $self->as_string;

	close( FILE ) or carp( "File close error ($file): $!" );
}

1;

=pod

=head1 NAME

Syndication::ESF - Create and update ESF files

=head1 SYNOPSIS

	use Syndication::ESF;

	my $esf = Syndication::ESF->new;

	$esf->parsefile( 'my.esf' );

	$esf->channel( title => 'My channel' );

	$esf->add_item(
		date  => time
		title => 'new item'
		link  => 'http://example.org/#foo'
	);

	print "Channel: ", $esf->channel( 'title' ), "\n";
	print "Items  : ", scalar @{ $esf->{ items } }, "\n";

	my $output = $esf->as_string;

	$esf->save( 'my.esf' );

=head1 DESCRIPTION

This module is the basic framework for creating and maintaing Epistula Syndication
Format (ESF) files. More information on the format can be found at the Aquarionics
web site: http://www.aquarionics.com/article/name/esf

This module tries to copy the XML::RSS module's interface. All applicable methods
have been copied and should respond in the same manner.

Like in XML::RSS, channel data is accessed through the C<channel()> sub, and item
data is accessed straight out of the items array.

=head1 METHODS

=over 4

=item new()

Creates a new Syndication::ESF object. It currently does not accept any parameters.

=item channel(title => $title, contact => $contact, link => $link)

Supplying no parameters will give you a reference to the channel data. Specifying
a field name returns the value of the field. Giving it a hash will update the channel
data with the supplied values.

=item add_item(date => $date, title => $title, link => $link, mode => $mode)

By default, this will append the new item to the end of the list. Specifying
C<'insert'> for the C<mode> parameter adds it to the front of the list.

=item parse($string)

Parse the supplied raw ESF data.

=item parsefile($filename)

Same as C<parse()>, but takes a filename as input.

=item contact_name()

shortcut to get the contact name

=item contact_email()

shortcut to get the contact email

=item as_string()

Returns the current data stored in the object as a string.

=item save($filename)

Saves the value of C<as_string()> to the supplied filename.

=back

=head1 BUGS

If you have any questions, comments, bug reports or feature suggestions, 
email them to Brian Cassidy <brian@alternation.net>.

=head1 CREDITS

This module was written by Brian Cassidy (http://www.alternation.net/).

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under the terms
of the Artistic License, distributed with Perl.

=head1 SEE ALSO

XML::RSS

=cut

