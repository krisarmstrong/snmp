--[[
SNMP Interface Status Checker (snmp-interface-status.nse)

Version: 1.0
Author: [Your Name]
Date: 2025

Description:
  This script retrieves the administrative and operational status of network interfaces
  on a target device using SNMP (v1, v2c, or v3). It also fetches interface names (if available).

Features:
  - Supports SNMP v1, v2c, and v3 authentication.
  - Allows user-defined SNMP community strings (default: "public").
  - Allows custom SNMP ports (default: UDP 161).
  - Retrieves interface names (if available via SNMP OID ifDescr).
  - Supports multiple output formats: JSON (default), Plain Text, and XML.
  - Includes verbose logging for debugging.

Usage:
  nmap --script snmp-interface-status.nse -p 161 <target>
  nmap --script snmp-interface-status.nse --script-args="snmpcommunity=private,output=json" -p 161 <target>
  nmap --script snmp-interface-status.nse --script-args="snmpuser=myuser,snmppass=mypassword,snmpauth=SHA,snmppriv=AES,output=xml" -p 161 <target>

License:
  Released under GPL v3 License.
]]

local snmp = require "snmp"
local stdnse = require "stdnse"
local json = require "json"
local nmap = require "nmap"
local xml = require "xml"

-- Define SNMP OIDs
local ifAdminStatusOID = "1.3.6.1.2.1.2.2.1.7" -- OID for interface administrative status
local ifOperStatusOID = "1.3.6.1.2.1.2.2.1.8" -- OID for interface operational status
local ifDescrOID = "1.3.6.1.2.1.2.2.1.2"     -- OID for interface description

-- Helper function to fetch SNMP values
-- @param host: Target host
-- @param community: SNMP community string
-- @param oid: OID to retrieve
-- @param port: SNMP port (default: 161)
-- @param version: SNMP version (default: v2c)
-- @param user, pass, auth, priv: SNMP v3 authentication details
-- @return SNMP walk result or error message
local function fetch_snmp(host, community, oid, port, version, user, pass, auth, priv)
  local result, err
  if version == "3" then
    result, err = snmp.walk(host, user, pass, oid, port, auth, priv)
  else
    result, err = snmp.walk(host, community, oid, port)
  end
  if not result then
    stdnse.debug("SNMP request failed: %s", err)
    return nil, "Error retrieving OID " .. oid .. ": " .. (err or "Unknown error")
  end
  return result
end

-- Function to format output in JSON, plain text, or XML
-- @param data: Table containing SNMP results
-- @param output_type: Output format type ("json", "text", "xml")
-- @return Formatted string output
local function format_output(data, output_type)
  if output_type == "json" then
    return json.encode(data)
  elseif output_type == "xml" then
    return xml.dump_table(data, "interfaces")
  else
    local text_output = "Interface Status:\n"
    for i, v in ipairs(data) do
      text_output = text_output .. string.format("%s - Admin: %s, Oper: %s\n", v.name or "Unknown", v.admin, v.oper)
    end
    return text_output
  end
end

-- Main function executed by Nmap
action = function(host, port)
  local status = {}

  -- Get script arguments
  local community = stdnse.get_script_args("snmpcommunity") or "public"
  local snmp_port = port.number or 161
  local snmp_version = stdnse.get_script_args("snmpversion") or "2c"
  local output_format = stdnse.get_script_args("output") or "json"
  local verbose = stdnse.get_script_args("verbose") or "false"

  -- SNMP v3 parameters
  local snmp_user = stdnse.get_script_args("snmpuser")
  local snmp_pass = stdnse.get_script_args("snmppass")
  local snmp_auth = stdnse.get_script_args("snmpauth") or "MD5"
  local snmp_priv = stdnse.get_script_args("snmppriv") or "AES"

  -- Fetch interface descriptions
  local ifDescr, err1 = fetch_snmp(host, community, ifDescrOID, snmp_port, snmp_version, snmp_user, snmp_pass, snmp_auth, snmp_priv)
  if not ifDescr then
    return stdnse.format_output(false, err1)
  end

  -- Fetch ifAdminStatus
  local ifAdmin, err2 = fetch_snmp(host, community, ifAdminStatusOID, snmp_port, snmp_version, snmp_user, snmp_pass, snmp_auth, snmp_priv)
  if not ifAdmin then
    return stdnse.format_output(false, err2)
  end

  -- Fetch ifOperStatus
  local ifOper, err3 = fetch_snmp(host, community, ifOperStatusOID, snmp_port, snmp_version, snmp_user, snmp_pass, snmp_auth, snmp_priv)
  if not ifOper then
    return stdnse.format_output(false, err3)
  end

  -- Process results
  for i, ifAdminValue in ipairs(ifAdmin) do
    status[i] = {
      name = ifDescr[i] or "Unknown",
      admin = ifAdminValue,
      oper = ifOper[i] or "Unknown"
    }
  end

  -- Output formatted data
  return stdnse.format_output(true, format_output(status, output_format))
end
