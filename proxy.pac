// This proxy will redirect request to *.local to your localhost.
// This is useful when setting up passenger for rails apps, you can simply 
// use projectname.local for each project and not have to edit your hosts file.
// This is also useful when needing subdomains in your rails apps, as they will 
// automatically proxy the request to localhost.

// To install for Firefox:
//   Preferences => Advanced => Network => Settings
//   Choose "Automatic proxy configuration url"
//   In the text box, enter the path to this file (eg. "file:///Users/mvanholstyn/mhs/mhs/tidbits/proxy.pac")

// To install for Safari:
//   System Preferences => Network => Airport => Advanced => Proxies
//   Choose "Using a PAC file"
//   In the text box, navigate to or enter the path to this file (eg. "file:///Users/mvanholstyn/mhs/mhs/tidbits/proxy.pac")

function FindProxyForURL(url, host) {
  if (shExpMatch(url,"*.local/*")) {
    return "PROXY localhost";
  }
  return "DIRECT";
}