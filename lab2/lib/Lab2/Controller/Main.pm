package Lab2::Controller::Main;
use Mojo::Base 'Mojolicious::Controller';

sub index
{
	my $self = shift;
	$self->render();
}

sub status
{
	my $self = shift;

	if (eval { $self->oauthh->is_authorized($self) }) {
		$self->render(json => {auth => 'true'});
	} else {
		$self->render(json => {auth => 'false'});
	}
}

1;
