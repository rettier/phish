function cd --description 'List directory content on cd'
	builtin cd $argv; and ll
end

# helper methods, cause we don't like conditional statements
function on-error
	set res $status
	if res -ne 0
		$argv
	end
	return res
end
function on-success
	set res $status
	if res -eq 0
		$argv
	end
	return res
end

# tmux functions
function __tmux_has_session
 	tmux has-session -t $argv[1] ^ /dev/null
end


function tmx --description 'Creates/Resurrects tmux sessions'
	# take over given arg or default back to main session
	set argc (count $argv)
	if $argc -eq 0
		set session main
	else
		set session $argv[1]
	end
	# check if user is currently in a tmux session
	if test -n $TMUX
		if $argc -eq 0
			tmux list-sessions | awk '{sub(":","") ; print "- " $argv[1] " " $argv[1]1}' 
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

switch (uname)
case Darwin
	source $path/os/osx/functions.fish
case '*'
	source $path/os/linux/functions.fish
end
