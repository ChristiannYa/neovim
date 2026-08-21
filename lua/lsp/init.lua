local M = {}

function M.setup(servers)
	for _, name in ipairs(servers) do
		local ok, server = pcall(require, "lsp.servers." .. name)
		if ok and type(server) == "table" and server.setup then
			server.setup()
		elseif ok and type(server) == "table" then
			vim.lsp.config(name, server)
			vim.lsp.enable(name)
		else
			vim.lsp.enable(name)
		end
	end
end

return M
