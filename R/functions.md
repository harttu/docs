## do.call

you can pass a named list to a function in R and automatically replace the named variables inside the list to the ones inside the function using the do.call() function. Here's an example:

Suppose you have the following function func:

```R
func <- function(a, b, c) {
  result <- a * b + c
  return(result)
}
```
And you have a named list ll:

```R
ll <- list(a = 2, b = 5, c = 4)
```
You can pass the named list ll to the function func using the do.call() function:

```R
result <- do.call(func, ll)
print(result)
```

This will automatically replace the named variables inside the list ll to the ones inside the function func. In this case, the output will be:

```
14
```
