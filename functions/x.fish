function x --description "Extracts archived file"
    argparse 'l/list' 'r/remove' 'h/help' -- $argv 2>/dev/null

    if test $status -ne 0
        _x_help
        return 1
    end

    if set -q _flag_help
        _x_help
        return 0
    end

    if test -z "$argv"
        _x_help
        return 2
    end

    set -l cwd (pwd)
    for file in $argv
        if test ! -f $file
            echo "x: '$file' is not a valid file" >&2
            continue
        end

        set -l full_path (realpath $file)
        set -l dir (dirname $full_path)
        set -l base (basename $full_path)

        builtin cd $dir
        echo "x: extracting $file" >&2

        switch "$base"
            case '*.tar.gz' '*.tgz'
                _x_check_dependence tar || continue
                if set -q _flag_list
                    type -q pigz && tar -I pigz -tvf "$full_path" || tar ztvf "$full_path"
                else
                    type -q pigz && tar -I pigz -xvf "$full_path" || tar xvzf "$full_path"
                    test $status -eq 0 && set -q _flag_remove && command rm -f $file
                end
            case '*.tar.bz2' '*.tbz' '*.tbz2'
                _x_check_dependence tar || continue
                if set -q _flag_list
                    type -q pbzip2 && tar -I pbzip2 -tvf "$full_path" || tar tvjf "$full_path"
                else
                    type -q pbzip2 && tar -I pbzip2 -xvf "$full_path" || tar xvjf "$full_path"
                    test $status -eq 0 && set -q _flag_remove && command rm -f $file
                end
            case '*.tar.xz' '*.txz'
                _x_check_dependence tar || continue
                _x_check_dependence xz xzcat || continue
                if set -q _flag_list
                    type -q xz && tar --xz -tvf "$full_path" || xzcat "$full_path" | tar tvf -
                else
                    type -q xz && tar --xz -xvf "$full_path" || xzcat "$full_path" | tar xvf -
                    test $status -eq 0 && set -q _flag_remove && command rm -f $file
                end
            case '*.tar.zma' '*.tar.lzma' '*.tlz'
                _x_check_dependence tar || continue
                _x_check_dependence lzma lzcat || continue
                if set -q _flag_list
                    type -q lzma && tar --lzma -tvf "$full_path" || lzcat "$full_path" | tar tvf -
                else
                    type -q lzma && tar --lzma -xvf "$full_path" || lzcat "$full_path" | tar xvf -
                    test $status -eq 0 && set -q _flag_remove && command rm -f $file
                end
            case '*.tar.zst' '*.tzst'
                _x_check_dependence tar || continue
                _x_check_dependence zstd || continue
                if set -q _flag_list
                    tar --zstd -tvf "$full_path"
                else
                    tar --zstd -xvf "$full_path"
                    test $status -eq 0 && set -q _flag_remove && command rm -f $file
                end
            case '*.tar.lz'
                _x_check_dependence tar || continue
                _x_check_dependence lzip || continue
                if set -q _flag_list
                    tar --lzip -tvf "$full_path"
                else
                    tar --lzip -xvf "$full_path"
                    test $status -eq 0 && set -q _flag_remove && command rm -f $file
                end
            case '*.tar.lz4'
                _x_check_dependence tar || continue
                _x_check_dependence lz4 || continue
                if set -q _flag_list
                    lz4 -c -d "$full_path" | tar tvf -
                else
                    lz4 -c -d "$full_path" | tar xvf -
                    test $status -eq 0 && set -q _flag_remove && command rm -f $file
                end
            case '*.tar.lrz'
                if set -q _flag_list
                    _x_check_dependence tar || continue
                    _x_check_dependence lrzcat || continue
                    lrzcat $file 2>/dev/null | tar tvf -
                else
                    _x_check_dependence lrzuntar || continue
                    lrzuntar $full_path
                    test $status -eq 0 && set -q _flag_remove && command rm -f $file
                end
            case '*.tar'
                _x_check_dependence tar || continue
                if set -q _flag_list
                    tar tvf "$full_path"
                else
                    tar xvf "$full_path"
                    test $status -eq 0 && set -q _flag_remove && command rm -f $file
                end
            case '*.gz'
                _x_check_dependence gzip || continue
                if set -q _flag_list
                    gunzip -l "$full_path"
                else
                    gunzip -N -k "$full_path"
                    test $status -eq 0 && set -q _flag_remove && command rm -f $file
                end
            case '*.bz2'
                if set -q _flag_list
                    _x_check_dependence 7zz || continue
                    7zz l "$full_path"
                else
                    _x_check_dependence bzip2 || continue
                    bunzip2 -k "$full_path"
                    test $status -eq 0 && set -q _flag_remove && command rm -f $file
                end
            case '*.xz'
                if set -q _flag_list
                    _x_check_dependence 7zz || continue
                    7zz l "$full_path"
                else
                    _x_check_dependence xz || continue
                    unxz -k "$full_path"
                    test $status -eq 0 && set -q _flag_remove && command rm -f $file
                end
            case '*.lrz'
                _x_check_dependence lrzip || continue
                if set -q _flag_list
                    lrzip -i -vv "$full_path"
                else
                    lrunzip "$full_path"
                    test $status -eq 0 && set -q _flag_remove && command rm -f $file
                end
            case '*.lz4'
                _x_check_dependence lz4 || continue
                if set -q _flag_list
                    lz4 --list "$full_path"
                else
                    unlz4 -k "$full_path"
                    test $status -eq 0 && set -q _flag_remove && command rm -f $file
                end
            case '*.lzma'
                if set -q _flag_list
                    _x_check_dependence 7zz || continue
                    7zz l "$full_path"
                else
                    _x_check_dependence lzma || continue
                    unlzma -k "$full_path"
                    test $status -eq 0 && set -q _flag_remove && command rm -f $file
                end
            case '*.z'
                if set -q _flag_list
                    _x_check_dependence 7zz || continue
                    7zz l "$full_path"
                else
                    _x_check_dependence compress || continue
                    uncompress -k -N "$full_path"
                    test $status -eq 0 && set -q _flag_remove && command rm -f $file
                end
            case '*.zip'
                _x_check_dependence zip || continue
                if set -q _flag_list
                    unzip -l "$full_path"
                else
                    unzip "$full_path" 
                    test $status -eq 0 && set -q _flag_remove && command rm -f $file
                end
            case '*.rar'
                _x_check_dependence rar || continue
                if set -q _flag_list
                    unrar l "$full_path"
                else
                    unrar x "$full_path"
                    test $status -eq 0 && set -q _flag_remove && command rm -f $file
                end
            case '*.7z'
                _x_check_dependence 7zz || continue
                if set -q _flag_list
                    7zz l "$full_path"
                else
                    7zz x "$full_path"
                    test $status -eq 0 && set -q _flag_remove && command rm -f $file
                end
            case '*.zst'
                _x_check_dependence zstd || continue
                if set -q _flag_list
                    unzstd -l "$full_path"
                else
                    unzstd "$full_path"
                    test $status -eq 0 && set -q _flag_remove && command rm -f $file
                end
            case '*.cpio' '*.obscpio'
                _x_check_dependence cpio || continue
                if set -q _flag_list
                    cpio -t -I "$full_path"
                else
                    cpio -idmvF "$full_path"
                    test $status -eq 0 && set -q _flag_remove && command rm -f $file
                end
            case '*.zpaq'
                _x_check_dependence zpaq || continue
                if set -q _flag_list
                    zpaq l "$full_path"
                else
                    zpaq x "$full_path"
                    test $status -eq 0 && set -q _flag_remove && command rm -f $file
                end
            case '*'
                echo "x: '$file' cannot be extracted" >&2
                continue
        end

    end

    builtin cd $cwd
end

function _x_help
    printf %s\n \
        'x: Extracts archived file' \
        'Usage: x [options...] [archived files]...' \
        '' \
        'Options:' \
        '  -l/--list     list the contents of the archived file' \
        '  -r/--remove   remove the archived file' \
        '  -h/--help     print this help message'
end

# _x_check_dependence check dependence
# input: programs
# output: return 0 if one of the program is runable
function _x_check_dependence
    if test -z "$argv"
        return 0
    end

    for v in $argv
        if type -q $v
            return 0
        end
    end

    echo "x: Dependence: <$argv>, please install it first" >&2
    return 1
end
