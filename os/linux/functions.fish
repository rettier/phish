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

