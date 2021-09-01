#!/usr/bin/perl
#use strict;
use warnings;
use File::Copy;
use File::Copy::Recursive qw(dircopy);
use File::Compare;
use File::Basename;
use File::Spec;
use Cwd;
my @com = ("init", "add", "commit", "log", "show", "rm", "status", "branch", "checkout", "merge");
my %status_log;
if ($#ARGV < 0){
    print"Usage: $0 <command> [<args>]\n\n";
    printf "   %-10s %s\n","init","Create an empty legit repository";
    printf "   %-10s %s\n","add","Add file contents to the index";
    printf "   %-10s %s\n","commit","Record changes to the repository";
    printf "   %-10s %s\n","log","Show commit log";
    printf "   %-10s %s\n","show","Show file at particular state";
    printf "   %-10s %s\n","rm","Remove files from the current directory and from the index";
    printf "   %-10s %s\n","status","Show the status of files in the current directory, index, and repository";
    printf "   %-10s %s\n","branch","list, create or delete a branch";
    printf "   %-10s %s\n","checkout","Switch branches or restore current directory files";
    printf "   %-10s %s\n","merge","Join two development histories together";
    die "\n";
}else{
    $first_argv = $ARGV[0];
    if (!grep( /^$first_argv$/, @com ) ) {
        print"Usage: $0 <command> [<args>]\n\n";
        printf "   %-10s %s\n","init","Create an empty legit repository";
        printf "   %-10s %s\n","add","Add file contents to the index";
        printf "   %-10s %s\n","commit","Record changes to the repository";
        printf "   %-10s %s\n","log","Show commit log";
        printf "   %-10s %s\n","show","Show file at particular state";
        printf "   %-10s %s\n","rm","Remove files from the current directory and from the index";
        printf "   %-10s %s\n","status","Show the status of files in the current directory, index, and repository";
        printf "   %-10s %s\n","branch","list, create or delete a branch";
        printf "   %-10s %s\n","checkout","Switch branches or restore current directory files";
        printf "   %-10s %s\n","merge","Join two development histories together";
        die "\n";
    }else{
        if($first_argv eq "init"){
            die "usage: legit.pl init\n"
            if ($#ARGV != 0 );
            init();
        }
        if ($first_argv eq "add"){
            #is_folder_empty()
            @files = splice @ARGV, 1, $#ARGV;
            foreach my $s (@files){
                if ($#files > -1){
                    die "invalid $s file name\n" 
                    if !($s=~ /^[a-zA-Z0-9]+[.-_]*+[a-zA-Z0-9]*/);
                }else{
                    die "usage: legit.pl add <filenames>";
                }
                die "legit.pl: error: '$s' is not a regular file\n" if (-d $s);
            }
            add(@files);
        }
        if ($first_argv eq "commit"){
            die "usage: legit.pl commit [-a] -m commit-message\n"
            if ($#ARGV == 0);
            commit();
        }
        if ($first_argv eq "log"){
            log_fun();
        }
        if ($first_argv eq "show"){
            show();
        }
        if ($first_argv eq "rm"){
            rm();
        }
        if ($first_argv eq "status"){
            write_status();
            foreach $name ( sort { lc($a) cmp lc($b) } keys %status_log) {
                print  "$name - $status_log{$name}";
            }
        }
    }
}
sub init{
    if (!-e ".legit"){
        mkdir ".legit";
        mkdir ".legit/log";
        open F, ">", ".legit/log/log" || die;
        close F;
        mkdir ".legit/index";
        mkdir ".legit/master";
        print "Initialized empty legit repository in .legit\n";
    }else{
        print "legit.pl: error: .legit already exists\n"
    }
}
sub add{
    if (!-e ".legit"){
        print "legit.pl: error: no .legit directory containing legit repository exists\n";
    }else{
        @files = @_;

        foreach $f (@files){
            if (! -e "$f"){
                die "legit.pl: error: can not open '$f'\n" if ( !-e ".legit/index/$f");
            }
            if ((! -e "$f") && (-e ".legit/index/$f")){
                unlink ".legit/index/$f";
            }else{
                copy("$f", ".legit/index/$f") || die;
            }     
        }
    }
}

sub is_folder_empty {
    my $dir = shift;
    $num = 0;
    foreach $file (glob "$dir/*"){
        $num++;
    }
    return 0
    if $num > 0;
    return 1;
}

sub commit{
    $a_flag = 0;
    $m_flag = 0;
    @comm = splice @ARGV, 1, $#ARGV;
    $message = "";
    foreach $com (@comm){
        if($com eq "-m"){
            $m_flag = 1;
        }elsif ($com eq "-a"){
            $a_flag = 1;
        }else{
            $message = $com;
        }
    }

    die "usage: legit.pl commit [-a] -m commit-message\n"
    if (($m_flag == 0) && ($a_flag == 0)) || ($message eq "");

    $commit_index = 0;
    while(-e ".legit/master/$commit_index"){
        $commit_index++;       
    }
    $last = $commit_index-1;
    mkdir ".legit/master/$commit_index" || die;
    if ($a_flag == 1){
        foreach my $file(glob ".legit/index/*"){
            add(basename($file));
        }
    }    
    $sign = 0;
    foreach my $file (glob ".legit/index/*") {
        $name = basename($file);
        $f_master = ".legit/master/$last/$name";
        if(-e "$f_master"){
            $sign ++ if(compare ($file, $f_master) != 0);
        }else{
            $sign ++;
        }
    }
    
    foreach my $file (glob ".legit/master/$last/*" ){
        $name = basename($file);
        $f_index = ".legit/index/$name";
        $sign ++ if( ! -e "$f_index");
    }
    
    if($sign == 0) {
        rmdir ".legit/master/$commit_index";
        die "nothing to commit\n";
    
    }else{
        dircopy(".legit/index", ".legit/master/$commit_index");
        print "Committed as commit $commit_index\n";
        open $f,'+>>',".legit/log/log" || die "Couldn't open log: $!\n";
        print $f "$commit_index $message\n";
        close $f;
    }
}

sub log_fun{
    if(! -e ".legit/master/0"){
        die "legit.pl: error: your repository does not have any commits yet\n";
    }
    open( FILE, "<", ".legit/log/log" )
    || die( "Can't open log file\n" );
    @lines = reverse <FILE>;
    foreach $line (@lines) {
        print $line;
    }
}

sub show{
    if (! -e ".legit"){
        die "legit.pl: error: no .legit directory containing legit repository exists\n";
    }
    my @commod = split /\:/, $ARGV[1];
    if ($#commod == -1){
        die "usage: legit.pl show <commit>:<filename>\n";
    }else{
        $num = $commod[0];
        $name =  $commod[1];
        if ($num eq ""){
            die "legit.pl: error: '$name' not found in index\n"
            if (!( -e ".legit/index/$name"));
            open my $file, ".legit/index/$name"; print <$file>; close $file;
        }else{
            die "legit.pl: error: unknown commit '$num'\n"
            if(!(-e ".legit/master/$num"));
            
            die "legit.pl: error: '$name' not found in commit $num\n"
            if(! -e ".legit/master/$num/$name");
            open my $file, ".legit/master/$num/$name"; print <$file>; close $file;
        }
    }
}

sub rm{
    if (!-e ".legit"){
        die "legit.pl: error: no .legit directory containing legit repository exists\n";
    }
    @commod = splice @ARGV, 1, $#ARGV;
    if ($#commod == -1){
        die "need more commod\n";
    }
    $f_flag = 0;
    $c_flag = 0;
    my @files;
    foreach $com (@commod){
        if ($com eq '--force'){
            $f_flag = 1;
        }elsif ($com eq '--cached'){
            $c_flag = 1;
        }else{
            die "invalid $com file name\n"
            if (!($com=~ /^[a-zA-Z0-9]+[.-_]*+[a-zA-Z0-9]*/));
            push @files, $com;
        }
    }
    $commit_index = 0;
    while(-e ".legit/master/$commit_index"){
        $commit_index++;
    }
    $commit_index --;                   #lastest commit_index
    if ($c_flag == 0 && $f_flag == 0){
        foreach $file (@files){
            #print "$file , ";
            $f_index = ".legit/index/$file";
            $f_master = ".legit/master/$commit_index/$file";
            
            die"legit.pl: error: '$file' is not in the legit repository\n"
            if (! -e "$file");

            if(-e $f_index){
                if ((compare($f_index, $file) != 0)){
                    die "legit.pl: error: '$file' in repository is different to working file\n"
                    if (compare($f_index, $f_master) == 0);
                    die "legit.pl: error: '$file' in index is different to both working file and repository\n"
                    if (compare ($f_index, $f_master) != 0);
                }

                die "legit.pl: error: '$file' has changes staged in the index\n"
                if (compare($f_index, $f_master) != 0 || compare($file, $f_index) != 0);
            }
            die "legit.pl: error: '$file' has changes staged in the index\n"
            if (!( -e ".legit/index/$file") && (-e ".legit/master/$commit_index/$file"));
           
            #print("I am here LLL\n");
            die"legit.pl: error: '$file' is not in the legit repository\n"
            if (!( -e ".legit/index/$file"));
            
        }

    }
    
    if ($c_flag == 1 && $f_flag == 0){
        foreach $file (@files){
            $f_index = ".legit/index/$file";
            $f_master = ".legit/master/$commit_index/$file"; 
            
            die"legit.pl: error: '$file' is not in the legit repository\n"
            if (! -e ".legit/index/$file");

            die "legit.pl: error: '$file' in index is different to both working file and repository\n"
            if((compare($f_index, $file) != 0) && (compare($f_index, $f_master) != 0));
         }
    }

    if($f_flag == 1){
        if($c_flag == 0){
            foreach $file (@files){
                die "legit.pl: error: '$file' is not in the legit repository\n"
                if (! (-e ".legit/index/$file"));

                unlink ".legit/index/$file"
                if (".legit/index/$file");

                die "legit.pl: error: '$file' is not in the legit repository\n"
                if (! (-e "$file"));
                
                unlink "$file"
                if (-e "$file");
            }
            return;
        }else{
            foreach $file (@files){
                die "legit.pl: error: '$file' is not in the legit repository\n"
                if (! (-e ".legit/index/$file"));

                unlink ".legit/index/$file"
                if  (-e ".legit/index/$file");
            }
        }
    }
    foreach $file (@files){
        $f_index = ".legit/index/$file"; 
        unlink $f_index;
        if (($c_flag == 0) && (-e "$file" )) {
            unlink "$file";
        }
    }

}

sub write_status{
    $last = 0;
    while( -e ".legit/master/$last"){
        $last++;
    }
    $last --;
    if($last == -1){
        die "legit.pl: error: your repository does not have any commits yet\n"
    }
    foreach $file (glob "*") {
        if(! -d $file){         #make sure it is not dir
            $name = $file;
            $f_index=".legit/index/$name";
            $f_master=".legit/master/$last/$name";

            if(!$status_log{$name}) {
                $status_log{$name}="untracked\n";
            } else {
               if ((-e $f_index) && !(-e $f_master)) {
                    $status_log{$name}="file changed, changes staged for commit\n"
                    if (compare($name, $f_index) == 1);
                    $status_log{$name}="added to index\n"
                    if (compare($name, $f_index) == 0);
                }
                
                $status_log{$name}="untracked\n"
                if (!(-e $f_index));
                
                if((-e $f_index) && (-e $f_master)) {
                    if(compare($f_index, $f_master) == 0) {
                        $status_log{$name}="same as repo\n"
                        if (compare($name, $f_index) == 0);

                        $status_log{$name}="file changed, changes staged for commit\n"
                        if (compare($name, $f_index) != 0);

                    }else{
                        $status_log{$name}="file changed, changes not staged for commit\n"
                        if (compare($name, $f_index) == 0);

                        $status_log{$name}="file changed, different changes not staged for commit\n"
                        if (compare($name, $f_index) != 0);
                    }
                }

            }
        }
    }


    foreach $file (glob"\.legit\/index\/*") {
        if (! -d $file ){
            $name = basename($file);
            $f_index=".legit/index/$name";
            $f_master=".legit/master/$last/$name";

            if(! $status_log{$name}) {
                $status_log{$name}="untracked\n";
            } else {
                if((-e $name) && (-e $f_master)){
                    if (compare($f_index, $f_master) == 0){
                        $status_log{$name} = "same as repo\n" 
                        if (compare($name, $f_index) == 0 );
                        $status_log{$name} = "file changed, changes staged for commit\n" 
                        if (compare($name, $f_index)!= 0 ) ;
                    }
                    if (compare($f_index, $f_master)!=0){
                        $status_log{$name} = "file changed, changes not staged for commit\n" 
                        if(compare($name, $f_index)==0);
                        $status_log{$name} = "file changed, different changes staged for commit\n"
                        if (compare($name, $f_index)!=0);
                    }
                } elsif (!(-e $name) && (-e $f_master)) {
                        $status_log{$name} = "file changed, different changes staged for commit\n"
                        if (compare($f_index, $f_master) != 0);
                        $status_log{$name} = "file changed, changes not staged for commit\n"
                        if (compare($f_index, $f_master) == 0);
                        
                } elsif ((-e $name) && !(-e $f_master)) {
                        $status_log{$name} = "file changed, different changes staged for commit\n"
                        if (compare($name, $f_index) !=0 );
                        $status_log{$name} = "added to index\n"
                        if (compare($name, $f_index) ==0 )
                } else {
                    $status_log{$name} = "file changed, different changes staged for commit\n";
                }
            }
        }
    }

    foreach $nameile (glob ".legit/master/$last/* ") {
        if (! -d $nameile){
            $name = basename($nameile);
            $f_index=".legit/index/$name";
            $f_master=".legit/master/$last/$name";

            if(! $status_log{$name}) {
                $status_log{$name}="deleted\n";
            } else {
                if(!(-e $name)){
                    $status_log{$name}="file deleted\n"
                    if (-e $f_index);

                    $status_log{$name}="deleted\n"
                    if (!-e $f_index);
                    
                } elsif((-e $name) && !(-e $f_index) ){
                    $status_log{$name}="untracked\n";
                } else {
                    $status_log{$name}="same as repo\n"
                    if(compare($name, $f_index) == 0 && compare($f_index, $f_master)==0);

                    $status_log{$name}="file changed, changes not staged for commit\n"
                    if (compare($name, $f_index)!= 0 && compare($f_index, $f_master)==0);

                    $status_log{$name}="file changed, changes staged for commit\n"
                    if (compare($name, $f_index) == 0 && compare($f_index, $f_master)!=0);

                    $status_log{$name}="file changed, different changes staged for commit\n"
                    if (compare($name, $f_index) != 0 && compare($f_index, $f_master)!=0);
                }
            }
        }
    }
}
