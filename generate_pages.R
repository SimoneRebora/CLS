# chapter selection
my_selection <- c(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)

# (...or) select one specific chapter
# my_selection <- 2

# chapter_n	page_id	title
# 0	Introduction	Introduction
# 1	TextAnalysis	1. Literary historiography and computational text analysis
# 2	Stylometry	2. Stylistics and stylometry
# 3	SentimentAnalysis	3. Emotions in literature and sentiment analysis
# 4	TopicModeling	4. Thematic criticism and topic modeling
# 5	Mapping	5. Mapping literature
# 6	Networks	6. Networking characters
# 7	TextReuse	7. Intertextuality and text reuse detection
# 8	MLGenAI	8. Artificial Intelligence and the challenge of interpretation
# 9	Conclusion	Conclusion

library(glue)
library(webshot2)

all_chapters <- read.csv("data/all_chapters.csv", stringsAsFactors = F)

today <- Sys.Date()

for(chapter_n in my_selection){
  
  cat("###### Processing page n.", chapter_n, "\n\n\n")

  my_chapter <- all_chapters[which(all_chapters$chapter_n == chapter_n),]
  
  page_content <- glue("---
page_id: {my_chapter$page_id}
layout: single
title: {my_chapter$title}
permalink: /{my_chapter$page_id}/
sidebar:
  nav: \"docs\"
toc: true
toc_sticky: true
classes: small-text-page
---

*Last update: {today}*

{my_chapter$description}


")
  
  my_write_file <- glue("_pages/{my_chapter$page_id}.md")
  
  cat(page_content, file = my_write_file)
  
  chapter_contents <- read.csv(glue("data/{my_chapter$page_id}.csv"))
  
  # save screenshots 
  
  for (i in seq_along(chapter_contents$link)) {
    
    if(is.na(chapter_contents$screenshot[i]) | chapter_contents$screenshot[i] == ""){
      
      webshot(
        url = chapter_contents$link[i],
        file = glue("assets/images/{my_chapter$page_id}_{i}.png"),
        vwidth = 1600,
        vheight = 900,
        cliprect = "viewport",
        delay = 10
      )
      
      chapter_contents$screenshot[i] <- glue("/assets/images/{my_chapter$page_id}_{i}.png")
      
    }
    
  }
  
  write.csv(chapter_contents, file = glue("data/{my_chapter$page_id}.csv"), row.names = F)

  types <- unique(chapter_contents$type)
  
  if(chapter_n == 0){ # different rule for introduction
    
    for (type in types) {
      cat("## ", type, "\n\n", sep = "", file = my_write_file, append = T)
      
      subset_df <- chapter_contents[chapter_contents$type == type, ]
      
      for (i in seq_len(nrow(subset_df))) {
        cat("### [", subset_df$title[i], "](", subset_df$link[i], ")\n\n", sep = "", file = my_write_file, append = T)
        cat("![Screenshot of ", subset_df$title[i], "]({{ '", subset_df$screenshot[i], "' | relative_url }})\n\n", sep = "", file = my_write_file, append = T)
        cat(subset_df$description[i], "  \n", sep = "", file = my_write_file, append = T)
        cat("***Funded by:*** ", subset_df$funded_by[i], "  \n", sep = "", file = my_write_file, append = T)
        cat("***Duration:*** ", subset_df$duration[i], "  \n", sep = "", file = my_write_file, append = T)
        cat("***More info [here](", subset_df$link[i], ")***\n\n", sep = "", file = my_write_file, append = T)
      }
      
    }
    
  }else{ # all other chapters
    
    for (type in types) {
      cat("## ", type, "\n\n", sep = "", file = my_write_file, append = T)
      
      subset_df <- chapter_contents[chapter_contents$type == type, ]
      
      for (i in seq_len(nrow(subset_df))) {
        cat("### [", subset_df$title[i], "](", subset_df$link[i], ")\n\n", sep = "", file = my_write_file, append = T)
        cat("![Screenshot of ", subset_df$title[i], "]({{ '", subset_df$screenshot[i], "' | relative_url }})\n\n", sep = "", file = my_write_file, append = T)
        cat(subset_df$description[i], "  \n", sep = "", file = my_write_file, append = T)
        cat("***More info [here](", subset_df$link[i], ")***\n\n", sep = "", file = my_write_file, append = T)
      }
      
    }
    
  }

}
