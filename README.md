# CrazyXSS

This little script tries to collect all subdomains of a target domain by using archive.org, subfinder and gau.

After collecting the subdomains it tries to look for parameters in which a Reflected XSS can be injected.

The idea is to gather the information received in the BurpSuite intruder and thus try to get Reflected XSS.
