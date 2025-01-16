run_segment() {
    type rainbarf >/dev/null 2>&1
    if [ "$?" -ne 0 ]; then
        echo 'rainbarf was not found'
        return
    fi

    # Customize via ~/.rainbarf.conf
    stats=$(rainbarf --rgb)
    if [ -n "$stats" ]; then
        echo "$stats";
    fi
    return 0
}
