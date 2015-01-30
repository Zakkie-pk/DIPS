package Lab2::Model::OAuth2;

use strict;
use warnings;
use Digest::MD5 qw(md5_hex);

use lib 'lib';
use Lab2::DB qw(:all);

my $__oauth;

sub instance
{
	my $class = shift;

	return $__oauth
		if $__oauth;

	$__oauth = bless {
		last_app_id => 1,
	}, $class;

	return $__oauth;
}

sub __generate_random_string
{
	my ($self, $need_length, @args) = @_;

	return substr(md5_hex(@args, scalar localtime), 0, $need_length);
}

sub auth_code_generate
{
	my ($self, $user_id, $client_id) = @_;

	my $code = $self->__generate_random_string(16, rand(1000000), $client_id, $user_id);

	return unless auth_code_update_code($user_id, $client_id, $code);
	return $code;
}

sub auth_code_get_user_id
{
	my ($self, $client_id, $code, $client_secret) = @_;

	my $row = auth_code_get_info($code, $client_id);

	if ($row->{secret_key} eq $client_secret) {
        # TODO fix nonexpiring codes
		return $row->{user_id};
	}

	return;
}

sub access_token_new
{
	my ($self, $code, $client_secret, $after_refresh) = @_;

    my $code_id = ($after_refresh) ? $code : Lab2::DB::get_code_id_by_code($code);

	my $access_token =
		$self->__generate_random_string(16, 'access_token', rand(1000000), $code, $client_secret);

	my $refresh_token =
		$self->__generate_random_string(16, 'refresh_token', rand(1000) * rand(1000), $code, $client_secret);

	my $token_info = {
		token => $access_token,
		refresh_token => $refresh_token,
		time => time(),
	};

    print "$code_id        $token_info->{token}, $token_info->{refresh_token}, $token_info->{time}\n";
	access_token_update_info($code_id, $token_info);

	return $token_info;
}

sub refresh_token
{
	my ($self, $client_id, $client_secret, $refresh_token) = @_;

    print "C_ID: $client_id, R_T: $refresh_token\n";
	my @sk = access_token_get_info($client_id, $refresh_token);

    print "$sk[1]   $sk[2]   $client_secret\n";
	return {
		error => 'invalid_request',
		error_description => 'specified invalid argument',
	} unless @sk and $client_id and $client_secret eq $sk[0];


	return $self->access_token_new($sk[1], $client_secret, 1);
}

sub __access_token_check
{
	my ($self, $access_token) = @_;

	return 1
		if access_token_exists($access_token);

	return 0;
}

sub is_authorized
{
	my ($self, $controller) = @_;

	my $token = $controller->param('token') || '';
	my $header = $controller->req->headers->header('Authorization') || '';

	return 1
		if $controller->session('user');
	return 1
		if $self->__access_token_check($token);
	return 1
		if $header =~ /Bearer\s+(\S+)/ && $self->__access_token_check($1);

	return 0;
}

sub get_username_by_token
{
	my ($self, $token) = @_;

	return select_username_by_token($token);
}

sub get_login_from_controller
{
	my ($self, $controller) = @_;

	my $login = $controller->session('user');
	return $login if $login;

	my $header = $controller->req->headers->header('Authorization') || '';
	if ($header =~ /Bearer\s+(\S+)/) {
		$login = $self->get_username_by_token($1);
	}

	return $login;
}

1;
