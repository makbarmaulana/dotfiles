-- ========================================================================== --
-- 1. BASIC SETTINGS & KEYMAPS
-- ========================================================================== --
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.wrap = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.clipboard = "unnamedplus"
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("i", "jj", "<Esc>")

-- ========================================================================== --
-- 2. BOOTSTRAP LAZY.NVIM (plugin manager)
-- ========================================================================== --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- ========================================================================== --
-- 3. PLUGINS
-- ========================================================================== --
require("lazy").setup({

	-- ------------------------------------------------------------------ --
	-- Colorscheme
	-- ------------------------------------------------------------------ --
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd("colorscheme tokyonight")
		end,
	},

	-- ------------------------------------------------------------------ --
	-- Icons (dependency for telescope, neo-tree, statusline, etc.)
	-- ------------------------------------------------------------------ --
	{ "nvim-tree/nvim-web-devicons" },

	-- ------------------------------------------------------------------ --
	-- Treesitter (syntax highlighting)
	-- ------------------------------------------------------------------ --
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master", -- stable API (the "main" branch is a newer rewrite with a different config API)
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua",
					"vim",
					"vimdoc",
					"javascript",
					"typescript",
					"tsx",
					"html",
					"css",
					"json",
					"yaml",
					"markdown",
					"bash",
				},
				auto_install = true,
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},

	-- ------------------------------------------------------------------ --
	-- Mason + LSP
	-- ------------------------------------------------------------------ --
	{ "williamboman/mason.nvim", config = true },

	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"ts_ls", -- JavaScript / TypeScript
					"html",
					"cssls",
					"jsonls",
					"lua_ls",
					"tailwindcss",
				},
			})
		end,
	},

	{
		-- Ships default per-server configs (lsp/*.lua) consumed by vim.lsp.config;
		-- we no longer call require("lspconfig")[server].setup() (deprecated).
		"neovim/nvim-lspconfig",
		dependencies = { "hrsh7th/cmp-nvim-lsp" },
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Applies to every server (native Neovim 0.11+ API)
			vim.lsp.config("*", { capabilities = capabilities })

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
					},
				},
			})

			vim.lsp.enable({ "ts_ls", "html", "cssls", "jsonls", "tailwindcss", "lua_ls" })

			-- LSP keymaps (buffer-local, set on attach)
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local opts = { buffer = args.buf }
					vim.keymap.set(
						"n",
						"gd",
						vim.lsp.buf.definition,
						vim.tbl_extend("force", opts, { desc = "Go to definition" })
					)
					vim.keymap.set(
						"n",
						"gr",
						vim.lsp.buf.references,
						vim.tbl_extend("force", opts, { desc = "Find references" })
					)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover docs" }))
					vim.keymap.set(
						"n",
						"<leader>rn",
						vim.lsp.buf.rename,
						vim.tbl_extend("force", opts, { desc = "Rename symbol" })
					)
					vim.keymap.set(
						"n",
						"<leader>ca",
						vim.lsp.buf.code_action,
						vim.tbl_extend("force", opts, { desc = "Code action" })
					)
					vim.keymap.set(
						"n",
						"<leader>d",
						vim.diagnostic.open_float,
						vim.tbl_extend("force", opts, { desc = "Show diagnostic" })
					)
				end,
			})
		end,
	},

	-- ------------------------------------------------------------------ --
	-- Formatter (Prettier, etc.) via conform.nvim
	-- ------------------------------------------------------------------ --
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					javascript = { "prettier" },
					typescript = { "prettier" },
					javascriptreact = { "prettier" },
					typescriptreact = { "prettier" },
					html = { "prettier" },
					css = { "prettier" },
					json = { "prettier" },
					yaml = { "prettier" },
					markdown = { "prettier" },
					lua = { "stylua" },
				},
				format_on_save = {
					timeout_ms = 500,
					lsp_fallback = true,
				},
			})
		end,
	},

	-- Ensure prettier & stylua binaries are installed via mason
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = { "prettier", "stylua" },
			})
		end,
	},

	-- ------------------------------------------------------------------ --
	-- Autocomplete
	-- ------------------------------------------------------------------ --
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				}),
			})
		end,
	},

	-- ------------------------------------------------------------------ --
	-- Auto Pairs & Auto Tag (JSX/TSX/HTML)
	-- ------------------------------------------------------------------ --
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},
	{
		"windwp/nvim-ts-autotag",
		event = "InsertEnter",
		config = true,
	},

	-- ------------------------------------------------------------------ --
	-- Telescope (fuzzy finder)
	-- ------------------------------------------------------------------ --
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-file-browser.nvim",
		},
		config = function()
			local actions = require("telescope.actions")
			local fb_actions = require("telescope._extensions.file_browser.actions")

			require("telescope").setup({
				defaults = {
					-- Open pickers in normal mode so j/k work immediately without pressing <Esc>
					initial_mode = "normal",
					file_ignore_patterns = {
						"node_modules/",
						"%.git/",
						"build/",
						"dist/",
					},
					mappings = {
						n = {
							["q"] = actions.close, -- press q to close the picker while in normal mode
						},
					},
				},
				extensions = {
					file_browser = {
						-- hjkl navigation: h = go to parent dir, l = open dir/file (like Neo-tree)
						hijack_netrw = false,
						hidden = { file_browser = true, folder_browser = true },
						respect_gitignore = false,
						grouped = true, -- list folders first, then files
						mappings = {
							["n"] = {
								["h"] = fb_actions.goto_parent_dir,
								["l"] = actions.select_default,
							},
						},
					},
				},
			})
			require("telescope").load_extension("file_browser")

			local builtin = require("telescope.builtin")

			-- Find the git project root (falls back to cwd if not in a git repo)
			local function get_git_root()
				local dot_git_path = vim.fn.finddir(".git", vim.loop.cwd() .. ";")
				if dot_git_path ~= "" then
					return vim.fn.fnamemodify(dot_git_path, ":h")
				end
				return vim.loop.cwd()
			end

			-- <leader>ff : find files, recursive, from current working directory
			vim.keymap.set("n", "<leader>ff", function()
				builtin.find_files({ cwd = vim.loop.cwd() })
			end, { desc = "Find files (cwd)" })

			-- <leader>fa : find ALL files (including hidden + gitignored), from cwd,
			-- still excluding node_modules/.git/build (via file_ignore_patterns above)
			vim.keymap.set("n", "<leader>fa", function()
				builtin.find_files({
					cwd = vim.loop.cwd(),
					hidden = true,
					no_ignore = true,
					file_ignore_patterns = {
						"node_modules/",
						"%.git/",
						"build/",
						"dist/",
					},
				})
			end, { desc = "Find ALL files (incl. hidden)" })

			-- <leader>fp : find files from the git project root (whole project), recursive
			vim.keymap.set("n", "<leader>fp", function()
				builtin.find_files({ cwd = get_git_root() })
			end, { desc = "Find files (project root)" })

			-- <leader>fe : browse folders + files one level at a time from cwd,
			-- navigate with h (parent dir) / l (open dir or file) / j,k (move)
			vim.keymap.set("n", "<leader>fe", function()
				require("telescope").extensions.file_browser.file_browser({
					path = vim.loop.cwd(),
					cwd = vim.loop.cwd(),
					select_buffer = true,
				})
			end, { desc = "File browser (hjkl navigation)" })

			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "List open buffers" })
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
		end,
	},

	-- ------------------------------------------------------------------ --
	-- Neo-tree (file explorer)
	-- ------------------------------------------------------------------ --
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("neo-tree").setup({
				close_if_last_window = true,
				filesystem = {
					filtered_items = {
						visible = true, -- show hidden/gitignored items in the tree (still togglable with `H`)
						hide_dotfiles = false,
						hide_gitignored = false,
					},
				},
			})
			vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle file explorer (Neo-tree)" })
		end,
	},

	-- ------------------------------------------------------------------ --
	-- Which-key: shows a popup of available keybindings after <leader>
	-- ------------------------------------------------------------------ --
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			require("which-key").setup({})
			require("which-key").add({
				{ "<leader>f", group = "Find / Telescope" },
				{ "<leader>c", group = "Code" },
			})
		end,
	},
})
