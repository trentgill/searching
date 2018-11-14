function main( filename )
    local file = assert(io.open(filename, "r"))
    local line = file:read("l")
    if line ~= nil then
        print( line )
    end
end

main( 'asl.lua' )
