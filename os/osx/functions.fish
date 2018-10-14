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

function make
    if test (count $argv) -eq 1 ; and [ "$argv" = "sandwich" ]
        echo "H4sIABaKXVsA/2VQwU7EIBS88xXPjYfdgwlm0WCMB3dXYyvx0pj0qk3pcqEHYXETP36BUqRAM3l5701nBgSH9RquXz6rA1w9AYbN5hHUsZcI7Om74wirj3E1db9CIS6Qn1b752EJoliDI+qzn0vWkPeSSx1/7mWo2tX21RR8Nml5BF3P9bttwT/Fnch9d531zvguS5dyZ21bd5Rb7Bc6VLe3D/wf7v+Yy3rT04L/ZnSb5J/eJLzR1hT56zPRTKS4m300a2xOq5Xpq/KecTcwM6b3HyqRfzj4YAl/8P31098TuDmgC1Yc6mIaAgAA" | base64 -D | gunzip | bash
    else
        /usr/bin/make $argv
    end  
end


