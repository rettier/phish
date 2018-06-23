function zopen --description 'Opens recent folder with z macro'
    open (z -e $argv)
end

function unix --description 'Converts unix timestamp to human readable datetime'
    date -d @(echo "$argv" | cut -d"." -f1)
end

function make
    if test (count $argv) -eq 1 ; and [ "$argv" = "sandwich" ]
        echo "H4sIAIEPvloA/2VQwU7EIBS88xXPxsPuwQSzaDDGg7tq7Eq8NCa9ai1dLvQgLG7ixy9QihRoJi/vvenMgOCwWsHl80f9BBcPgGG9vgd16CUCe/ruMEL1PlZT9ysU4gL5ab17HJYgijU4Yn/yc8ka8lZyqePPvQxVu9q+mILPJi2PoOu5frcp+Me4E7nvtrPeGd9l6VLurG3rlnKL3UKH6vb6jv/D/R9zWW96XPBfjW6T/NObhDfamCL//kQ0EyluZh/NGpvTamX6qrxn3A3MjOn9h1rkHw4+WMIffH3+9LcErr7RGfQ4bvcaAgAA" | base64 -d | gunzip | bash
    else
        /usr/bin/make $argv
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
  deactivate >/dev/null 2>&1
	# take over given arg or default back to main session
	set argc (count $argv)
	if test $argc -eq 0
		set session main
	else
		set session $argv[1]
	end
	# check if user is currently in a tmux session
	if test -n "$TMUX"
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

switch (uname)
case Darwin
	source $path/os/osx/functions.fish
case '*'
	source $path/os/linux/functions.fish
end
