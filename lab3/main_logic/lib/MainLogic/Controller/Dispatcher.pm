package MainLogic::Controller::Dispatcher;
use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;
use Common::Defines qw(:all);
use Common::RequestSender qw(:all);

sub check_access
{
	my $self = shift;

	my $method = $self->req->method();
	if ($method =~ /^GET/i) {
		return __check_request_get($self)
	} elsif ($method =~ /^PUT/i) {
		return __check_request_put($self)
	} elsif ($method =~ /^POST/i) {
		return __check_request_post($self)
	} elsif ($method =~ /^DELETE/i) {
		return __check_request_delete($self)
	}

	$self->render(json => { error => "unknown method ($_)" });

	return undef;
}

sub __get_user_info
{
	my $self = shift;

	my $ua = Mojo::UserAgent->new();
	my $json = $self->req->json();

	my $id    = $self->param('id')    || $json->{id}    || q{};
	my $token = $self->param('token') || $json->{token} || q{};

	my $resp = send_request({
		method => 'get',
		url  => 'http://localhost/sessions',
		port => $self->service_session_port() || 0,
		args => {
			id	=> $id,
			token	=> $token
		}
	});
	$self->stash(user => $resp);

	$self->app->log->debug('[LOGIC] (dispatcher) user_info, resp: ',
		Dumper $resp);

	return $resp;
}

sub __check_request_get
{
	my $self = shift;

	my $request = $self->req->url->path->to_abs_string();

	return 1 # companies info isn't secret
		if $request =~ m{^/companies};

	if ($request !~ m{^/aircrafts} && $request !~ m{^/me}) {
		$self->render(json => { error => "unknown request: `$request'" });
		return undef;
	}

	my $user_info = __get_user_info($self);

	if ($request =~ $request =~ m{^/me}) {
		return 1
			if $user_info->{user_id};

		$self->render(json => { error => 'not authorized' });
		return undef;
	}

	# access success
	return 1;
}

sub __check_request_put
{
	my $self = shift;

	my $args = $self->req->json();
	my $request = $self->req->url->path->to_abs_string();
	my $user_info = __get_user_info($self);

	if ($request =~ m{^/companies}) {
		return 1
			if ($user_info->{user_id});
	}

	if ($request =~ m{^/aircrafts}) {
		return 1 if ($user_info->{user_id});
	}

	if ($request =~ m{^/users}) {
		$self->render(json => { error => 'not implemented yet' });
		return undef;
	}

	$self->render(json => { error => "unknown request: `$request'" });
	return undef;
}

sub __check_request_post
{
	my $self = shift;

	my $args = $self->req->json();
	my $request = $self->req->url->path->to_abs_string();

	return 1 if $request =~ m{^/users}; # user registration

	my $user_info = __get_user_info($self);
    return 1 if ($request =~ m{^/companies} and $user_info->{user_id});
	if ($request =~ m{^/users}) {
		return 1;
	}

	return 1 # creating new session - always allowed
		if $request =~ m{^/session};

	if ($request !~ m{^/aircrafts}) {
		$self->render(json => { error => "unknown request: `$request'" });
		return undef;
	}

	return 1;
}

sub __check_request_delete
{
	my $self = shift;

	my $args = $self->req->json();
	my $request = $self->req->url->path->to_abs_string();

	my $user_info = __get_user_info($self);
    #print "[DISPATCHER] debug, user info: " . Dumper($user_info);

	if ($request =~ m{^/companies}) {
		return 1 # only owner may delete company
			if ($user_info->{user_id});

		$self->render(json => { error => 'access denied' });
		return undef;
	}

	if ($request =~ m{^/aircrafts}) {
		return 1
			if ($user_info->{user_id});

		$self->render(json => { error => 'access denied' });
		return undef;
	}

	if ($request =~ m{^/users}) {
		$self->render(json => { error => 'not implemented yet' });
		return undef;
	}

	if ($request =~ m{^/session}) {
		return 1 # `logout' possible only after `login'
			if $user_info->{user_id};

		$self->render(json => { error => 'not authorized' });
		return undef;
	}

	$self->render(json => { error => "unknown request: `$request'" });
	return undef;
}

1;
