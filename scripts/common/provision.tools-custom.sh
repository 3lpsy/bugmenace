#!/bin/bash

set -e;

if [  -n "$(uname -a | grep -i ubuntu)" ]; then 
    SUDOER="ubuntu"
else
    SUDOER="vagrant"
fi

TOOL_DIR=${TOOL_DIR:-/opt}
SECLISTS_VER="2019.4"
GOBUSTER_VER="v3.0.1"
AMASS_VER="v3.4.2"
AMASS_NAME="amass_${AMASS_VER}_linux_amd64"
AQUATONE_VER="1.7.0"

export DEBIAN_FRONTEND=noninteractive;

echo "Starting Custom installs";


# Put apps here to be installed

echo "Installing some programs"
sudo apt-get install -y masscan nikto whois wfuzz sqlmap cewl;


if [ -n "$(uname -a | grep -i ubuntu)" ]; then 

    echo "Performing Ubuntu Specific setup..."
    sudo apt-get install -y snapd
        # manually add 1.13
    sudo wget https://dl.google.com/go/go1.13.3.linux-amd64.tar.gz -O /tmp/golang.tar.gz;
    cd /tmp/;
    sudo tar -xvzf /tmp/golang.tar.gz
    sudo mv go /usr/local/go;
    export GOROOT=/usr/local/go
    export GOPATH=/root/.go; 
    export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
    GO="GOROOT=/usr/local/go GOPATH=/root/.go PATH=$GOPATH/bin:$GOROOT/bin:$PATH /usr/local/go/bin/go"
    echo 'export GOROOT=/usr/local/go' | sudo tee -a /root/.bashrc;
    echo 'export GOPATH=/root/.go' | sudo tee -a /root/.bashrc;
    echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' | sudo tee -a /root/.bashrc;

    if [[ -d /home/$SUDOER ]]; then 
        echo 'export GOROOT=/usr/local/go' | sudo tee -a /home/$SUDOER/.bashrc;
        echo "export GOPATH=/home/${SUDOER}/.go" | sudo tee -a /home/$SUDOER/.bashrc;
        echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' | sudo tee -a /home/$SUDOER/.bashrc;
        sudo chown  ${SUDOER}:${SUDOER} /home/${SUDOER}/.bashrc
    fi
    # due this later
    # echo "Setting up: Zaproxy";
    # sudo snap install zaproxy --classic
    echo "Installing: eyewitness + Aquatone Dependencies";
    sudo apt-get install -y firefox chromium-browser xvfb
    # these don't exist in kali, helps with discover scripts
    sudo apt-get install -y python-pyftpdlib python3-pyftpdlib
else
    echo "Performing Kali Specific setup..."
    echo "Installing: eyewitness + Aquatone Dependencies";
    sudo apt-get install -y golang zaproxy;
    sudo apt-get install -y firefox-esr chromium xvfb;
    GO="go"
fi


echo "Installing some python stuff and ruby stuff"

sudo apt-get install -y python3-fuzzywuzzy python-fuzzywuzzy python-requests python3-requests python3-urllib3 python-urllib3 python-whois python3-whois python-texttable python3-texttable python-dnspython python3-dnspython ruby-dev;

# pro gamer move, for xsstrike
sudo -H pip3 install tld

## Discover Scripts Dependencies
echo "Installing Discover Scripts dependencies";
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y dnsrecon libjpeg-dev zlib1g-dev python-pil python3-lxml python-lxml python3-pil

## RECON 

## All.txt
if [ ! -d ${TOOL_DIR}/wordlists ]; then 
    echo "Setting up: all.txt";
    sudo mkdir ${TOOL_DIR}/wordlists;
    sudo wget https://gist.github.com/jhaddix/f64c97d0863a78454e44c2f7119c2a6a/raw/96f4e51d96b2203f19f6381c8c545b278eaa0837/all.txt -O ${TOOL_DIR}/wordlists/all.txt;

    sudo git clone https://github.com/minimaxir/big-list-of-naughty-strings.git ${TOOL_DIR}/wordlists/naughtystrings

    # sudo rm -rf /tmp/seclists || true;
    # sudo mkdir /tmp/seclists;
    sudo wget https://github.com/danielmiessler/SecLists/archive/$SECLISTS_VER.zip -O ${TOOL_DIR}/wordlists/seclists.zip;
    # sudo unzip -o -d /tmp/seclists /tmp/seclists/seclists.zip;
    # sudo mv "/tmp/seclists/SecLists-${SECLISTS_VER}" /opt/wordlists/seclists
    # sudo rm -rf /tmp/seclists;
fi

if [ ! -d ${TOOL_DIR}/payloads ]; then 
    sudo mkdir ${TOOL_DIR}/payloads;
    sudo git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git ${TOOL_DIR}/payloads/PayloadsAllTheThings;
    cd ${TOOL_DIR};
fi 

## Gobuster Source
if [ ! -d ${TOOL_DIR}/gobuster ]; then 
    echo "Setting up: Gobuster";
    sudo git clone https://github.com/OJ/gobuster.git ${TOOL_DIR}/gobuster;
    ## Amass Binary
    sudo rm -rf /tmp/gobuster || true; 
    sudo mkdir /tmp/gobuster;
    sudo wget https://github.com/OJ/gobuster/releases/download/$GOBUSTER_VER/gobuster-linux-amd64.7z -O /tmp/gobuster/gobuster.7z;
    cd /tmp/gobuster;
    sudo 7z x gobuster.7z
    sudo mv gobuster-linux-amd64/gobuster /usr/local/bin/gobuster;
    cd -;
    sudo chmod +x /usr/local/bin/gobuster;
    sudo rm -rf /tmp/gobuster;
    cd ${TOOL_DIR};
fi

## Ffuf Source
if [ ! -d ${TOOL_DIR}/ffuf ]; then 
    echo "Setting up: ffuf";
    sudo git clone https://github.com/ffuf/ffuf.git ${TOOL_DIR}/ffuf;
    cd ${TOOL_DIR}/ffuf;
    sudo $GO get github.com/ffuf/ffuf;
    sudo $GO build
    sudo chmod +x ${TOOL_DIR}/ffuf/ffuf;
    sudo ln -s ${TOOL_DIR}/ffuf/ffuf /usr/local/bin/ffuf
    cd ${TOOL_DIR};
fi

## Amass Source
if [ ! -d ${TOOL_DIR}/amass ]; then 
    echo "Setting up: Amass";
    sudo git clone https://github.com/OWASP/Amass.git ${TOOL_DIR}/amass;
    ## Amass Binary
    sudo rm -rf /tmp/amass || true; 
    sudo mkdir /tmp/amass;
    sudo wget https://github.com/OWASP/Amass/releases/download/${AMASS_VER}/$AMASS_NAME.zip -O /tmp/amass/amass.zip;
    sudo unzip -o -d /tmp/amass /tmp/amass/amass.zip;
    sudo mv /tmp/amass/${AMASS_NAME}/amass /usr/local/bin/;
    sudo rm -rf /tmp/amass;
    cd ${TOOL_DIR};
fi

## MassDNS Source
if [ ! -d ${TOOL_DIR}/massdns ]; then 
    echo "Setting up: MassDNS";
    sudo git clone https://github.com/blechschmidt/massdns.git ${TOOL_DIR}/massdns;
    ## MassDNS Binary
    cd ${TOOL_DIR}/massdns;
    sudo make
    sudo chmod +x ${TOOL_DIR}/massdns/bin/massdns;
    sudo cp ${TOOL_DIR}/massdns/bin/massdns /usr/local/bin/
    cd ${TOOL_DIR};

fi


## EyeWitness Source
if [ ! -d ${TOOL_DIR}/EyeWitness ]; then 
    echo "Setting up: EyeWitness";
    sudo git clone https://github.com/FortyNorthSecurity/EyeWitness.git ${TOOL_DIR}/EyeWitness;
    ## EyeWitness Binary
    sudo bash ${TOOL_DIR}/EyeWitness/setup/setup.sh;
    sudo chmod +x ${TOOL_DIR}/EyeWitness/EyeWitness.py
    sudo ln -s ${TOOL_DIR}/EyeWitness/EyeWitness.py /usr/local/bin/eyewitness;
    cd ${TOOL_DIR};
fi

## Aquatone Source
if [ ! -d ${TOOL_DIR}/aquatone ]; then 
    echo "Setting up: Aquatone";
    sudo git clone https://github.com/michenriksen/aquatone.git ${TOOL_DIR}/aquatone;
    ## Aquatone Binary
    sudo rm -rf /tmp/aquatone || true;
    sudo mkdir /tmp/aquatone;
    sudo wget https://github.com/michenriksen/aquatone/releases/download/v${AQUATONE_VER}/aquatone_linux_amd64_${AQUATONE_VER}.zip -O /tmp/aquatone/aquatone.zip;
    sudo unzip -o -d /tmp/aquatone /tmp/aquatone/aquatone.zip
    sudo mv /tmp/aquatone/aquatone /usr/local/bin/
    sudo rm -rf /tmp/aquatone;
    cd ${TOOL_DIR};
fi

## Dirsearch Source
if [ ! -d ${TOOL_DIR}/dirsearch ]; then 
    echo "Setting up: Dirsearch";
    sudo git clone https://github.com/maurosoria/dirsearch.git ${TOOL_DIR}/dirsearch;
    ## DirSearch Binary
    sudo ln -s ${TOOL_DIR}/dirsearch/dirsearch.py /usr/local/bin/dirsearch;
    cd ${TOOL_DIR};
fi

## GitRob Source
if [ ! -d ${TOOL_DIR}/gitrob ]; then 
    echo "Setting up: GitRob";
    sudo git clone https://github.com/michenriksen/gitrob.git ${TOOL_DIR}/gitrob;
    ## GitRob Binary 
    sudo rm -rf /tmp/gitrob || true;
    sudo mkdir /tmp/gitrob;
    sudo wget https://github.com/michenriksen/gitrob/releases/download/v2.0.0-beta/gitrob_linux_amd64_2.0.0-beta.zip -O /tmp/gitrob/gitrobbeta.zip; 
    sudo unzip -o -d /tmp/gitrob /tmp/gitrob/gitrobbeta.zip
    sudo mv /tmp/gitrob/gitrob /usr/local/bin/gitrobbeta;
    sudo rm -rf /tmp/gitrob;
    cd ${TOOL_DIR};
fi

## SubFinder Source
if [ ! -d ${TOOL_DIR}/subfinder ]; then 
    echo "Setting up: SubFinder";
    sudo git clone https://github.com/projectdiscovery/subfinder.git ${TOOL_DIR}/subfinder;
    cd ${TOOL_DIR}/subfinder/cmd/subfinder;
    ## SubFinder Binary (Releases too old)
    sudo $GO get -v github.com/projectdiscovery/subfinder/cmd/subfinder
    sudo $GO build;
    sudo chmod +x subfinder;
    sudo ln -s ${TOOL_DIR}/subfinder/subfinder /usr/local/bin/subfinder;
    cd ${TOOL_DIR};
fi

function tomnomnom_install() {
    tool="$1"
    if [ ! -d "${TOOL_DIR}/$tool" ]; then
        echo "Setting up: $1"
        sudo git clone https://github.com/tomnomnom/$tool.git ${TOOL_DIR}/$tool;
        cd ${TOOL_DIR}/$tool;
        sudo $GO get -u github.com/tomnomnom/$tool;
        sudo $GO build;
        sudo chmod +x $tool;
        sudo ln -s ${TOOL_DIR}/$tool/$tool /usr/local/bin/$tool;
        cd ${TOOL_DIR};
    fi
}

tomnomnom_install assetfinder
tomnomnom_install meg
tomnomnom_install gf


echo "Setting up: Sourcing gf examples for root"
sudo cp -R ${TOOL_DIR}/gf/examples /root/.gf;

echo "Setting up: Copying gf examples for root"
echo "source ${TOOL_DIR}/gf/gf-completion.bash" | sudo tee -a /root/.bashrc

if [[ -d /home/${SUDOER} ]]; then 
    echo "Setting up: Copying gf examples for $SUDOER"
    sudo cp -R ${TOOL_DIR}/gf/examples /home/$SUDOER/.gf;
    sudo chown -R ${SUDOER}:${SUDOER} /home/$SUDOER/.gf;

    echo "Setting up: Sourcing gf examples for $SUDOER"
    echo "source ${TOOL_DIR}/gf/gf-completion.bash" | sudo tee -a /home/$SUDOER/.bashrc
    sudo chown -R ${SUDOER}:${SUDOER} /home/$SUDOER/.bashrc;
fi

tomnomnom_install gron
tomnomnom_install waybackurls
tomnomnom_install httprobe
tomnomnom_install qsreplace
tomnomnom_install concurl
tomnomnom_install unfurl

## Arjun
if [ ! -d ${TOOL_DIR}/arjun ]; then 
    echo "Setting up: Arjun";
    sudo git clone https://github.com/s0md3v/Arjun.git ${TOOL_DIR}/arjun;
    sudo chmod +x ${TOOL_DIR}/arjun/arjun.py
    sudo ln -s ${TOOL_DIR}/arjun/arjun.py /usr/local/bin/arjun.py;
    cd ${TOOL_DIR};
fi

## Xsstrike
if [ ! -d ${TOOL_DIR}/xsstrike ]; then 
    echo "Setting up: XSStrike";
    sudo git clone https://github.com/s0md3v/XSStrike.git ${TOOL_DIR}/xsstrike;
    sudo chmod +x ${TOOL_DIR}/xsstrike/xsstrike.py 
    sudo ln -s ${TOOL_DIR}/xsstrike/xsstrike.py /usr/local/bin/xsstrike.py;
    cd ${TOOL_DIR};
fi

if [ ! -d ${TOOL_DIR}/webscreenshot ]; then 
    echo "Setting up: WebScreenshot";
    sudo git clone https://github.com/maaaaz/webscreenshot.git ${TOOL_DIR}/webscreenshot;
    sudo ln -s ${TOOL_DIR}/webscreenshot/webscreenshot.py /usr/local/bin/webscreenshot.py;
    cd ${TOOL_DIR};
fi

## Testssl
if [ ! -d ${TOOL_DIR}/testssl ]; then 
    echo "Setting up: Testssl";
    sudo git clone https://github.com/drwetter/testssl.sh.git ${TOOL_DIR}/testssl;
    sudo ln -s ${TOOL_DIR}/testssl/testssl.sh /usr/local/bin/testssl.sh;
    cd ${TOOL_DIR};
fi


## Cloudflare Enum
if [ ! -d ${TOOL_DIR}/cloudflare_enum ]; then 
    echo "Setting up: Cloudflare Enum";
    sudo git clone https://github.com/mandatoryprogrammer/cloudflare_enum.git ${TOOL_DIR}/cloudflare_enum;
    sudo chmod +x ${TOOL_DIR}/cloudflare_enum/cloudflare_enum.py
    sudo ln -s ${TOOL_DIR}/cloudflare_enum/cloudflare_enum.py /usr/local/bin/cloudflare_enum.py;
    cd ${TOOL_DIR};
fi

if [ ! -d ${TOOL_DIR}/lazyrecon ]; then 
    echo "Setting up: LazyRecon";
    sudo git clone https://github.com/nahamsec/LazyRecon.git ${TOOL_DIR}/lazyrecon;
    sudo chmod +x ${TOOL_DIR}/lazyrecon/lazyrecon.sh
    sudo ln -s ${TOOL_DIR}/lazyrecon/lazyrecon.sh /usr/local/bin/lazyrecon.sh;
    cd ${TOOL_DIR};
fi

if [ ! -d ${TOOL_DIR}/knock ]; then 
    echo "Setting up: Knock";
    sudo git clone https://github.com/guelfoweb/knock.git ${TOOL_DIR}/knock;
    cd ${TOOL_DIR}/knock;
    sudo pip install . || echo "Failed to install knock";
    # knock uses setup.py
    cd ${TOOL_DIR};
fi

if [ ! -d ${TOOL_DIR}/lazys3 ]; then 
    echo "Setting up: lazys3";
    sudo git clone https://github.com/nahamsec/lazys3.git ${TOOL_DIR}/lazys3;
    sudo chmod +x ${TOOL_DIR}/lazys3/lazys3.rb
    sudo ln -s ${TOOL_DIR}/lazys3/lazys3.rb /usr/local/bin/lazys3.rb;
    cd ${TOOL_DIR};
fi

if [ ! -d ${TOOL_DIR}/bucketeers ]; then 
    echo "Setting up: bucketeers";
    sudo git clone https://github.com/tomdev/teh_s3_bucketeers.git ${TOOL_DIR}/bucketeers;
    sudo chmod +x ${TOOL_DIR}/bucketeers/bucketeer.sh
    sudo ln -s ${TOOL_DIR}/bucketeers/bucketeer.sh /usr/local/bin/bucketeer.sh;
    cd ${TOOL_DIR};
fi

if [ ! -d ${TOOL_DIR}/wpscan ]; then 
    echo "Setting up: wpscan";
    sudo git clone https://github.com/wpscanteam/wpscan.git ${TOOL_DIR}/wpscan;
    cd ${TOOL_DIR}/wpscan;
    # sudo chown -R $SUDOER:$SUDOER ${TOOL_DIR}/wpscan
    # sudo gem install bundler ffi nokogiri;
    # sudo chown -R $SUDOER:$SUDOER /home/$SUDOER/.*
    # sudo su - $SUDOER -c "cd ${TOOL_DIR}/wpscan && bundle install --without test" || echo "Error installing wpscan..."
    cd ${TOOL_DIR};
fi


## WhatWeb
if [ ! -d ${TOOL_DIR}/whatweb ]; then 
    echo "Setting up: whatweb";
    sudo git clone https://github.com/urbanadventurer/WhatWeb.git ${TOOL_DIR}/whatweb;
    sudo chmod +x ${TOOL_DIR}/whatweb/whatweb
    sudo ln -s ${TOOL_DIR}/whatweb/whatweb /usr/local/bin/whatweb;
    cd ${TOOL_DIR};
fi

if [ ! -d ${TOOL_DIR}/theHarvester ]; then 
    echo "Setting up: theHarvester";
    sudo git clone https://github.com/laramies/theHarvester.git ${TOOL_DIR}/theHarvester;
    sudo chmod +x ${TOOL_DIR}/theHarvester/theHarvester
    sudo python3.7 -m venv ${TOOL_DIR}/theHarvester/.venv;
    sudo -H bash -c "source ${TOOL_DIR}/theHarvester/.venv/bin/activate && pip install -r ${TOOL_DIR}/theHarvester/requirements.txt" || true;
    echo '#!/bin/bash' | sudo tee /usr/local/bin/theHarvester;
    echo "source ${TOOL_DIR}/theHarvester/.venv/bin/activate" | sudo tee -a /usr/local/bin/theHarvester;
    echo "python ${TOOL_DIR}/theHarvester/theHarvester.py" | sudo tee -a /usr/local/bin/theHarvester;
    sudo chmod +x /usr/local/bin/theHarvester;
    cd ${TOOL_DIR};
fi



# Discover Scripts Source
# Discover Scripts are difficult, maybe another time
if [ ! -d /opt/discover ]; then 
    sudo mkdir /root/.recon-ng
    if [[ -d /home/${SUDOER} ]]; then 
        sudo mkdir /home/$SUDOER/.recon-ng
        sudo chown ${SUDOER}:${SUDOER} /home/$SUDOER/.recon-ng
    fi
    echo "Setting up: Discover Scripts";
    sudo git clone https://github.com/leebaird/discover.git /opt/discover;
    echo "Not installing discover scripts"
    # cd /opt/discover;
    # ## Discover Scripts Needs Egress-Assess Preinstalled for Non-interactive
    # echo "Setting up: Egress-Assess (on behalf of discover scripts)"
    # sudo git clone https://github.com/ChrisTruncer/Egress-Assess.git /opt/Egress-Assess;
    # printf "\n\n\n\n\n\n\n" | sudo -H /opt/Egress-Assess/setup/setup.sh
    # sudo mv server.pem ../Egress-Assess/
    # sudo rm impacket*
    # ## Discover Scripts Install
    # sudo -H DEBIAN_FRONTEND=noninteractive ./update.sh || echo "Discover scripts had issues. Continueing"
    cd ${TOOL_DIR};
fi

# 
if [ ! -d ${TOOL_DIR}/recon-ng ]; then 
    echo "Setting up: Recon-ng"
    sudo git clone https://github.com/lanmaster53/recon-ng.git ${TOOL_DIR}/recon-ng;
    sudo -H pip3 install -r ${TOOL_DIR}/recon-ng/REQUIREMENTS;
    sudo chmod +x ${TOOL_DIR}/recon-ng/recon-ng;
    sudo chmod +x ${TOOL_DIR}/recon-ng/recon-cli;
    sudo chmod +x ${TOOL_DIR}/recon-ng/recon-web;
    sudo ln -s ${TOOL_DIR}/recon-ng/recon-ng /usr/local/bin/recon-ng;
    sudo ln -s ${TOOL_DIR}/recon-ng/recon-cli /usr/local/bin/recon-cli;
    sudo ln -s ${TOOL_DIR}/recon-ng/recon-web /usr/local/bin/recon-web;
    recon-ng -r /opt/discover/resource/recon-ng-modules-install.rc || true;
    sudo -H recon-ng -r /opt/discover/resource/recon-ng-modules-install.rc || true;
    cd ${TOOL_DIR};
fi 

if [ ! -d ${TOOL_DIR}/goprox ]; then 
    echo "Setting up: Goprox";
    sudo git clone https://github.com/3lpsy/goprox.git ${TOOL_DIR}/goprox;
    cd ${TOOL_DIR};
fi

# Teknogeek Stuff
if [ ! -d ${TOOL_DIR}/ssrf-sheriff ]; then 
    echo "Setting up: ssrf-sheriff";
    sudo git clone https://github.com/teknogeek/ssrf-sheriff.git ${TOOL_DIR}/ssrf-sheriff;
    cd ${TOOL_DIR}/ssrf-sheriff;
    sudo $GO get github.com/teknogeek/ssrf-sheriff
    sudo cp config/base.example.yaml config/base.yaml
    sudo $GO build
    sudo ln -s ${TOOL_DIR}/ssrf-sheriff/ssrf-sheriff /usr/local/bin/ssrf-sheriff
    cd ${TOOL_DIR};
fi

if [ ! -d ${TOOL_DIR}/fresh.py ]; then 
    echo "Setting up: fresh.py";
    sudo git clone https://github.com/teknogeek/fresh.py.git ${TOOL_DIR}/fresh.py;
    cd ${TOOL_DIR}/fresh.py;
    sudo -H pip3 install -r ${TOOL_DIR}/fresh.py/requirements.txt

    echo '#!/bin/bash' | sudo tee /usr/local/bin/fresh.py
    echo "python3 ${TOOL_DIR}/fresh.py/fresh.py --clean /opt/fresh.py/clean_regex.txt \$@" | sudo tee -a /usr/local/bin/fresh.py
    sudo chmod +x /usr/local/bin/fresh.py
    cd ${TOOL_DIR};
fi


if [ ! -d ${TOOL_DIR}/ssrfmap ]; then 
    sudo git clone https://github.com/swisskyrepo/SSRFmap.git ${TOOL_DIR}/ssrfmap;
    cd ${TOOL_DIR}/ssrfmap;
    sudo -H pip3 install -r ${TOOL_DIR}/ssrfmap/requirements.txt;
    sudo chmod +x ${TOOL_DIR}/ssrfmap/ssrfmap.py;
    echo '#!/bin/bash' | sudo tee /usr/local/bin/ssrfmap.py;
    echo "python3 ${TOOL_DIR}/ssrfmap/ssrfmap.py" | sudo tee -a /usr/local/bin/ssrfmap.py;
    sudo chmod +x /usr/local/bin/ssrfmap.py;
    cd ${TOOL_DIR};
fi 

if [ ! -d ${TOOL_DIR}/gitleaks ]; then 
    sudo git clone https://github.com/zricethezav/gitleaks.git ${TOOL_DIR}/gitleaks;
    cd ${TOOL_DIR}/gitleaks
    sudo $GO get -u github.com/zricethezav/gitleaks;
    sudo $GO build
    sudo ln -s ${TOOL_DIR}/gitleaks/gitleaks /usr/local/bin/gitleaks;
    cd ${TOOL_DIR};
fi 

if [ ! -d ${TOOL_DIR}/interlace ]; then 
    sudo git clone https://github.com/codingo/Interlace.git ${TOOL_DIR}/interlace;
    cd ${TOOL_DIR}/interlace;
    sudo python3 setup.py install
    cd ${TOOL_DIR};
fi 

## Pentesting
if [ ! -d ${TOOL_DIR}/nishang ]; then 
    echo "Setting up: Nishang";
    sudo git clone https://github.com/samratashok/nishang.git ${TOOL_DIR}/nishang;
    cd ${TOOL_DIR};
fi

if [ ! -d ${TOOL_DIR}/misc ]; then 
    echo "Setting up: misc";
    sudo mkdir ${TOOL_DIR}/misc;
    sudo git clone https://github.com/tomnomnom/dotfiles.git ${TOOL_DIR}/misc/tomnomnom.dotfiles;
    sudo git clone https://github.com/tomnomnom/hacks.git ${TOOL_DIR}/misc/tomnomnom.hacks;
    sudo git clone https://github.com/nahamsec/recon_profile.git ${TOOL_DIR}/misc/nahamsec.recon_profile;
    cd ${TOOL_DIR};
fi

if [[ -d /home/${SUDOER} ]]; then 
    echo "Changing permissions for ${TOOL_DIR}"
    sudo ls -alh ${TOOL_DIR}
    sudo chown -R ${SUDOER}:${SUDOER} ${TOOL_DIR}/*
fi

if [ -n "$(uname -a | grep -i ubuntu)" ]; then 
    echo "Setting up: Zaproxy";
    sudo snap install zaproxy --classic
fi
