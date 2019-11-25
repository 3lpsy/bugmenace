# Bug Menace: A Bug Bounty Packer Build

This project contains the packer build (targeting AWS) for a Bug Bounty enumeration and attack server. It's basically just ubuntu + some osint tools.

## Purpose

For Bug Hunting, you may wish to have a templated VM in the cloud for each project. Installing tools can take time and may lead to multiple VMs with different states. To avoid this, you can use Hashicorp's Packer to build a template which can be spun up on demand. This project contains a Packer Build for AWS.

### In a VM

I actually run a Kali VM that connects to the Bugmenace server via Wireguard. The provision.install.sh script should work for both operating systems such that you will have similar tools on both your VM (client) and BugMenace (server). You will need to copy the /etc/wireguard/peerprivkey from BugMenace if you wish to connect the local instance to the Wireguard service. You also may want to regenerate the wireguard key pairs.

You can find the version to build a local kali under "kali-bounty" VM here: (VM-Builds)[https://github.com/3lpsy/vm-builds/]. Right now to only targets libvirt/qemu but PRs are welcome. The primary provisioning script is nearly identical but sometimes lags behind this one. You do not need the local kali version to utlize the Bugmenace and can ignore this if you want to just test from the Bugmenace instance in the cloud.

![Do you Want to Know More](./im-doing-my-part.png)

## Building the AMI

**Note: running the build will destroy any other AMIs that have the same name. You can increment the "version" variable to create duplicates.**

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
- assetfinder
- meg
- gf
- gron
- waybackurls
- httprobe
- qsreplace
- concurl
- unfurl
- ssrfmap
- fresh.py
- ssrf-sheriff
- ffuf
- interlace
- gitleaks
- other random things (sqlmap, dirb, nikto, etc)

### Wireguard

A Wireguard VPN will also be installed that listens on port 36283. Comment out the "provision.wireguard.sh" line in config.json if this is unintersting to you.

### Leebaird's Discover Scripts

Discover scripts are pulled onto the box but not setup as running "update.sh" will delete /opt/recon-ng as well as do other things. If you decide to use discover scripts (/opt/discover), you will want to understand how to reconfigure (and redownload) recon-ng manually as the ubuntu version is too old.

### Seclists

Seclists is on the box under /opt/wordlists but is zipped and needs to be unzipped to be used.

## Other Uses

Don't want to target AWS? Open an Issue and/or PR a build for your favorite hosting provider.

Hate the cloud? Just steel the provision.install.sh script (though you may need the provision.sh script as well).

## Are you also using Boucan or just want some Terraform Code?

Boucan now has the option to deploy a Bugmenace server alongside the typically boucan infrastructure. The relevant terraform code can be found here: (Boucan Deploy: bugmenace.tf)[https://github.com/3lpsy/boucan-deploy/blob/master/terraform/bugmenace.tf.example]
