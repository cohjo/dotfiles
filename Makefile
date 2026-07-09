DOTFILES := $(HOME)/github/dotfiles

.PHONY: link editors tools doctor

link:
	./scripts/link-editors.sh

editors: link

tools:
	./scripts/install-language-tools.sh

doctor:
	nvim --version | head -n 1
	nvim --headless "+lua print(vim.fn.stdpath('config'))" +qa
