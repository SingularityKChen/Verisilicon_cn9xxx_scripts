# Verisilicon_cn9xxx_scripts
Some scripts I write in Verisilicon


# Learning_note

## 2019.2.18-2.22

+ run a new shell script
	>> chmod +x myshell.sh
	>> .dir/myshell.sh

+ create new filefolder
```bash
	#!/bin/bash2
	#create hack
	DN='hack'
	if [ -d $DN ];
	then
	    echo $DN "exists"
	   #do something
	else
	    mkdir $DN
	    echo $DN "is created"
	fi
```
+ getopts

## 2019.2.25-3.1

+ open new terminal and run new cmd:
	gnome-terminal --title="test2" -x bash -c "ls; exec bash"

+ transport parameters from one terminal to another
	gnome-terminal --title="test2" -x bash -c "\~ /bin/script/test2.sh $test1 $test2 $test3; exec bash"

	then at test2.sh
	test21=$1
	test22=$2
	test23=$3

+ can't run the alias in default sheel:
	$echo $shell and see if it was tcsh, and sh can't attain the alias of tcsh.
	So we'd better use it to check the shell firstly.

+ use alias to save time.

+ `:%s/^\(.*\)$\n\1/alternative text/g` in vim to delete to same para

+ use `pop` and `push` to deal with `@` in perl.

+ use `glob` to find the filename and `grep` to find the context.

## 2019.3.4-3.8

+ open a new terminal
```sh
gnome-terminal --title="regression_feRegressNightly" -x tcsh -c "ls; exec tcsh"
```

+ jobs, bg %?

+ cp across file in vim
	open file1name with vim,then `: [num] r file2name` copy file2name to line [num] in file1name.

+ /local/scratch/SG_LINT_CDC_DFT/waiver_list
+ /local/Run200/cn9259/SG_CDC/[tag]/cdc_env
+ VIVANTE_GPU_waiver.awl


+ system 256 not dir

+ include the additional script
```perl
unshift (@INC, "/home/cn9259/bin/script/");
require("chip_readinfo.pl");
```

+ Can't use string ("3") as a symbol ref while "strict refs" in use at /home/cn9259/bin/script/regression.pl line 22. 
Check the filename and semicolon


## 2019.3.11-3.15

- get $HOST and ${user}
```perl
#!/usr/bin/perl 
use Sys::Hostname;
print hostname, "\n"; #$HOST
print getlogin, "\n"; #${user}
```

- the size of one dir
`du -sh *`

- cp:omitting directory
`cp -f`

- tanslate varables between perl and tcl
在perl里面， $ENV{'XXXX'} = yyyyy
在tcl中，     ::\$env(XXXX) 就可以把yyyy传统到tcl的变量XXXX上了。

- ls after cd
`alias cd 'cd \!* ; ls'`

## 2019.3.25-3.29
- colorfulize the information
```perl
#!/usr/bin/perl 
use Term::ANSIColor;
print color 'bold on_white red';
print "\n--------------\n[*E*R*R*O*R*] $temp_exit_case[1] failed\n--------------\n";
print color 'reset';
```

- to see whether one process successed
```perl
#!/usr/bin/perl 
use strict;
my $source_result[$i] = system "/bin/tcsh -c 'gnome-terminal --title=\"$prc[$i]\" -x tcsh -c \"$sourcecode; mkdir -p successful/$prc[$i]; exec tcsh\" '";
my $datestring = strftime "%Y_%m_%d__%H_%M", localtime;
if ($source_result[$i] == 0 && -e "successful/$prc[$i]") {
	print "\n--------------\n[*I*N*F*O*] source $prc[$i] successful\ntag is $tag\n--------------\n";
```
