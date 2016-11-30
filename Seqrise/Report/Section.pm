package Seqrise::Report::Section;
#!/usr/bin/perl -w
use strict;
use Carp;
use JSON;


sub new {
	my ($class, %params) = @_;
	my $errs = 0;
	my $self = bless {
		title => undef,
		id => undef,
		contents => []

	}, $class;

	my ($k, $v);
	if (defined ($v = delete $params{title})) {
		$self->{title} = $v;
	}
	else {
		carp "Error: please set  named parameter `title` and its value";
		$errs ++;
	}

	while (($k, $v) = each %params) {
		carp "Error: Unknown named parameter `$k=>$v`";
		$errs++;
	}
	return undef if $errs;
	return $self;
}

sub TO_JSON { return { %{ shift() } }; }


### Add paragraph or table or figure
sub AddContent {
	my ($self, $content) = @_;
	if (!ref($content)) {
		push  @{$self->{contents}}, {type => "paragraph", text => $content};
	}
	else {
		push @{$self->{contents}}, $content;
	}
}

### Set id of this section
sub SetID {
	my ($self, $id) = @_;
	$self->{id} = $id;
}
1;

