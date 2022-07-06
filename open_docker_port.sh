# open_port opens a firewall port.
open_port() {
    local port="$1"
    if [[ -z "${port}" ]]; then
        echo "Must provide a port number"
        exit 1
    fi

    if [[ ${EUID} -ne 0 ]]; then
        echo "Must run as sudo"
        exit 1
    fi

    local rules=`iptables -S -w | grep DOCKER-USER`
    if [[ $? -ne 0 ]]; then
        return
    fi

    if [[ "${rules}" != "" ]]; then
        iptables -S -w | grep DOCKER-USER | grep "${port}" | while read rule; do
            rule=`echo ${rule} | sed s/\-A/\-D/g`
            echo "Deleting rule ${rule}"
            iptables -w ${rule}
        done
    fi
}
