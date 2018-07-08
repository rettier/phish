function c --description 'Copies or paste content from clipboard'
	if tty > /dev/null
		pbpaste
	else
		pbcopy
	end
end

function cc --description 'Copies and/or paste clipboard content to shell'
	if tty > /dev/null
		pbpaste
	else
		pbcopy & pbpaste
	end
end

function cf --description 'Copies full file path to clipboard'
	greadlink -f $argv | cc
end
