package Lab2::Model::Companies;

use strict;
use warnings;

use lib 'lib';
use Lab2::DB qw(:all);

my $__companies;

sub instance
{
	my $class = shift;

	return $__companies
		if $__companies;

	$__companies = bless {
	}, $class;

	return $__companies;
}

sub company
{
	my ($self, $id) = @_;

	return Lab2::DB::get_company_info($id);
}

sub list
{
	my ($self) = @_;

	return (Lab2::DB::get_companies());
}

1;
