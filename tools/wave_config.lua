local config =
{
    ['small-biter'] = {{name='small-biter', count = 1, tick = 0}},
    ['medium-biter'] = {{name='medium-biter', count = 1, tick = 0}},
    ['big-biter'] = {{name='big-biter', count = 1, tick = 0}},
    ['behemoth-biter'] = {{name='behemoth-biter', count = 1, tick = 0}},
    [1] = {{name='small-biter', count = 10, tick = 60}},
    [2] = {{name='small-biter', count = 10, tick = 0}, {name='medium-biter', count = 5, tick = 60}},
    [3] = {{name='medium-biter', count = 10, tick = 0}, {name='big-biter', count = 5, tick = 0}},
    [4] = {{name='big-biter', count = 10, tick = 0}, {name='behemoth-biter', count = 1, tick = 0}},
    [5] = {{name='behemoth-biter', count = 10, tick = 0}},
}

return config