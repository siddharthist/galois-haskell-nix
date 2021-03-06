PKGS ?= \
  abcBridge \
  aig \
  binary-symbols \
  constraints \
  crackNum \
  cryptol \
  crucible \
  crucible-c \
  crucible-jvm \
  crucible-llvm \
  crucible-saw \
  crux \
  cryptol \
  cryptol-verifier \
  elf-edit \
  flexdis86 \
  galois-dwarf \
  itanium-abi \
  jvm-parser \
  jvm-verifier \
  llvm-pretty \
  llvm-pretty-bc-parser \
  llvm-verifier \
  macaw-base \
  macaw-symbolic \
  macaw-x86 \
  macaw-x86-symbolic \
  parameterized-utils \
  sbv \
  saw-script \
  saw-core \
  saw-core-aig \
  saw-core-sbv \
  saw-core-what4 \
  what4 \
  what4-abc \
  what4-sbv

# This doesn't exactly match to_build, because multiple projects are in the same
# git repo.
#
# Additionally, abcBridge is handled manually.
#
# TODO: This is unused. Should make update-all target.
JSON ?= \
  constraints \
  crackNum \
  crucible \
  cryptol \
  cryptol-verifier \
  dwarf \
  elf-edit \
  flexdis86 \
  itanium-abi \
  jvm-parser \
  jvm-verifier \
  llvm-pretty \
  llvm-pretty-bc-parser \
  llvm-verifier \
  macaw \
  parameterized-utils \
  sbv \
  saw-core \
  saw-core-aig \
  saw-core-sbv \
  saw-core-what4 \
  saw-script

.PHONY: travis
travis:
	./scripts/travis-yml.sh $(PKGS)

.PHONY: build
build:
	./scripts/build-all.sh $(PKGS)

.PHONY: status
status:
	./scripts/status.sh $(PKGS)

.PHONY: local
local:
	LOCAL=1 ./scripts/build-all.sh $(PKGS)

.PHONY: json
json:
	./scripts/json.sh $(JSON)

%.json.master:
	$(eval BN := $(basename $(basename $@)))
	@if [[ $(BN) == "llvm-pretty" ]]; then \
		nix-prefetch-git "ssh://git@github.com/elliottt/$(BN)" > "$(basename $@)"; \
	elif [[ $(BN) == "sbv" || $(BN) == "crackNum" ]]; then \
		nix-prefetch-git "ssh://git@github.com/LeventErkok/$(BN)" > "$(basename $@)"; \
	elif [[ $(BN) == "constraints" ]]; then \
		nix-prefetch-git "ssh://git@github.com/ekmett/$(BN)" > "$(basename $@)"; \
	elif [[ $(BN) == "itanium-abi" ]]; then \
		nix-prefetch-git "ssh://git@github.com/travitch/$(BN)" > "$(basename $@)"; \
	else \
		nix-prefetch-git "ssh://git@github.com/GaloisInc/$(BN)" > "$(basename $@)"; \
	fi
	mv "$(basename $@)" json/

%.json.saw:
	@bash scripts/saw-dep.sh "$(basename $(basename $@))"

haskellPackages.%:
	@nix-build --max-jobs auto -A "$@" |& tee log

haskellPackages.%.local:
	@nix-build --max-jobs auto -A "$(basename $@)" local.nix |& tee log

.PHONY: clean
clean:
	rm result*

.PHONY: all
all: travis build
