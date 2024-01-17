set source a
set archived a 

function _mock_typeq_value
    argparse 'v/value=!test -n "$_flag_value"' -- $argv 2>/dev/null
    set mocks (string split ' ' $argv)
    for v in $mocks
        @echo "mock $v"
        set -pgx cmd $v
    end
    @echo "current mocks: $mocks"
    set -gx query_value $_flag_value
    function type
        argparse 'q/query=!test -n "$_flag_value"' -- $argv 2>/dev/null
        if builtin contains -- $_flag_q $cmd
            return $query_value
        end
        # builtin type -q $_flag_value
        return 0
    end
end

function _demock_typeq
    set mocks (string split ' ' $argv)
    for q in $mocks
        @echo "demock $q"
        set -e cmd[(contains -i $q $cmd)]
    end
end

function _init_env
    argparse 'f/func=!test -n "$_flag_value"' 's/suffix=!test -n "$_flag_value"' -- $argv 2>/dev/null

    if test -z "$_flag_s" -o -z "$_flag_f"
        return 1
    end

    set -l suffix $_flag_s

    command rm -f $source $archived$suffix &>/dev/null
    echo 'hello world' > $source
    eval "$_flag_f 2>/dev/null"
    @echo 'after init env, files'
    ls -al
    command rm -f $source
end

function _test_x
    argparse 'f/func=!test -n "$_flag_value"' \
        's/suffix=!test -n "$_flag_value"' \
        'p/pattern=!test -n "$_flag_value"' \
        -- $argv 2>/dev/null

    @echo === "[-f:$_flag_f] [-s:$_flag_s] [-p:$_flag_p]" ===

    set -l suffix $_flag_s

    set temp (command mktemp -d)
    builtin cd $temp

    @echo --- x -l ---
    _init_env -f "$_flag_f" -s $suffix
    set list (x -l $archived$suffix)
    @test "check list" (string match -q -r -- "$_flag_p" "$list") $status -eq 0

    @echo --- x ---
    _init_env -f "$_flag_f" -s $suffix
    x $archived$suffix 
    @test "without remove check source file" -f $temp/$source
    @test "without remove check tar file" -f $temp/$archived$suffix
    @test "without remove check content" (cat $temp/$source) = "hello world"

    @echo --- x -r ---
    _init_env -f "$_flag_f" -s $suffix
    x -r $archived$suffix 
    @test "with remove check source file" -f $temp/$source
    @test "with remove check tar file" ! -f $temp/$archived$suffix
    @test "with remove check content" (cat $temp/$source) = "hello world"

    command rm -rf $temp
end

function _test_dependence
    argparse 's/suffix=!test -n "$_flag_value"' \
        'd/denpence=+!test -n "$_flag_value"' \
        'l/list' \
        -- $argv 2>/dev/null

    @echo === "[-s:$_flag_s] [-d:$_flag_d] [-l:$_flag_l]" ===

    set temp (command mktemp -d)
    builtin cd $temp
    set cwd (pwd)

    set suffix $_flag_s

    @echo "touch $archived$suffix"
    touch "$archived$suffix"
    ls -al

    if set -q _flag_l
        for d in $_flag_d
            _mock_typeq_value -v 1 $d
            @test "match msg:" (x -l $archived$suffix 2>&1 | string collect) = "x: extracting $archived$suffix
x: Dependence: <$d>, please install it first"
            _demock_typeq $d
        end
    else
        for d in $_flag_d
            _mock_typeq_value -v 1 $d
            @test "match msg:" (x $archived$suffix 2>&1 | string collect) = "x: extracting $archived$suffix
x: Dependence: <$d>, please install it first"
            _demock_typeq $d
        end
    end

    command rm -rf $temp
end

@echo =========== pigz ===========
for suffix in .tar.gz .tgz
    _test_x -f "tar czf $archived$suffix $source" \
        -s $suffix \
        -p "-rw-r--r--.*$source\$"
    _test_dependence -s $suffix -d tar -l
    _test_dependence -s $suffix -d tar
end

@echo =========== ztvf ===========
_mock_typeq_value -v 1 pigz
for suffix in .tar.gz .tgz
    _test_x -f "tar czf $archived$suffix $source" \
        -s $suffix \
        -p "-rw-r--r--.*$source\$"
end
_demock_typeq pigz

@echo =========== pbzip2 ===========
for suffix in .tar.bz2 .tbz .tbz2
    _test_x -f "tar cjf $archived$suffix $source" \
        -s $suffix \
        -p "-rw-r--r--.*$source\$"
    _test_dependence -s $suffix -d tar -l
    _test_dependence -s $suffix -d tar
end

@echo =========== xvjf ===========
_mock_typeq_value -v 1 pbzip2
for suffix in .tar.bz2 .tbz .tbz2
    _test_x -f "tar cjf $archived$suffix $source" \
        -s $suffix \
        -p "-rw-r--r--.*$source\$"
end
_demock_typeq pbzip2

@echo =========== xz ===========
for suffix in .tar.xz .txz
    _test_x -f "tar --xz -cf $archived$suffix $source" \
        -s $suffix \
        -p "-rw-r--r--.*$source\$"
    _test_dependence -s $suffix -d tar -d "xz xzcat" -l
    _test_dependence -s $suffix -d tar -d "xz xzcat"
end

@echo =========== xzcat ===========
_mock_typeq_value -v 1 xz
for suffix in .tar.xz .txz
    _test_x -f "tar --xz -cf $archived$suffix $source" \
        -s $suffix \
        -p "-rw-r--r--.*$source\$"
end
_demock_typeq xz

@echo =========== lzma ===========
for suffix in .tar.zma .tar.lzma .tlz
    _test_x -f "tar --lzma -cf $archived$suffix $source" \
        -s $suffix \
        -p "-rw-r--r--.*$source\$"
    _test_dependence -s $suffix -d tar -d "lzma lzcat" -l
    _test_dependence -s $suffix -d tar -d "lzma lzcat"
end

@echo =========== lzcat ===========
_mock_typeq_value -v 1 lzma
for suffix in .tar.zma .tar.lzma .tlz
    _test_x -f "tar --lzma -cf $archived$suffix $source" \
        -s $suffix \
        -p "-rw-r--r--.*$source\$"
end
_demock_typeq lzma

@echo =========== zstd ===========
for suffix in .tar.zst .tzst
    _test_x -f "tar --zstd -cf $archived$suffix $source" \
        -s $suffix \
        -p "-rw-r--r--.*$source\$"
    _test_dependence -s $suffix -d tar -d zstd -l
    _test_dependence -s $suffix -d tar -d zstd
end

@echo =========== lzip ===========
for suffix in .tar.lz
    _test_x -f "tar --lzip -cf $archived$suffix $source" \
        -s $suffix \
        -p "-rw-r--r--.*$source\$"
    _test_dependence -s $suffix -d tar -d lzip -l
    _test_dependence -s $suffix -d tar -d lzip
end

@echo =========== lz4 ===========
for suffix in .tar.lz4
    _test_x -f "tar cf $archived_file_name.tar $source && lz4 $archived_file_name.tar $archived$suffix" \
        -s $suffix \
        -p "-rw-r--r--.*$source\$"
    _test_dependence -s $suffix -d tar -d lz4 -l
    _test_dependence -s $suffix -d tar -d lz4
end

@echo =========== .tar.lrz ===========
for suffix in .tar.lrz
    _test_x -f "lrztar -o $archived$suffix $source" \
        -s $suffix \
        -p "-rw-r--r--.*$source\$"
    _test_dependence -s $suffix -d tar -d lrzcat -l
    _test_dependence -s $suffix -d lrzuntar
end

@echo =========== tar ===========
for suffix in .tar
    _test_x -f "tar cf $archived$suffix $source" \
        -s $suffix \
        -p "-rw-r--r--.*$source\$"
    _test_dependence -s $suffix -d tar -l
    _test_dependence -s $suffix -d tar
end

@echo =========== gz ===========
for suffix in .gz
    _test_x -f "gzip -c $source > $archived$suffix" \
        -s $suffix \
        -p "compressed        uncompressed  ratio uncompressed_name"
    _test_dependence -s $suffix -d gzip -l
    _test_dependence -s $suffix -d gzip
end

@echo =========== bz2 ===========
for suffix in .bz2
    _test_x -f "bzip2 -k $source" \
        -s $suffix \
        -p "Date      Time    Attr         Size   Compressed  Name"
    _test_dependence -s $suffix -d "7zz 7za" -l
    _test_dependence -s $suffix -d bzip2
end

@echo =========== xz ===========
for suffix in .xz
    _test_x -f "xz -k -c $source > $archived$suffix" \
        -s $suffix \
        -p "Date      Time    Attr         Size   Compressed  Name"
    _test_dependence -s $suffix -d "7zz 7za" -l
    _test_dependence -s $suffix -d xz
end

@echo =========== lrz ===========
for suffix in .lrz
    _test_x -f "lrzip $source" \
        -s $suffix \
        -p "CRC32 used for integrity testing"
    _test_dependence -s $suffix -d lrzip -l
    _test_dependence -s $suffix -d lrzip
end

@echo =========== lz4 ===========
for suffix in .lz4
    _test_x -f "lz4 $source $archived$suffix" \
        -s $suffix \
        -p "Frames           Type Block  Compressed  Uncompressed     Ratio   Filename"
    _test_dependence -s $suffix -d lz4 -l
    _test_dependence -s $suffix -d lz4
end

@echo =========== lzma ===========
for suffix in .lzma
    _test_x -f "lzma -k $source" \
        -s $suffix \
        -p "Date      Time    Attr         Size   Compressed  Name"
    _test_dependence -s $suffix -d "7zz 7za" -l
    _test_dependence -s $suffix -d lzma
end

@echo =========== z ===========
for suffix in .z
    _test_x -f "compress -c $source > $archived$suffix" \
        -s $suffix \
        -p "Date      Time    Attr         Size   Compressed  Name"
    _test_dependence -s $suffix -d "7zz 7za" -l
    _test_dependence -s $suffix -d compress
end

@echo =========== zip ===========
for suffix in .zip
    _test_x -f "zip $archived$suffix $source" \
        -s $suffix \
        -p "Length      Date    Time    Name"
    _test_dependence -s $suffix -d zip -l
    _test_dependence -s $suffix -d zip
end

@echo =========== rar ===========
for suffix in .rar
    _test_x -f "rar a $archived$suffix $source" \
        -s $suffix \
        -p "Attributes      Size     Date    Time   Name"
    _test_dependence -s $suffix -d rar -l
    _test_dependence -s $suffix -d rar
end

@echo =========== 7z ===========
for suffix in .7z
    _test_x -f "7zz a $archived$suffix $source" \
        -s $suffix \
        -p "Date      Time    Attr         Size   Compressed  Name"
    _test_dependence -s $suffix -d "7zz 7za" -l
    _test_dependence -s $suffix -d "7zz 7za"
end

@echo =========== zst ===========
for suffix in .zst
    _test_x -f "zstd $source -o $archived$suffix" \
        -s $suffix \
        -p "Frames  Skips  Compressed  Uncompressed  Ratio  Check  Filename"
    _test_dependence -s $suffix -d zstd -l
    _test_dependence -s $suffix -d zstd
end

@echo =========== cpio ===========
for suffix in .cpio .obscpio
    _test_x -f "ls $source | cpio -o > $archived$suffix" \
        -s $suffix \
        -p "a"
    _test_dependence -s $suffix -d cpio -l
    _test_dependence -s $suffix -d cpio
end

@echo =========== zpaq ===========
for suffix in .zpaq
    _test_x -f "zpaq a $archived$suffix $source" \
        -s $suffix \
        -p "a.zpaq: 1 versions, 1 files, 1 fragments,"
    _test_dependence -s $suffix -d zpaq -l
    _test_dependence -s $suffix -d zpaq
end

@echo =========== help ===========
# set help (x -h | string collect)
@test "test help" (x -h | string collect) = "x: Extracts archived file
Usage: x [options...] [archived files]...

Options:
  -l/--list     list the contents of the archived file
  -r/--remove   remove the archived file
  -h/--help     print this help message"
