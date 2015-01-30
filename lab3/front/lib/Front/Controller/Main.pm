package Front::Controller::Main;
use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;
use Digest::MD5 qw(md5_hex);
use Common::RequestSender qw(:all);

my $PORT_LOGIC_SERVICE = $ENV{SERVICE_LOGIC_PORT};

sub index
{
	my $self = shift;

	$self->render();
}

sub users
{
	my $self = shift;

	my $pass	= $self->param('pass')		|| '';
	my $login	= $self->param('login')		|| '';
    my $email   = $self->param('email')     || '';
    my $country = $self->param('country')   || '';

    print "[Controller.Users] got params: $login/$pass\n";
	return $self->render()
		if not ($login and $pass and $email and $country);

	my $pass_hash = md5_hex($pass);
    print "[Controller.Users] MD5 of pass: $pass_hash\n";
	my $session = $self->session('session_info') || {};

	my $resp = send_request({
		method	=> 'post',
		url	=> 'http://localhost/users',
		port	=> $PORT_LOGIC_SERVICE,
		args	=> {
			id		=> $session->{id},
			token		=> $session->{token},
			login		=> $login,
			pass_hash	=> $pass_hash,
            email       => $email,
            country     => $country
		}
	});

	$self->app->log->debug('[FRONT], users, resp: ', Dumper $resp);

	return $self->redirect_to('index')
		if exists $resp->{ok};

	return $self->render();
}

sub __new_company
{
	my $self = shift;

	#my $name	= $self->param('name')		|| q{};
	#my $pass	= $self->param('pass')		|| q{};
	#my $login	= $self->param('login')		|| q{};
	my $company_name	= $self->param('c_name')	|| q{};
    my $company_country = $self->param('c_country') || q{};
    my $session_info    = $self->session('session_info')    || {};

	#my $pass_hash = md5_hex($pass);

	#return $self->redirect_to('companies')
	#	if not ($login and $pass);

    print "[FRONT] new_company, input: '$company_name, $company_country'.\n";
    my $session = $self->session('session_info') || {};
    print "Session info: " . Dumper($session);
	my $resp = send_request({
		method	=> 'post',
		url	=> 'http://localhost/companies',
		port	=> $PORT_LOGIC_SERVICE,
		args	=> {
			#name		=> $name,
			#login		=> $login,
			#pass_hash	=> $pass_hash,
            id          => $session->{id},
            token       => $session->{token},
			c_name      => $company_name,
            c_country   => $company_country,
		}
	});

	$self->app->log->debug('[FRONT], new_company, resp: ', Dumper $resp);

	return $self->redirect_to('index')
		if exists $resp->{user_resp}{ok}
		   and exists $resp->{company_resp}{ok};

	return $self->redirect_to('companies');
}

sub __update_company
{
	my $self = shift;

	my $c_id		= $self->param('c_id')			|| q{};
	#my $name	= $self->param('name')			|| q{};
	my $c_name	= $self->param('c_name')		|| q{};
    my $c_country   = $self->param('c_country') || q{};
	my $session	= $self->session('session_info')	|| {};

	my $resp = send_request({
		method	=> 'put',
		url	=> "http://localhost/companies/",
		port	=> $PORT_LOGIC_SERVICE,
		args	=> {
			id		=> $session->{id},
			token	=> $session->{token},
			c_id	=> $c_id,
			c_name	=> $c_name,
            c_country   => $c_country,
		}
	});

	$self->app->log->debug('[FRONT], update_company, resp: ', Dumper $resp);

	$self->render(json => $resp);
}

sub __delete_company
{
	my $self = shift;

	my $c_id		= $self->param('c_id')			|| q{};
	my $session	= $self->session('session_info')	|| {};

	my $resp = send_request({
		method	=> 'delete',
		url	=> "http://localhost/companies/",
		port	=> $PORT_LOGIC_SERVICE,
		args	=> {
			id		=> $session->{id},
			token		=> $session->{token},
			c_id	=> $c_id,
		}
	});

	$self->app->log->debug('[FRONT], delete_company, resp: ', Dumper $resp);

	$self->render(json => $resp);
}

sub __select_company
{
	my $self = shift;

	my $page	= $self->param('page')		|| 1;
	my $c_id	= $self->param('c_id')	|| q{};

	my $limit	= 2;
	my $offset	= ($page - 1) * $limit;

	my $resp = send_request({
		method	=> 'get',
		url	=> "http://localhost/companies/$c_id",
		port	=> $PORT_LOGIC_SERVICE,
		args	=> {
			limit	=> $limit,
			offset	=> $offset,
			detail	=> 1,
		}
	});

	$self->app->log->debug('[FRONT], select_company, resp: ', Dumper $resp);

	if ($c_id) {
		$self->stash($resp);
		return $self->render(template => 'main/companies.main');
	}

	return $self->render(template => 'main/companies.list',
			     prev => $page - 1,
			     next => $page + 1,
			     list_ref => $resp,
	);
}

sub companies
{
	my $self = shift;

	my $method = $self->param('button') || q{};

    print Dumper $method;

	if ($method eq 'Add') {
		return __new_company($self);
	} elsif ($method eq 'Update') {
		return __update_company($self);
	} elsif ($method eq 'Delete') {
		return __delete_company($self);
	} elsif ($method eq 'Select') {
		return __select_company($self);
	}

	$self->render(text => 'unknown method specified');
}

sub links {
    my $self = shift;
        my $c_id = $self->param('c_id') || '';
        my $a_id = $self->param('a_id') || '';
        my $session = $self->session('session_info') || {};
               
	    my $resp = send_request({
		    method	=> 'post',
    		url	=> "http://localhost/aircrafts/",
	    	port	=> $PORT_LOGIC_SERVICE,
		    args	=> {
    			id		=> $session->{id},
	    		token		=> $session->{token},
		    	c_id		=> $c_id,
			    a_id        => $a_id,
                links       => 1
		    }
    	});
	    $self->app->log->debug('[FRONT], links, resp: ', Dumper $resp);

	    $self->render(json => $resp);
}

sub __new_aircraft
{
	my $self = shift;

	# name, roominess, distance
	my $session = $self->session('session_info') || {};

	my $name		= $self->param('name')		|| q{};
	my $roominess	= $self->param('roominess')	|| q{};
	my $distance	= $self->param('distance')	|| q{};

	my $resp = send_request({
		method	=> 'post',
		url	=> "http://localhost/aircrafts/",
		port	=> $PORT_LOGIC_SERVICE,
		args	=> {
			id		=> $session->{id},
			token		=> $session->{token},
			name		=> $name,
			roominess	=> $roominess,
			distance	=> $distance,
		}
	});

	$self->app->log->debug('[FRONT], new_aircraft, resp: ', Dumper $resp);

	$self->render(json => $resp);
}

sub __update_aircraft
{
	my $self = shift;

	my $id			= $self->param('id')		|| q{};
	my $name		= $self->param('name')		|| q{};
	my $roominess	= $self->param('roominess')	|| q{};
	my $distance	= $self->param('distance')	|| q{};

	my $session = $self->session('session_info') || {};

	my $resp = send_request({
		method	=> 'put',
		url	=> "http://localhost/aircrafts/",
		port	=> $PORT_LOGIC_SERVICE,
		args	=> {
			id		=> $session->{id},
			token		=> $session->{token},
			a_id		=> $id,
			name		=> $name,
			roominess	=> $roominess,
			distance	=> $distance,
		}
	});

	$self->app->log->debug('[FRONT], update_aircraft, resp: ', Dumper $resp);

	$self->render(json => $resp);
}

sub __delete_aircraft
{
	my $self = shift;

	my $id			= $self->param('id')			|| q{};
	my $session		= $self->session('session_info')	|| {};

	my $resp = send_request({
		method	=> 'delete',
		url	=> "http://localhost/aircrafts/",
		port	=> $PORT_LOGIC_SERVICE,
		args	=> {
			id  		=> $session->{id},
			token		=> $session->{token},
			a_id		=> $id,
		}
	});

	$self->app->log->debug('[FRONT], delete_aircraft, resp: ', Dumper $resp);

	$self->render(json => $resp);
}

sub __select_aircraft
{
	my $self = shift;

	my $page	= $self->param('page')		|| 1;
	my $a_id	= $self->param('id')	|| q{};

    print "[Controller.Aircrafts] __select_aircraft, input: 'page: $page, ID: $a_id'.\n";
	my $limit	= 2;
	my $offset	= ($page - 1) * $limit;

	my $session = $self->session('session_info') || {};

	if ($self->param('add')) {
		$self->stash({
			c_id		=> $self->param('c_id'),
	        id          => ''
		});

		return $self->render(template => 'main/links.new', button => 'Add')
	}

	my $resp = send_request({
		method	=> 'get',
		url	=> "http://localhost/aircrafts/$a_id",
		port	=> $PORT_LOGIC_SERVICE,
		args	=> {
			limit		=> $limit,
			offset		=> $offset,
			id		=> $session->{id},
			token		=> $session->{token},
		}
	});

	$self->app->log->debug('[FRONT], select_aircraft, resp: ', Dumper $resp);

	return $self->render(text => 'access denied')
		if ref $resp eq 'HASH' and exists $resp->{error};

	if ($a_id) {
		$self->stash($resp);
		return $self->render(template => 'main/aircrafts.main');
	}

	return $self->render(template => 'main/aircrafts.list',
			     prev => $page - 1,
			     next => $page + 1,
			     list_ref => $resp,
	);
}

sub aircrafts
{
	my $self = shift;

	my $method = $self->param('button') || q{};

	if ($method eq 'Add') { # registrations
		return __new_aircraft($self);
	} elsif ($method eq 'Update') { # update
		return __update_aircraft($self);
	} elsif ($method eq 'Delete') { # delete
		return __delete_aircraft($self);
	} elsif ($method eq 'Select') { # select
		return __select_aircraft($self);
	}

	$self->render(text => 'unknown method specified');
}

sub user_info
{
	my $self = shift;

	my $session = $self->session('session_info');
	$self->app->log->debug('[FRONT] user_info, session:', Dumper $session);

	my $resp = send_request({
		method => 'get',
		url => 'http://localhost/me',
		port => $PORT_LOGIC_SERVICE,
		args => $session,
	});

	$self->app->log->debug('[FRONT] user_info, resp:', Dumper $resp);

	$self->render(template => 'main/user', user_info => $resp);
}

sub login
{
	my $self = shift;

	my $login = $self->param('login') || '';
	my $pass  = $self->param('pass')  || '';

    print "[Controller.Users] got params: $login/$pass\n";
	return $self->render()
		unless $login or $pass;

	my $pass_hash = md5_hex($pass);

	my $resp = send_request({
		method => 'post',
		url => 'http://localhost/sessions',
		port => $PORT_LOGIC_SERVICE,
		args => {
			login => $login,
			pass_hash => $pass_hash,
		}
	});

	$self->app->log->debug('[FRONT] login, resp: ', Dumper $resp);

	if ($resp and $resp->{id}) {
		$self->session(session_info => $resp);
		return $self->redirect_to('index');
	}

	$self->redirect_to('login');
}

sub logout
{
	my $self = shift;

	my $session = $self->session('session_info');
	return $self->redirect_to('index')
		if not $session;

	my $resp = send_request({
		method => 'delete',
		url => 'http://localhost/sessions',
		port => $PORT_LOGIC_SERVICE,
		args => $session,
	});

	$self->app->log->debug('[FRONT] logout, resp: ', Dumper $resp);

	$self->session(expires => 1);
	$self->redirect_to('index');
}

sub dispatch_request
{
	my $self = shift;

	$self->render(json => 'not implemented yet');
}

1;
