package BackendAircrafts::Controller::Aircrafts;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

sub info
{
	my $self = shift;
	my $aircraft_id = $self->param('id');

	my $resp = eval {
		$self->aircrafts_helper->info($aircraft_id)
	} || {
		error => "can't get info for aircraft with ID: $aircraft_id",
		error_description => $@,
	};

	$self->render(json => $resp);
}

sub list
{
	my $self = shift;

	my $limit	= $self->param('limit');
	my $offset	= $self->param('offset');
	my $company_id	= $self->param('company_id') || -1;
    my $for_list = $self->param('for_list') || '';

	print "[debug | aircrafts] limit: $limit, offset: $offset, company_id: $company_id\n";

	my $resp = eval {
		$self->aircrafts_helper->list($limit, $offset, $company_id, $for_list)
	} || {
		error => 'server_error',
		error_description => $@,
	};

	$self->render(json => $resp);
}

sub count
{
	my $self = shift;

	my $resp = eval {
		$self->aircrafts_helper->count()
	} || {
		error => 'server_error',
		error_description => $@,
	};

	$self->render(json => $resp);
}

sub add
{
	my $self = shift;

	# name, roominess, distance
	my $args = $self->req->json();

    print "[Controller.Aircrafts] add, input: " . Dumper($args);
    if ($args->{'links'} && $args->{'links'} == 1) {
        my $ret = eval {
            $self->aircrafts_helper->add_link($args)
        } || {
            error => 'server error',
            error_description => $@
        };
        $self->render(json => $ret);
        return 1;
    }
	my $ret = eval {
		$self->aircrafts_helper->add($args)
	} || {
		error => 'server_error',
		erorr_description => $@,
	};

	$self->render(json => $ret);
}

sub edit
{
	my $self = shift;

	# id, name, roominess, distance
	my $args = $self->req->json();

	my $ret = eval {
		$self->aircrafts_helper->edit($args)
	} || {
		error => 'server_error',
		erorr_description => $@,
	};

	$self->render(json => $ret);
}

sub delete
{
	my $self = shift;

	# id
	my $args = $self->req->json();

	my $ret = eval {
		$self->aircrafts_helper->delete($args->{id})
	} || {
		error => 'server_error',
		erorr_description => $@,
	};

	$self->render(json => $ret);
}

1;
