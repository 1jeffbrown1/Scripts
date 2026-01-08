# Helm is a client that connects to your k8s cluster and executes work
# Ideally, you would install the client on your k8s management box
# otherwise, per my understanding of it as I write this, install it on each control plane node

# get the key, and add it to the keyring
curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | sudo gpg --dearmor -o /etc/apt/keyrings/helm.gpg

# Add the repo
echo "deb [signed-by=/etc/apt/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

# Install Helm
sudo apt-get update
sudo apt-get install helm
