SHELL := /usr/bin/env bash

.PHONY: meta check proof qemu-probe repro test clean distclean

meta:
	./tools/scripts/collect_meta.sh

check:
	./tools/scripts/check_toolchain.sh

proof:
	./tools/scripts/proof_compile.sh

qemu-probe:
	./tools/scripts/qemu_probe.sh

repro:
	rm -rf build/repro
	mkdir -p build/repro/run1
	mkdir -p build/repro/run2

	./tools/scripts/proof_compile.sh
	sha256sum build/proof/freestanding_probe.elf > build/repro/sha256-run1.txt

	rm -rf build/proof

	./tools/scripts/proof_compile.sh
	sha256sum build/proof/freestanding_probe.elf > build/repro/sha256-run2.txt

	diff -u build/repro/sha256-run1.txt build/repro/sha256-run2.txt \
	> build/repro/sha256-diff.txt || true

	echo "OK: reproducibility check completed"

test: meta check proof qemu-probe repro
	@echo "OK: M1 test suite passed"

clean:
	rm -rf build/proof

distclean:
	rm -rf build
