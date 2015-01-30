package Common::Defines;

use strict;
use warnings;

use base qw(Exporter);
our @EXPORT_OK = qw(
	SCOPE_JOB_READ
	SCOPE_JOB_WRITE

	SCOPE_COMPANY_READ
	SCOPE_COMPANY_WRITE

	SCOPE_PERSONAL_READ
	SCOPE_PERSONAL_WRITE

	%ROLES
);

our %EXPORT_TAGS = (
	all => [@EXPORT_OK],
);

sub SCOPE_JOB_READ()		{ 0x1 }
sub SCOPE_JOB_WRITE()		{ 0x2 }
sub SCOPE_COMPANY_READ()	{ 0x10 }
sub SCOPE_COMPANY_WRITE()	{ 0x20 }
sub SCOPE_PERSONAL_READ()	{ 0x100 }
sub SCOPE_PERSONAL_WRITE()	{ 0x200 }
