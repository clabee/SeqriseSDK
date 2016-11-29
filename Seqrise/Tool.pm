package Seqrise::Tool;
#!/usr/bin/perl -w
use strict;
use Carp;


sub new {
	my $class = shift;
	my %params = @_;
	my $errs = 0;
	my $self = bless {
		runner => undef,
		name => undef,
		image => undef,
		subcommands => [],
		parameters => [],
		memory => undef,
		cpu => 1
	}, $class;

	my ($k, $v);
	if (defined ($v = delete $params{runner})) {
		$self->{runner} = $v;
	}
	if (defined ($v = delete $params{name})) {
		$self->{name} = $v;
	}
	if (defined ($v = delete $params{path})) {
		$self->{path} = $v;
	}

	if (defined ($v = delete $params{image})) {
		$self->{image} = $v;
	}


	if (defined ($v = delete $params{subcommands})) {
		$self->{subcommands} = $v;
	}

	if (defined ($v = delete $params{memory})) {
		$self->{memory} = $v;
	}
	if (defined ($v = delete $params{cpu})) {
		$self->{cpu} = $v;
	}

    while (($k, $v) = each %params) {
		carp "Unknown named parameter `$k=>$v`";
		$errs++;
    }
    return undef if $errs;
	return $self;
}

#sub AddParameter {
#	my $self = shift;
#	my ($key, $value) = @_;
#	if (exists $self->{parameters}{$key}) {
#		carp "Warning: parameter `$key` exists, ignored\n";
#	}
#	else {
#		$self->{parameters}{$key} = $value;
#	}
#}

sub AddParameters {
#my ($self, $params) = @_;
	my $self = shift;
## an ARRAY reference 
	my $params = shift;
	$self->{parameters} = $params;
}

sub GetParameterString{
	my $self = shift;
	my $para_str = "";
	foreach my $data (@{$self->{parameters}}) {
		if ($data->{'type'} eq 'boolean' and (not $data->{'separator'} or $data->{'separator'} eq 'space')) {
			if ($data->{'value'} and uc($data->{'value'}) ne 'FALSE') {
				$para_str .= " $data->{'option'}";
			}
		}
		else {
		 	my $key_str = "";
		 	my $value_str = "";
			my $sep_str = "";
			if ($data->{'option'}) {
				$key_str = $data->{'option'};
			}
	
			if ($data->{'type'} eq 'boolean') {
				if ($data->{'value'} and uc($data->{'value'}) ne 'FALSE') {
					$value_str = 'true';
				}
				else {
					$value_str = 'false';
				}
			}
			elsif ($data->{'type'} eq 'int' or $data->{'type'} eq 'float') {
				$value_str = "$data->{'value'}";
			}
			else {
				$value_str = $data->{'value'};
			}
	
			if ($data->{'separator'} eq 'space') {
				$sep_str = ' ';
			}
			elsif (not $data->{'separator'}) {
				$sep_str = '';
			}
			else {
				$sep_str = $data->{'separator'};
			}
	
			$para_str .= " ".$key_str . $sep_str . $value_str;
		}
	}
	return $para_str;
}

sub GetRunner {
	my $self = shift;
	return $self->{runner};
}

sub GetName {
	my $self = shift;
	return $self->{name};
}

sub GetPath {
	my $self = shift;
	return $self->{image};
}

sub GetImage {
	my $self = shift;
	return $self->{image};
}

sub GetMemory {
	my $self = shift;
	return $self->{memory};
}

sub GetSubcommandsString {
	my $self = shift;
	my $subcommands_str = join(" ", @{$self->{subcommands}});
	return $subcommands_str;

}

1;
