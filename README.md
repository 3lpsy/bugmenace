# Bug Menace: A Bug Bounty Packer Build

Note: As this project has aged, I am mostly just using it for a semi-custom kali vagrant box with libvirt. For this purpose it works (as of this edit), but I've omitted to custom tool provisioning. 

This project contains two packer builds (targeting AWS and libvirt/qemu) for a Bug Bounty enumeration and attack server. You can build either for the cloud, locally, or both. It's basically just ubuntu/kali light + some osint tools.

**Note: Packer v1.4.5 may be required to build the local version. v.1.5.1 may cause failures with the libvirt post-processor**

## Purpose

For Bug Hunting, you may wish to have a templated VM in the cloud for each project. Installing tools can take time and may lead to multiple VMs with different states. To avoid this, you can use Hashicorp's Packer to build a template which can be spun up on demand. This project contains a Packer Build for AWS.

![Do you Want to Know More](./im-doing-my-part.png)

## Building the AMI

**Note: running the build will destroy any other AMIs that have the same name. You can increment the "version" variable to create duplicates.**

The AWS build contains an Ubuntu system a bunch of osint/pentesting tools installed. It also comes with a wireguard server (though you do not have to use it).

### Setting the Environment Variables

Copy `env.sh.example` to `env.sh` and set the appropriate variables. Make sure you have an AWS profile that can build EC2s.

### Running the Build

It's very important to use -only=aws if just targeting AWS.

```
$ packer build -only=aws -on-error=ask config.json
```

### Building in a VM

The VM build targets Kali light and builds a vagrant box for Qemu/libvirt. The Kali system comes with the same tools as the Ubuntu system with the addition of some kali defaults. In addition, wireguard is installed on the Kali VM and a template file is created which can be used with the corresponding Ubuntu build. It's not enabled by default and you have to add the correct public and private keys after deployment

```
$ packer build -only=qemu -on-error=ask config.json
```

If you wish to build for a different hypervisor, you will have to port the existing qemu build which may require fiddling with the "boot_command" option and preseed file.

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

### Leebaird's Discover Scripts

Discover scripts are pulled onto the box but not setup as running "update.sh" will delete /opt/recon-ng as well as do other things. If you decide to use discover scripts (/opt/discover), you will want to understand how to reconfigure (and redownload) recon-ng manually as the ubuntu version is too old.

### Seclists

Seclists is on the box under /opt/wordlists but is zipped and needs to be unzipped to be used.

## Other Uses

Don't want to target AWS/qemu? Open an Issue and/or PR a build for your favorite hosting provider or hypervisor.

Hate the cloud? Just steel the provision.tools.sh script (though you may need the provision.sh script as well).

## Are you also using Boucan or just want some Terraform Code?

Boucan now has the option to deploy a Bugmenace server alongside the typically boucan infrastructure. The relevant terraform code can be found here: [Boucan Deploy: bugmenace.tf](https://github.com/3lpsy/boucan-deploy/blob/master/terraform/bugmenace.tf.example)
