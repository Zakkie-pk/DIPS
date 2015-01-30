package Lab2::Controller::Register;
use Mojo::Base 'Mojolicious::Controller';

sub index {
	my $self = shift;
	my $errstr = $self->param('errstr') || '';

	return $self->render(errstr => $errstr);
}

sub register {
	my $self = shift;

	my $login = $self->param('login') || undef;
	my $pass  = $self->param('pass' ) || undef;
	my $email  = $self->param('email' ) || undef;
	my $country = $self->param('country') || undef;

	my $url = $self->url_for('index');

	my $ret = eval {
		$self->usersh->add_user({
			login => $login,
			pass  => $pass,
			email  => $email,
			country => $country,
		});
	};

	if ($ret) { # registration is ok
		$self->redirect_to('main');
	} else {
		my $url = $self->url_for('index');
		$self->redirect_to($url->query(errstr => 'some error occurred'));
	}
}

1;
