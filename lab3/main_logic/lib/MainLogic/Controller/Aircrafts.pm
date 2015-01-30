package MainLogic::Controller::Aircrafts;
use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;
use Common::RequestSender qw(:all);

sub count
{
	my $self = shift;

	my $resp = send_request({
		method => 'get',
		url => 'http://localhost/aircrafts/count',
		port => $self->service_aircrafts_port() || 0,
	});

	$self->app->log->debug('[AIRCRAFTS] count, resp: ', Dumper $resp);

	return $self->render(json => $resp);
}

sub list
{
	my $self = shift;

	my $user = $self->stash('user');
    print "[Controller.Aircrafts] list, input: 'L: $self->param('limit'), O: $self->param('offset')'.\n";
	my $resp = send_request({
		method => 'get',
		url => 'http://localhost/aircrafts',
		port => $self->service_aircrafts_port() || 0,
		args => {
			limit		=> $self->param('limit'),
			offset		=> $self->param('offset'),
		},
	});


	#my @ids = map {
	#	$_->{company_id}
	#} @{$resp};

	#my $joined_ids = join q{,}, @ids;
	#my $companies_resp = send_request({
	#	method => 'get',
	#	url => 'http://localhost/companies/batch',
	#	port => $self->service_companies_port() || 0,
	#	args => {
	#		ids => $joined_ids,
	#	}
	#});

	#my %companies_info = map {
	#	$_->{id} => $_
	#} @{$companies_resp};

	#my $final_resp = [];
	#foreach my $job (@{$resp}) {
	#	$job->{company_info} = $companies_info{$job->{company_id}};
	#	push @{$final_resp}, $job;
	#}

	$self->app->log->debug('[AIRCRAFTS] list, resp ', Dumper $resp);

	return $self->render(json => $resp);
}

sub info
{
	my $self = shift;

	my $id = $self->param('id');
	my $resp = send_request({
		method => 'get',
		url => "http://localhost/aircrafts/$id",
		port => $self->service_aircrafts_port() || 0,
	});

	$self->app->log->debug('[AIRCRAFTS] count, info: ', Dumper $resp);

	return $self->render(json => $resp);
}

# company_id, name, salary, requirements
sub add
{
	my $self = shift;

	my $args = $self->req->json();
	my $user = $self->stash('user');
	#$args->{company_id} = $user->{company_id};

    if ($args->{links} && $args->{links} == 1) {    
    	my $resp = send_request({
	    	method => 'post',
		    url => 'http://localhost/aircrafts/',
		    port => $self->service_aircrafts_port() || 0,
		    args => $args,
	    });
        $self->app->log->debug('[AIRCRAFTS] count, add: ', Dumper $resp);
        return $self->render(json => $resp);
    }

	my $resp = send_request({
		method => 'post',
		url => 'http://localhost/aircrafts/',
		port => $self->service_aircrafts_port() || 0,
		args => $args,
	});

	$self->app->log->debug('[AIRCRAFTS] count, add: ', Dumper $resp);

	return $self->render(json => $resp);
}

# id, name, salary, requirements
sub update
{
	my $self = shift;

	my $args = $self->req->json();
	$args->{id} = $args->{a_id};

	my $resp = send_request({
		method => 'put',
		url => 'http://localhost/aircrafts/',
		port => $self->service_aircrafts_port() || 0,
		args => $args,
	});

	$self->app->log->debug('[AIRCRAFTS], update: ', Dumper $resp);

	return $self->render(json => $resp);
}

# id
sub delete
{
	my $self = shift;

	my $args = $self->req->json();
	$args->{id} = $args->{a_id} || q{};

	my $resp = send_request({
		method => 'delete',
		url => 'http://localhost/aircrafts/',
		port => $self->service_aircrafts_port() || 0,
		args => $args,
	});

	$self->app->log->debug('[AIRCRAFTS], delete: ', Dumper $resp);

	return $self->render(json => $resp);
}

1;
