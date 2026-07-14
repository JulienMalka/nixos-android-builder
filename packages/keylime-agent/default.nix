# SPDX-FileCopyrightText: 2026 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  clang,
  openssl,
  tpm2-tss,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "keylime-agent";
  version = "0.2.10";

  src = fetchFromGitHub {
    owner = "keylime";
    repo = "rust-keylime";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+MypjFxEmuxgQilgtnAyfw1a0yf0QRpfENHTBhuK/94=";
  };

  cargoHash = "sha256-eVn9R5Ue9cPB8Xin2rVldHDycGWvyCCQ7RuVMRkb2yM=";

  nativeBuildInputs = [
    pkg-config
    clang
  ];

  buildInputs = [
    openssl
    tpm2-tss
  ];

  env.LIBCLANG_PATH = "${lib.getLib clang.cc}/lib";

  doCheck = false;

  meta = {
    description = "Rust-based Keylime agent for TPM-based remote attestation";
    homepage = "https://keylime.dev";
    changelog = "https://github.com/keylime/rust-keylime/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    mainProgram = "keylime_agent";
  };
})
