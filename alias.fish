alias ..='cd ..'
alias ccd='builtin cd'
alias mkdir='mkdir -p'
abbr -a nano vim
alias ccat='command cat'
alias meh='echo "¯\\_(ツ)_/¯"'
alias pubip='curl ipecho.net/plain; and echo'
alias htf='fish_logo; and echo "       All hail the Fish"'
alias make="make -j(nproc --all)"
abbr -a unixc unix \(c\)
abbr -a ssh-agent eval \(ssh-agent -c\)
abbr -a le load-env
abbr -a cdc cd \(c\)
abbr -a rle readlink -e
abbr -a gcmeh git commit -m \"(meh)\"

# git
abbr -a gau git add -u
abbr -a grm  git rm 
abbr -a grmca git rm --cached
abbr -a grao git remote add origin
abbr -a grf git rm -rf
abbr -a grfca git rm -rf --cached
abbr -a glne git pull --no-edit
abbr -a gpristine 'git reset --hard; and git clean -dfx'
abbr -a gg gogit
abbr -a gunpushed 'git log --branches --not --remotes --simplify-by-decoration --decorate --oneline'

# python
abbr -a pi pip install 
abbr -a pir pip install -r 
abbr -a pirr pip install -r requirements.txt

# docker
abbr -a d docker
abbr -a dc docker-compose
abbr -a dcud docker-compose up -d

# json
alias j='python -c "import sys, json; print json.dumps(json.load(sys.stdin), sort_keys=True, indent=2)" | cat'
alias pj='python -c "import sys, ast, json; print json.dumps(ast.literal_eval(sys.stdin.read().strip()))" | j'
alias cj='c | j'

# tmux
alias t='tmx'
alias res='cp $path/tmux/resurrect/last ~/.tmux/resurrect/last'

# ansible
alias play='ansible-playbook'
alias playask='ansible-playbook --ask-become-pass'
alias playsudo='ansible-playbook --extra-vars 'ansible_ssh_user=root''

# kubernetes helpers
alias kname='kubectl config set-context (kubectl config current-context) --namespace '
abbr -a kaf kubectl apply -f
abbr -a k   kubectl
abbr -a kdp   kubectl delete pod
abbr -a kgp   kubectl get pods

abbr -a r redis-cli

# add os depending alias file
switch (uname)
case Darwin
	source $path/os/osx/alias.fish
case '*'
	source $path/os/linux/alias.fish
end
