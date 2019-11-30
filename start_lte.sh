sudo ifdown wlan0
sleep 1
sudo qmicli -d /dev/cdc-wdm0 --dms-set-operating-mode='online'
sleep 1
sudo qmicli -d /dev/cdc-wdm0 -w
sleep 1
sudo ip link set wwan0 down
sleep 1
echo 'Y' | sudo tee /sys/class/net/wwan0/qmi/raw_ip
sleep 1
sudo ip link set wwan0 up
sleep 1
sudo qmicli -p -d /dev/cdc-wdm0 --device-open-net='net-raw-ip|net-no-qos-header' --wds-start-network="apn='internet',ip-type=4" --client-no-release-cid
sleep 1
sudo udhcpc -i wwan0
sleep 1

ip a s wwan0
ip r s

sudo qmicli -d /dev/cdc-wdm0 --dms-get-operating-mode
sudo qmicli -d /dev/cdc-wdm0 --nas-get-signal-strength
sudo qmicli -d /dev/cdc-wdm0 --nas-get-home-network
