package Seqrise::Workflow;
#!/usr/bin/perl -w
use strict;
use Carp;
use JSON;
use lib "/clabeedata/usr/pell/git/CBWorkflow";
use lib "/Users/mac/Projects/git/CBWorkflow";
use Seqrise::File;
use Seqrise::FileSet;
use Seqrise::Tool;
use File::Path;
use Data::Dumper;




sub new {
	my ($class, %params) = @_;

	my ($workflow_hash, $input_hash);
	my ($k, $v);

	if (defined ($v = delete $params{workflow})) {
		$workflow_hash = __read_json__($v);
	}
	if (defined ($v = delete $params{input})) {
		$input_hash = __read_json__($v);
	}

#	else {
#		carp "Should input json\n";
#		return undef;
#	}

	my $self = bless {
		name => undef,
		tools => {},
		parameters => {},
		inputs => {},
		outdir => undef,
		resultdir => undef,
		taskshell => undef,
		reportdir => undef,
		reportcn => undef,
		reporten => undef
	}, $class;

	my $errs = 0;
	if (defined ($v = delete $params{'name'})) {
		$self->{name} = $params{'name'};
	}

	if ($input_hash->{outdir}) {
		$self->{outdir} = $input_hash->{outdir};
	}
	else {
		$self->{outdir} = "./";
	}
	$self->{outdir} = File::Spec->rel2abs($self->{outdir});
	$self->{resultdir} = join('/', $self->{outdir}, 'results');
	$self->{taskshell} = join('/', $self->{outdir}, 'tasks.sh');
	$self->{reportdir} = join('/', $self->{outdir}, 'report');
	$self->{reportcn} = join('/', $self->{outdir}, 'report_cn.json');
	$self->{reporten} = join('/', $self->{outdir}, 'report_en.json');

	mkpath $self->{resultdir};
	mkpath $self->{reportdir};
	
	while (($k, $v) = each %params) {
		carp "Unknown named parameter `$k=>$v`\n";
		$errs++;
	}
	return undef if $errs;

	$self->__add_tools__($workflow_hash->{tools}, $input_hash->{parameters});


	$errs = $self->__add_inputs__(${$workflow_hash}{inputs}, $input_hash->{inputs});

	return undef if $errs;
	
	$self->__add_parameters__(${$workflow_hash}{parameters}, $input_hash->{parameters});

	return $self;
}


sub GetTool {
	my ($self, $name) = @_;
	return $self->{tools}->{$name};
}

sub GetToolRunner {
	my ($self, $name) = @_;
	return $self->{tools}->{$name}->GetRunner();
}

sub GetToolPath {
	my ($self, $name) = @_;
	return $self->{tools}->{$name}->GetPath();
}

sub GetToolImage {
	my ($self, $name) = @_;
	return $self->{tools}->{$name}->GetImage();
}

sub GetToolSubcommandsString {
	my ($self, $name) = @_;
	return $self->{tools}->{$name}->GetSubcommandsString();
}

sub GetToolParameterString {
	my ($self, $name) = @_;
	return $self->{tools}->{$name}->GetParameterString();
}

sub GetToolMemory {
	my ($self, $name) = @_;
	return $self->{tools}->{$name}->GetMemory();
}

## Get largest memory
sub GetLargestMemory {
	my @memories = @_;
	my $largest_mem = 0;
	foreach my $mem (@memories) {
		if ($mem =~ /(\d+\.\d+)([G|g|M|m])/) {
			my $temp = $1;
			$temp = $temp / 1000 if ($2 eq "M" | $2 eq "m");
			$largest_mem = $temp if ($temp > $largest_mem);
		}
		elsif ($mem =~ /(\d+)([G|g|M|m])/) {
			my $temp = $1;
			$temp = $temp / 1000 if ($2 eq "M" | $2 eq "m");
			$largest_mem = $temp if ($temp > $largest_mem);
		}
		else {
		    	print STDERR "memory format error!";
		}
	}

	return "$largest_mem"."G";
}

## Get largest cpu
sub GetLargestCPU {
	my @cpu_array = @_;
	my $largest_cpu = 1;
	foreach my $cpu (@cpu_array) {
		$largest_cpu = $cpu if ($cpu > $largest_cpu);
	}
	return $largest_cpu;
}



## Get workflow's parameter value with specified key
sub GetParameterValue {
	my ($self, $key) = @_;
	return $self->{parameters}->{$key}->{value};
}


sub ToolExists {
	my ($self, $name) = @_;
	if (exists $self->{tools}->{$name}) {
		return 1;
	}
	else {
		return 0;
	}
}

sub GetTools {
	my $self = shift;
	return $self->{tools};
}

sub GetInput {
	my ($self, $key) = @_;
	return $self->{inputs}->{$key};
}

sub GetInputs {
	my $self = shift;
	return $self->{inputs};
}

sub GetOutdir {
	my $self = shift;
	return $self->{outdir};
}

sub GetTaskShell {
	my $self = shift;
	return $self->{taskshell};
}

sub GetResultDir {
	my $self = shift;
	return $self->{resultdir};
}

sub GetReportDir {
	my $self = shift;
	return $self->{reportdir};
}

sub GetReportJsonFileCN {
	my $self = shift;
	return $self->{reportcn};
}

sub GetReportJsonFileEN {
	my $self = shift;
	return $self->{reporten};
}



sub __read_json__ {
	my ($json_file) = @_;	
	open FIN, $json_file or die "Open file `$json_file` failure!\n";
	my $json_str;
	while (<FIN>) {
		chomp;
		$json_str .= $_;
	}
	my $json = new JSON;
	my $json_obj = $json->decode($json_str);
	return $json_obj;
}

sub __add_inputs__ {
	my ($self, $workflow_hash, $input_hash) = @_;
	my $errs = 0;
	foreach my $input_id (keys %{$workflow_hash}) {
		if (exists $input_hash->{$input_id}) {
			if ($workflow_hash->{$input_id}->{array}->{value}) {
				if (ref($input_hash->{$input_id}) eq 'ARRAY') {
					my $file_set = Seqrise::FileSet->new();
					foreach my $input (@{$input_hash->{$input_id}}) {
						if (__necessary_metadata_exist__($workflow_hash->{$input_id}->{metadata}, $input->{metadata})) {
							my $file = Seqrise::File->new(path => $input->{path});
							$file->AddMetadata($input->{metadata});
							$file_set->AddFiles($file);
						}
						else {
							$errs++;
						}
					}
					$self->{inputs}->{$input_id} = $file_set;
				}
				else {
					$errs++;
					carp "Error: input $input_id should be file array(file set)\n";
				}
			}
			else {
				if (ref($input_hash->{$input_id}) eq 'HASH') {
					if (__necessary_metadata_exist__($workflow_hash->{$input_id}->{metadata}, $input_hash->{$input_id}->{metadata})) {
						my $file = Seqrise::File->new(path => $input_hash->{$input_id}->{path});
						$file->AddMetadata($input_hash->{$input_id}->{metadata});
						$self->{inputs}->{$input_id} = $file;
					}
					else {
						$errs++;
					}
				}
				else {
					$errs++;
					carp "Error: input $input_id should be file object\n";

				}

			}
		}
		elsif ($workflow_hash->{$input_id}->{required}) {
			$errs ++;
			carp "Error: input $input_id is requried, pelease offer it in the input json file\n";
		}
	}
	return $errs;
}

sub __add_tools__ {
	my ($self, $workflow_hash, $input_parameters_hash) = @_;
	foreach my $key (keys %{$workflow_hash}) {
		my $tool = Seqrise::Tool->new('runner' => $workflow_hash->{$key}->{runner}, 'name' => $key, 'image' => $workflow_hash->{$key}->{image}, 'subcommands' => $workflow_hash->{$key}->{subcommands}, 'cpu' => $workflow_hash->{$key}->{cpu}, 'memory' => $workflow_hash->{$key}->{memory});
		$tool->AddParameters($workflow_hash->{$key}->{parameters});
		foreach my $parameter (@{$tool->{parameters}}) {
			if (exists $input_parameters_hash->{$parameter->{id}}) {
				$parameter->{value} = $parameter->{$parameter->{id}};
			}
		}
		$self->{tools}->{$key} = $tool;
	}
}

sub __add_parameters__ {
	my ($self, $workflow_hash, $input_parameters_hash) = @_;
	$self->{parameters} = $workflow_hash;
	foreach my $parameter_id (keys %{$workflow_hash}) {
		if (exists $input_parameters_hash->{$parameter_id}) {
			$self->{parameters}->{$parameter_id} = $input_parameters_hash->{$parameter_id};
		}
	}
}

sub __necessary_metadata_exist__ {
	my ($metadata_key_array, $metadata_hash) = @_;
	foreach my $metadata_key (@{$metadata_key_array}) {
		if (not exists $metadata_hash->{$metadata_key}) {
			carp "Error: necessary metadata $metadata_key doesn't exist";
			return 0;
		}
	}
	return 1;
}





1;