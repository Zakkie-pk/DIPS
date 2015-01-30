package Lab2::Controller::OAuth2;
use Mojo::Base 'Mojolicious::Controller';

sub index
{
	my $self = shift;
	$self->render(text => 'oauth 2.0');
}

sub authorize {
	my $self = shift;

	my $response_type	= $self->param('response_type') || '';
	my $redirect_uri	= $self->param('redirect_to') || '';
	my $client_id		= $self->param('app_id')	|| 0;
	my $state  		    = $self->param('state')		|| '';
    #my $continue           = $self->param('cont')     || '';

    #print "CONTINUE: $continue\n";
	return $self->render(json => {
		error => 'invalid_request',
		error_description => 'redirect_uri not specified',
	}) unless $redirect_uri;

    #return $self->redirect_to('login', cont => 1) unless $continue;
	my $user_id = $self->session('user');
    print "$user_id\n";
	my $url = $self->url_for($redirect_uri);
    return $self->redirect_to($url->query(error => 'unauthorized_client'))
       unless $user_id;

    print "USER_ID: $user_id; APP_ID: $client_id;\n";
	my $code = eval {
		$self->oauthh->auth_code_generate($user_id, $client_id,
						  $state, $redirect_uri)
	};

	return $self->redirect_to($url->query(error => 'invalid_request'))
		if $response_type ne 'code' or $@;

	$self->redirect_to(
		$url->query(
			code => $code,
			($state ? (state => $state) : ()),
		)
	);
}

sub access_token {
	my $self = shift;

	my $client_secret	= $self->param('secret_key')	|| '';
	my $redirect_uri	= $self->param('redirect_to') || '';
	my $grant_type		= $self->param('grant_type')	|| '';
	my $client_id		= $self->param('app_id')	|| 0;
	my $code		    = $self->param('code')		|| '';

	# invalid redirect uri
	return $self->render(json => {
		error => 'invalid_request',
		error_description => 'redirect uri not specified',
	}) unless $redirect_uri;

	# some required parameters are not specified
	return $self->render(json => {
		error => 'invalid_request',
		error_description => 'skipped required parameter',
	}) unless ($client_id and $client_secret and $code and $grant_type);

	# invalid grant_type specified
	return $self->render(json => {
		error => 'invalid_request',
		error_description => 'invalid grand type',
	}) unless $grant_type eq 'authorization_code';

	my $user_id = eval {
		$self->oauthh->auth_code_get_user_id($client_id, $code, $client_secret)
	};

	return $self->render(json => {
		error => 'invalid_request',
		error_description => "check code failed ($@)",
	}) unless $user_id;

	my $new_access_token = eval {
		$self->oauthh->access_token_new($code, $client_secret)
	} || {
		error => 'server_error',
		error_description => $@,
	};

	$self->render(json => $new_access_token);
}

sub refresh_token
{
	my $self = shift;

	my $client_secret	= $self->param('secret_key')	|| '';
	my $refresh_token	= $self->param('refresh_token')	|| '';
	my $grant_type		= $self->param('grant_type')	|| '';
	my $client_id		= $self->param('app_id')	|| 0;

	return $self->render(json => 'invalid_request')
		unless $grant_type eq 'refresh_token';

	my $new_access_token = eval {
		$self->oauthh->refresh_token($client_id, $client_secret, $refresh_token)
	} || {
		error => 'server_error',
		error_description => $@,
	};

	$self->render(json => $new_access_token);
}

1;
