df <- data.table::fread('./data-raw/airports_int.csv')

# get missing icaos
missing_icaos <- df100$destino[which(is.na(df100$dest_iata))] |> unique()

# get missing info
airports_df <- airportr::airports

missing_airports <- dplyr::filter(airports_df, ICAO %in% missing_icaos) |>
  select(country = "Country Code (Alpha-3)",
         city_name  = "City"  ,
         iata_code = "IATA" ,
         icao_code= "ICAO")


df2 <- rbind(df, missing_airports)
df2 <- unique(df2)

df2 <- filter(df2, iata_code != "\\N")

data.table::fwrite(df2, './data-raw/airports_int.csv', encoding = 'UTF-8')

arrow::write_parquet(df2, './data-raw/airports_int2.parquet')


arrow::read_parquet('./data-raw/airports_int.parquet')
