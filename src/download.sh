get_latest_version() {
    case $1 in
    core)
        name=$is_core_name
        latest_ver="v1.9.7"
        ;;
    sh)
        name="$is_core_name 脚本"
        latest_ver="latest"
        ;;
    caddy)
        name="Caddy"
        latest_ver="v2.9.0"
        ;;
    esac
}

download() {
    latest_ver=$2
    [[ ! $latest_ver ]] && get_latest_version $1
    # tmp dir
    tmpdir=$(mktemp -u)
    [[ ! $tmpdir ]] && {
        tmpdir=/tmp/tmp-$RANDOM
    }
    mkdir -p $tmpdir
    case $1 in
    core)
        name=$is_core_name
        tmpfile=$tmpdir/$is_core.tar.gz
        link="https://github.com/${is_core_repo}/releases/download/${latest_ver}/${is_core}-${latest_ver:1}-linux-${is_arch}.tar.gz"
        download_file
        tar zxf $tmpfile --strip-components 1 -C $is_core_dir/bin
        chmod +x $is_core_bin
        ;;
    sh)
        name="$is_core_name 脚本"
        tmpfile=$tmpdir/sh.tar.gz
        link="https://github.com/${is_caddy_repo}/releases/${latest_ver}/download/code.tar.gz"
        download_file
        tar zxf $tmpfile -C $is_sh_dir
        chmod +x $is_sh_bin ${is_sh_bin/$is_core/sb}
        ;;
    caddy)
        name="Caddy"
        tmpfile=$tmpdir/caddy.tar.gz
        link="https://github.com/${is_caddy_repo}/releases/download/${latest_ver}/caddy_${latest_ver:1}_linux_${is_arch}.tar.gz"
        download_file
        tar zxf $tmpfile -C $tmpdir
        cp -f $tmpdir/caddy $is_caddy_bin
        chmod +x $is_caddy_bin
        ;;
    esac
    rm -rf $tmpdir
    unset latest_ver
}

download_file() {
    if ! _wget -t 5 -c $link -O $tmpfile; then
        rm -rf $tmpdir
        err "\n下载 ${name} 失败.\n"
    fi
}
