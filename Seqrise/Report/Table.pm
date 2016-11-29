package Seqrise::Report::Table;
#!/usr/bin/perl -w
use strict;
use Carp;
use lib "/clabeedata/usr/pell/git/CBWorkflow";
use lib "/Users/mac/Projects/git/CBWorkflow";
use JSON;



sub new {
	my ($class, %params) = @_;
	my $errs = 0;
	my $self = bless {
		title => undef,
		id => undef,
		name => undef,
		type => 'table',
		fields => [],
		footnote => undef,
		view => -1
	}, $class;

	my ($k, $v);
	if (defined ($v = delete $params{title})) {
		$self->{title} = $v;
	}
	else {
		carp "Error: please set  named parameter `title` and its value";
		$errs ++;
	}

	if (defined ($v = delete $params{name})) {
		$self->{name} = $v;
	}
	else {
		carp "Error: please set  named parameter `name` and its value";
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



sub AddFootnote {
	my ($self, $footnote) = @_;
	$self->{footnote} = $footnote;
}



sub AddField {
	my ($self, $name, $title, $type, %other_params) = @_;
	my $field_value = {name => $name, title => $title, type => $type};
	foreach my $key (keys %other_params) {
		if ($key eq "align" or $key eq "desc") {
			$field_value->{$key} = $other_params{$key};
		}
		else {
			carp "Error: unknown  named parameter `$key` and its value";
		}
	}
	push @{$self->{fields}}, $field_value;

}


sub SetID {
	my ($self, $id) = @_;
	$self->{id} = $id;
}


1;
