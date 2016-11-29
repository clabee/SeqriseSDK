package Seqrise::FileSet;
#!/usr/bin/perl -w
use strict;
use Carp;


sub new {
	my ($class, %params) = @_;
    my $errs = 0;

	my $self = bless {
		files => undef,
	}, $class;

	my ($k, $v);
    while (($k, $v) = each %params) {
		carp "Error: Unknown named parameter `$k=>$v`";
		$errs++;
    }

	return undef if $errs;
	
	return $self;
}

## Add at least on file to the file set
sub AddFiles {
	my $self = shift;
	my @files = @_;
	foreach my $file (@files) {
		push @{$self->{files}}, $file;
	}
}


sub GetFilesWithMetadata {
	my $self = shift;
	my %metadata = @_;
	my $fileset = Seqrise::FileSet->new();
	foreach my $file (@{$self->{files}}) {
		my $same = 1;
		foreach my $key (keys %metadata) {
			if ($file->GetMetadataValue($key) ne $metadata{$key}) {
				$same = 0;
				last;
			}
		}
		if ($same == 1) {
			$fileset->AddFiles($file);
		}
	}
	return $fileset;
}

sub GetFile {
	my ($self, $index) = @_;
	return $self->{files}->[$index];
}

sub GetFilePath {
	my ($self, $index) = @_;
	return $self->{files}->[$index]->GetFilePath();
}

### return all files of this object
sub GetFiles {
	my $self = shift;
	return $self->{files};
}

sub GroupFilesByMetadata {
	my $self = shift;
	my @metadata_keys = @_;
### file set array
	my @files_set_array = ($self);
### one-dimensional metadata


	foreach my $md_key (@metadata_keys) {
		my @tmp_files_set_array = @files_set_array;
		undef @files_set_array;
		foreach my $file_set (@tmp_files_set_array) {
			my %hash_metadata_value2file_set;
			foreach my $file (@{$file_set->{files}}) {
				my $metadata_value = $file->GetMetadataValue($md_key);
#print $md_key."\t".$metadata_value,"\n";
				if (exists $hash_metadata_value2file_set{$metadata_value}) {
					$hash_metadata_value2file_set{$metadata_value}->AddFiles($file);
				}
				else {
					my $file_set = Seqrise::FileSet->new();
					$file_set->AddFiles($file);
					$hash_metadata_value2file_set{$metadata_value} = $file_set;
				}
			}
			foreach my $metadata_value (keys %hash_metadata_value2file_set) {
				push @files_set_array, $hash_metadata_value2file_set{$metadata_value};
			}
			undef %hash_metadata_value2file_set;
		}
	}
### return reference of files set array
	return \@files_set_array;
}

sub FileCount {
	my $self = shift;
	return $#{$self->{files}} + 1;
}

## Change file set to string with specified prefix 
sub ChangeToString
{
    my ($self, $prefix, $split_char) = @_;
    my $str = "";
    foreach my $element (@{$self->{files}}) {
		my $path = $element->GetFilePath();
		if ($prefix) {
			$str .= " $prefix$split_char$path";
		}
		else {
			$str .= " $path";
		}
    }
    return $str;
}

## Inherit shared  metadata value of input files

1;
