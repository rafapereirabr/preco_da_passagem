painel de grafico interativo
https://albert-rapp.de/posts/ggplot2-tips/17_ggiraph/17_ggiraph.html
https://stackoverflow.com/questions/63358511/create-interactive-bar-chart-with-shared-data-filtered-by-time-range
https://stackoverflow.com/questions/52321695/filter-a-plotly-line-chart-based-on-categorical-variable


# https://www.anac.gov.br/acesso-a-informacao/dados-abertos/areas-de-atuacao/voos-e-operacoes-aereas/tarifas-aereas-domesticas/46-tarifas-aereas-domesticas

df_int <- flightsbr::read_airfares(
  date = 202406,
  domestic = FALSE
  ) |>
  janitor::clean_names()

# filter classe economica Y
df_int <- df_int[ classe_volta == "Y", ]


# fix numeric columns
df_int[, tarifa := gsub(',', '.', tarifa)]
df_int[, tarifa := as.numeric(tarifa)]
df_int[, assentos := as.numeric(assentos)]






df_int[, od_pair := paste0(pmin(origem, destino), "-", pmax(origem, destino))]
df_int[, id := .GRP, by = od_pair]


# determine top 100 OD pairs
od_rank <- df_int[, .(total_demand = sum(assentos)),
                  by = .(id, od_pair)][order(-total_demand)]

od_rank <- od_rank |>
  dplyr::slice_max(order_by = total_demand, n = 100) |>
  mutate( ranking = 1:100)

# filter raw data only for top 100 and bring raking column
df_int_100 <- df_int[ id %in% od_rank$id]
df_int_100[od_rank, on='id', ranking := i.ranking]

# calculate reference values
df <- df_int_100[, .(passageiros = sum(assentos),
                     minima = min(tarifa),
                     q25 = Hmisc::wtd.quantile(x = tarifa, weights=assentos,probs = 0.25),
                     media = weighted.mean(x = tarifa, w=assentos),
                     q75 = Hmisc::wtd.quantile(x = tarifa, weights=assentos,probs = 0.75),
                     maxima = max(tarifa)
                     ),
                 by = .(id, ranking, origem, destino)][order(ranking)]


df100 <- df[, .(passageiros = sum(passageiros),
                # minima = sum(minima),
                q25 = sum(q25),
                media = sum(media),
                q75 = sum(q75)
                #, maxima = sum(maxima)
                ),
            by = .(id, ranking)][order(ranking)]



# bring OD pair info back
df100[df_int_100, on='id', od_pair := i.od_pair ]
df100[, origem := substring(od_pair, 1, 4)]
df100[, destino := substring(od_pair, 6, 9)]

head(df100)


# add airport information
airports <- data.table::fread('./data-raw/int_airports.csv')

# head(airports)

airports[df_airport_codes, on=c('codigo_oaci'='icao_code'), iata:= i.iata_code]


df100[airports,
      on=c('origem'='icao_code'),
      c('orig_iata', 'orig_muni') := list(i.iata_code, i.city_name )]

df100[airports,
      on=c('destino'='icao_code'),
      c('dest_iata', 'dest_muni') := list(i.iata_code, i.city_name )]







# reorganize origem and destino columns
df100[, De := paste0(orig_muni," (",orig_iata,")")]
df100[, Para := paste0(dest_muni," (",dest_iata,")")]

# round values
cols <- c('q25', 'media', 'q75')
df100 <- df100 |> mutate_at(cols, ~round(.,1))


# rename and reorder columns
df_output <- df100[order(ranking)] |>
  select(Ranking = ranking,
         De,
         Para,
         `N. de passageiros` = passageiros,
         Q25 = q25,
         Média = media,
         Q75 = q75
  )


quak::quak(df_output)
