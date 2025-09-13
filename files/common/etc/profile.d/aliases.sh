# misc
alias la='eza -a'
alias lal='eza -lal'
alias pong='ping -c 3 www.google.com'
alias ts='sudo tailscale status'

# firewalld
alias fw='sudo firewall-cmd'
alias fwp='sudo firewall-cmd --permanent'
alias fwr='sudo firewall-cmd --reload'
alias fwrp='sudo firewall-cmd --runtime-to-permanent'

# systemd
alias sc-cat='sudo systemctl cat'
alias sc-daemon-reload='sudo systemctl daemon-reload'
alias sc-enable='sudo systemctl enable'
alias sc-enable-now='sudo systemctl enable --now'
alias sc-disable='sudo systemctl disable'
alias sc-disable-now='sudo systemctl disable --now'
alias sc-start='sudo systemctl start'
alias sc-stop='sudo systemctl stop'
alias sc-restart='sudo systemctl restart'
alias sc-status='sudo systemctl status'
alias sc-list-sockets='sudo systemctl list-sockets'
alias sc-list-timers='sudo systemctl list-timers'
alias sc-list-units='sudo systemctl list-units'
alias sc-list-svc='sudo systemctl list-units --type=service'
alias sc-reboot='sudo systemctl reboot'
alias sc-poweroff='sudo systemctl poweroff'
