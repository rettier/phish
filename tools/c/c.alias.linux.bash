function c(){
  if [[ $# -eq 1 ]] ; then
    cr $1 <&0
    return
  fi

  if tty > /dev/null; then
    xclip -selection clipboard -o
  else
    xclip -selection c
  fi
}

function cc(){
  if tty > /dev/null ; then
    xclip -selection clipboard -o
  else
    xclip -selection c
    xclip -selection clipboard -o
  fi
}

function cf(){
    readlink -f $1 | cc
}

CR_HOST="http://192.168.15.10"
function cr(){
	tty > /dev/null
	if [[ $? -eq 0 ]] ; then
	    curl "$CR_HOST:8099/?c=$1" -XGET -s | base64 -d | gunzip
	else
	    gzip <&0 | base64 | curl -H 'Content-Type: text/plain' -XPOST -d @- -s "$CR_HOST:8099/?c=$1"
	fi
}
