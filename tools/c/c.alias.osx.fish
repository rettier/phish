function c --description 'Copies or paste content from clipboard'
    if test (count $argv) -eq 1
        cr $argv <&0
        return
    end

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
		pbcopy
		pbpaste
	end
end

function cf --description 'Copies full file path to clipboard'
	greadlink -f $argv | cc
end

function cr --description 'copy/retrieve data from/to c server'
    set CR_HOST "http://192.168.15.10"
	if tty > /dev/null
		curl "$CR_HOST:8099/?c=$argv[1]" -XGET -s | base64 -D | gunzip
	else
	    gzip <&0 | base64 | curl -H 'Content-Type: text/plain' -XPOST -d @- -s "$CR_HOST:8099/?c=$argv[1]"
	end
end