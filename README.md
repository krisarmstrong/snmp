# SNMP Interface Status Checker

## Overview
This script (`snmp-interface-status.nse`) is an Nmap Scripting Engine (NSE) script designed to retrieve the administrative and operational status of network interfaces on a target device using SNMP (v1, v2c, or v3). It also fetches interface names when available.

## Features
- **Supports SNMP v1, v2c, and v3 authentication**
- **Allows user-defined SNMP community strings** (default: `public`)
- **Allows custom SNMP ports** (default: `161`)
- **Retrieves interface names** (if available via SNMP OID `ifDescr`)
- **Supports multiple output formats:** JSON (default), Plain Text, and XML
- **Includes verbose logging** for debugging

## Usage
### Basic SNMP v1/v2c Scan
```sh
nmap --script snmp-interface-status.nse -p 161 <target>
```
_Defaults to SNMP v2c with the `public` community._

### Custom SNMP Community String
```sh
nmap --script snmp-interface-status.nse --script-args="snmpcommunity=private" -p 161 <target>
```
_Uses `private` as the SNMP community._

### SNMP v3 Authentication
```sh
nmap --script snmp-interface-status.nse -p 161 <target> \
--script-args="snmpuser=myuser,snmppass=mypassword,snmpauth=SHA,snmppriv=AES"
```
_Uses SNMP v3 authentication with username, password, authentication, and encryption settings._

### Specify Output Format (JSON, Plain Text, XML)
```sh
nmap --script snmp-interface-status.nse --script-args="output=xml" -p 161 <target>
```
_Defaults to JSON if not specified._

### Enable Verbose Debugging
```sh
nmap --script snmp-interface-status.nse --script-args="verbose=true" -p 161 <target>
```
_Logs additional SNMP debugging information._

## Sample Output
### JSON Output
```json
{
  "1": { "name": "eth0", "admin": "1", "oper": "1" },
  "2": { "name": "eth1", "admin": "1", "oper": "2" },
  "3": { "name": "lo", "admin": "2", "oper": "2" }
}
```
### Plain Text Output
```
Interface Status:
eth0 - Admin: 1, Oper: 1
eth1 - Admin: 1, Oper: 2
lo - Admin: 2, Oper: 2
```
### XML Output
```xml
<interfaces>
  <interface>
    <name>eth0</name>
    <admin>1</admin>
    <oper>1</oper>
  </interface>
  <interface>
    <name>eth1</name>
    <admin>1</admin>
    <oper>2</oper>
  </interface>
</interfaces>
```

## Explanation of Status Codes
| Value | **Admin Status** (ifAdminStatus) | **Operational Status** (ifOperStatus) |
|--------|----------------------------------|----------------------------------|
| 1 | **Up** | **Up** |
| 2 | **Down** | **Down** |
| 3 | **Testing** | **Testing** |
| 4 | N/A | **Unknown** |
| 5 | N/A | **Dormant** |
| 6 | N/A | **Not Present** |
| 7 | N/A | **Lower Layer Down** |

## Requirements
- **Nmap 7.80+** (Supports latest SNMP NSE features)
- **Target device must support SNMP**

## Notes
- **Ensure SNMP is enabled on the target** before running this script.
- SNMP v3 requires correct authentication settings to function.

## License
This script is released under the **GPL v3 License**.

## Author
Developed by **[Your Name]**, 2025.
