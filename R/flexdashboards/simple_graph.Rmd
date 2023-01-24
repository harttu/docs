---
title: "R shiny flexboard - graph example"
output: flexdashboard::flex_dashboard
runtime: shiny 
---

```{r setup, include=FALSE}
library(igraph)
library(visNetwork)
```


Column {.sidebar}
-------------------------------------
```{r}
numericInput("n","Number of nodes", value = 10)
sliderInput("children", "Number of children", 1,10,2)
```

Column
-------------------------------------

## Graph viz

```{r}
renderVisNetwork({
  make_tree(input$n, input$children) %>% 
    visIgraph(layout = "layout_as_tree", circular= T)
})
```
