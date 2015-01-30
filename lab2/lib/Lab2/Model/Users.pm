package Lab2::Model::Users;

use strict;
use warnings;

use lib 'lib';
use Lab2::DB qw(:all);

my $__users;

sub instance
{
	my $class = shift;

	return $__users
		if $__users;

	$__users = bless {
	}, $class;

	return $__users;
}

sub user_info
{
	my ($self, $login) = @_;

	return user_get_info($login);
}

sub check_user
{
	my ($self, $login, $pass) = @_;
	my $saved_pass = user_get_pass($login) || '';

    print "PASS: $pass, SAVED: $saved_pass\n";
	return 0 unless $login and $pass eq $saved_pass;
	return 1;
}

sub add_user
{
	my ($self, $user_info) = @_;

	return user_insert($user_info)
}

1;
