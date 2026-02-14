return {
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    event = {
      "BufReadPre " .. vim.fn.expand("~") .. "/Documents/knowledge/**.md",
      "BufNewFile " .. vim.fn.expand("~") .. "/Documents/knowledge/**.md",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "knowledge",
          path = "~/Documents/knowledge",
        },
      },

      -- Use Telescope as the picker
      picker = {
        name = "telescope.nvim",
        note_mappings = {},
        tag_mappings = {},
      },

      -- Case-insensitive search
      search_opts = { "--smart-case" },

      -- Don't manage frontmatter — we handle it manually per README conventions
      disable_frontmatter = true,

      -- Wiki-link style (matches our README conventions)
      wiki_link_func = function(opts)
        if opts.label ~= opts.path then
          return string.format("[[%s|%s]]", opts.path, opts.label)
        else
          return string.format("[[%s]]", opts.path)
        end
      end,

      -- Where to put new notes (default to personal/topics)
      notes_subdir = "personal/topics",

      -- Attachments go to the domain's assets folder
      attachments = {
        img_folder = "personal/assets",
      },

      -- Completion (disabled — LazyVim uses blink.cmp, not nvim-cmp)
      completion = {
        nvim_cmp = false,
        min_chars = 2,
      },

      -- Follow links with gf
      follow_url_func = function(url)
        vim.fn.jobstart({ "open", url })
      end,
    },
    keys = {
      { "<leader>of", "<cmd>ObsidianQuickSwitch<cr>", desc = "Find note" },
      { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Search notes" },
      { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New note" },
      { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Backlinks" },
      { "<leader>ot", "<cmd>ObsidianTags<cr>", desc = "Tags" },
      { "<leader>ol", "<cmd>ObsidianLinks<cr>", desc = "Links in note" },
    },
  },
}
