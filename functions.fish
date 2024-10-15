function make
    if test (count $argv) -eq 1 ; and [ "$argv" = "sandwich" ]
        echo "H4sIAOnYHF0A/2VQTU8DIRS88yuejYf20ARTNBjjwVaNW4mXjclelcKWCxyEYhN/fIH9cBfYTF7ee7MzA0rCcgnXL5/VM1w9AobV6gHsUWgE4Qh+NLD4MIuu+1UWSYXStNo9tXMQy2o8Yn9Oc81q8l5yaeQPve6ri7V59QWfdVoJvW7ipt2m4J/Gncp9tzx4Z/yYhU+5g3aoWyoDdjMd6pqbe/mP+P+YK3jT04z/5l0zyd+9Sf9GG1/k35+JY2qK28HHsTrkDFqZvi3vOe5a5s30/m2l8g/3PljDH3x//Yg7Auv1QXBzEOgC0WPWeiACAAA=" | base64 --decode | gunzip | bash
    else
        eval (which make) $argv
    end  
end

function load-env --description "load docker env file"
    for i in (cat $argv | grep -o '^[^#]*')
        set arr (echo $i |tr = \n)
        set -gx $arr[1] $arr[2]
    end
end

function htb --description "hex to binary"
    perl -pe 's/([0-9a-f]{2})/chr hex $1/gie' <&0
end

function zopen --description 'Opens recent folder with z macro'
    open (z -e $argv)
end

function unix --description 'Converts unix timestamp to human readable datetime'
    date -d @(echo "$argv" | grep -oP '(\d{10})' | head -n1)
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
    git log --color=always --graph --oneline --decorate --all | fzf --ansi --preview "echo {} | grep -Eow '[a-z0-9A-Z]+' | head -n1 | xargs git show --color=always" | grep -Eow '[a-z0-9A-Z]+' | head -n1
end

function gogit --description 'zcd to the directory and open the git remote in the browser'
	set argc (count $argv)
	if test $argc -gt 0 
        pushd .
        z $argv
    end

	set toplevel (git rev-parse --show-toplevel)
	set relative (pwd | sed s~$toplevel~~)
	set url (git remote get-url (git remote | head -n1) | sed -r 's/git@(.*):([^\.]*)(\.git)?/https:\/\/\1\/\2/g')
	set url (echo "$url" | sed s~\\.git~~)
	set branch (git rev-parse --abbrev-ref HEAD)

	if [ -n "$relative" ]
	  switch "$url"
	    case "*gitlab.com*"
	      set url "$url/-/tree/$branch$relative"
	    case "*github.com*"
              set url "$url/tree/$branch$relative"
	    case "*"
	  end
	end

	open "$url" >/dev/null 2>&1

	if test $argc -gt 0 
        popd
    end
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
    basename (readlink -e $argv) | cc
end

function cbd --description 'Copies basename of current directory to clipboard'
    cb $PWD
end

function ipy --description 'Start ipython with current venv'
	python -c "import IPython;" >/dev/null 2>&1
	if test $status -ne 0
		pip install ipython
	end
	python -c "import IPython; IPython.terminal.ipapp.launch_new_instance()"
end

function rc --description "clear redis keys with pattern"
  redis-cli --scan --pattern $argv[1] | xargs redis-cli del
end

function docker-copy --description "copy images from one repo/tag to another repo/tag"
  docker pull $argv[1]
  docker tag $argv[1] $argv[2]
  docker push $argv[2]
end


switch (uname)
case Darwin
	source $path/os/osx/functions.fish
case '*'
	source $path/os/linux/functions.fish
end
