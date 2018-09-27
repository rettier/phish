function load-env --description "load docker env file"
    for i in (cat $argv | grep -o '^[^#]*')
        set arr (echo $i |tr = \n)
        set -gx $arr[1] $arr[2]
    end
end

function zopen --description 'Opens recent folder with z macro'
    open (z -e $argv)
end

function shoot --description "fucking ignore ssh hosts file"
    ssh-keygen -f "~/.ssh/known_hosts" -R '[shootback.acc.si]':$argv[1] >/dev/null 2>&1
    if test (count $argv) -gt 2
      set runarg $argv[2..-1]
    else
      set runarg ""
    end
    ssh -lalpr -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p $argv[1] shootback.acc.si $runarg
end

function shootcp --description "scp without host check"
    ssh-keygen -f "~/.ssh/known_hosts" -R '[shootback.acc.si]':$argv[1] >/dev/null 2>&1
    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P $argv
end

function unix --description 'Converts unix timestamp to human readable datetime'
    date -d @(echo "$argv" | cut -d"." -f1)
end

function zz --description 'search through and cd into z history with fzf'
    z -l | sed 's/\([0-9]\+\)\.\([0-9]\+\)/\1,\2/' | sort -n | fzf --tac --no-sort --with-nth 2 --preview "ls --color=always {2}" --preview-window=up -q "$argv" | tr -s "[:space:]" | cut -d" " -f2 | read -l res
    if [ $res ] 
      cd "$res"
    else
      return 1
    end
end

function ww --description 'search through and activate desktop windows'
    wmctrl -ia (wmctrl -l | tr -s " " | fzf --with-nth=4.. | cut -d" " -f1)
end

function zg --description 'search through git history'
    git log --color=always --graph --oneline --decorate --all | fzf --ansi --preview "git show --color=always {2}"
end

function gogit --description 'zcd to the directory and open the git remote in the browser'
	pushd .
	z $argv
	open (git remote get-url (git remote | head -n1) | sed -r 's/git@(.*):(.*)\.git/https:\/\/\1\/\2/g') 2>&1 >/dev/null
	popd
end


# helper methods, cause we don't like conditional statements
function on-error
	set res $status
	if test "$res" -ne 0
		eval $argv
	end
	return $res
end
function on-success
	set res $status
	if test "$res" -eq 0
		eval $argv
	end
	return $res
end

# tmux functions
function __tmux_has_session
 	tmux has-session -t $argv[1] ^ /dev/null
end


function tmx --description 'Creates/Resurrects tmux sessions'
	# take over given arg or default back to main session
	set argc (count $argv)
	if test $argc -eq 0
		set session main
	else
		set session $argv[1]
	end
        
        # check if user is currently in a tmux session
	if test -n "$TMUX"
        deactivate >/dev/null 2>&1 
		if test $argc -eq 0
			tmux list-sessions | awk '{sub(":", ""); print "- " $1 " " $11}' 
		else
			__tmux_has_session $session
			on-error tmux new-session -d -s $session
			tmux switch-client -t $session
		end
	else
		__tmux_has_session $session
		on-error tmux new-session -s $session
		on-success tmux attach -t $session 
	end
end


function cb --description 'Copies basename to clipboard'
    basename $argv | cc
end

function cbd --description 'Copies basename of current directory to clipboard'
    cb $PWD
end


switch (uname)
case Darwin
	source $path/os/osx/functions.fish
case '*'
	source $path/os/linux/functions.fish
end
