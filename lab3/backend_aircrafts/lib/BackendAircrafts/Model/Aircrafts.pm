package BackendAircrafts::Model::Aircrafts;

use strict;
use warnings;

use BackendAircrafts::DB::Aircrafts qw(:all);

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

sub info
{
	my ($self, $id) = @_;

	return aircrafts_info($id);
}

sub list
{
	my ($self, $limit, $offset, $company_id, $for_list) = @_;

    return BackendAircrafts::DB::Aircrafts::aircrafts_list_for_c_list($for_list) if (defined $for_list && $for_list ne '');

	return BackendAircrafts::DB::Aircrafts::aircrafts_list_by_company_id($company_id)
		if ($company_id && $company_id != -1);

    print "[Model.Aircrafts] list, getting whole list...\n";
	return aircrafts_list($limit, $offset);
}

sub count
{
	my ($self) = @_;

	return aircrafts_total();
}

sub add
{
	my ($self, $args) = @_;

	return aircraft_add($args);
}

sub add_link
{
    my ($self, $args) = @_;

    return BackendAircrafts::DB::Aircrafts::add_link($args);
}

sub edit
{
	my ($self, $args) = @_;

	return aircraft_edit($args);
}

sub delete
{
	my ($self, $id) = @_;

	return aircraft_delete($id);
}

1;
