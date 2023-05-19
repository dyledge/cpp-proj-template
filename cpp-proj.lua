-- initialize the project's git repository
local Res, Msg = api.execute("git init")
if Res == nil then
  print("Unable to run 'git init':")
  print("  " .. Msg)
elseif Res ~= 0 then
  print("'git init' failed")
end

-- bootstrap vcpkg for the project
Res, Msg = api.execute("scripts/bootstrap-vcpkg.sh")
if Res == nil then
  print("Unable to run 'scripts/bootstrap-vcpkg.sh':")
  print("  " .. Msg)
elseif Res ~= 0 then
  print("'scripts/bootstrap-vcpkg.sh' failed")
end
