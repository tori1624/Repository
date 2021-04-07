# ------------------------------------------------------------------------------
# assignment 1
# 석사 1기 이영호
# 2019/03/28
# ------------------------------------------------------------------------------

setwd("D:/Study/2019/Rgraphics/assign1/")
png(filename = "assign1_이영호.png", width = 600, height = 750)

# margin
par(mar = c(1.5, 1.5, 2, 0.75))

# plot
plot.new()
plot.window(xlim = c(-4, 4), xaxs = "i", ylim = c(-5, 5), yaxs = "i")

# line(background)
for (i in c(-4:-1, 1:4)) {
  for (j in c(-5:-1, 1:5)) {
    abline(h = i, v = j, col = "grey")
  }
}
abline(h = 0, v = 0)

# line(exponential, log)
x <- seq(-4, 4, length.out = 10000)
y <- seq(0, 4, length.out = 10000)

lines(x, exp(x))
lines(y, log(y), lty = 2)

# axis
axis(side = 1, at = -4:-1, tick = FALSE, pos = 0, outer = TRUE,
     padj = -1.1, hadj = 1.45)
axis(side = 1, at = c(0, 1, 3, 4), tick = FALSE, pos = 0, outer = TRUE,
     padj = -1.1, hadj = 1.75)
axis(side = 1, at = 2, tick = FALSE, pos = 0, outer = TRUE,
     padj = -1.1, hadj = 1.8)
axis(side = 2, at = -1:-2, tick = FALSE, pos = 0, outer = TRUE, las = 2,
     padj = 1.5, hadj = 0.1)
axis(side = 2, at = -3:-5, tick = FALSE, pos = 0, outer = TRUE, las = 2,
     padj = 1.55, hadj = 0.1)
axis(side = 2, at = 1:3, tick = FALSE, pos = 0, outer = TRUE, las = 2,
     padj = 1.5, hadj = -.4)
axis(side = 2, at = 4:5, tick = FALSE, pos = 0, outer = TRUE, las = 2,
     padj = 1.6, hadj = -.4)

# legend
legend(x = 1.7, y = -3.68, legend = c("Exponential", "Log"), lty = c(1, 2), 
       cex = 1.01)

# box
box()

# title
title("The Log and Exponential Functions")

dev.off()