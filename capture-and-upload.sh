#!/bin/bash

capture_file=$(mktemp /tmp/capture.XXXXXXXX)
keylog_file=$(mktemp /tmp/keylog.XXXXXXXX)

capture_filter="port 443 or port 80"

# These iptables rules will route traffic to the mitmproxy
add_firewall_rules () {
  echo "Setting up firewall rules"
  sudo iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 80 -j REDIRECT --to-port 8080
  sudo iptables -t nat -A PREROUTING -i wlan0 -p tcp --dport 443 -j REDIRECT --to-port 8080
  echo "Done"
}

remove_firewall_rules () {
  echo "Removing firewall rules"
  sudo iptables -t nat -D PREROUTING -i wlan0 -p tcp --dport 80 -j REDIRECT --to-port 8080
  sudo iptables -t nat -D PREROUTING -i wlan0 -p tcp --dport 443 -j REDIRECT --to-port 8080
  echo "Done"
}

# This will upload the capture file and keylog to CloudShark
cloudshark_upload () {
  cloudshark_url="https://www.cloudshark.org"
  api_token=${CLOUDSHARK_API}

  echo -e "Uploading to ${cloudshark_url}"
  response=$(curl -s -F file="@${capture_file}" -F keylog="@${keylog_file}" ${cloudshark_url}/api/v1/${api_token}/upload)

  json_id=$(echo $response | python -m json.tool | grep id)

  if [ "$json_id" != "" ]; then
    # find the CloudShark ID for this session
    id=`echo $json_id | sed 's/:/ /1' | awk -F" " '{ print $2 }'| sed 's/\"//g'`

    # show a URL using the capture session in CloudShark
    echo -e "\nA new CloudShark session has been created at:"
    echo "${cloudshark_url}/captures/$id"
  else
    echo -e "\nCould not upload capture to CloudShark:"
    echo $response | python -m json.tool
  fi
}

# Setup
add_firewall_rules

# Post Capture Steps
post_capture () {
  remove_firewall_rules
  cloudshark_upload
}

echo "Capturing traffic to: ${capture_file}"
echo "Logging TLS keys to: ${keylog_file}"

# Capture and upload to CloudShark
trap 'kill %1; kill %2; post_capture' SIGINT; \
  sudo tcpdump -i eth0 -w ${capture_file} ${capture_filter} & \
  MITMPROXY_SSLKEYLOGFILE="${keylog_file}" mitmdump -m transparent --showhost --no-http2
