# check if docker already installed
if [ -x "$(command -v docker)" ]; then
    echo "Docker already installed"
    exit 0
fi

# Install Homebrew if not installed
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh

# Install Docker
brew install docker

# Start Docker
open /Applications/Docker.app

# Check is installation successful
docker --version

# print success message
echo "Docker installed successfully"