-- creates 'count' number of 'name' enemies, 'tick' ticks apart.
-- [2] = {{name='small-biter', count = 10, tick = 0}, {name='medium-biter', count = 5, tick = 60}}
-- the index (2) means it is Wave 2
-- this would create 10 small biters, 0 ticks apart (simulatenously) as a group
-- then create 5 medium biters, 60 ticks apart (1 each second for 5 seconds) as a stream

local config =
{
    -- this section is used to create waves containing enemies by name
    -- meant for creating a single enemy type, mostly for testing
    ['small-biter'] = {{name='small-biter', count = 1, tick = 0}},
    ['medium-biter'] = {{name='medium-biter', count = 1, tick = 0}},
    ['big-biter'] = {{name='big-biter', count = 1, tick = 0}},
    ['behemoth-biter'] = {{name='behemoth-biter', count = 1, tick = 0}},
    
    -- this section is used to create waves containing enemies by number
    -- meant for creating pre-defined waves
    -- also mostly for testing, we've decided to use an algorithm later
    [1] = {{name='small-biter', count = 10, tick = 60}},
    [2] = {{name='small-biter', count = 10, tick = 60}, {name='medium-biter', count = 5, tick = 60}},
    [3] = {{name='medium-biter', count = 10, tick = 60}, {name='big-biter', count = 5, tick = 120}},
    [4] = {{name='big-biter', count = 10, tick = 60}, {name='behemoth-biter', count = 1, tick = 60}},
    [5] = {{name='behemoth-biter', count = 10, tick = 60}},
}

return config