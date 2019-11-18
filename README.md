# Bug Menace: A Bug Bounty Packer Build

This project contains the packer build (targeting AWS) for a Bug Bounty enumeration and attack server. It's basically just ubuntu + some osint tools.

**Note: running the build will destroy any other AMIs that have the same name. You can increment the "version" variable to create duplicates.**

## Building the AMI

### Setting the Environment Variables

Copy `env.sh.example` to `env.sh` and set the appropriate variables. Make sure you have an AWS profile that can build EC2s.

### Running the Build

```
$ packer build -on-error=ask config.json
```

### Installed Software

Most installed tools can be found in the /opt folder. Some tools include:

- Zaproxy
- Jason Haddix's all.txt
- SecLists (not unzipped)
- Gobuster
- Amass
- MassDNS
- EyeWitness
- Aquatone
- Dirsearch
- GitRob
- SubFinder
- Arjun
- XSStrike
- WebScreenshot
- Testssl
- Cloudflare
- LazyRecon
- Knock
- lazys3
- bucketeers
- wpscan (not fully installed)
- whatweb
- theHarvester
- Discover (not fully installed)
- Recon-ng
- Goprox
- Nishang
- misc
- other random things (sqlmap, dirb, nikto, etc)

### Leebaird's Discover Scripts

Discover scripts are pulled onto the box but not setup as running "update.sh" will delete /opt/recon-ng as well as do other things. If you decide to use discover scripts (/opt/discover), you will want to understand how to reconfigure (and redowload) recon-ng manually as the ubuntu version is too old.

### Seclists

Seclists is on the box under /opt/wordlists but is zipped and needs to be unzipped to be used.
