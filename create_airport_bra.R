library(data.table)
library(flightsbr)
library(dplyr)
library(airportr)


# get Brazilian airports
airports_br <- flightsbr::read_airports(type = 'public') |>
  janitor::clean_names() |>
  dplyr::select( icao_code = 'codigo_oaci',
                 city_name = 'municipio_atendido')


# manually add canoas airport
airports_br <- rbind(airports_br, 
                  data.frame(icao_code='SBCO', 
                             city_name='Canoas'))

# a few codes missing
df_airport_codes <- dplyr::tribble(
  ~icao_code, ~iata_code,
  "SBAM",	"MCP",
  "SNAL",	"APQ",
  "SWBC",	"BAZ",
  "SBBE",	"BEL",
  "SBCF",	"CNF",
  "SBBH",	"PLU",
  "SBBV",	"BVB",
  "SBBR",	"BSB",
  "SBCD",	"CFC",
  "SBKP",	"VCP",
  "SDAM",	"CPQ",
  "SNRU",	"CAU",
  "SWCA",	"CAF",
  "SWKO",	"CIZ",
  "SBAA",	"CDJ",
  "SBCZ",	"CZS",
  "SBBI",	"BFH",
  "SBCT",	"CWB",
  "SWFJ",	"FEJ",
  "SBFL",	"FLN",
  "SBFZ",	"FOR",
  "SBFI",	"IGU",
  "SBZM",	"IZA",
  "SBGO",	"GYN",
  "SBGR",	"GRU",
  "SBIZ",	"IMP",
  "SBJE",	"JJD",
  "SBJV",	"JOI",
  "SBJP",	"JPA",
  "SBJF",	"JDF",
  "SBJD",	"QDV",
  "SBMQ",	"MCP",
  "SBEG",	"MAO",
  "SBMO",	"MCZ",
  "SBMS",	"MVF",
  "SBNF",	"NVT",
  "SBSG",	"NAT",
  "SBPB",	"PHB",
  "SSZW",	"PGZ",
  "SBPA",	"POA",
  "SBPV",	"PVH",
  "SBRF",	"REC",
  "SBRP",	"RAO",
  "SBRB",	"RBR",
  "SBRJ",	"SDU",
  "SBGL",	"GIG",
  "SBRD",	"ROO",
  "SBSM",	"RIA",
  "SBST",	"SSZ",
  "SBSV",	"SSA",
  "SDSC",	"QSC",
  "SBSL",	"SLZ",
  "SBSP",	"CGH",
  "SWSN",	"ZMD",
  "SDCO",	"SOD",
  "SBTT",	"TBT",
  "SBTK",	"TRQ",
  "SBTF",	"TFF",
  "SBTE",	"THE",
  "SBBC",	"QAV",
  "SBPP",	"PMG",
  "SBCR",	"CMG",
  "SBBG",	"BGX",
  "SBCH",	"XAP",
  "SBDN",	"PPB",
  "SBHT",	"ATM",
  "SBAN",	"APS",
  "SBAU",	"ARU",
  "SBAQ",	"AQA",
  "SBCB",	"CFB",
  "SBCG",	"CGR",
  "SBCA",	"CAC",
  "SBME",	"MEA",
  "SBPK",	"PET",
  "SBPJ",	"PMW",
  "SBPC",	"POO",
  "SBSJ",	"SJK",
  "SBQV",	"VDC",
  "SBMG", "MGF", # maringa
  "SBLO", "LDB", # londrina
  "SBIL", "IOS", # ilheus
  "SBPS", 'BPS', # portoseguro  
  "SBSR", 'SJP', # sao jose do rio preto
  "SBMK", 'MOC', # montes calros
  "SBCO", "QNS", # canoas
  "SBCY", "CGB", # cuiaba
  "SBPL", "PNZ", # petrolina
  "SBVT", "VIX", # vitoria
  "SBVC", "VDC", # vitoria da consquista
  "SBJU", "JDO", # juazeiro do norte
  "SBAR", "AJU", # aracaju
  "SBSN", "STM"  # santarem
)

data.table::setDT(df_airport_codes)

airports_br[df_airport_codes, on='icao_code', iata_code := i.iata_code]


# camel case for city names
airports_br[, city_name  := snakecase::to_title_case(city_name , sep_out=' ')]
airports_br[, city_name  := gsub(" De ", " de ", city_name )]
airports_br[, city_name  := gsub(" Da ", " da ", city_name )]
airports_br[, city_name  := gsub(" Do ", " do ", city_name )]
airports_br[, city_name  := gsub(" Das ", " das ", city_name )]
airports_br[, city_name  := gsub(" Dos ", " dos ", city_name )]


# a few IATA codes missing
airports_all <- airportr::airports
data.table::setDT(airports_all)
airports_br[airports_all, on=c('icao_code'='ICAO'), iata_code2 := i.IATA]


airports_br[, iata_code := ifelse(is.na(iata_code),iata_code2,iata_code)]
airports_br[, iata_code2 := NULL]

airports_br$country <- "BRA"

setcolorder(airports_br, c('country', 'city_name', 'iata_code', 'icao_code'))

# 
# # get missing info
# airports_df <- airportr::airports
# 
# airports_df <- airports_df |>
#   select(country = "Country Code (Alpha-3)",
#          city_name  = "City"  ,
#          iata_code = "IATA" ,
#          icao_code= "ICAO")
# 
# airports_df <- filter(airports_df, country == "BRA")
# df2 <- rbind(df, missing_airports)
# df2 <- unique(df2)
# 
# df2 <- filter(df2, iata_code != "\\N")


# save table
data.table::fwrite(airports_br, './data-raw/airports_bra.csv', encoding = 'UTF-8')
arrow::write_parquet(airports_br, './data-raw/airports_bra.parquet')
