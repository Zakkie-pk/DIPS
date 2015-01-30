package Lab2::Model::Aircrafts;

use strict;
use warnings;

use lib 'lib';
use Lab2::DB qw(:all);

my $__aircrafts;

sub instance
{
	my $class = shift;

	return $__aircrafts
		if $__aircrafts;

	$__aircrafts = bless {
	}, $class;

	return $__aircrafts;
}

sub aircraft
{
	my ($self, $id) = @_;

	return Lab2::DB::get_aircraft_info($id);
}

sub list
{
	my ($self, $limit, $offset) = @_;

	return Lab2::DB::get_aircrafts_list($limit, $offset);
}

sub cnt {
    my ($self) = @_;
    return Lab2::DB::get_aircrafts_cnt();
}

1;
