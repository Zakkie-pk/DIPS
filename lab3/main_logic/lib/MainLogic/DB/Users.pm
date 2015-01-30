package MainLogic::DB::Users;

use strict;
use warnings;

#use Readonly;
use Data::Dumper;
use Common::DB qw(:all);
use Common::Defines qw(:all);

use base qw(Exporter);

our @EXPORT_OK = qw(
	users_add
	users_delete
);

our %EXPORT_TAGS = (
	all => [@EXPORT_OK],
);

sub users_add
{
	my $args = shift;

    print "[DB.Users] add, input: " . Dumper($args);
	my $ret = execute_query(qq{
		INSERT INTO $TABLE_NAME_USERS
			(login, password, email, country)
		VALUES	(?, ?, ?, ?)
	}, @{$args}{qw(login pass_hash email country)});

	return { ok => 'user was added' };
}

sub users_delete
{
	my $args = shift;

	my $ret = execute_query(qq{
		DELETE FROM $TABLE_NAME_USERS
		WHERE login=?
	}, $args->{login});

	return { ok => 'user was deleted' };
}

1;
