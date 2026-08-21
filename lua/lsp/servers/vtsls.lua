local M = {}

function M.setup()
    local mason_registry = require("mason-registry")

    local function enable()
        local pkg = mason_registry.get_package("vue-language-server")
        local vue_ts_plugin = pkg:get_install_path() .. "/node_modules/@vue/typescript-plugin"

        local plugin = {
            name = "@vue/typescript-plugin",
            location = vue_ts_plugin,
            languages = { "vue" },
            configNamespace = "typescript",
            enableForWorkspaceTypeScriptVersions = true,
        }

        vim.lsp.config("vue_ls", {
            cmd = {
                "vue-language-server",
                "--stdio",
                "--tsdk=" .. vim.fn.getcwd() .. "/node_modules/typescript/lib",
            },
        })

        vim.lsp.config("vtsls", {
            settings = {
                vtsls = {
                    tsserver = {
                        globalPlugins = { plugin },
                    },
                    autoUseWorkspaceTsdk = true,
                },
            },
            filetypes = {
                "typescript",
                "javascript",
                "javascriptreact",
                "typescriptreact",
                "vue",
            },
            on_attach = function()
                vim.lsp.enable("vue_ls")
            end,
        })

        vim.lsp.enable("vtsls")
    end

    local pkg = mason_registry.get_package("vue-language-server")
    if pkg:is_installed() then
        enable()
    else
        pkg:once("install:success", enable)
    end
end

return M

