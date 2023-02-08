## Assign to parent function
A <- function() {
  B <- function() {
    x <- 10
    assign("x", x, envir = parent.frame())
  }
  B()
  print(x)
}

A()
