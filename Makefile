.DEFAULT_GOAL := help
.PHONY: help all test lint-shell dark-theme screenshots

# Show available targets.
help:
	@printf '%s\n' "Usage: make TARGET" "" "Targets:"
	@awk '\
	/^[[:space:]]*#[[:space:]]/ { \
		description = $$0; \
		sub(/^[[:space:]]*#[[:space:]]*/, "", description); \
		next; \
	} \
	/^[a-zA-Z0-9_-]+:/ { \
		target = $$0; \
		sub(/:.*/, "", target); \
		printf "  %-15s %s\n", target, description; \
		description = ""; \
		next; \
	} \
	{ description = "" }' [Mm]akefile

# Run all available checks.
all: test lint-shell

# Run the Emacs theme tests.
test:
	@command -v emacs >/dev/null || { printf 'Emacs is required.\n' >&2; exit 127; }
	@emacs -Q --batch -l test/leuven-theme-test.el -f ert-run-tests-batch-and-exit

# Run ShellCheck on shell scripts.
lint-shell:
	@command -v shellcheck >/dev/null || { printf 'ShellCheck is required.\n' >&2; exit 127; }
	@find . -type d -name .git -prune -o -type f \
		\( -perm /111 -o -name '*.sh' -o -name '*.bash' \) -print0 \
		| xargs -0 -r grep -IlZ -m1 -E '^#!.*(bash|/sh|/dash|/ksh)([[:space:]]|$$)' \
		| xargs -0 -r shellcheck

# Regenerate the dark theme from the light theme (overwrites local changes).
dark-theme:
	@bin/make-dark-theme

# Regenerate the screenshots embedded in README.org.
screenshots:
	@bin/make-screenshots
