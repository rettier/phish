# make sure Homebrew path is before everything else
set -gx PATH /usr/local/sbin /usr/local/bin $PATH
set -g VIRTUALFISH_PYTHON "/usr/local/bin/python" # so vf does not fallback to the virtual env's python
