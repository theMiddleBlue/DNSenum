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


