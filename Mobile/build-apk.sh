#!/bin/sh
java -version
flutter build apk --split-per-abi --dart-define-from-file environment.prod.json

