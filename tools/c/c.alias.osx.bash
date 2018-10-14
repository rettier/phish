function c(){
  if [[ $# -eq 1 ]] ; then
    cr $1 <&0
    return
  fi

  if tty > /dev/null; then
    pbpaste
  else
    pbcopy
  fi
}

function cc(){
  if tty > /dev/null ; then
    pbpaste
  else
    pbcopy
    pbpaste
  fi
}

function cf(){
    greadlink -f $1 | cc
}

CR_HOST="http://192.168.15.10"
function cr(){
	tty > /dev/null
	if [[ $? -eq 0 ]] ; then
		curl "$CR_HOST:8099/?c=$1" -XGET -s | base64 -D | gunzip
	else
	    gzip <&0 | base64 | curl -H 'Content-Type: text/plain' -XPOST -d @- -s "$CR_HOST:8099/?c=$1"
	fi
}
