package Lab2::Controller::Login;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

sub index
{
	my $self = shift;

	my $login = $self->param('login') || '';
	my $pass  = $self->param('pass')  || '';
    my $cont  = $self->req->url->query->param('cont') || '';
    my $redir_url = $self->req->url->query->param('redirect_to') || '';
    my $redirect_url_2 = $self->param('redirect') || '';

    unless ($redirect_url_2) {
        $self->stash({ redirect => '', oauth => 0 });
    }

    #print "CONT: $cont\n";
    #print "REDIR: $redir_url\n";
    #print "REDIR2: $redirect_url_2\n";
	my $ret = eval { $self->usersh->check_user($login, $pass) };

	return $self->render(text => $@)
		if $@;
	return $self->render()
		unless $ret;

	$self->session(user => $login);
	(defined ($redirect_url_2)) ? $self->redirect_to($redirect_url_2) : $self->redirect_to('main');
    #$self->redirect_to('main');
}

sub logged_in
{
	my $self = shift;

    $self->stash({ redirect => '', oauth => 0});
	return 1
		if eval { $self->oauthh->is_authorized($self) };

    my $params = $self->req->query_params->to_hash();
    print Dumper $params;
    if ($self->req->url->to_abs() =~ /resources\/authorize/) {
        my $url = $self->url_for("login");
        #$self->redirect_to($url->query(cont => 1, redirect_to => $params->{redirect_to}, app_id => $params->{app_id}, response_type => $params->{response_type}));
        #$self->redirect_to($url->query(cont => 1, redirect_to => $self->req->url->to_abs()));
        $self->stash({ redirect => $self->req->url->to_abs(), oauth => 1 });
        $self->render(template => 'login/index');
        return undef;
    }

	$self->render(json => {
			error => 'permission_denied',
			error_description => $@,
		}
	);
    #$self->redirect_to('login');
    return 0;
}

sub logout {
	my $self = shift;

	$self->session(expires => 1);
	$self->redirect_to('login');
}

1;
