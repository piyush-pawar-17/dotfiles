local M = {}

local state_file = vim.fs.joinpath(vim.fn.stdpath("state"), "opencode-sessions.json")

local function load_sessions()
	local ok, lines = pcall(vim.fn.readfile, state_file)
	if not ok then
		return {}
	end

	local decoded, sessions = pcall(vim.json.decode, table.concat(lines, "\n"))
	return decoded and type(sessions) == "table" and sessions or {}
end

local sessions = load_sessions()
local pending_sessions = {}

local function save_sessions()
	vim.fn.mkdir(vim.fn.fnamemodify(state_file, ":h"), "p")
	vim.fn.writefile({ vim.json.encode(sessions) }, state_file)
end

local function project_dir()
	local cwd = vim.fn.getcwd()
	return vim.fs.root(cwd, { ".git" }) or cwd
end

local function notify_error(message)
	vim.notify("OpenCode: " .. message, vim.log.levels.ERROR)
end

local function api(project, method, path, body, callback, on_error)
	local function fail(message)
		notify_error(message)
		if on_error then
			on_error()
		end
	end

	if vim.fn.executable("opencode") == 0 then
		fail("the opencode executable was not found in $PATH")
		return
	end

	local args = { "opencode", "api", method, path }
	if body then
		table.insert(args, "--data")
		table.insert(args, vim.json.encode(body))
	end
	vim.system(args, { cwd = project, text = true }, function(result)
		vim.schedule(function()
			if result.code ~= 0 then
				local message = vim.trim(result.stderr ~= "" and result.stderr or result.stdout)
				fail(message ~= "" and message or "API request failed")
				return
			end

			local ok, response = pcall(vim.json.decode, result.stdout)
			if not ok then
				fail("could not read the API response: " .. response)
				return
			end

			callback(response)
		end)
	end)
end

local function session_title(project, session, callback)
	if not session then
		callback("Manual session")
		return
	end

	api(project, "get", "/api/session/" .. session, nil, function(response)
		callback(response.data and response.data.title or "Untitled session")
	end, function()
		callback("Unknown session")
	end)
end

local function tmux_available()
	return vim.env.TMUX and vim.fn.executable("tmux") == 1
end

local function open_in_tmux(session, project)
	if not tmux_available() then
		notify_error("tmux is required to open the external OpenCode window")
		return
	end

	vim.system({
		"tmux",
		"new-window",
		"-d",
		"-n",
		"opencode",
		"opencode",
		"--session",
		session,
		project,
	}, { text = true }, function(result)
		vim.schedule(function()
			if result.code ~= 0 then
				local message = vim.trim(result.stderr ~= "" and result.stderr or result.stdout)
				notify_error(message ~= "" and message or "could not create the tmux window")
				return
			end

			vim.notify("Opened OpenCode session " .. session .. " in a detached tmux window")
		end)
	end)
end

local function find_tmux_pane(session, project, callback)
	if not tmux_available() then
		notify_error("tmux is required to stage text in the external OpenCode window")
		return
	end

	vim.system({
		"tmux",
		"list-panes",
		"-a",
		"-F",
		"#{pane_id}\t#{window_index}\t#{pane_current_command}\t#{pane_start_command}",
	}, { text = true }, function(result)
		vim.schedule(function()
			if result.code ~= 0 then
				notify_error("could not find the OpenCode tmux pane")
				return
			end

			local opencode_panes = {}
			for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
				local pane, window, current_command, start_command = line:match("^([^\t]+)\t([^\t]+)\t([^\t]*)\t(.*)$")
				local pane_session = start_command:match("%-%-session%s+(ses[%w_-]+)")
				local expected = session and start_command:find(session, 1, true)
				if pane and (current_command:match("^opencode") or expected) then
					pane_session = pane_session or (expected and session or nil)
					table.insert(opencode_panes, { pane = pane, window = window, session = pane_session })
				end
			end

			if #opencode_panes == 1 then
				callback(opencode_panes[1].pane)
				return
			end

			if #opencode_panes > 1 then
				local remaining = #opencode_panes
				for _, item in ipairs(opencode_panes) do
					session_title(project, item.session, function(title)
						item.title = title
						remaining = remaining - 1
						if remaining ~= 0 then
							return
						end

						vim.ui.select(opencode_panes, {
							prompt = "Select OpenCode tmux pane",
							format_item = function(pane)
								return ("(%s) %s"):format(pane.window, pane.title)
							end,
						}, function(selected)
							if selected then
								callback(selected.pane)
							end
						end)
					end)
				end
				return
			end

			notify_error("no OpenCode tmux pane was found; use <leader>on to open one")
		end)
	end)
end

local function ensure_session(project, callback)
	if sessions[project] then
		callback(sessions[project])
		return
	end

	if pending_sessions[project] then
		table.insert(pending_sessions[project], callback)
		return
	end

	pending_sessions[project] = { callback }
	api(project, "post", "/api/session", { location = { directory = project } }, function(response)
		local session = response.data and response.data.id
		if not session then
			notify_error("the API did not return a session ID")
			pending_sessions[project] = nil
			return
		end

		sessions[project] = session
		save_sessions()
		local callbacks = pending_sessions[project]
		pending_sessions[project] = nil
		for _, pending in ipairs(callbacks) do
			pending(session)
		end
	end, function()
		pending_sessions[project] = nil
	end)
end

local function range(visual)
	local buffer = vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(0)[1]
	local first, last = cursor, cursor

	if visual then
		first = vim.fn.getpos("'<")[2]
		last = vim.fn.getpos("'>")[2]
		if first == 0 or last == 0 then
			first, last = cursor, cursor
		end
	end

	return buffer, math.min(first, last), math.max(first, last)
end

local function context(visual)
	local buffer, first, last = range(visual)
	local path = vim.api.nvim_buf_get_name(buffer)
	local description = path ~= ""
		and ("Current editor context: %s, lines %d-%d."):format(path, first, last)
		or ("Current editor context: unnamed buffer, lines %d-%d."):format(first, last)

	local files = path ~= "" and { { uri = vim.uri_from_fname(path) } } or nil
	return description, files
end

local function send(prompt, visual)
	local project = project_dir()
	local description, files = context(visual)
	local body = {
		text = prompt .. "\n\n" .. description,
	}
	if files then
		body.files = files
	end

	ensure_session(project, function(session)
		api(project, "post", "/api/session/" .. session .. "/prompt", body, function()
			vim.notify("Sent to OpenCode session " .. session)
		end)
	end)
end

--- Ask OpenCode about the current cursor position or visual selection.
---@param visual boolean
function M.ask(visual)
	vim.ui.input({ prompt = "Ask OpenCode: " }, function(prompt)
		if prompt and prompt ~= "" then
			send(prompt, visual)
		end
	end)
end

--- Send a ready-made prompt with the current cursor position or visual selection.
---@param prompt string
---@param visual boolean
function M.prompt(prompt, visual)
	send(prompt, visual)
end

--- Insert the current file location into the external OpenCode tmux pane.
---@param visual boolean
function M.reference(visual)
	local project = project_dir()
	local buffer, first, last = range(visual)
	local path = vim.api.nvim_buf_get_name(buffer)
	if path == "" then
		notify_error("the current buffer has no file name")
		return
	end

	local relative = vim.fs.relpath(project, path) or path
	local location = first == last and ("%s:%d"):format(relative, first) or ("%s:%d-%d"):format(relative, first, last)
	location = "@" .. location
	find_tmux_pane(sessions[project], project, function(pane)
		vim.system({ "tmux", "send-keys", "-t", pane, "-l", location }, { text = true }, function(result)
			vim.schedule(function()
				if result.code ~= 0 then
					local message = vim.trim(result.stderr ~= "" and result.stderr or result.stdout)
					notify_error(message ~= "" and message or "could not insert text into the OpenCode pane")
					return
				end

				vim.notify("Inserted " .. location .. " into OpenCode pane " .. pane)
			end)
		end)
end)
end

--- Select a common prompt to send with the current editor context.
---@param visual boolean
function M.select(visual)
	local prompts = {
		{ label = "Ask…" },
		{ label = "Explain", prompt = "Explain this context." },
		{ label = "Review", prompt = "Review this context for correctness and readability." },
		{ label = "Fix", prompt = "Fix the issues in this context." },
		{ label = "Implement", prompt = "Implement the requested change in this context." },
		{ label = "Optimize", prompt = "Optimize this context for performance and readability." },
		{ label = "Test", prompt = "Add tests for this context." },
	}

	vim.ui.select(prompts, {
		prompt = "OpenCode",
		format_item = function(item)
			return item.label
		end,
	}, function(item)
		if not item then
			return
		end
		if item.prompt then
			send(item.prompt, visual)
		else
			M.ask(visual)
		end
	end)
end

--- Create a fresh project session in a detached tmux window.
function M.new_session()
	local project = project_dir()
	sessions[project] = nil
	save_sessions()
	ensure_session(project, function(session)
		open_in_tmux(session, project)
	end)
end

local map = require("utils.keymap").map
local function visual_mode()
	return vim.tbl_contains({ "v", "V", "\22" }, vim.fn.mode())
end

map({ "n", "x" }, "<C-c><C-w>", function()
	M.ask(visual_mode())
end, { desc = "Ask OpenCode" })
map({ "n", "x" }, "<leader>os", function()
	M.select(visual_mode())
end, { desc = "Execute OpenCode action…" })
map({ "n", "x" }, "<C-c><C-c>", function()
	M.reference(visual_mode())
end, { desc = "Insert file location in OpenCode" })
map("n", "<leader>on", M.new_session, { desc = "New OpenCode session" })

return {}
