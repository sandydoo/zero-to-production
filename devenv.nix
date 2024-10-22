{ pkgs, lib, config, inputs, ... }:

{
  # Disable dotenv
  dotenv.disableHint = true;

  env.DATABASE_URL = "postgres://localhost:5432/newsletter";

  # Enable rust support
  languages.rust = {
    enable = true;
    # Use a newer version of the rust compiler via fenix
    channel = "stable";
  };

  # Extra build and runtime dependencies for our application
  packages = [
    pkgs.sqlx-cli
    pkgs.openssl

    pkgs.llvmPackages.clang
    pkgs.llvmPackages.llvm
    pkgs.llvmPackages.lld
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    pkgs.zld
    pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  processes.backend = {
    exec = "cargo run";
  };

  # Our postgres database
  services.postgres = {
    enable = true;
    listen_addresses = "localhost";
    port = 5432;
    initialDatabases = [
      {
        name = "newsletter";
        user = "app";
        pass = "secret";
      }
    ];
    initialScript = ''
      CREATE ROLE postgres WITH LOGIN PASSWORD 'password' SUPERUSER;
    '';
  };

  services.redis = {
    enable = true;
    port = 6379;
  };

  scripts.migrate-db = {
    description = "Run database migrations";
    exec = "sqlx migrate run";
  };
}
