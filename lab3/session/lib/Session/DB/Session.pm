package Session::DB::Session;

use strict;
use warnings;

#use Readonly;
use Data::Dumper;
use Common::DB qw(:all);
use Common::Defines qw(:all);

use base qw(Exporter);

our @EXPORT_OK = qw(
	session_new
	session_check
	session_delete
);

our %EXPORT_TAGS = (
	all => [@EXPORT_OK],
);

sub session_new
{
	my $args = shift;

    print "[DB.Session] input for new session: " . Dumper($args);
	return { error => 'incorrect login specified' }
		if not $args->{login};
	return { error => 'incorrect pass_hash specified' }
		if not $args->{pass_hash};

	my $ret = select_row(qq{
		SELECT 1
		FROM $TABLE_NAME_USERS
		WHERE login=? and password=?
	}, @{$args}{qw(login pass_hash)});

	return { error => 'invalid login or password' }
		if not $ret;

	$ret = execute_query(qq{
		INSERT INTO $TABLE_NAME_SESSIONS
			(id, user_id, token, expiration_date)
		VALUES	(DEFAULT, ?, ?, ?)
	}, @{$args}{qw(login token)}, time() + $args->{'expires_in'});
    $ret = select_row("SELECT LAST_INSERT_ID()");
    print "[DB.Session] last ID of session returned: " . Dumper $ret;

	return { token => $args->{token}, id => $ret->{'LAST_INSERT_ID()'} };
}

sub session_delete
{
	my $args = shift;

	return { error => 'incorrect id specified' }
		if not $args->{id};
	return { error => 'incorrect token specified' }
		if not $args->{token};

	my $ret = execute_query(qq{
		DELETE FROM $TABLE_NAME_SESSIONS
		WHERE id=? and token=?
	}, @{$args}{qw(id token)});

	return { ok => 'session deleted' };
}

sub session_check
{
	my $args = shift;

	return { error => 'incorrect id specified' }
		if not $args->{id};
	return { error => 'incorrect token specified' }
		if not $args->{token};

    print "[DB.Session], check, input: " . Dumper($args);
	#my $ret = select_row(qq{
	#	SELECT user_id
	#	FROM $TABLE_NAME_SESSIONS
	#	INNER JOIN $TABLE_NAME_USERS
	#		ON ${TABLE_NAME_SESSIONS}.user_id = ${TABLE_NAME_USERS}.login
	#	WHERE ${TABLE_NAME_SESSIONS}.id=? and token=? and expiration_date > now()
	#}, $args->{id}, $args->{token});
	my $ret = select_row(qq{
		SELECT user_id
		FROM $TABLE_NAME_SESSIONS
		WHERE id=? and token=? and expiration_date > ?
	}, $args->{id}, $args->{token}, time());
    

    print Dumper $ret;
	return { error => 'bad token or session id' }
		if not $ret;

    print "[Session.DB] debug, user info: " . Dumper($ret);
	return $ret;
}

1;
