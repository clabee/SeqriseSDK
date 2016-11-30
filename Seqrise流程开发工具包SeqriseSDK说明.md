## 简介
Seqrise流程开发工具包SeqriseSDK用于开发在云蜂云计算平台Seqrise上运行的生物信息分析流程。用户调用SeqriseSDK可以读取含有流程、工具、输入文件、参数信息的workflow.json文件和包含实际输入文件和参数信息的input.json文件，定义工具间的依赖关系，打印任务文件。此任务文件可直接在使用sh命令，在Linux命令行中执行。




## json文件格式
- [workflow.json文件示例](https://github.com/clabee/SeqriseSDK/blob/master/tests/workflow.json)
- [input.json文件示例](https://github.com/clabee/SeqriseSDK/blob/master/tests/input.json)

## 输出任务文件
### 文件格式
```
#input=file1
#input=file2
#output=file3
#cpu=1
#memory=5G
command1
command2
command3
#input=file3
#input=file1
#output=file4
#output=file5
#cpu=2
#memory=3G
command4
command5
```
### 任务文件说明
- 任务文件由若干个任务块构成
- 每个任务块包含都包含有输入文件、输出文件、所需cpu数、所需内存、实际命令，输入文件、输出文件、实际命令允许输入多行，所需cpu数和内存只允许一行。输入文件、输出文件、所需内存排在实际命令前面
- 输入文件以#input=开头，后面接输入文件的绝对路径
- 输出文件以#output=开头，后面接输出文件的绝对路径
- 所需cpu以#cpu=开头，后面接运行任务块所需要的cpu
- 所需内存以#memory=开头，后面接运行任务块所需要的内存

## 模块说明
### 流程模块
#### 名字
Seqrise::Workflow 
#### 用途
用于读入json格式的流程配置文件（workflow.json)和输入信息文件(input.json)，获取流程需要的工具信息、输入文件信息、参数信息，根据流程信息和实际输入文件和参数信息，生成可执行命令。
#### 成员函数
##### new( [option => value ...])
- 返回一个新的Workflow（流程）对象，若出错则返回undef
- 参数1：name workflow_name
  - 定义流程的名字
- 参数2：workflow workflow.json
  - json格式的流程定义文件路径，必填
- 参数3：input  input.json
  - json的输入信息文件，此文件记录了实际输入的文件路径，流程调用时实际使用的参数
- 示例：
```
$wf = Seqrise::Workflow->new(workflow => "/path/to/workflow.json", input => "/path/to/input.json");
$wf = Seqrise::Workflow->new(name => "WGS", workflow => "/path/to/workflow.json", input => "/path/to/input.json");
```
##### GetTool($tool_id)
- 返回id为$tool_id的工具对象（Seqrise::Tool对象）
- 示例：
```
$obj_bwa = $wf->GetTool('bwa_id_on_seqrise');
```
##### GetToolRunner($tool_id)
- 返回id为$tool_id的工具的执行器，一般为"docker"
- 示例:
```
$bwa_runner = $wf->GetToolRunner('bwa_id_on_seqrise');
```

##### GetToolImage($tool_id)
- 返回id为$tool_id的工具的docker镜像名
- 示例：
```
$bwa_image = $wf->GetToolImage('bwa_id_on_seqrise');
```


##### GetToolParameterString($tool_id)
- 返回id为$tool_id的工具的参数拼接成的字符串
- 如例如工具bwa实际运行的参数为 -t 4 -k 19 -M，则GetToolParameterString('bwa_id_on_seqrise')的返回值为"-t 4 -k 19 -M"
```
$bwa_para = $wf->GetToolParameterString('bwa_id_on_seqrise');
```
##### GetToolCPU($tool_id)
- 返回id为$tool_id的工具运行所需的cpu数
- 示例：
```
$bwa_cpu = $wf->GetToolCPU('bwa_id_on_seqrise');
```


##### GetToolMemory($tool_id)
- 返回id为$tool_id的工具运行所需的内存
- 示例：
```
$bwa_memory = $wf->GetToolMemory('bwa_id_on_seqrise');
```

##### ToolExists($tool_id)
- 判断流程是否包含工具$tool_id,包含则返回1，不包含则返回0
- 示例：
```
if ($wf->ToolExists('bwa_id_on_seqrise') {
    print "Tool bwa exists in the workflow\n";
}
else {
    print "Tool bwa doesnot exist in the workflow\n";
}
```

##### GetTools()
- 返回流程使用到的所有工具，返回值的类型是HASH的引用，此HASH的键是工具的id。
- 示例：
```
$wf_tools = $wf->GetTools();
```

##### GetInput($input_id)
- 输入参数是流程输入文件的id（用于代表 此输入的id,非真实文件id)，在input.json中,这个名字作为输入文件路径、metadata等文件属性的键（key)。
- 返回Seqrise::FileSet类对象或者Seqrise::File类对象,Seqrise::FileSet模块存储了同一类型的若干个文件。
```
## 在这里$fq是Seqrise::FileSet类对象，$ref是Seqrise::File类对象，至于是哪种，由workflow.json中$input_id对应的"array"的值决定。arary的值是true，表明此返回值是Seqrise::FileSet类对象，false表明此返回值是Seqrise::File类对象
$fq = $wf->GetInput('fastq_input_id_on_seqrise');
$ref = $wf->GetInput('reference_input_id_on_seqrise');
```
##### GetInputs()
- 返回流程的所有输入文件，返回值的类型是HASH的引用，所引用的HASH的键是流程输入文件的id，值是Seqrise::FileSet或者Seqrise::File类的对象
- 示例：
```
$files = $wf->GetInputs();
```

##### GetOutdir()
- 返回流程的输出目录的路径
- 示例：
```
$outdir = $wf->GetOutdir();
```

##### GetTaskShell()
- 获取任务文件的路径，需要把所有task记录到这个任务文件中
- 这个路径必须是：$outdir/tasks.sh
- 示例
```
$taskshell = $wf->GetTaskShell()
```

##### GetResultDir()
- 获取结果目录，这个目录是：$outdir/results
- 示例
```
$resultdir = $wf->GetResultDir()
```

##### GetReportDir()
- 获取报告文件所在目录，这个目录是: $outdir/report
- 示例：
```
$reportdir = $wf->GetReportDir()
```

##### GetLargestCPU($tool1_id [,$tool2_id, ...])
- 参数是若干个工具的id，返回这些工具所需使用的最大cpu数目
- 示例：
```
$largest_cpu = $wf->GetLargestCPU('bwa_id_on_seqrise', 'samtools_id_on_seqrise');
```

##### GetLargestMemory($tool1_id [,$tool2_id, ...])
- 参数是若干个工具的id，返回这些工具所需使用的最大内存
- 示例：
```
$largest_mem = $wf->Workflow('bwa_id_on_seqrise', 'samtools_id_on_seqrise');
```
##### GetParameterValue($id)
- 此函数的功能是根据参数的id，获取参数的值
- 函数参数$id对应的是流程的参数的id
- 示例：
```
$key = "wf_parameter_id_on_seqrise";
$para_value = $wf->GetParameterValue($key);
```




### 文件模块
#### 名字
Seqrise::File
#### 用途
用于封装文件的路径、元数据，并提供一系列操作文件的方法
#### 成员函数
##### new( [option => value ...])
- 返回一个新的File（文件）对象，若出错则返回undef
- 参数1：path file_path
  - 文件的路径，必填
- 示例：
```
$file = Seqrise::File->new( path => '/path/to/sample.fq.gz');
```

##### AddMetadata($metadata)
- $metadata是HASH的引用，此HASH记录了文件要新增的metadata的若干键值对。若新增的metadata的键在文件中已存在，则用此键对应的新值覆盖旧值
- 示例：
```
my %metadata = ('Sample ID' => 'SM1', 'Library ID' => 'Lib1');
$file->AddMetadata(\%metadata);
```

##### InheritMetadata($file1 [,$file2, ...])
- 参数是1个或多个文件(Seqrise::File类的对象），当前文件继承参数中的文件的metadata值相同的metadata
- 示例：
```
my $file1 = Seqrise::File->new(path => '/path/to/SM1-1.fq.gz')
my %metadata1 = ('Sample ID' => 'SM1', 'Library ID' => 'Lib1');
$file1->AddMetadata(\%metadata1);
my $file2 = Seqrise::File->new(path => '/path/to/SM1-2.fq.gz')
my %metadata2 = ('Sample ID' => 'SM1', 'Library ID' => 'Lib2');
$file1->AddMetadata(\%metadata2);
$file->InheritMetadata($file1, $file2);
### 这时$file的metadata为('Sample ID' => 'SM1'）
```
##### InheritMetadataFromFileSet($fileset)
- 功能跟InheritMetadata([$file])类似，参数是FileSet类型的对象，当前文件FileSet类型对象中的File共有的metadata

##### GenerateMetadataFile()
- 参数是Seqrise::File类型对象
- 函数的作用是把$file的metadata以json格式，输出在$file.metadata文件中
- 示例：
```
###假如$file的路径为:/path/to/sample.fq.gz,执行完以下命令后，会生成/path/to/sample.fq.gz.metadata文件，文件以json格式，记录$file的metadata信息。
$file->GenerateMetadataFile();
```

##### GetFilePath()
- 返回文件的路径

##### GetMetadataValue($key)
- 返回键为$key的metadata的值

##### GetMetadata()
- 返回文件的所有metadata，返回值 HASH的引用


### 文件集模块
#### 名字
Seqrise::FileSet
#### 用途
用于封装相同类型的文件，并提供一系列操作文件的方法
#### 成员函数
##### new()
- 返回一个新的FileSet对象，若出错则返回undef
- 示例：
```
$fileset = Seqrise::FileSet->new();
```

##### AddFiles($file1 [,$file2, ...])
- 把参数中的文件添加到当前文件集中
- 示例：
```
$fileset->AddFiles($file1, $file2, $file3);
##添加完之后，$fileset增加了$file1, $file2, $file3 三个文件
```

##### GetFile($index)
- Seqrise::FileSet中的文件是以数组的方式存放的，本函数返回下标为$index的文件，返回的文件类型为Seqrise::File
- 示例：
```
$file = $fileset->GetFile(0);
## 返回的$file是Seqrise::File类的对象，可使用Seqrise::File类的成员函数访问$file的路径等属性
```
##### GetFilePath($index)
- 返回下标为$index的文件的路径
- 示例：
```
$file_path = $fileset->GetFilePath(0);
## 此语句等价于：
$file = $fileset->GetFile(0);
$file_path = $file->GetFilePath();
```

##### GroupFilesByMetadata($metadata_key1, [,$metadata_key2, ...])
- 根据参数提供的metadata的键，获得FileSet的文件对应的metadata的值，根据metadata的值对FileSet中的文件进行分组，在参数中出现的metadata值相同的文件分成一组。
- 返回元素为Seqrise::FileSet类型的数组
```
## 假如$fileset里面包含$file1,$file2,$file3三个文件，
## $file1的metadata是 {'Sample ID' => 'SM1', 'Library ID' => 'Lib1'}, 
## $file2的metadata是{'Sample ID' => 'SM1', 'Library ID' => 'Lib1'},
## $file3的metadata是 {'Sample ID' => 'SM2', 'Library ID' => 'Lib1'}
$fileset_array = $filset->GroupFilesByMetadata('Sample ID');
## 这时$fileset被分成两组（两个Seqrise::FileSet类型对象），$file1和$file2为一组，$file3为另外一组。
$fileset1 = $fileset_array->[0];
$fileset2 = $fileset_array->[1];
```

##### GetFilesWithMetadata($metadata_key1 => $metadata_value1 [,$metadata_key2 => $metadata_value2, ...])
- 参数是一系列metadata的键值对
- 返回Seqrise::FileSet对象的子集，这个子集中的文件的metadata跟此函数参数提供的一致。返回值也是Seqrise::FileSet类的对象
- 示例:
```
## $fileset包含的文件同GroupFilesByMetadata($metadata_key1, [,$metadata_key2, ...])函数示例的一样
## $fileset1 包含$file1和$file2两个文件
$fileset1 = $fileset->GetFilesWithMetadata('Sample ID' => 'SM1');
## $fileset2 包含$file3
$fileset2 = $fileset->GetFilesWithMetadata('Sample ID' => 'SM2');

```

##### FileCount()
- 返回Seqrise::FileSet类对象包含的文件的数目

##### ChangeToString($prefix, $split_char)
- 功能：把Seqrise::FileSet类对象的文件路径以空格为分隔符，以$prefix, $split_char为前缀，拼接成一个字符串，并返回这个拼接好的字符串
- $prefix: 拼字符串时，放在文件路径前面的前导字符串，可不填
- $split_char: 前导字符跟文件中间的分隔符
- 示例：
```
## 假如FileSet包含$file1, $file2, $file3三个文件
## $file1的路径为/path/to/file1.bam,$file2的路径为/path/to/file2.bam,$file3的路径为/path/to/file3.bam
$file_str1 = $fileset->ChangeToString();
$file_str2 = $fileset->ChangeToString('INPUT', '=');
## $file_str1的值为："/path/to/file1.bam /path/to/file2.bam /path/to/file3.bam"
## $file_str2的值为: "INPUT=/path/to/file1.bam INPUT=/path/to/file2.bam INPUT=/path/to/file3.bam"
```

### 任务模块
#### 名字
Seqrise::Task
#### 用途
用于封装执行分析的任务，一个Seqrise::Task的对象对应一个任务块，这个任务块包函数若干个输入、若干个输出、分析需要的内存、若干个分析命令。多个任务块够成一个完整的分析。
#### 成员函数
##### new([name=>$name, memory=$mem])
- 返回一个新的Seqrise::Task对象，若出错则返回undef
- 参数name和memory都是可选参数，若不输入，name的值为null，momory的默认值为“5G”
- 参数name $task_name
  - 定义任务块的名称,名称只允许：英文大小写字母、数字、横杠和下划线，选填
- 参数memory $memory
  - 定义运行此任务块所需要的内存，内存单位为：M或G
- 示例：
```
$fileset = Seqrise::Task->new(name=>'bwa_mem', memory => '5G');
```


##### AddInput($input_file)
- 给任务块添加一个输入文件
- 参数：$input_file
  - 定义输入文件的路径，此函数不对输入文件进行路径转换（不把相对路径转换成绝对路径）
- 示例：
```
$input_file = '/home/clabee/HiSeq_1.fq.gz';
$task->AddInput($input_file);
```
##### AddInputs($input_file1[, $input_file2 ...])
- 给任务块添加一个或多个输入文件
- 参数：$input_file1，$input_file2,...,$input_filen
  - 定义输入文件的路径，此函数不对输入文件进行路径转换（不把相对路径转换成绝对路径）
- 示例：
```
$input_file1 = '/home/clabee/HiSeq_1.fq.gz';
$input_file2 = '/home/clabee/HiSeq_2.fq.gz';
$task->AddInput($input_file1, $input_file2);
```

##### AddOutput($output_file)
- 给任务块添加一个输出文件
- 参数：$output_file
  - 定义输出文件的路径
- 示例：
```
$output_file = '/home/clabee/HiSeq_1.fq.gz';
$task->AddOutput($output_file);
```

##### AddOutputs($output_file1[, $output_file2])
- 给任务块添加一个或多个输出文件
- 参数：$output_file1, $output_file2, ..., $output_filen
  - 定义输出文件的路径
- 示例：
```
$output_file1 = '/home/clabee/HiSeq_1.fq.gz';
$output_file2 = '/home/clabee/HiSeq_2.fq.gz';

$task->AddOutputs($output_file1, $output_file2);
```

##### AddCommand($cmd)
- 给任务块添加一个命令行语句
- 参数： $cmd
  - 定义命令
- 示例：
```
$cmd = "sed -i 's/a/b/g' file.txt";
$task->AddCommand($cmd);
```


##### PrintTasks($task_shell, $ref_task_array)
- 打印整个任务（由多个任务块构成），把任务输出在文件$task_shell中
- 参数$task_shell
  - 函数输出的整个任务输出在此文件中
- 参数$ref_task_array
  - Seqrise::Task对象的数组的引用
- 示例：
```
$task1 = Seqrise::Task->new();
$task2 = Seqrise::Task->new();
push @tasks, $task1;
push @tasks, $task2;
$task_shell = "/home/clabee/outputs/shell/tasks.sh";
Seqrise::Task->PrintTasks($task_shell, \@tasks);
```


##### PrintGraph($svg, $ref_task_array)
- 打印整个任务中各个任务之间基于输入输出文件的依赖关系流程图
- 参数$svg
  - 生成的SVG格式的流程图
- 参数$ref_task_array
  - Seqrise::Task对象的数组的引用
- 示例：
```
$svg = "/home/clabee/outputs/flowchart.svg";
Seqrise::Task->PrintGraph($svg, \@tasks);
```
### 工具模块
#### 名字
Seqrise::Tool
#### 用途
用于封装工具的镜像、运行内存、参数等信息，提且提供了一系列的参数访问这些信息。工具类的对象是Seqrise::Workflow的成员之一
#### 成员函数
##### new( [option => value ...])
- 返回一个新的Tool（工具）对象，若出错则返回undef
- 参数1：name tool_name
  - 定义工具的名字，必填
- 参数2：path tool_path
  - 工具的路径，必填
- 参数3: memory tool_memory
  - 运行工具所需内存，必填
- 示例：
```
$tool = Seqrise::Tool->new(name => 'bwa', path => '/path/to/bwa', memory => '5G');
```
##### AddParameters($ref_params)
- $ref_params是ARRAY的引用，这个ARRAY是工具对应的参数的ARRAY
- 作为：添加工具的所有参数
- 示例：
```
my @params_array = ({'option'=>'-t', 'type'=>'boolean', 'separator'=null, 'value' => 'true'},'option'=>'-a', 'type'=>'int', 'separator'=null, 'value' => '4'});
$tool->AddParameters(\@params_array);
```

##### GetParameterString()
- 返回工具的参数拼接成的字符串
- 如例如工具bwa实际运行的参数为 -t 4 -k 19 -M，则GetParameterString()的返回值为"-t 4 -k 19 -M"
```
$tool_para = $tool->GetParameterString();
```

##### GetToolName()
- 返回工具的名字
- 示例：
```
$tool_name = $tool->GetToolName();
```



##### GetToolPath()
- 返回工具的路径
- 示例：
```
$tool_path = $tool->GetToolPath();
```

##### GetToolMemory()
- 返回工具所需内存
- 示例
```
$tool_mem = $tool->GetToolMemory();
```


### 多工具共享参数
当某个参数，在多个工具中都出现时，这个参数作为流程的参数，填写在流程的参数中。
比如：toolA 的参数有 ```-a 10 -b 20 -l 100```, toolB的参数有```-c 10 -d 20 -len 30```,假如toolA的-l参数和toolB的-len参数都是指read长度，他们应该保持一致的，这时封装toolA和toolB时，toolA只添加参数```-a 10```和```-b 20```,toolB只添加参数```-c 10```和```-d 20```, 给流程增加一个len参数，把len参数的值分别传递给toolA和toolB，具体传递过程，请在流程中自行指定。

