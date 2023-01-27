Arrange on custom character vector, use custom arrangements
```R
tibble(S = c("A","4","B")) %>% arrange(factor(S, levels=c("A","B","4"))
```
