package BackendCompanies::Controller::Companies;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

sub company_info
{
	my $self = shift;
	my $id = $self->param('id');

    print "[Controller.Companies] company_info, input: '$id'.\n";
	my $resp = eval {
		$self->companies_helper->info($id)
	} || {
		error => "can't get info for company with ID $id",
		error_description => $@,
	};

	$self->render(json => $resp);
}

sub companies_batch_list
{
	my $self = shift;
	my $id = $self->param('ids') || q{};

	my @ids = split qr{,}, $id;
	my $resp = eval {
		$self->companies_helper->batch_list(\@ids)
	} || {
		error => "can't get info for companies with IDs: [@ids]",
		error_description => $@,
	};

	$self->render(json => $resp);
}

sub companies_count
{
	my $self = shift;

	my $resp = eval {
		$self->companies_helper->count()
	} || {
		error => 'server_error',
		error_description => $@,
	};

	$self->render(json => $resp);
}

sub companies_list
{
	my $self = shift;

	my $limit  = $self->param('limit');
	my $offset = $self->param('offset');

	my $resp = eval {
		$self->companies_helper->list($limit, $offset)
	} || {
		error => 'server_error',
		error_description => $@,
	};

	$self->render(json => $resp);
}

sub add
{
	my $self = shift;

	# name, country
	my $args = $self->req->json();

    print "[Controller.Companies] add, args: " . Dumper($args);
	my $ret = eval {
		$self->companies_helper->add($args)
	} || {
		error => 'server_error',
		erorr_description => $@,
	};

	$self->render(json => $ret);
}

sub edit
{
	my $self = shift;

	# id, name, country
	my $args = $self->req->json();

	my $ret = eval {
		$self->companies_helper->edit($args)
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
		$self->companies_helper->delete($args->{c_id})
	} || {
		error => 'server_error',
		erorr_description => $@,
	};

	$self->render(json => $ret);
}

1;
