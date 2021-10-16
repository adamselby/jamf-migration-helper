#!/bin/bash
# Created by Adam Selby for
# University of North Texas

apiUser="jamfAPIuser"
apiPass='jamfAPIpassword'
prodURL="https://jamf.yourdomain.com"
legacyURL="https://jss.yourdomain.com"

prodCount=$(curl -X GET -s -k -u "$apiUser:$apiPass" $prodURL/JSSResource/mobiledevicegroups/id/1 | xmllint --xpath xmllint --xpath '/mobile_device_group/mobile_devices/size/text()' - )
echo "Production Server currently has $prodCount devices"

legacyCount=$(curl -X GET -s -k -u "$apiUser:$apiPass" $legacyURL/JSSResource/mobiledevicegroups/id/1 | xmllint --xpath xmllint --xpath '/mobile_device_group/mobile_devices/size/text()' - )
echo "Legacy server currently has $legacyCount devices"

echo "…downloading list of all devices enrolled with new production server…"
ids+=($(curl -X GET -s -k -u "$apiUser:$apiPass" "$prodURL/JSSResource/mobiledevices" | xmllint --format - | awk -F'>|<' '/<id>/{print $3}' | sort -n))

for id in "${ids[@]}"; do
    serial=$(curl -X GET -s -k -u "$apiUser:$apiPass" "$prodURL/JSSResource/mobiledevices/id/$id" | xmllint --xpath xmllint --xpath '/mobile_device/general/serial_number/text()' - )
    if [[ -n "$serial" ]]; then
        echo "Found iPad with serial: $serial, attempting to delete from legacy server…"
        result=$(curl -X DELETE -s -k -f -u "$apiUser:$apiPass" "$legacyURL/JSSResource/mobiledevices/serialnumber/$serial" | sed 's/<?xml version="1.0" encoding="UTF-8"?><mobile_device><id>\|//' | sed 's/<\/id><\/mobile_device>\|//')
    else
        echo "Can't get serial for ID $id, waiting…"
        sleep 1
    fi
done

echo "…completed all deletions…"

updatedLegacyCount=$(curl -X GET -s -k -u "$apiUser:$apiPass" $legacyURL/JSSResource/mobiledevicegroups/id/1 | xmllint --xpath xmllint --xpath '/mobile_device_group/mobile_devices/size/text()' - )
echo "Legacy server now has $updatedLegacyCount devices"

exit 0
