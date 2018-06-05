function c --description 'Copies or paste content from clipboard'
	if tty > /dev/null
		xclip -selection clipboard -o
	else
		xclip -selection c
	end
end

function cc --description 'Copies and/or paste clipboard content to shell'
	if tty > /dev/null
		xclip -selection clipboard -o
	else
		xclip -selection c
		xclip -selection clipboard -o
	end
end

function cf --description 'Copies full file path to clipboard'
	readlink -f $argv | cc
end

function open --description 'open any file/folder with xdg open and mute stdout/stderr'
    xdg-open $argv 2>&1 >/dev/null
end

function load-env --description "load docker env file"
    for i in (cat $argv | grep -o '^[^#]*')
        set arr (echo $i |tr = \n)
        set -gx $arr[1] $arr[2]
    end
end
abbr -a le load-env
