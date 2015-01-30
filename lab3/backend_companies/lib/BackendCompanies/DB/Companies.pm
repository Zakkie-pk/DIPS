package BackendCompanies::DB::Companies;

use strict;
use warnings;

#use Readonly;
use Common::DB qw(:all);
use Data::Dumper;

use base qw(Exporter);

our @EXPORT_OK = qw(
	companies_info
	companies_list
	companies_count

	companies_add
	companies_edit
	companies_delete
	companies_batch_list
);

our %EXPORT_TAGS = (
	all => [@EXPORT_OK],
);

sub companies_batch_list
{
	my $ids = shift;
	my $ids_join = join q{,}, @{$ids};

	return select_array(qq{
		SELECT id, name, country
		FROM $TABLE_NAME_COMPANIES
		WHERE id IN ($ids_join)
	}, 'use_hash');
}

sub companies_info
{
	my $id = shift;

	return select_row(qq{
		SELECT id AS c_id, name AS c_name, country AS c_country
		FROM $TABLE_NAME_COMPANIES
		WHERE id=?
	}, $id);
}

sub companies_count
{
	return select_row(qq{
		SELECT COUNT(*) as total
		FROM $TABLE_NAME_COMPANIES
	});
}

sub companies_list
{
	my ($limit, $offset) = @_;

    print "[DB.Companies] $TABLE_NAME_COMPANIES $limit $offset\n";
	return select_array(qq{
		SELECT id, name, country
		FROM $TABLE_NAME_COMPANIES
		ORDER BY id
		LIMIT ?
		OFFSET ?
	}, 'use_hash', $limit, $offset);
}

sub companies_add
{
	my $args = shift;

    print "[DB.Companies] add, input: " . Dumper($args);
	my @args_list = qw(c_name c_country);
	my $ret = execute_query(qq{
		INSERT INTO $TABLE_NAME_COMPANIES
			(id, name, country)
		values (DEFAULT, ?, ?)
	}, @{$args}{@args_list});
    $ret = select_row("SELECT LAST_INSERT_ID()");

	return { ok => 'company was added', company_id => $ret->{'LAST_INSERT_ID()'} };
}

sub companies_edit
{
	my $args = shift;

    print "[DB.Companies], edit, input: " . Dumper($args);
	my $company_id = delete $args->{c_id};
	return { error => 'company id not specified' }
		if not $company_id;

	$args = { map { $_ => $args->{$_} } qw(c_name c_country) };
	my @keys = grep { defined $args->{$_} } keys %{$args};
	my @values = @{$args}{@keys};
    foreach my $k (@keys) {
        $k =~ s/^c_//;
    }

	my @pairs = map { "$_=?" } @keys;

	my $update_string = join q{, }, @pairs;
	return { ok => 'nothing to update' }
		if not $update_string;
    print "[DB.Companies], edit, update string: '$update_string'.\n";

	my $ret = execute_query(qq{
		UPDATE $TABLE_NAME_COMPANIES
		SET $update_string
		WHERE id=?
	}, @values, $company_id);

	return { ok => 'company was changed' };
}

sub companies_delete
{
	my $id = shift;

	return { error => 'company id not specified' }
		if not $id;

	my $ret = execute_query(qq{
		DELETE FROM $TABLE_NAME_COMPANIES
		WHERE id=?
	}, $id);

	return { ok => 'company was deleted' };
}

1;
