package BackendAircrafts::DB::Aircrafts;

use strict;
use warnings;

use Common::DB qw(:all);
use Data::Dumper;

use base qw(Exporter);

our @EXPORT_OK = qw(
	aircrafts_info
	aircrafts_total

	aircrafts_list
    aircrafts_list_by_company_id

	aircraft_add
	aircraft_edit
	aircraft_delete

    add_link
);

our %EXPORT_TAGS = (
	all => [@EXPORT_OK],
);

sub aircrafts_info
{
	my $id = shift;

	return { error => 'invalid aircraft id specified' }
		if not $id;

	return select_row(qq{
		SELECT id, name, roominess, distance
		FROM $TABLE_NAME_AIRCRAFTS
		WHERE id=?
	}, $id);
}

sub aircrafts_total
{
	return select_row(qq{
		SELECT COUNT(*) as total
		FROM $TABLE_NAME_AIRCRAFTS
	});
}

sub aircrafts_list
{
	my ($limit, $offset, $c_id) = @_;

    print "[DB.Aircrafts] aircrafts_list, input: '$limit, $offset, $c_id'.\n";
    if ($c_id && $c_id != -1) {
        return aircrafts_list_by_company_id($c_id);
    }

	return { error => 'invalid limit or offset' }
		if not (defined $limit and defined $offset);

	return select_array(qq{
		SELECT id, name, roominess, distance
		FROM $TABLE_NAME_AIRCRAFTS
		ORDER BY id
		LIMIT ?
		OFFSET ?
	}, 'use_hash', $limit, $offset);
}

sub aircrafts_list_by_company_id
{
    my $id = shift;

    my $result = select_array("SELECT A.id, name FROM $TABLE_NAME_AIRCRAFTS AS A JOIN $TABLE_NAME_LINKS AS L ON A.id=L.aircraft_id WHERE company_id=?", undef, $id);
    $result = [ map { $_->[0] } @{$result} ];

    return { aircrafts => $result };
}

sub aircrafts_list_for_c_list {
    my $ids = shift;
    
    my $result = select_array("SELECT DISTINCT A.id, name, company_id FROM $TABLE_NAME_AIRCRAFTS AS A JOIN $TABLE_NAME_LINKS AS L ON A.id=L.aircraft_id WHERE company_id IN $ids");
    #print Dumper $result;
    $result = [ map { { id => $_->[0], name => $_->[1], company_id => $_->[2] } } @$result ];

    return { aircrafts => $result };
}

sub aircraft_add
{
	my $args = shift;

	my @args_list = qw(name roominess distance);
	my $ret = execute_query(qq{
		INSERT INTO $TABLE_NAME_AIRCRAFTS
			(name, roominess, distance)
		VALUES (?, ?, ?)
	}, @{$args}{@args_list});
    $ret = select_row("SELECT LAST_INSERT_ID()");

	#@args_list = qw(company_id);
	#$ret = execute_query(qq{
	#	INSERT INTO $TABLE_NAME_LINKS
	#		(company_id, aircraft_id)
	#	VALUES (?, ?)
	#}, @{$args}{@args_list}, $ret->{'LAST_INSERT_ID()'});

	return { ok => 'aircraft was added', id => $ret->{'LAST_INSERT_ID()'} };
}

sub add_link {
    my $args = shift;

    my @args_list = qw(c_id a_id);
    if (!$args->{'c_id'} || !$args->{'a_id'}) {
        return { error => 'wrong company ID or aircraft ID' };
    }

	my $ret = execute_query(qq{
		INSERT INTO $TABLE_NAME_LINKS
			(company_id, aircraft_id)
		VALUES (?, ?)
	}, @{$args}{@args_list});

	return { ok => 'link  was added' };
}

sub aircraft_edit
{
	my $args = shift;

	my $aircraft_id = delete $args->{id};
	return { error => 'aircraft id not specified' }
		if not $aircraft_id;

	$args = { map { $_ => $args->{$_} } qw(id name roominess distance) };

	my @keys = grep { defined $args->{$_} } keys %{$args};
	my @values = @{$args}{@keys};

	my @pairs = map { "$_=?" } @keys;

	my $update_string = join q{, }, @pairs;
	return { ok => 'nothing to update' }
		if not $update_string;

	my $ret = execute_query(qq{
		UPDATE $TABLE_NAME_AIRCRAFTS
		SET $update_string
		WHERE id=?
	}, @values, $aircraft_id);

	return { ok => 'aircraft info was successfully updated' };
}

sub aircraft_delete
{
	my $id = shift;

	return { error => 'aircraft is not specified' }
		if not $id;

	my $ret = execute_query(qq{
		DELETE FROM $TABLE_NAME_AIRCRAFTS
		WHERE id=?
	}, $id);

	return { ok => 'aircraft was deleted' };
}

1;
