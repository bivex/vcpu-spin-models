.PHONY: all verify clean

all: verify

verify:
	@chmod +x run_verification.sh
	@./run_verification.sh

clean:
	@rm -rf .spin_build pan pan.* _spin_nvr.tmp *.trail models/*.trail
	@echo "Cleaned all temporary Spin artifacts."
