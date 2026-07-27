-- ~/.config/nvim-mail/init.lua
-- Dedicated config for composing mail. No plugin manager: opens instantly.

-- Temp files; don't litter the filesystem
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = false

vim.opt.number = false
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.mouse = ""

-- Make invisible junk visible: trailing whitespace and stray tabs/nbsp
vim.opt.list = true
vim.opt.listchars = { trail = "·", tab = "→ ", nbsp = "␣" }

vim.opt.spelllang = "en_us"
vim.opt.spellfile = vim.fn.expand("~/.config/nvim-mail/spell/en.utf-8.add")

-- neomutt's temp filenames aren't always detected; this config only ever
-- opens mail, so force it.
vim.filetype.add({
	pattern = {
		[".*/neomutt%-.*"] = "mail",
		[".*/mutt%-.*"] = "mail",
	},
})

local grp = vim.api.nvim_create_augroup("MailCompose", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	group = grp,
	pattern = "mail",
	callback = function()
		vim.opt_local.textwidth = 72
		vim.opt_local.colorcolumn = "73"
		vim.opt_local.spell = true
		-- t: auto-wrap  c: ...  q: allow gq  j: sane joins
		-- 'a' deliberately absent: never auto-reflow quoted text
		vim.opt_local.formatoptions = "tcqj"
		vim.opt_local.comments = "n:>" -- gq respects '>' quote levels
	end,
})

-- Start on the first body line rather than in the headers
vim.api.nvim_create_autocmd("BufReadPost", {
	group = grp,
	pattern = "*",
	callback = function()
		if vim.bo.filetype ~= "mail" then
			return
		end
		local blank = vim.fn.search("^$", "nw")
		if blank > 0 then
			vim.api.nvim_win_set_cursor(0, { math.min(blank + 1, vim.fn.line("$")), 0 })
		end
	end,
})
