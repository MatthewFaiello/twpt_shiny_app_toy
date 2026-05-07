# ==== THEME VALUES ====
#
# This file stores Delaware DOE-inspired colors and plot theme settings.
#
# These objects are used by:
# - ui.R
# - plot helpers


# ==== DELAWARE DOE COLORS ====

DDOE_COLORS <-
  list(
    navy = "#103957",
    blue = "#155D8C",
    light_blue = "#1F7FC0",
    gold = "#E79924",
    light_gray = "#E7EEF3",
    dark_gray = "#2F3A40",
    white = "#FFFFFF"
  )

DDOE_ROW_COLORS <-
  c(
    "Observed LEA data" = DDOE_COLORS$blue,
    "Forecast from app inputs" = DDOE_COLORS$gold
  )

DDOE_ROW_LINETYPES <-
  c(
    "Observed LEA data" = "solid",
    "Forecast from app inputs" = "dashed"
  )


# ==== DELAWARE DOE PLOT THEME ====

theme_ddoe <-
  function(base_size = 13) {
    
    theme_minimal(base_size = base_size) +
      theme(
        plot.title = element_text(
          color = DDOE_COLORS$blue,
          face = "bold",
          size = base_size + 4
        ),
        
        plot.subtitle = element_text(
          color = DDOE_COLORS$dark_gray,
          size = base_size
        ),
        
        axis.title = element_text(
          color = DDOE_COLORS$navy,
          face = "bold"
        ),
        
        axis.text = element_text(
          color = DDOE_COLORS$dark_gray
        ),
        
        panel.grid.major = element_line(
          color = DDOE_COLORS$light_gray,
          linewidth = 0.4
        ),
        
        panel.grid.minor = element_blank(),
        
        legend.position = "bottom",
        
        legend.title = element_blank(),
        
        legend.text = element_text(
          color = DDOE_COLORS$dark_gray
        ),
        
        plot.background = element_rect(
          fill = DDOE_COLORS$white,
          color = NA
        ),
        
        panel.background = element_rect(
          fill = DDOE_COLORS$white,
          color = NA
        )
      )
  }



