package Lab2::Controller::Resource;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

sub me
{
	my $self = shift;

	my $login = eval { $self->oauthh->get_login_from_controller($self) };
	return $self->render(json => {
		error => 'permission_denied',
		error_description => $@,
	}) unless $login;

	my $user_info = eval { $self->usersh->user_info($login) } || {
		error => 'can\'t get user info',
		error_description => $@,
	};

	$self->render(json => $user_info);
}

sub aircraft
{
	my $self = shift;
	my $aircraft_id = $self->param('id');

	my $resp = eval { $self->aircraftsh->aircraft($aircraft_id) } || {
		error => "can't get info for: $aircraft_id",
		error_description => $@,
        status => 404
	};

    print Dumper $resp;

	$self->respond_to(
		json => { json => $resp, status => $resp->{status} || 200 },
		html => { template => 'resource/aircraft', info => $resp, status => $resp->{status} || 200 },
	);
}

sub aircrafts
{
	my $self = shift;

    my $page_number = $self->param('p') ||
              $self->req->headers->header('Page-Number') || 1;
    my $per_page = $self->param('pp') || 2;

    my $limit = $per_page;
    my $offset = $per_page * ($page_number - 1);

	my ($resp, $cnt) = eval { $self->aircraftsh->list($limit, $offset), $self->aircraftsh->cnt() }
		or return $self->render(json => {
			error => 'server_error',
			error_description => $@,
		});
    unless ($resp) {
        return $self->render(json => {
            error => 'not_found'
        });
    }

	$self->respond_to(
		json => {
			json => {
                page => $page_number,
                cnt => $cnt,
                per_page => $per_page,
				items => ($resp || []),
			},
		},
		html => {
			template => 'resource/aircrafts',
			page => $page_number,
			info => $resp,
		},
	);
}

sub company {
	my $self = shift;
	my $company_id = $self->param('id');

	my $resp = eval { $self->companiesh->company($company_id) } || {
		error => "can't get info for: $company_id",
		error_description => $@,
	};

    print Dumper $resp;
    if (scalar @{$resp->{planes}} == 0) {
        $resp = {
            error => "can't get info for: $company_id",
            error_description => $@
        }
    }

	$self->respond_to(
		json => { json => $resp },
		html => { template => 'resource/company', info => $resp },
	);
}

sub companies {
	my $self = shift;

	my $resp = eval { $self->companiesh->list() }
		or return $self->render(json => {
			error => 'server_error',
			error_description => $@,
		});

	$self->respond_to(
		json => {
			json => {
				items => ($resp || []),
			},
		},
		html => {
			template => 'resource/companies',
			info => $resp,
		},
	);
}

1;
