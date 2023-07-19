local Path = require("plenary.path")

local M = {}

local home = ""

-- Get Home path
local get_home = function()
  if vim.loop.os_uname().sysname == "Windows_NT"
  then
    return require("os").getenv("USERPROFILE") or ""
  else
    return require("os").getenv("HOME") or ""
  end
end

-- Get the default Wiki folder path
M.get_wiki_path = function()
  if home == "" then
    home = get_home()
  end
  local default_dir = home .. Path.path.sep .. "wiki"
  return default_dir
end

-- Create wiki folder and the diary folder inside it
M.ensure_directories = function(wiki_path)
  local path = Path:new(wiki_path)
  if not path:exists() then
    path:mkdir()
  end
  path = Path:new(wiki_path .. Path.path.sep .. "diary")
  if not path:exists() then
    path:mkdir()
  end
end

-- Check if the cursor is on a link on the line
utils.is_link = function(cursor, line)
  local filename_bounds = {}
  local found_opening = false
  for i = cursor[2], 0, -1 do
    if (line:sub(i, i) == ")") then
      return nil
    end
    if (line:sub(i, i) == "(") then
      filename_bounds[1] = i + 1
      break
    end
    if (line:sub(i, i) == "[") then
      found_opening = true
      break
    end
  end
  if not found_opening then
    return nil
  end
  for i = cursor[2] + 2, line:len(), 1 do
    if (line:sub(i, i) == "[") then
      return nil
    end
    if (line:sub(i, i) == "(") then
      filename_bounds[1] = i + 1
    end
    if (line:sub(i, i) == ")") then
      filename_bounds[2] = i - 1
      break
    end
  end
  if (filename_bounds[1] ~= nil and filename_bounds[2] ~= nil) then
    return line:sub(unpack(filename_bounds))
  end
end

return M
