# Scripts for Raspberry Pi 4G hat (SIM7600) with GPS configuration

Scripts based on this description:[Setup wwan0 interface for 4G network](https://www.raspberrypi.org/forums/viewtopic.php?p=1374909#p1450784)

### Hardware requirements:
- Raspberry Pi 3B+
- [Waveshare 4G hat SIM7600e-H](https://www.waveshare.com/wiki/SIM7600E-H_4G_HAT)
- SIM card (standard size 15 x 25mm preferable)

4G hat conneted to Raspberry via USB, the folowing devices are created:
`/dev/ttyUSB1` - for communication with GPS part (NMEA protocol), 9600 bod default
`/dev/ttyUSB3` - main communication port, AT commands, 115200 bod default

### Software requirements:
- scripts were tested with DietPi and Linux 4.19.75-v7+
- QMI driver is used to communicate with modem (packets `libqmi-utils`, `udhcpc`)
- packets `gpsd`, `gpsd-clients`, `python-gps` for the GPS use

## Contents:
 
**start_lte.sh** - bash script that disable WiFi interface and configures LTE as wwan0, also prints information
**configure_gps.py** - Python 3 script that configure SIM7600 for GPS (uses pyserial module)

## Additional configuration

1. Provider information

This part of script contains provider information ans should be changed to meet actual requirements (enter APN, Username and Password).

Example for Megafon (Russia):

```bash
sudo qmicli -p -d /dev/cdc-wdm0 --device-open-net='net-raw-ip|net-no-qos-header' --wds-start-network="apn='internet',username='gdata',password='gdata',ip-type=4" --client-no-release-cid
```

Example for TELE2 (Russia):

```bash
sudo qmicli -p -d /dev/cdc-wdm0 --device-open-net='net-raw-ip|net-no-qos-header' --wds-start-network="apn='internet.TELE2.ru',ip-type=4" --client-no-release-cid
```
> NOTE: Many cellular operators block modem devices when that works with regual SIM cards. Please ensure that you're use proper plan and your SIM card suitable for modem use.

## GPS using

1. Run Python 3 script `configure_gps.py` to enable GPS output on SIM7600

2. Check that gpsd daemon is not running:
```bash
sudo lsof -i :2947 #find process that uses gpsd port 
sudo lsof | grep ttyU #find process that uses ttyUSB
```

3. One can disable startup service configuration for the `gpsd` on Raspberry Pi by
```bash
sudo update-rc.d gpsd disable #disable boot service
```
Reboot is needed after changing configuration.

4. Run `gpsd` daemon with custom configuration. Please also check this [guide](https://www.lammertbies.nl/comm/info/gps-time)
```bash
sudo gpsd -n -N -D9 -F /dev/ttyUSB1
```
This command prints debug output that you can check for possible errors. It uses standart input for PPS signal, but you can change it by 
```bash
sudo gpsd -n -G -N -D9 -F /var/run/gpsd.sock /dev/ttyUSB1 /dev/pps0
``` 
and add this lines to `/DietPi/settings.txt` file (not tested yet):
```bash
dtoverlay=pps-gpio,gpiopin=18 tp 
```
where GPIO18 - Raspberry Pi pin for PPS signal.
You can test PPS by command
```bash
sudo ppstest /dev/pps0 #(require packet pps-tools)
```
5. View GPS information by
```bash
gpsmon /dev/ttyUSB1  # view GPS
```
