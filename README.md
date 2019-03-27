# Pi-in-the-Middle

This is a collection of scripts to configure a 
[Raspberry Pi](https://www.raspberrypi.org/) as a wireless access point and
install [mitmproxy](https://mitmproxy.org) to act as an HTTP & HTTPS proxy. It
can be configured as a transparent proxy and network traffic can be recorded
using tcpdump and uploaded to [CloudShark](https://cloudshark.io) with the
SSL/TLS master keys automatically applied for decryption.

## Installation

This was tested using a [Raspberry Pi 3 Model B](https://www.raspberrypi.org/products/raspberry-pi-3-model-b/)
running [Raspbian Stretch Lite](https://www.raspberrypi.org/downloads/raspbian/).

### Python

Installing mitmproxy v4 requires Python 3.6 (or higher) and pip3. This version
is not available currently in the Raspbian repository so it will have to be
installed manually. 

In this git repository the
[install-python-mitmproxy.sh](/install-python-mitmproxy.sh)
script will download and compile version 3.7.2 
of Python and install it to `$HOME/.local`. Then this script will add this
version of Python to the users path and install mitmproxy using pip3. It will
also download the packages necessary to build Python using apt. 

## Network Configuration

The [setup-network.sh](/setup-network.sh) will install the packages necessary
to configure the device as a wireless access point and tcpdump to capture the
network traffic. This script must be run as root using sudo:

```
sudo ./setup-network.sh
```

After running this script the Raspberry Pi should be rebooted to finish the
network configuration.

By default the Raspberry Pi will act as a wireless AP for the `pi in the
middle` network and this is also the WPA pre-shared key. This can be configured
in the [/etc/hostapd.conf](/etc/hostapd.conf) file. The `wlan0` will be
configured with a static IP address of `192.168.1.1/24` and will serve IP
addresses via DHCP from the range 192.168.1.50-192.168.1.100. This can be
modified in the file [/etc/dnsmasq.conf](/etc/dnsmasq.conf)

## CloudShark API Token

An API token is required to upload captures and keylog files to CloudShark
using the [upload api method](https://support.cloudshark.io/api/upload.html).

CloudShark users can view and create API tokens in the Preferences menu at the
top of the page after logging in. This can be added as an environment variable
by running:

```
echo "export CLOUDSHARK_API=<Replace with API Token>" >> ~/.bashrc
```

Now captures can be automatically be uploaded to CloudShark using the API after
capturing the traffic.

## Capturing and uploading

The [capture-and-upload.sh](/capture-and-upload.sh) starts by configuring the
firewall to direct HTTP & HTTPS traffic to our mitmproxy acting as a
[transparent proxy](https://docs.mitmproxy.org/stable/concepts-modes/#transparent-proxy).

Next it begins capturing HTTP and HTTPS traffic on the `eth0` interface using
tcpdump and starts `mitmdump` to act as our man-in-the-middle proxy. This will
also dump the [SSLKEYLOGFILE](https://docs.mitmproxy.org/stable/howto-wireshark-tls/)
so that HTTPS traffic can be decrypted.

Clients connecting to the `pi in the middle` wireless traffic will now have all
of their HTTP and HTTPS traffic being proxied though mitmproxy but may not
trust its built-in certificate authority. There is a built in certificate
installation app clients can use by brwosing to `mitm.it`.
[Here](https://docs.mitmproxy.org/stable/concepts-certificates/) is more
information on the mitmproxy certificate authority and how it can be
configured.

Once the script is killed using `Ctrl+c` the proxy and network capture will be
stopped and the capture file will be uploaded to CloudShark with a keylog file
applied to decrypt the SSL/TLS traffic that was captures. 
[Here is an example](https://www.cloudshark.org/captures/662f862bb6d4) of a
capture file that was taking using our Pi-in-the-Middle! 

## CS Enterprise

Customers with their own instance of CS Enterprise can update the
`cloudshark_url` in the [capture-and-upload.sh](/capture-and-upload.sh) script
to upload captures to their own private instance of CloudShark.
