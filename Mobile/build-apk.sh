#!/bin/sh
java -version
flutter build apk --split-per-abi --no-shrink --dart-define-from-file environment.prod.json

