for name_of_callback in pairs(bs.cbs) do
	bs.cbs["register_"..name_of_callback] = function(function_to_run) table.insert(bs.cbs[name_of_callback], function_to_run) end
end