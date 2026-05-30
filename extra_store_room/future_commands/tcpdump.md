# Network Sniffing with tcpdump

## Sniff your device network and SMS traffic via Wireshark on your PC
```
adb shell su -c tcpdump -nn -i wlan0 -U -s0 -w - 'not port 5555' | wireshark -k -i -
```

```
adb exec-out "su -c tcpdump -i any -U -w - 2>/dev/null" | wireshark -k -S -i -
```
