# Things I Always Want To Know About Debian

## Set Console Resolution

Set in `/etc/default/grub`:

```
GRUB_CMDLINE_LINUX_DEFAULT="video=1280x1024 consoleblank=600"
GRUB_GFXMODE=1280x1024
GRUB_GFXPAYLOAD_LINUX=keep
```

Then run: `sudo update-grub`

## Basic Things I Like

* `su - -c "apt install sudo"`
* Add my user to all the groups, relogin
* `sudo apt install vim`
* `sudo update-alternatives --set editor /usr/bin/vim.basic`

## Stop Clearing My Screen

From <http://mywiki.wooledge.org/SystemdNoClear>.

```
rm ~/.bash_logout
sudo mkdir /etc/systemd/system/getty@.service.d
cat << EOF | sudo tee /etc/systemd/system/getty@.service.d/noclear.conf
[Service]
TTYVTDisallocate=no
EOF
sudo systemctl daemon-reload
```
