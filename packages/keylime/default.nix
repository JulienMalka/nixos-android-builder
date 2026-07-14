# SPDX-FileCopyrightText: 2026 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

{
  lib,
  python3Packages,
  fetchFromGitHub,
  gnupg,
  tpm2-tools,
  efivar,
}:
python3Packages.buildPythonApplication rec {
  pname = "keylime";
  format = "setuptools";
  version = "7.14.3";

  src = fetchFromGitHub {
    owner = "keylime";
    repo = "keylime";
    rev = "v${version}";
    hash = "sha256-Mdsg4InWz9ekNh/dmXuXBJ2vewr8IoGqfZzMgtnS/Og=";
  };

  build-system = with python3Packages; [
    setuptools
    jinja2
  ];

  dependencies = with python3Packages; [
    cryptography
    tornado
    pyzmq
    pyyaml
    requests
    sqlalchemy
    alembic
    packaging
    psutil
    lark
    pyasn1
    pyasn1-modules
    gpgme
    jinja2
    jsonschema
  ];

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    "${lib.makeBinPath [
      gnupg
      tpm2-tools
    ]}"
    # efivar is needed by keylime for UEFI event log parsing
    "--prefix"
    "LD_LIBRARY_PATH"
    ":"
    "${lib.getLib efivar}/lib"
  ];

  patches = [
    # https://github.com/keylime/keylime/issues/1880
    # Tracked upstream as an issue, no PR yet.  The verifier maps
    # `mbpolicies` and `verifiermain` to two independent SQLAlchemy
    # ORM classes (declarative_base in db/ versus the model framework
    # in models/), with separate identity maps that cannot see each
    # other's writes.  Both patches issue raw SQL to bypass the cache
    # for fields that are read or written across the mapping boundary.
    # Until upstream consolidates to a single mapping per table, this
    # is the only mechanism that works.
    ./0003-tpm_engine-bypass-dual-mapping-cache-for-uefi_ref_st.patch
    ./0004-tpm_engine-bypass-dual-mapping-cache-for-accept_atte.patch
  ];

  doCheck = false;

  meta = {
    description = "TPM-based key bootstrapping and system integrity measurement system";
    homepage = "https://keylime.dev";
    changelog = "https://github.com/keylime/keylime/releases/tag/v${version}";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
  };
}
