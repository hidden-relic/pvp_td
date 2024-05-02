local wave_config =
{
    ['small-biter'] = {['small-biter'] = 1},
    ['medium-biter'] = {['medium-biter'] = 1},
    ['big-biter'] = {['big-biter'] = 1},
    ['behemoth-biter'] = {['behemoth-biter'] = 1},
    [1] = {['small-biter'] = 10},
    [2] = {['small-biter'] = 10, ['medium-biter'] = 5},
    [3] = {['medium-biter'] = 10, ['big-biter'] = 5},
    [4] = {['big-biter'] = 10, ['behemoth-biter'] = 1},
    [5] = {['behemoth-biter'] = 10},
}

return wave_config