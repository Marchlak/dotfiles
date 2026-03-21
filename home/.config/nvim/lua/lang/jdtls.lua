local M = {}

local function mason_package_path(package_name)
  return vim.fn.expand("$MASON/packages/" .. package_name)
end

local function install_jdtls_notify_filter()
  if vim.g.jdtls_source_path_notify_filtered then
    return
  end

  local original_notify = vim.notify

  vim.notify = function(msg, level, opts)
    if type(msg) == "string" and msg:match("^Couldn't retrieve source path settings%. Can't set 'path'") then
      return
    end

    return original_notify(msg, level, opts)
  end

  vim.g.jdtls_source_path_notify_filtered = true
end

local function set_java_source_path(bufnr, root_dir)
  local source_roots = {
    "src/main/java",
    "src/test/java",
    "src/integrationTest/java",
  }

  local path_entries = {}

  for _, relative_path in ipairs(source_roots) do
    local absolute_path = root_dir .. "/" .. relative_path
    if vim.fn.isdirectory(absolute_path) == 1 then
      table.insert(path_entries, absolute_path .. "/**")
    end
  end

  for _, match in ipairs(vim.fn.glob(root_dir .. "/src/*/java", false, true)) do
    if vim.fn.isdirectory(match) == 1 then
      table.insert(path_entries, match .. "/**")
    end
  end

  if #path_entries > 0 then
    vim.bo[bufnr].path = table.concat(path_entries, ",")
  end
end

local function get_bundles()
  local mason_registry = require("mason-registry")
  local bundles = {}

  if mason_registry.is_installed("java-debug-adapter") then
    local java_debug_path = mason_package_path("java-debug-adapter")
    vim.list_extend(
      bundles,
      vim.split(vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true), "\n", { trimempty = true })
    )
  end

  if mason_registry.is_installed("java-test") then
    local java_test_path = mason_package_path("java-test")
    vim.list_extend(
      bundles,
      vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar", true), "\n", { trimempty = true })
    )
  end

  return bundles
end

local function get_workspace()
  local home = os.getenv("HOME")
  local workspace_path = home .. "/code/workspace/"
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

  return workspace_path .. project_name
end

local function java_keymaps(bufnr)
  local opts = { buffer = bufnr }

  vim.cmd("command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._complete_compile JdtCompile lua require('jdtls').compile(<f-args>)")
  vim.cmd("command! -buffer JdtUpdateConfig lua require('jdtls').update_project_config()")
  vim.cmd("command! -buffer JdtBytecode lua require('jdtls').javap()")
  vim.cmd("command! -buffer JdtJshell lua require('jdtls').jshell()")

  vim.keymap.set("n", "<leader>jo", "<Cmd> lua require('jdtls').organize_imports()<CR>", vim.tbl_extend("force", opts, { desc = "Java organize imports" }))
  vim.keymap.set("n", "<leader>jv", "<Cmd> lua require('jdtls').extract_variable()<CR>", vim.tbl_extend("force", opts, { desc = "Java extract variable" }))
  vim.keymap.set("v", "<leader>jv", "<Esc><Cmd> lua require('jdtls').extract_variable(true)<CR>", vim.tbl_extend("force", opts, { desc = "Java extract variable" }))
  vim.keymap.set("n", "<leader>jx", "<Cmd> lua require('jdtls').extract_constant()<CR>", vim.tbl_extend("force", opts, { desc = "Java extract constant" }))
  vim.keymap.set("v", "<leader>jx", "<Esc><Cmd> lua require('jdtls').extract_constant(true)<CR>", vim.tbl_extend("force", opts, { desc = "Java extract constant" }))
  vim.keymap.set("n", "<leader>jm", "<Cmd> lua require('jdtls').test_nearest_method()<CR>", vim.tbl_extend("force", opts, { desc = "Java test nearest method" }))
  vim.keymap.set("v", "<leader>jm", "<Esc><Cmd> lua require('jdtls').test_nearest_method(true)<CR>", vim.tbl_extend("force", opts, { desc = "Java test nearest method" }))
  vim.keymap.set("n", "<leader>jt", "<Cmd> lua require('jdtls').test_class()<CR>", vim.tbl_extend("force", opts, { desc = "Java test class" }))
  vim.keymap.set("n", "<leader>ju", "<Cmd> JdtUpdateConfig<CR>", vim.tbl_extend("force", opts, { desc = "Java update config" }))
end

function M.setup()
  vim.env.JAVA_HOME = "/usr/lib/jvm/java-21-openjdk-amd64"
  install_jdtls_notify_filter()

  local jdtls = require("jdtls")
  local jdtls_path = mason_package_path("jdtls")
  local lombok = jdtls_path .. "/lombok.jar"
  local workspace_dir = get_workspace()
  local bundles = get_bundles()
  local root_dir = jdtls.setup.find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" })

  if not root_dir then
    return
  end

  local capabilities = {
    workspace = { configuration = true },
    textDocument = { completion = { snippetSupport = false } },
  }
  local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()

  for key, value in pairs(lsp_capabilities) do
    capabilities[key] = value
  end

  local extended_client_capabilities = jdtls.extendedClientCapabilities
  extended_client_capabilities.resolveAdditionalTextEditsSupport = true

  local cmd = {
    "jdtls",
    "--jvm-arg=-Dlog.protocol=true",
    "--jvm-arg=-Dlog.level=ALL",
    "--jvm-arg=-Xmx1g",
    "--jvm-arg=-javaagent:" .. lombok,
    "-data", workspace_dir,
  }

  local config = {
    cmd = cmd,
    root_dir = root_dir,
    settings = {
      java = {
        configuration = {
          updateBuildConfiguration = "interactive",
          runtimes = {
            { name = "JavaSE-1.8", path = "/usr/lib/jvm/java-8-openjdk-amd64" },
            { name = "JavaSE-11", path = "/usr/lib/jvm/java-11-openjdk-amd64" },
            { name = "JavaSE-21", path = "/usr/lib/jvm/java-21-openjdk-amd64", default = true },
          },
        },
        format = {
          enabled = true,
          settings = {
            url = vim.fn.stdpath("config") .. "/lang_servers/intellij-java-google-style.xml",
            profile = "GoogleStyle",
          },
        },
        eclipse = { downloadSource = true },
        maven = { downloadSources = true },
        signatureHelp = { enabled = true },
        contentProvider = { preferred = "fernflower" },
        saveActions = { organizeImports = true },
        completion = {
          favoriteStaticMembers = {
            "org.hamcrest.MatcherAssert.assertThat",
            "org.hamcrest.Matchers.*",
            "org.hamcrest.CoreMatchers.*",
            "org.junit.jupiter.api.Assertions.*",
            "java.util.Objects.requireNonNull",
            "java.util.Objects.requireNonNullElse",
            "org.mockito.Mockito.*",
          },
          filteredTypes = { "com.sun.*", "io.micrometer.shaded.*", "java.awt.*", "jdk.*", "sun.*" },
          importOrder = { "java", "jakarta", "javax", "com", "org" },
        },
        sources = { organizeImports = { starThreshold = 9999, staticThreshold = 9999 } },
        codeGeneration = {
          toString = { template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}" },
          hashCodeEquals = { useJava7Objects = true },
          useBlocks = true,
        },
        referencesCodeLens = { enabled = true },
        inlayHints = { parameterNames = { enabled = "all" } },
      },
    },
    capabilities = capabilities,
    init_options = { bundles = bundles, extendedClientCapabilities = extended_client_capabilities },
    on_attach = function(_, bufnr)
      set_java_source_path(bufnr, root_dir)
      java_keymaps(bufnr)
      require("jdtls.dap").setup_dap()
      require("jdtls.dap").setup_dap_main_class_configs()
      require("jdtls.setup").add_commands()
      vim.lsp.codelens.refresh()

      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = { "*.java" },
        callback = function()
          pcall(vim.lsp.codelens.refresh)
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function()
          local original_copen = vim.cmd.copen

          vim.cmd.copen = function(...)
            local key = vim.fn.getchar(0)
            if key == 0 then
              return
            end

            return original_copen(...)
          end
        end,
      })
    end,
  }

  require("jdtls").start_or_attach(config)
end

return M
