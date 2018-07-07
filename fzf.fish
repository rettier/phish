# fzf integration by https://github.com/fisherman/fzf

set -q FZF_TMUX_HEIGHT; or set -U FZF_TMUX_HEIGHT "40%"
set -q FZF_DEFAULT_OPTS; or set -U FZF_DEFAULT_OPTS "--height $FZF_TMUX_HEIGHT"
set -q FZF_LEGACY_KEYBINDINGS; or set -U FZF_LEGACY_KEYBINDINGS 0

function __fzf_cd -d "Change directory"
    set -l commandline (__fzf_parse_commandline)
    set -l dir $commandline[1]
    set -l fzf_query $commandline[2]

    set -l options  "h/hidden"

    argparse $options -- $argv

    set -l COMMAND

    set -q FZF_CD_COMMAND
    or set -l FZF_CD_COMMAND "
    command find -L \$dir -mindepth 1 \\( -path \$dir'*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' \\) -prune \
    -o -type d -print 2> /dev/null | sed 's@^\./@@'"

    set -q FZF_CD_WITH_HIDDEN_COMMAND
    or set -l FZF_CD_WITH_HIDDEN_COMMAND "
    command find -L \$dir \
    \\( -path '*/\\.git*' -o -fstype 'dev' -o -fstype 'proc' \\) -prune \
    -o -type d -print 2> /dev/null | sed 1d | cut -b3-"

    if set -q _flag_hidden
        set COMMAND $FZF_CD_WITH_HIDDEN_COMMAND
    else
        set COMMAND $FZF_CD_COMMAND
    end

    eval "$COMMAND | "(__fzfcmd)" +m $FZF_DEFAULT_OPTS $FZF_CD_OPTS --query \"$fzf_query\"" | read -l select

    if not test -z "$select"
        cd "$select"

        # Remove last token from commandline.
        commandline -t ""
    end

    commandline -f repaint
end
##
# Use fzf as fish completion widget.
#
#
# When FZF_COMPLETE variable is set, fzf is used as completion
# widget for the fish shell by binding the TAB key.
#
# FZF_COMPLETE can have some special numeric values:
#
#   `set FZF_COMPLETE 0` basic widget accepts with TAB key
#   `set FZF_COMPLETE 1` extends 0 with candidate preview window
#   `set FZF_COMPLETE 2` same as 1 but TAB walks on candidates
#   `set FZF_COMPLETE 3` multi TAB selection, RETURN accepts selected ones.
#
# Any other value of FZF_COMPLETE is given directly as options to fzf.
#
# If you prefer to set more advanced options, take a look at the
# `__fzf_complete_opts` function and override that in your environment.


# modified from https://github.com/junegunn/fzf/wiki/Examples-(fish)#completion
function __fzf_complete -d 'fzf completion and print selection back to commandline'
    # As of 2.6, fish's "complete" function does not understand
    # subcommands. Instead, we use the same hack as __fish_complete_subcommand and
    # extract the subcommand manually.
    set -l cmd (commandline -co) (commandline -ct)

    switch $cmd[1]
        case env sudo
            for i in (seq 2 (count $cmd))
                switch $cmd[$i]
                    case '-*'
                    case '*=*'
                    case '*'
                        set cmd $cmd[$i..-1]
                        break
                end
            end
    end

    set -l cmd_lastw $cmd[-1]
    set cmd (string join -- ' ' $cmd)

    set -l initial_query ''
    test -n "$cmd_lastw"; and set initial_query --query="$cmd_lastw"

    set -l complist (complete -C$cmd)
    set -l result

    # do nothing if there is nothing to select from
    test -z "$complist"; and return

    set -l compwc (echo $complist | wc -w)
    if test $compwc -eq 1
        # if there is only one option dont open fzf
        set result "$complist"
    else

        set -l query
        string join -- \n $complist \
        | sort \
        | eval (__fzfcmd) $initial_query --print-query (__fzf_complete_opts) \
        | cut -f1 \
        | while read -l r
            # first line is the user entered query
            if test -z "$query"
                set query $r
            # rest of lines are selected candidates
            else
                set result $result $r
            end
          end

        # exit if user canceled
        if test -z "$query" ;and test -z "$result"
            return
        end

        # if user accepted but no candidate matches, use the input as result
        if test -z "$result"
            set result $query
        end
    end

    set prefix (string sub -s 1 -l 1 -- (commandline -t))
    for i in (seq (count $result))
        set -l r $result[$i]
        switch $prefix
            case "'"
                commandline -t -- (string escape -- $r)
            case '"'
                if string match '*"*' -- $r >/dev/null
                    commandline -t --  (string escape -- $r)
                else
                    commandline -t -- '"'$r'"'
                end
            case '~'
                commandline -t -- (string sub -s 2 (string escape -n -- $r))
            case '*'
                commandline -t -- (string escape -n -- $r)
        end
        [ $i -lt (count $result) ]; and commandline -i ' '
    end

    commandline -f repaint
end

function __fzf_complete_opts_common
    echo --cycle --reverse --inline-info
end

function __fzf_complete_opts_tab_accepts
    echo --bind tab:accept,btab:cancel
end

function __fzf_complete_opts_tab_walks
    echo --bind tab:down,btab:up
end

function __fzf_complete_opts_preview
    set -l file (status -f)
    echo --with-nth=1 --preview-window=right:wrap --preview="fish\ '$file'\ __fzf_complete_preview\ '{1}'\ '{2..}'"
end

function __fzf_complete_preview -d 'generate preview for completion widget.
    argv[1] is the currently selected candidate in fzf
    argv[2] is a string containing the rest of the output produced by `complete -Ccmd`
    '

    if test "$argv[2]" = "Redefine variable"
        # show environment variables current value
        set -l evar (echo $argv[1] | cut -d= -f1)
        echo $argv[1]$$evar
    else
        echo $argv[1]
    end

    echo

    # list directories on preview
    if test -d "$argv[1]"
        ls $argv[1]
    end

    # show ten lines of non-binary files preview
    if test -f "$argv[1]"; and grep -qI . "$argv[1]"
        head -n 10 $argv[1]
    end

    # if fish knows about it, let it show info
    type -q "$argv[1]" 2>/dev/null; and type -a "$argv[1]"

    # show aditional data
    echo $argv[2]
end
test "$argv[1]" = "__fzf_complete_preview"; and __fzf_complete_preview $argv[2..3]

function __fzf_complete_opts_0 -d 'basic single selection with tab accept'
    __fzf_complete_opts_common
    echo --no-multi
    __fzf_complete_opts_tab_accepts
end

function __fzf_complete_opts_1 -d 'single selection with preview and tab accept'
    __fzf_complete_opts_0
    __fzf_complete_opts_preview
end

function __fzf_complete_opts_2 -d 'single selection with preview and tab walks'
    __fzf_complete_opts_1
    __fzf_complete_opts_tab_walks
end

function __fzf_complete_opts_3 -d 'multi selection with preview'
    __fzf_complete_opts_common
    echo --multi
    __fzf_complete_opts_preview
end

function __fzf_complete_opts -d 'fzf options for fish tab completion'
    switch $FZF_COMPLETE
        case 0
            __fzf_complete_opts_0
        case 1
            __fzf_complete_opts_1
        case 2
            __fzf_complete_opts_2
        case 3
            __fzf_complete_opts_3
        case '*'
            echo $FZF_COMPLETE
    end
end
function __fzf_find_file -d "List files and folders"
    set -l commandline (__fzf_parse_commandline)
    set -l dir $commandline[1]
    set -l fzf_query $commandline[2]

    set -q FZF_FIND_FILE_COMMAND
    or set -l FZF_FIND_FILE_COMMAND "
    command find -L \$dir -mindepth 1 \\( -path \$dir'*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' \\) -prune \
    -o -type f -print \
    -o -type d -print \
    -o -type l -print 2> /dev/null | sed 's@^\./@@'"

    begin
        eval "$FZF_FIND_FILE_COMMAND | "(__fzfcmd) "-m $FZF_DEFAULT_OPTS $FZF_FIND_FILE_OPTS --query \"$fzf_query\"" | while read -l s; set results $results $s; end
    end

    if test -z "$results"
        commandline -f repaint
        return
    else
        commandline -t ""
    end

    for result in $results
        commandline -it -- (string escape $result)
        commandline -it -- " "
    end
    commandline -f repaint
end
function __fzf_get_dir -d 'Find the longest existing filepath from input string'
    set dir $argv

    # Strip all trailing slashes. Ignore if $dir is root dir (/)
    if [ (string length $dir) -gt 1 ]
        set dir (string replace -r '/*$' '' $dir)
    end

    # Iteratively check if dir exists and strip tail end of path
    while [ ! -d "$dir" ]
        # If path is absolute, this can keep going until ends up at /
        # If path is relative, this can keep going until entire input is consumed, dirname returns "."
        set dir (dirname "$dir")
    end

    echo $dir
end
function __fzf_open -d "Open files and directories."
    function __fzf_open_get_open_cmd -d "Find appropriate open command."
        if type -q xdg-open
            echo "xdg-open"
        else if type -q open
            echo "open"
        end
    end

    set -l commandline (__fzf_parse_commandline)
    set -l dir $commandline[1]
    set -l fzf_query $commandline[2]

    set -l options "e/editor"

    argparse $options -- $argv

    set -q FZF_OPEN_COMMAND
    or set -l FZF_OPEN_COMMAND "
    command find -L \$dir -mindepth 1 \\( -path \$dir'*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' \\) -prune \
    -o -type f -print \
    -o -type d -print \
    -o -type l -print 2> /dev/null | sed 's@^\./@@'"

    eval "$FZF_OPEN_COMMAND | "(__fzfcmd) "-m $FZF_DEFAULT_OPTS $FZF_OPEN_OPTS --query \"$fzf_query\"" | read -l select

    # set how to open
    set -l open_cmd
    if set -q _flag_editor
        set open_cmd "$EDITOR"
    else
        set open_cmd (__fzf_open_get_open_cmd)
        if test -z "$open_cmd"
            echo "Couldn't find appropriate open command to use. Do you have 'xdg-open' or 'open' installed?"; and return 1
        end
    end

    set -l open_status 0
    if not test -z "$select"
        eval "$open_cmd $select"
        set open_status $status
        commandline -t ""
    end

    commandline -f repaint
    return $open_status
end
function __fzf_parse_commandline -d 'Parse the current command line token and return split of existing filepath and rest of token'
    # eval is used to do shell expansion on paths
    set -l commandline (eval "printf '%s' "(commandline -t))

    if [ -z $commandline ]
        # Default to current directory with no --query
        set dir '.'
        set fzf_query ''
    else
        set dir (__fzf_get_dir $commandline)

        if [ "$dir" = "." -a (string sub -l 1 $commandline) != '.' ]
            # if $dir is "." but commandline is not a relative path, this means no file path found
            set fzf_query $commandline
        else
            # Also remove trailing slash after dir, to "split" input properly
            set fzf_query (string replace -r "^$dir/?" '' "$commandline")
        end
    end

    echo $dir
    echo $fzf_query
end
function __fzf_reverse_isearch
    history -z | eval (__fzfcmd) --read0 --tiebreak=index --toggle-sort=ctrl-r $FZF_DEFAULT_OPTS $FZF_REVERSE_ISEARCH_OPTS -q '(commandline)' | perl -pe 'chomp if eof' | read -lz result
    and commandline -- $result
    commandline -f repaint
end
function __fzfcmd
    set -q FZF_TMUX; or set FZF_TMUX 0
    set -q FZF_TMUX_HEIGHT; or set FZF_TMUX_HEIGHT 40%
    if [ $FZF_TMUX -eq 1 ]
        echo "fzf-tmux -d$FZF_TMUX_HEIGHT"
    else
        echo "fzf"
    end
end

