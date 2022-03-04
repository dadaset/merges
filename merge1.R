# PROJETO: Base Alpha SENNA -RJ
#
# OBJETIVO: Esse script junta as bases do Saerjinho de língua portuguesa e matemática (apenas para o 
# 3º ano), depois une com as bases identificadores
#
#
# AUTOR: Artur Coelho
#   
# DATA DE CRIACAO: 02/2022
#---------------------------------------------------------------------------------------




# Limpa environment
rm(list = ls())

# Pacotes 
pacotes <- c('rio',        # Versao: 0.5.26
             'dplyr',      # Versao: 1.0.5
             'stringr',    # Versao: 1.4.0
             'openxlsx',   # Versao: 4.2.3
             'fuzzyjoin',   # Versao: 0.1.6
             'data.table',
             'stringdist',
             "readr"
)

# lapply(pacotes, packageVersion)
sapply(pacotes, require,character.only = T)

# Caminhos
dados_brutos         <- "path/to/each/file"
dados_intermediarios <- "path/to/each/file"
dados_saerjinho      <- "path/to/each/file" 
programas            <- "path/to/each/file"
programas_alpha      <- "path/to/each/file"
dados_desafio        <- "path/to/each/file"
dados_inter_saerji   <- "path/to/each/file"

options(scipen = 999) # Mantem valores com muitos digitos sem notacao cientifica



######                Merge Matemática e Base Identificadores ######


# Importando base identificadores-----
base_identificadores <- 
  import(paste0(dados_intermediarios,"identificadores_base_pilotao.csv")) %>% 
  select(-c(
    "idnt_ano","idnt_municipio","idnt_escola","idnt_turma","idnt_aluno")) %>% 
  
  # Mantem apenas alunos do 3 ano do EM
  
  filter(idnt_etapa == '3') 

# baixar bases matemática do terceiro bimestre 


saerji_mat <- read.xlsx(
  paste0(dados_saerjinho,
         "2013/3º Bimestre de 2013/_Microdados_Saerjinho 2013_MAT_3º Bimestre.xlsx"))

# Tirando variáveis "REDE","REGIONAL","TURNO","TURMA"

saerji_mat <- saerji_mat %>% 
  select(-c("REDE","REGIONAL","TURNO","TURMA" ))




# Juntar as duas bases com merge pelo CD_ALUNO (base_identificadores) = Matricula (serji)

inner_join_ident_saerji_mat <- inner_join(base_identificadores,
                 saerji_mat,
                 by = c('CD_ALUNO' = 'MATRICULA' ))


#### Portugues ####


saerji_port <- read.xlsx(
  paste0(dados_saerjinho,
         "2013/3º Bimestre de 2013/_Saerjinho_L Portuguesa_3Bim_2013.xlsx"))


saerji_port <- saerji_port %>% 
  select(-c("REDE","REGIONAL","TURNO","TURMA" ))

# Fazendo o merge de saerji portugues com a base identificadores

inner_join_ident_saerji_port <- inner_join(base_identificadores,
                                           saerji_port,
                                           by = c('CD_ALUNO' = 'MATRICULA' ))


# checando paraemento entre inner_join_mat com identificadores


nrow(inner_join_port)/nrow(base_identificadores)


# left anti_join entre base ident e saerji para entender o que não tem em comum nas bases

anti_join_left_port <- anti_join(base_identificadores, 
                                 saerji_port,
                                 by = c('CD_ALUNO' = 'MATRICULA' ))

# left anti_join entre base ident e saerji para entender o que não tem em comum nas bases

anti_join_right_port <- anti_join(saerji_port,
                                  base_identificadores,
                                  by = c('MATRICULA' = 'CD_ALUNO'))


# fazendo o stringdist para encontrar matches inexatos

gc()


base_stringdist<-stringdist_inner_join(
  anti_join_left_port,anti_join_right_port, by = c('nome_aluno' = 'ALUNO'),
  max_dist= 3,
  distance_col='diferenca')

gc()


#Fazendo o merge final

inner_join_ident_final <- inner_join(inner_join_ident_saerji,
                                     inner_join_ident_saerji_port,
                                           by = c('CD_ALUNO'))

write.csv(inner_join_ident_final,
          'C:/Users/dadaset/Desktop/LEPES/Salvar na pasta novo\\Base_merge.csv')



