#!/bin/sh
dotnet publish -r linux-arm64 -p:PublishSingleFile=true --self-contained false
rsync -vu bin/Release/net8.0/linux-arm64/publish/* reimar@reim.ar:/home/reimar/skantravels
ssh -t reimar@reim.ar "systemctl restart skantravels"

