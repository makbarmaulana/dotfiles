# ==============================
# SSH Agent forwarding (WSL <-> Windows via npiperelay)
# ==============================
export SSH_AUTH_SOCK=$HOME/.ssh/agent.sock
if [ ! -S "$SSH_AUTH_SOCK" ]; then
    rm -f "$SSH_AUTH_SOCK"
    (setsid socat UNIX-LISTEN:"$SSH_AUTH_SOCK",fork EXEC:"/mnt/c/Users/makba/AppData/Local/Microsoft/WinGet/Packages/jstarks.npiperelay_Microsoft.Winget.Source_8wekyb3d8bbwe/npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
fi

