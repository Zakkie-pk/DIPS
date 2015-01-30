package Lab2::DB;

use strict;
use warnings;

use DBI;
use Carp;
use Data::Dumper;
use base qw(Exporter);

our @EXPORT_OK = qw(
	user_insert
	user_get_pass
	user_get_info

	select_username_by_token

	access_token_exists
	access_token_get_info
	access_token_update_info

	auth_code_delete
	auth_code_get_info
	auth_code_update_code

    get_code_id_by_code
);

our %EXPORT_TAGS = (
	all => [@EXPORT_OK],
);

my $__dbh;

BEGIN {
	$__dbh = DBI->connect("DBI:mysql:database=lab2;host=127.0.0.1;port=3306", "root", "", 
		{
			AutoCommit => 1,
			RaiseError => 1
		}
	) or croak "error while connecting to DB.\n";
}

sub select_row {
	my ($query, @args) = @_;

	my $sth = $__dbh->prepare($query);
	$sth->execute(@args) or croak $__dbh->errstr();
	return $sth->fetchrow_hashref();
}

sub select_array {
	my ($query, $use_array_of_hashes, @args) = @_;

	my $response_type = $use_array_of_hashes ? { Slice => {} } : undef;
	my $res = $__dbh->selectall_arrayref($query, $response_type, @args) or croak $__dbh->errstr();

	return $res;
}

sub execute_query {
	my ($query, @args) = @_;

	my $ret = $__dbh->do($query, undef, @args) or croak $__dbh->errstr();

	return $ret;
}

sub access_token_exists {
	my $token = shift;

    my $row = select_row("SELECT token, time FROM tokens WHERE token=?", $token);
	return defined $row && time() - 600 < $row->{time};
}

sub select_username_by_token {
	my $token = shift;

	my $row1 = select_row("SELECT code_id FROM tokens WHERE token=? ORDER BY id DESC LIMIT 1", $token) or croak "Didn't find code for token '$token'.\n";
    my $row2 = select_row("SELECT user_id FROM codes WHERE id=? ORDER BY id DESC LIMIT 1", $row1->{code_id}) or croak "Didn't find user for code id '$row1->{code_id}'.\n";
    my $row3 = select_row("SELECT login FROM users WHERE id=?", $row2->{user_id}) or croak "Didn't find user for with id '$row2->{user_id}'.\n";

	return $row3->{login};
}

sub get_code_id_by_code {
    my $code = shift;
    my $row = select_row("SELECT id FROM codes WHERE code='$code'") or croak "Did not find code '$code'.\n";
    return $row->{id};
}

sub get_user_id_by_login {
    my $login = shift;
    my $row = select_row("SELECT id FROM users WHERE login='$login'") or croak "Did not find user '$login'.\n";
    return $row->{id};
}

sub get_app_id_by_app_id {
    my $app_id = shift;
    my $row = select_row("SELECT id FROM apps WHERE app_id='$app_id'") or croak "Did not find app '$app_id'.\n";
    return $row->{id};
}

sub access_token_get_info {
	my ($client_id, $refresh_token) = @_;

    my $row1 = select_row("SELECT code_id FROM tokens WHERE refresh_token='$refresh_token'") or croak "Did not find refresh key.\n";
    my $row2 = select_row("SELECT application_id FROM codes WHERE id=$row1->{code_id}") or croak "Did not find app id.\n";
    my $row3 = select_row("SELECT secret_key FROM apps WHERE id=$row2->{application_id}") or croak "Did not find secret key.\n";

	return ($row3->{secret_key}, $row1->{code_id});
    
}

sub access_token_update_info
{
	my ($code_id, $info) = @_;

	return execute_query("INSERT INTO tokens (code_id, time, token, refresh_token) VALUES (?, ?, ?, ?)", $code_id, $info->{time}, $info->{token}, $info->{refresh_token});
}

sub auth_code_update_code
{
	my ($user_id, $client_id, $code) = @_;

    my $u_id = get_user_id_by_login($user_id);
    my $app_id = get_app_id_by_app_id($client_id);
	return execute_query("INSERT INTO codes (user_id, application_id, code) VALUES (?, ?, ?)", $u_id, $app_id, $code);
}

sub auth_code_get_info {
	my ($code, $client_id) = @_;

	return select_row(qq{
		SELECT user_id, (
			SELECT secret_key
			FROM apps
			WHERE app_id=?) secret_key
		FROM codes
		WHERE code=?
        ORDER BY id DESC
        LIMIT 1
	}, $client_id, $code);
}

sub get_aircraft_info {
	my $id = shift;

	return select_row(qq{
		SELECT id, name, roominess, distance
		FROM aircrafts
		WHERE id=?
	}, $id);
}

sub get_aircrafts_list {
    my ($limit, $offset) = @_;
	return select_array(qq{
		SELECT id, name, roominess, distance
		FROM aircrafts
		ORDER BY id
        LIMIT $limit OFFSET $offset
	}, 'use_hash');
}

sub get_aircrafts_cnt {
    my $row = select_row(qq{
        SELECT COUNT(*) as cnt
        FROM aircrafts
    });

    return $row->{cnt};
}

sub get_planes_by_company_id {
	my $id = shift;

	my $result = select_array("SELECT name FROM aircrafts AS A JOIN links AS L ON A.id=L.aircraft_id WHERE company_id=?", undef, $id);
	$result = [ map { $_->[0] } @{$result} ];

	return $result;
}

sub get_company_info
{
	my $id = shift;

	my $row = select_row("SELECT id, name, country FROM companies WHERE id=?", $id);
	$row->{planes} = get_planes_by_company_id($id);

	return $row;
}

sub get_companies
{
	return select_array(qq{
		SELECT id, name, country
		FROM companies
		ORDER BY id ASC
	}, 'use_hash');
}

sub user_get_info
{
	my $login = shift;

	return select_row("SELECT login, email, country FROM users WHERE login=?", $login);
}

sub user_get_pass
{
	my $login = shift;

	my $row = select_row("SELECT password FROM users WHERE login=?", $login);

	return $row->{password};
}

sub user_insert {
	my $user_info = shift;

	return execute_query("INSERT INTO users (login, password, email, country) VALUES (?, ?, ?, ?)", $user_info->{login}, $user_info->{pass}, $user_info->{email}, $user_info->{country});
}

END {
	if ($__dbh) {
		$__dbh->disconnect();
	}
}

1;
