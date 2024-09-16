## Setting up

### C# backend

In the `API` folder, copy `appsettings.example.json` to `appsettings.json` and fill out the values. `AccessKey` and `SecretKey` are for the Cloudflare R2 service.

Run `dotnet ef database update` and then `dotnet run`.

### Rust backend

In the `rust-backend` folder, copy `.env.example` to `.env` and fill out the values. Make sure the JWT secret is the same on both backends.

Rust can be installed from <https://rustup.rs>. After installation, run `rustup default stable` in the terminal.

To start the backend, run `cargo run`.

### Flutter

In the `Mobile` folder, copy `environment.example.json` to `environment.json` and fill out the values.

Run `flutter run --dart-define-from-file environment.json`.

