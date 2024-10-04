# painel de grafico interativo
# https://albert-rapp.de/posts/ggplot2-tips/17_ggiraph/17_ggiraph.html
# https://stackoverflow.com/questions/63358511/create-interactive-bar-chart-with-shared-data-filtered-by-time-range
# https://stackoverflow.com/questions/52321695/filter-a-plotly-line-chart-based-on-categorical-variable
# https://www.anac.gov.br/acesso-a-informacao/dados-abertos/areas-de-atuacao/voos-e-operacoes-aereas/tarifas-aereas-domesticas/46-tarifas-aereas-domesticas


# camobio
library(rbcb)

cambio <- rbcb::get_currency(
  symbol = "USD",
  start_date = "2022-03-01", 
  end_date = "2022-04-01"
)

Ask(cambio)
