#!/bin/bash

curl -s https://data.zamzasalim.xyz/file/uploads/asclogo.sh | bash
sleep 5
# Fungsi untuk menampilkan pesan sukses
function success_message {
    echo "[✔] $1"
}

# Fungsi untuk menampilkan pesan proses
function info_message {
    echo "[-] $1..."
}

# Fungsi untuk menampilkan pesan kesalahan
function error_message {
    echo "[✘] $1"
}

# Langkah 1: Pengecekan apakah Docker sudah terpasang
if ! command -v docker &> /dev/null
then
    echo "Docker tidak ditemukan, memulai instalasi Docker..."
    
    # Install dependencies yang diperlukan
    sudo apt update && sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    
    # Menambahkan GPG key resmi Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    
    # Menambahkan repository resmi Docker
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    
    # Update indeks paket APT
    sudo apt update
    
    # Install Docker
    sudo apt install -y docker-ce
    sudo systemctl start docker
    sudo systemctl enable docker

    success_message "Docker berhasil diinstal dan dijalankan."
else
    success_message "Docker sudah terpasang. Lewati instalasi Docker."
fi

echo ""

sudo groupadd docker && sudo usermod -aG docker $(whoami) && newgrp docker

# Langkah 2: Tarik gambar Docker
info_message "Mengunduh gambar Docker"
if docker pull privasea/acceleration-node-beta:latest; then
    success_message "Gambar Docker berhasil diunduh"
else
    error_message "Gagal mengunduh gambar Docker"
    exit 1
fi

echo ""

# Langkah 3: Buat direktori konfigurasi
info_message "Membuat direktori konfigurasi"
if mkdir -p $HOME/privasea/config; then
    success_message "Direktori konfigurasi berhasil dibuat"
else
    error_message "Gagal membuat direktori konfigurasi"
    exit 1
fi

echo ""

# Langkah 4: Buat file keystore
info_message "Membuat file keystore"
if echo "$KEystorePassword" | docker run -v "$HOME/privasea/config:/app/config" privasea/acceleration-node-beta:latest ./node-calc new_keystore; then
    success_message "File keystore berhasil dibuat"
else
    error_message "Gagal membuat file keystore"
    exit 1
fi

echo ""

# Langkah 5: Pindahkan file keystore ke nama baru
info_message "Memindahkan file keystore"
if mv $HOME/privasea/config/UTC--* $HOME/privasea/config/wallet_keystore; then
    success_message "File keystore berhasil dipindahkan ke wallet_keystore"
else
    error_message "Gagal memindahkan file keystore"
    exit 1
fi

echo ""

# Langkah 6: Pilihan untuk melanjutkan atau tidak
read -p "Apakah Anda ingin melanjutkan untuk menjalankan node (y/n)? " choice
if [[ "$choice" != "y" ]]; then
    echo "Proses dibatalkan."
    exit 0
fi

# Langkah 7: Meminta password untuk keystore
info_message "Masukkan password untuk keystore (untuk mengakses node):"
read -s KEystorePassword
echo ""

# Langkah 8: Jalankan node
info_message "Menjalankan Privasea Acceleration Node"
if docker run -d -v "$HOME/privasea/config:/app/config" \
-e KEYSTORE_PASSWORD=$KEystorePassword \
privasea/acceleration-node-beta:latest; then
    success_message "Node berhasil dijalankan"
else
    error_message "Gagal menjalankan node"
    exit 1
fi

echo ""

# Langkah akhir
echo "File konfigurasi tersedia di: $HOME/privasea/config"
echo "Keystore disimpan sebagai: wallet_keystore"
echo "Password Keystore yang digunakan: $KEystorePassword"
