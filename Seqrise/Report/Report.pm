package Seqrise::Report::Report;
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
		version => undef,
		language => undef,
		results => [],
		methods => [],
		references => []
	}, $class;

	my ($k, $v);
	if (defined ($v = delete $params{title})) {
		$self->{title} = $v;
	}
	else {
		carp "Error: please set  named parameter `title` and its value";
		$errs ++;
	}

	if (defined ($v = delete $params{version})) {
		$self->{version} = $v;
	}
	else {
		carp "Error: please set  named parameter `version` and its value";
		$errs ++;
	}

	if (defined ($v = delete $params{language})) {
		$self->{language} = $v;
	}
	else {
		carp "Error: please set  named parameter `language` and its value";
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


### Add one result section to the report
sub AddResultSection {
	my ($self, $section) = @_;
	push @{$self->{results}}, $section;
}

### Add one method section to the report
sub AddMethodSection {
	my ($self, $section) = @_;
	push @{$self->{methods}}, $section;
}

### Add reference
sub AddReference {
	my ($self, $id, $text, $url) = @_;
	push @{$self->{references}}, {id => $id, text => $text, url => $url};
}

### print report json 
sub PrintJson {
	my $self = shift;
	my $JSON  = JSON->new->utf8;
	$JSON->convert_blessed(1);
	my $json = $JSON->encode($self);
	print $json,"\n";
}

### store report json to a file
sub PrintJsonToFile {
	my ($self, $file) = @_;
#	my $JSON  = JSON->new->utf8;
	my $JSON  = JSON->new;
	$JSON->convert_blessed(1);
	my $json = $JSON->encode($self);
	open FOUT, ">$file" or die "Error: Open file $file failure!:$!\n";
	print FOUT $json;
	close FOUT;
}

1;
