# 🐳 Single-Node Kubernetes Setup Script (Ubuntu-based)

This repository includes a Bash script designed to automate the setup of a single-node Kubernetes cluster using `kubeadm`, `containerd`, and Docker on Ubuntu-based systems. It installs all required dependencies, configures system settings, and ensures container runtimes and Kubernetes tools are ready to use.

> ✅ Ideal for testing, learning, local development, or small-scale deployment environments.

---

## 📄 Script: `install.sh`

### 🔧 What the Script Does

1. **System Preparation**  
   Updates packages, installs essential tools, sets the locale and time zone (Europe/Istanbul), and disables automatic NTP syncing.

2. **Install Docker & Containerd**  
   Adds Docker’s official APT repository, installs Docker Engine and `containerd`, and configures required kernel modules.

3. **Container Runtime Configuration**  
   Sets `SystemdCgroup = true` in `containerd` config for compatibility with Kubernetes and restarts the service.

4. **System Kernel Settings for Kubernetes**  
   Applies network settings required for Kubernetes networking (bridge networking and IP forwarding).

5. **Kubernetes Installation**  
   Adds the Kubernetes repository, installs `kubelet`, `kubeadm`, and `kubectl`, and marks them to prevent accidental upgrade.

---

## 📦 Requirements

- **Operating System:** Ubuntu 20.04 / 22.04
- **Privileges:** Root or sudo
- **Architecture:** x86_64 / AMD64

---

## 🚀 Usage

```bash
chmod +x install.sh
sudo ./install.sh
```

Logs will be saved to `installer.log` in the same directory.

---

## 🧰 Installed Tools & Packages

- `vim`, `nano`, `net-tools`, `wget`, `jq`, `curl`, `ca-certificates`
- `docker-ce`, `docker-ce-cli`, `containerd.io`
- `kubelet`, `kubeadm`, `kubectl`
- `tzdata`, `locales`, `apt-transport-https`

---

## 📂 Key Configuration Changes

### `containerd`
```toml
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
SystemdCgroup = true
```

### `sysctl`
```bash
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
```

---

## 📌 Notes

- The script sets the timezone to `Europe/Istanbul`. Change it if needed.
- Automatic time syncing via NTP is disabled. Configure manually if required.
- You can initialize your cluster after this setup using:

```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

- Don’t forget to apply a CNI plugin like Flannel or Calico for networking.

---

## License

This project is licensed under the [MIT License](LICENSE). See the license file for details.

---

## Issues, Feature Requests or Support

Please use the Issue > New Issue button to submit issues, feature requests or support issues directly to me. You can also send an e-mail to akin.bicer@outlook.com.tr.
