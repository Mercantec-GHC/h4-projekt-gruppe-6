#!/bin/sh

cd API
dotnet publish -r linux-arm64 -p:PublishSingleFile=true --self-contained false
dotnet ef migrations bundle -r linux-arm64 --force

cd ../rust-backend
OPENSSL_DIR=/usr/aarch64-linux-gnu/usr cargo build --release --target=aarch64-unknown-linux-gnu

cd ..
rsync -va \
	rust-backend/target/aarch64-unknown-linux-gnu/release/skantravels \
	API/efbundle \
	API/bin/Release/net8.0/linux-arm64/publish/API \
	API/bin/Release/net8.0/linux-arm64/publish/libe_sqlite3.so \
	reimar@reim.ar:/home/reimar/skantravels

ssh -t reimar@reim.ar "systemctl restart skantravels && systemctl restart skantravels-rust"

