**sitemap.xml**

> "...allows a webmaster to inform search engines about URLs on a website that are available for crawling. A Sitemap is an XML file that lists the URLs for a site. It allows webmasters to include additional information about each URL: when it was last updated, how often it changes, and how important it is in relation to other URLs of the site. This allows search engines to crawl the site more efficiently and to find URLs that may be isolated from the rest of the site's content."

**robots.txt**

A file that list the pages that the site admin don't want crawlers to access.

**Insecure Direct Object Reference (IDOR)**

> Insecure direct object references (IDOR) are a type of access control vulnerability that arises when an application uses user-supplied input to access objects directly.

Say you should only have accesss to https://store.tryhackme.thm/customers/user?id=16 to edit your user profile, but then you can edit other people's profile by just changing the id in the URL.

Another example is when a web site will let users retrieve static files that are located on the server-side filesystem. Say we can visit the URL https://insecure-website.com/static/12144.txt, then we might just try other URL paths and maybe find sensitive information.

**gobuster**

A tool to check if a web site responds to a set of URL paths taken from a wordlist.

**netcat**

**socat**

**Metasploit**

multi/hanlder:

**Msfvenom**

**Reverse shell**

Reverse shells are when the target is forced to execute code that connects back to your computer. On your own computer you would set up a listener which would be used to receive the connection. Reverse shells are a good way to bypass firewall rules that may prevent you from connecting to arbitrary ports on the target.

To set up a listener:
```sh
nc -lvnp <port number>
```

It's often a good idea to use a well-known port number (80, 443 or 53 being good choices) as this is more likely to get past outbound firewall rules on the target.

**Bind shell**

Bind shells are when the code executed on the target is used to start a listener attached to a shell directly on the target. This would then be opened up to the internet, meaning you can connect to the port that the code has opened and obtain remote code execution that way.

Connecting to a listener:
```sh
nc <target-ip> <chosen-port>
```

# Links
Reverse shell cheat sheet:

* https://web.archive.org/web/20200901140719/http://pentestmonkey.net/cheat-sheet/shells/reverse-shell-cheat-sheet

* https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Reverse%20Shell%20Cheatsheet.md

SecLists: https://github.com/danielmiessler/SecLists

CTF Time: https://ctftime.org/

Hack The Box: https://www.hackthebox.com/

Try Hack Me: https://tryhackme.com/
