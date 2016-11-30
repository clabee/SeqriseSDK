package Seqrise::File;
#!/usr/bin/perl -w
use strict;
use Carp;
use Seqrise::FileSet;
use JSON;
use File::Basename;



sub new {
	my ($class, %params) = @_;
    my $errs = 0;

	my $self = bless {
		path => undef,
		metadata => {},
	}, $class;

	my ($k, $v);
	if (defined ($v = delete $params{path})) {
		$self->{path} = $v;
	}

    while (($k, $v) = each %params) {
		carp "Error: Unknown named parameter `$k=>$v`";
		$errs++;
    }

	return undef if $errs;
	
	return $self;
}

sub AddMetadata {
	my $self = shift;
##  a HASH reference
	my $metadata = shift;
	foreach my $key (keys %{$metadata}) {
		$self->{metadata}->{$key} = $metadata->{$key};
	}
}

sub InheritMetadata {
	my $self = shift;
	my @files = @_;
	my $file = shift @files;
	my $shared_metadata = $file->GetMetadata();
	
	foreach my $file1 (@files) {
		if (%{$shared_metadata}) {
			foreach my $key (keys %{$shared_metadata}) {
				my $md_value = $file1->GetMetadataValue($key);
				if ("$shared_metadata->{$key}" ne "$md_value") {
					delete $shared_metadata->{$key};
				}
			}
		}
		else {
			last;
		}
	}
	$self->AddMetadata($shared_metadata);
}

sub InheritMetadataFromFileSet {
	my $self = shift;
	my $file_set = shift;
	my $file = $file_set->GetFile(0);
	my $shared_metadata = $file->GetMetadata();
	
	for (my $i = 1; $i < $file_set->FileCount(); $i ++) {
		my $file1 = $file_set->GetFile(0);
		if (%{$shared_metadata}) {
			foreach my $key (keys %{$shared_metadata}) {
				my $md_value = $file1->GetMetadataValue($key);
				if ("$shared_metadata->{$key}" ne "$md_value") {
					delete $shared_metadata->{$key};
				}
			}
		}
		else {
			last;
		}
	}
	$self->AddMetadata($shared_metadata);
}

## generate metadata file,if a file path is /test/sample.bam, then its metadata file is /test/sample.bam.metadata
sub GenerateMetadataFile {
    my $self = shift;
    my $metadata_file = $self->GetFilePath().".metadata";
    open FOUT,">$metadata_file" or die "Open file $metadata_file failure:$!\n";
    my $json = encode_json($self->GetMetadata());
    print FOUT $json,"\n";
    close FOUT;
}

sub ChangeMetadataValue {
}


sub GetPath {
	my $self = shift;
	return $self->{path};
}

#### generate new path in docker
sub GetPathInDocker {
	my $self = shift;
	my $new_dir = shift;
	my $filename = basename($self->{path});
	return $new_dir."/".$filename;
}


sub GetMetadataValue {
	my $self = shift;
	my $key = shift;
	return $self->{metadata}{$key};
}

sub GetMetadata {
	my $self = shift;
	return $self->{metadata};
}

sub GetFilePath {
	my $self = shift;
	return $self->{path};
}


1;
