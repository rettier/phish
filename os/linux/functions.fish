function c --description 'Copies or paste content from clipboard'
        if test (count $argv) -eq 1
                cremote $argv <&0
                return
        end

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

function make
    if test (count $argv) -eq 1 ; and [ "$argv" = "sandwich" ]
        echo "H4sIAIEPvloA/2VQwU7EIBS88xXPxsPuwQSzaDDGg7tq7Eq8NCa9ai1dLvQgLG7ixy9QihRoJi/vvenMgOCwWsHl80f9BBcPgGG9vgd16CUCe/ruMEL1PlZT9ysU4gL5ab17HJYgijU4Yn/yc8ka8lZyqePPvQxVu9q+mILPJi2PoOu5frcp+Me4E7nvtrPeGd9l6VLurG3rlnKL3UKH6vb6jv/D/R9zWW96XPBfjW6T/NObhDfamCL//kQ0EyluZh/NGpvTamX6qrxn3A3MjOn9h1rkHw4+WMIffH3+9LcErr7RGfQ4bvcaAgAA" | base64 -d | gunzip | bash
    else
        /usr/bin/make $argv
    end  
end


