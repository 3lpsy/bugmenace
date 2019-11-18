# Bug Menace: A Bug Bounty Packer Build

This project contains the packer build (targeting AWS) for a Bug Bounty enumeration and attack server. It's basically just ubuntu + some osint tools.

## Purpose

For Bug Hunting, you may wish to have a templated VM in the cloud for each project. Installing tools can take time and may lead to multiple VMs with different states. To avoid this, you can use Hashicorp's Packer to build a template which can be spun up on demand. This project contains a Packer Build for AWS.

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
- other random things (sqlmap, dirb, nikto, etc)

### Leebaird's Discover Scripts

Discover scripts are pulled onto the box but not setup as running "update.sh" will delete /opt/recon-ng as well as do other things. If you decide to use discover scripts (/opt/discover), you will want to understand how to reconfigure (and redowload) recon-ng manually as the ubuntu version is too old.

### Seclists

Seclists is on the box under /opt/wordlists but is zipped and needs to be unzipped to be used.

## Other Uses

Don't want to target AWS? Open an Issue and/or PR a build for your favorite hosting provider.

Hate the cloud? Just steel the provision.install.sh script (though you may need the provision.sh script as well).

## Are you also using Boucan or just want some Terraform Code?

You can add the following to the boucan-deploy/terraform directory to add a second vm (bugmenace) to your deployment. This is mostly just for me to reference later.

```
variable "bugmenace_ami" {
  default = "THE_AMI_CREATED_BY_PACKER"
}

resource "aws_instance" "bugmenace" {
  ami                         = var.bugmenace_ami
  instance_type               = "t2.medium"
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.main.id]
  key_name                    = aws_key_pair.main.key_name
  associate_public_ip_address = true
  root_block_device {
    volume_size = 16
  }
  tags = {
    Name = "bugmenace-server"
  }
}

resource "aws_route53_record" "a_menace" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "menace.${var.dns_root}"
  type    = "A"
  ttl     = "5"
  records = [aws_instance.bugmenace.public_ip]
}

output "bugmenace_domain" {
  value = "menace.${var.dns_root}"
}

output "bugmenace_ssh_command" {
  value = "ssh -i data/key.pem ubuntu@${aws_instance.bugmenace.public_ip}"
}

```
