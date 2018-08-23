# DNSenum
DNSenum is a Bash script for DNS Enumeration. Try to resolve all subdomains of a given domain name.

## Usage
```bash
+
+ Usage: ./dnsenum.sh -d <domain> [-f <file] [-n <dns server>] [-c]
+
+ -d <domain>       Domain name to test
+ -f <file>         Subdomain list file to use for test
+ -n <dns server>   DNS Server to use for query
+ -c                Check for HTTP Server banner
+ -v                Check Domain on VirusTotal
+ -s                Set Shodan API Key in order to query it
+ -r <result>       Show only result that match <result>
+
```

## Example
```bash
# ./dnsenum.sh -d iol.it -c

+
+ Dns Enumeration for domain iol.it
+
                 www | CNAME      | www.italiaonline.it.           | CloudFront
                mail | CNAME      | mail.libero.it.                |           
                 ftp | CNAME      | merope.iol.it.                 |           
             webmail | CNAME      | webmail.libero.it.             | Apache
                smtp | A          | 212.48.24.42                   |           
                 pop | CNAME      | popimap.iol.it.                |           
        autodiscover | A          | 212.48.24.27                   |           
          autoconfig | CNAME      | autoconfig.libero.it.          | Apache/2.2.15 (CentOS)
                pop3 | CNAME      | popimap.iol.it.                |           
                imap | CNAME      | popimap.iol.it.                |           
                www1 | CNAME      | nacho2000.iol.it.              |           
Trying www.blog ...
```

Example using `-v` that check the domain on VirusTotal
```bash
# ./dnsenum.sh -d waf.red -v

+
+ Dns Enumeration for domain waf.red
+ Check URL on VirusTotal
+

+
+ Querying VirusTotal...
+ Result from VirusTotal:
+
                blog | CNAME      | node1.waf.red.                 |           
+
+ End Results from VirusTotal.
+

+
+ Start enumeration from file...
+
             waf.red | A          | 188.166.133.184                |           
                 www | A          | 188.166.133.184                |           
                blog | CNAME      | node1.waf.red.                 |
trying www2...
```

[Example video](https://github.com/GrayHats/DNSenum/raw/master/2018-08-23%2011.33.33.mp4)
