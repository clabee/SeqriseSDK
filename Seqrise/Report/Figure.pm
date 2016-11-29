package Seqrise::Report::Figure;
#!/usr/bin/perl -w
use strict;
use Carp;
use lib "/clabeedata/usr/pell/git/CBWorkflow";
use lib "/Users/mac/Projects/git/CBWorkflow";
use Seqrise::FileSet;
use JSON;


sub new {
	my ($class, %params) = @_;
	my $errs = 0;
	my $self = bless {
		title => undef,
		id => undef,
		paths => [],
		width => 400,
		type => 'figure',
		desc => undef
	}, $class;

	my ($k, $v);
	if (defined ($v = delete $params{title})) {
		$self->{title} = $v;
	}
	else {
		carp "Error: please set  named parameter `title` and its value";
		$errs ++;
	}

	if (defined ($v = delete $params{id})) {
		$self->{id} = $v;
	}

	while (($k, $v) = each %params) {
		carp "Error: Unknown named parameter `$k=>$v`";
		$errs++;
	}
	return undef if $errs;
	return $self;
}

sub TO_JSON { return { %{ shift() } }; }


sub ChangeWidth {
	my ($self, $width) = @_;
	$self->{width} = $width;
}

sub AddSubFigure {
	my ($self, $title, $path) = @_;
	push @{$self->{paths}}, {title => $title, url => $path};
}


sub AddDescription {
	my ($self, $desc) = @_;
	$self->{desc} = $desc;
}

sub SetID {
	my ($self, $id) = @_;
	$self->{id} = $id;
}

1;
