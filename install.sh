#!/bin/bash

# A simple script for setting up macOS dev environment.

dev="$HOME/Developer"
pushd .
mkdir -p $dev
cd $dev

echo 'Enter new hostname of the machine (e.g. macbook-paulmillr)'
  read hostname
  echo "Setting new hostname to $hostname..."
  scutil --set HostName "$hostname"
  compname=$(sudo scutil --get HostName | tr '-' '.')
  echo "Setting computer name to $compname"
  scutil --set ComputerName "$compname"
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$compname"

pub="$HOME/.ssh/id_rsa.pub"
echo 'Checking for SSH key, generating one if it does not exist...'
if [[ -f $pub ]]
  then
    echo 'Key already exists'
  else
    echo 'Enter Mail Adress for SSH Key'
    read eMail 
    ssh-keygen -t rsa -b 4096 -C "$eMail"
fi

echo 'Copying public key to clipboard. Paste it into your Github account...'
  [[ -f $pub ]] && cat $pub | pbcopy
  open 'https://github.com/account/ssh'


# If we on macOS, install homebrew and tweak system a bit.
if [[ `uname` == 'Darwin' ]]; then
  ohMyZsh="$HOME/.oh-my-zsh"
  if [[ -f $ohMyZsh ]]; then
    echo 'Installing Oh My Zsh...'
	  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
  themePath="$ZSH_CUSTOM/themes/powerlevel10k"
  if [[ -f $themePath ]]; then
    echo 'Install Zsh Theme..'
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
  fi

  which -s brew
  if [[ $? != 0 ]]; then
    echo 'Installing Homebrew...'
	  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  fi

  nvm="$HOME/.nvm"
  if [[ -f $nvm ]]; then
  echo 'Install nvm...'
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
  fi

  # Homebrew packages.
  brew install node youtube-dl zsh-syntax-highlighting
  brew tap homebrew/cask-fonts
  brew cask install alfred iterm2 sublime-text spotify font-jetbrainsmono-nerd-font google-chrome visual-studio-code jetbrains-toolbox dash
  # echo 'Tweaking macOS...'
    # source 'etc/macos.sh'

  # https://github.com/sindresorhus/quick-look-plugins
  # echo 'Installing Quick Look plugins...'
  #   brew tap phinze/homebrew-cask
  #   brew install caskroom/cask/brew-cask
  #   brew cask install suspicious-package quicklook-json qlmarkdown qlstephen qlcolorcode
fi

pwd="$(pwd)"
for file in {.dotfiles,.ssh,.hushlogin,.vimrc,.zshrc}; do
  filepath="$pwd/dotfiles/$file"
  [ -r "$filepath" ] && echo "Copying $filepath" && cp -r "$filepath" ~/
done
unset file
echo 'Reloading zshrc'
source ~/.zshrc
