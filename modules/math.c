#include "tinyexpr-master/tinyexpr.h"
#include "tinyexpr-master/tinyexpr.c"
#include <stdio.h>

int evaluate(char a[10])
{
    return te_interp(a, 0);
}