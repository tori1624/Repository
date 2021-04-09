# packages
library(ggplot2)

# data(1)
x <- rep(c("OA", "PC", "PT", "Walk"), 3)
accuracy <- c(67.2, 55.7, 67.1, 72.4, 65.8, 58.4, 65.2, 68.7,
              71.4, 61.3, 70.7, 76.3)
Model <- rep(c("MNL", "DT", "SVM"), each = 4)
accuracy.df <- data.frame(x, accuracy, Model)

# visualization(1)
ggplot(accuracy.df, aes(x = x, y = accuracy, group = Model,
                        shape = Model)) +
  geom_point(size = 3, alpha = 0.8) +
  geom_path(alpha = 0.7) +
  geom_text(aes(label = accuracy), vjust = -0.9, color = "black") +
  scale_colour_brewer(palette = "Set1") +
  ylim(55, 80) + labs(x = "", y = "Accuracy") +
  theme_light() + theme(text = element_text(size = 17.5))

ggplot(accuracy.df, aes(x = x, y = accuracy, color = Model, group = Model,
                        shape = Model)) +
  geom_point(size = 4, alpha = 0.8) +
  geom_path(alpha = 0.7) +
  geom_text(aes(label = accuracy), vjust = -0.9, color = "black") +
  scale_colour_brewer(palette = "Set1") +
  facet_grid(Model ~ ., scales = "free_y") +
  ylim(50, 80) + labs(x = "", y = "Accuracy") +
  theme_light()

ggplot(accuracy.df, aes(x = x, y = accuracy, fill = Model)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = accuracy), vjust = -0.9, color = "black",
            position = position_dodge(.9)) +
  scale_fill_brewer(palette = "Set1") + 
  labs(x = "", y = "Accuracy") +
  theme_light()

# data(2)
x2 <- factor(rep(c("PC", "PT", "Walk"), 9))
accuracy2 <- c(51.8, 58.4, 82.9, 87.4, 85.0, 77.0, 69.6, 71.7, 79.9,
               44.7, 56.8, 84.9, 90.3, 84.1, 71.8, 67.5, 70.4, 78.4,
               54.9, 63.7, 84.9, 88.8, 86.2, 79.7, 71.8, 75.0, 82.3)
accuracy.type <- rep(c("Sensitivity", "Specificity", "BA"), 3, each = 3)
Model <- rep(c("MNL", "DT", "SVM"), each = 9)
accuracy.df2 <- data.frame(x2, accuracy2, accuracy.type, Model)

# visualization(2)
ggplot(accuracy.df2, aes(x = x2, y = accuracy2, group = Model,
                        shape = Model)) +
  geom_point(size = 3, alpha = 0.8) +
  geom_line(alpha = 0.7) +
  scale_colour_brewer(palette = "Set1") +
  facet_grid(accuracy.type ~ ., scales = "free_y") +
  labs(x = "", y = "Accuracy") + theme_light() +
  theme(text = element_text(size = 17.5))
