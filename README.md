# fish-x
This plugin defines a function called `x` that extracts the archived file. 

Use `x`, you can extract a archived file with the command `x <filename>`, you not need to known the detail which the extract program run actually. 
But, you also need to install the extract program.

This plugin is inspired by [ohmyzsh-extract](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/extract). 

# Usage 
The help message of the command:  
```
x: Extracts archived file
Usage: x [options...] [archived files]...

Options:
  -l/--list     list the contents of the archived file
  -r/--remove   remove the archived file
  -h/--help     print this help message
```

`x` will keep the origin file after extract by default. You can give the option `-r` to remove it after extract.
You can give the option `-l` the get the archived content.

# Install
Install using Fisher(or other plugin manager):
```
fisher install tenfyzhong/fish-x
```

# Supported file extensions
| Extension   | Description                    |
|-------------|--------------------------------|
| `.tar.gz`   | Tarball with gzip compression  |
| `.tgz`      | Tarball with gzip compression  |
| `.tar.bz2`  | Tarball with bzip2 compression |
| `.tbz`      | Tarball with bzip2 compression |
| `.tbz2`     | Tarball with bzip2 compression |
| `.tar.xz`   | Tarball with lzma2 compression |
| `.txz`      | Tarball with lzma2 compression |
| `.tar.zma`  | Tarball with lzma compression  |
| `.tar.lzma` | Tarball with lzma compression  |
| `.tlz`      | Tarball with lzma compression  |
| `.tar.zst`  | Tarball with zstd compression  |
| `.tzst`     | Tarball with zstd compression  |
| `.tar.lz`   | Tarball with lzip compression  |
| `.tar.lz4`  | Tarball with lz4 compression   |
| `.tar.lrz`  | Tarball with lrzip compression |
| `.tar`      | Tarball                        |
| `.gz`       | Gzip file                      |
| `.z`        | Gzip file                      |
| `.bz2`      | Bzip2 file                     |
| `.xz`       | LZMA2 archive                  |
| `.lrz`      | LRZ archive                    |
| `.lz4`      | LZ4 archive                    |
| `.lzma`     | LZMA archive                   |
| `.zip`      | Zip archive                    |
| `.rar`      | WinRAR archive                 |
| `.7z`       | 7zip file                      |
| `.zst`      | Zstandard file (zstd)          |
| `.cpio`     | Cpio archive                   |
| `.osbcpio`  | Cpio archive                   |
| `.zpaq`     | Zpaq file                      |
