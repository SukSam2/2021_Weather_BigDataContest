

################-----------------------0. packages------------------------------#####################

library(dplyr)
library(stringr)
library(lubridate)
library(tidyverse)
library(tidyr)
library(sqldf)
library(car) 
library(mice) 
library(cluster) 
library(fpc) 
library(randomForest)

library(readxl)
library(rpart)
library(rattle)
library(ggplot2) 
library(gridExtra)
library(vars)
library(forecast)
library(wordcloud2)
library(devtools)
library(RColorBrewer)

#################--------------------1-1.rearrange categories  ----------------###################### 

#buy_all : 온라인 구매 raw data 
#sns_all : SNS raw data 
#food_cat2 : 재정립한 카테고리 


buy_all <- read.csv("buy_all.csv", header=TRUE, sep=',') %>% mutate(sm_cat=str_trim(sm_cat)) 
sns_all <- read.csv("sns_all.csv", header=TRUE, sep=',') %>% mutate(sm_cat=str_trim(sm_cat)) 
food_cat <- read.csv("food_cat2.csv", header=TRUE, sep=',') 

buy_all_2 <-buy_all %>% left_join(food_cat, by=c('sm_cat'))
sns_all_2 <-sns_all %>% left_join(food_cat, by=c('sm_cat')) 

################# ---------------------------1-2. EDA -----------------------################# 



beauty_all <-read.csv(beauty_all, "beauty_all.csv", fileEncoding = 'utf-8')
nnb_all <- read.csv(nnb_all, "nnb_all.csv", fileEncoding = 'utf-8')
sp_all <- read.csv(sp_all, "sp_all.csv", fileEncoding = 'utf-8')



sp_all%>%
  group_by(sm_cat)%>%summarize(day_qty=sum(qty))%>%
  arrange(desc(day_qty))%>%
  head(3)

food <- sp_all%>%
  group_by(date,sm_cat)%>%summarize(day_qty=sum(qty))%>%
  arrange(date)

food_top_3 <- food%>%
  filter(sm_cat %in% c("생수","커피음료","회"))%>%
  mutate(date=ymd(date))

ggplot(food_top_3,aes(x=date,y=day_qty,group=sm_cat,color=sm_cat))+
  geom_line()+
  labs(y="day_count")+
  theme_bw() +
  labs(col = "제품")


beauty_all%>%
  group_by(sm_cat)%>%summarize(day_qty=sum(qty))%>%
  arrange(desc(day_qty)) %>% 
  head(3)
food <- sp_all%>%
  group_by(date,sm_cat)%>%summarize(day_qty=sum(qty))%>%
  arrange(date)

food_top_3 <- food%>%
  filter(sm_cat %in% c("생수","커피음료","회"))%>%
  mutate(date=ymd(date))


ggplot(food_top_3,aes(x=date,y=day_qty,group=sm_cat,color=sm_cat))+
  geom_line()+
  labs(y="day_count")+
  theme_bw() +
  labs(col = "제품")
food <- sp_all%>%
  group_by(date,sm_cat)%>%summarize(day_qty=sum(qty))%>%
  arrange(date)

food_top_3 <- food%>%
  filter(sm_cat %in% c("생수","커피음료","회"))%>%
  mutate(date=ymd(date))

ggplot(food_top_3,aes(x=date,y=day_qty,group=sm_cat,color=sm_cat))+
  geom_line()+
  labs(y="day_count")+
  theme_bw() +
  labs(col = "제품")


beauty <- buy_all_2%>%
  filter(big_cat=="뷰티")%>%
  group_by(date,sm_cat)%>%summarize(day_qty=sum(qty))%>%
  arrange(date)

beauty_top_3 <- beauty%>%
  filter(sm_cat %in% c("기초 화장용 크림","샴푸","기초 화장용 에센스"))%>%
  mutate(date=ymd(date))
head(beauty_top_3)

ggplot(beauty_top_3,aes(x=date,y=day_qty,group=sm_cat,color=sm_cat))+
  geom_line()+
  labs(y="day_count")+
  theme_bw() +
  labs(col = "제품")



nnb_all%>%
  group_by(sm_cat)%>%summarize(day_qty=sum(qty))%>%
  arrange(desc(day_qty)) %>% 
  head(3)

beauty <- beauty_all%>%
  group_by(date,sm_cat)%>%summarize(day_qty=sum(qty))%>%
  arrange(date)

beauty_top_3 <- beauty%>%
  filter(sm_cat %in% c("기초 화장용 크림","샴푸","기초 화장용 에센스"))%>%
  mutate(date=ymd(date))
head(beauty_top_3)

ggplot(beauty_top_3,aes(x=date,y=day_qty,group=sm_cat,color=sm_cat))+
  geom_line()+
  labs(y="day_count")+
  theme_bw() +
  labs(col = "제품")


nnb <- nnb_all%>%
  filter(big_cat=="냉난방가전")%>%
  group_by(date,sm_cat)%>%summarize(day_qty=sum(qty))%>%
  arrange(date)

nnb_top_3 <- nnb%>%
  filter(sm_cat %in% c("온열매트","공기정화 용품","공기청정기"))%>%
  mutate(date=ymd(date))
head(nnb)

ggplot(nnb_top_3,aes(x=date,y=day_qty,group=sm_cat,color=sm_cat))+
  geom_line()+
  labs(y="day_count")+
  theme_bw() +
  labs(col = "제품")








#################--------------------1-3.preprocessing ----------------###################### 


TA = read.csv("TA.csv");head(TA) 
RHM = read.csv("RHM.csv");head(RHM) 
RN = read.csv("RN.csv");head(RN) 
WIND = read.csv("WIND.csv");head(WIND) 
DUST = read.csv("dust_full.csv",);head(DUST)
#DUST <- read_xlsx("dust_full.xlsx");head(DUST)


TA_temp = TA %>% filter(stn_id %in% c(108, 202,98,203,119,99, 159)) %>% 
  select(tma_date, stn_id, avg_ta, max_ta, min_ta) %>% 
  mutate(area = ifelse(stn_id == 108, '서울', ifelse(stn_id == 159, '부산', '경기'))) %>% 
  group_by(tma_date, area) %>% summarize(avg_ta = mean(avg_ta, na.rm = T), max_ta = mean(max_ta, na.rm = T), min_ta = mean(min_ta, na.rm = T))
as_tibble(TA_temp)

TA_avg = TA_temp %>% select(tma_date, area, avg_ta) %>% 
  spread(area, avg_ta) %>% 
  rename('서울평균기온'='서울','경기평균기온'='경기','부산평균기온'='부산') 
TA_min = TA_temp %>% select(tma_date, area, min_ta) %>% 
  spread(area, min_ta) %>% 
  rename('서울최저기온'='서울','경기최저기온'='경기','부산최저기온'='부산') 
TA_max = TA_temp %>% select(tma_date, area, max_ta) %>% 
  spread(area, max_ta)  %>% 
  rename('서울최고기온'='서울','경기최고기온'='경기','부산최고기온'='부산') 

TA_fin = full_join(TA_avg, TA_min, by='tma_date')
TA_fin = full_join(TA_fin, TA_max, bu='tma_date')


RN_fin = RN %>% filter(stn_id %in% c(108, 202,98,203,119,99, 159)) %>% 
  select(tma_date, stn_id, sum_rn) %>% 
  mutate(area = ifelse(stn_id == 108, '서울', ifelse(stn_id == 159, '부산', '경기'))) %>% 
  group_by(tma_date, area) %>% summarize(sum_rn = mean(sum_rn, na.rm = T)) %>% 
  select(tma_date, area, sum_rn) %>% 
  spread(area, sum_rn) %>% 
  rename('서울일강수량'='서울','경기일강수량'='경기','부산일강수량'='부산')

as_tibble(RN_fin)


RHM_temp = RHM %>% filter(stn_id %in% c(108, 202,98,203,119,99, 159)) %>% 
  select(tma_date, stn_id, avg_rhm, min_rhm) %>% 
  mutate(area = ifelse(stn_id == 108, '서울', ifelse(stn_id == 159, '부산', '경기'))) %>% 
  group_by(tma_date, area) %>% summarize(avg_rhm = mean(avg_rhm, na.rm = T), min_rhm = mean(min_rhm, na.rm = T))
as_tibble(RHM_temp)

RHM_avg = RHM_temp %>% select(tma_date, area, avg_rhm) %>% 
  spread(area, avg_rhm) %>% 
  rename('서울평균습도'='서울','경기평균습도'='경기','부산평균습도'='부산') 
RHM_min = RHM_temp %>% select(tma_date, area, min_rhm) %>% 
  spread(area, min_rhm) %>% 
  rename('서울최저습도'='서울','경기최저습도'='경기','부산최저습도'='부산') 

RHM_fin = full_join(RHM_avg, RHM_min, by='tma_date')
as_tibble(RHM_fin)


WIND_temp = WIND %>% filter(stn_id %in% c(108, 202,98,203,119,99, 159)) %>% 
  select(tma_date, stn_id, avg_ws, max_ws, max_ins_ws) %>% 
  mutate(area = ifelse(stn_id == 108, '서울', ifelse(stn_id == 159, '부산', '경기'))) %>% 
  group_by(tma_date, area) %>% summarize(avg_ws = mean(avg_ws, na.rm = T), max_ws = mean(max_ws, na.rm = T), max_ins_ws = mean(max_ins_ws, na.rm = T))
as_tibble(WIND_temp)

WIND_avg = WIND_temp %>% select(tma_date, area, avg_ws) %>% 
  spread(area, avg_ws) %>% 
  rename('서울평균풍속'='서울','경기평균풍속'='경기','부산평균풍속'='부산') 
WIND_max = WIND_temp %>% select(tma_date, area, max_ws) %>% 
  spread(area, max_ws) %>% 
  rename('서울최고풍속'='서울','경기최고풍속'='경기','부산최고풍속'='부산') 
WIND_ins = WIND_temp %>% select(tma_date, area, max_ins_ws) %>% 
  spread(area, max_ins_ws)  %>% 
  rename('서울최고순간풍속'='서울','경기최고순간풍속'='경기','부산최고순간풍속'='부산') 

WIND_fin = full_join(WIND_avg, WIND_max, by='tma_date')
WIND_fin = full_join(WIND_fin, WIND_ins, bu='tma_date')

as_tibble(WIND_fin)
WIND_fin %>% nrow()


names(DUST)<-c("tma","pm10","pm25","sgg")
head(DUST)


DUST_temp = DUST %>% select(tma, sgg, pm10, pm25)
as_tibble(DUST_temp)

DUST_pm10 = DUST_temp %>% select(tma, sgg, pm10) %>% 
  spread(sgg, pm10) %>% 
  rename(tma_date = tma, '서울미세먼지'='1', '경기미세먼지'='2', '부산미세먼지'='3')

DUST_pm25 = DUST_temp %>% select(tma, sgg, pm25) %>% 
  spread(sgg, pm25) %>% 
  rename(tma_date = tma, '서울초미세먼지'='1', '경기초미세먼지'='2', '부산초미세먼지'='3')

DUST_fin = full_join(DUST_pm10, DUST_pm25, by='tma_date')
DUST_fin<-as_tibble(DUST_fin)


WTHR = cbind(TA_fin, RN_fin[,-1], RHM_fin[,-1], WIND_fin[,-1], DUST_fin[,-1])


head(WTHR)
nrow(TA_fin)
nrow(RN_fin[,-1])
nrow(RHM_fin[,-1])
nrow(WIND_fin[,-1])
nrow(DUST_fin[,-1])

write.csv(WTHR, "WTHR.csv", fileEncoding = "utf-8")



#################--------------1-4.imputation ----------------###################### 


na_sp_sm_cat = buy_all_2 %>% filter(big_cat =='식품')%>%
  distinct(sm_cat, date) %>% 
  group_by(sm_cat) %>% summarize(ndate = n()) %>%
  filter(ndate != 730) %>% select(sm_cat)

na_nnb_sm_cat = buy_all_2 %>% filter(big_cat =='냉난방가전')%>%
  distinct(sm_cat, date) %>% 
  group_by(sm_cat) %>% summarize(ndate = n()) %>%
  filter(ndate != 730) %>% select(sm_cat)

na_bt_sm_cat = buy_all_2 %>% filter(big_cat =='뷰티')%>%
  distinct(sm_cat, date) %>% 
  group_by(sm_cat) %>% summarize(ndate = n()) %>%
  filter(ndate != 730) %>% select(sm_cat)


tma=0
for( i in 1:730){
  tma[i] = as.character(ymd(20171231)+i)  
}
date = rep(tma,each = 10)

age=rep(rep(c(20,30,40,50,60), each = 2),730)
sex=rep(c('F', 'M'),730*5)

dat = data.frame(date, age, sex)



beauty = buy_all_2 %>% filter(big_cat == '뷰티') %>%
  select(date, age, sex, large_cat, sm_cat, qty) %>% 
  arrange(date, large_cat, sm_cat, age, sex)


bt_sm_cat= beauty %>% distinct(sm_cat)

dat[,4] = bt_sm_cat[1,]
dat_all = dat
for(i in 2:nrow(bt_sm_cat)){
  dat[,4] = bt_sm_cat[i,]
  dat_all = rbind(dat_all, dat)
}
nrow(dat_all)
names(dat_all) = c("date", "age", "sex", "sm_cat")

beauty_temp = left_join(dat_all, food_cat, by='sm_cat') %>% 
  select(date, age, sex, large_cat, sm_cat)
beauty_temp$date = as.integer(gsub('-','',beauty_temp$date))

as_tibble(beauty_temp)

beauty_buy = buy_all %>% filter(big_cat == "뷰티") %>% 
  select(date, age, sex, sm_cat, qty) %>% 
  arrange(date, sm_cat, age, sex)


as_tibble(beauty_buy)

beauty_all = full_join(beauty_temp, beauty_buy, by=c("date" = "date", "age"="age", "sex"="sex", "sm_cat"="sm_cat"))
beauty_all[is.na(beauty_all)] = 0



nnb = buy_all_2 %>% filter(big_cat == '냉난방가전') %>%
  select(date, age, sex, large_cat, sm_cat, qty) %>% 
  arrange(date, large_cat, sm_cat, age, sex)

nnb_sm_cat = nnb %>% distinct(sm_cat)

dat[,4] = nnb_sm_cat[1,]
dat_all = dat
for(i in 2:nrow(nnb_sm_cat)){
  dat[,4] = nnb_sm_cat[i,]
  dat_all = rbind(dat_all, dat)
}
nrow(dat_all)
names(dat_all) = c("date", "age", "sex", "sm_cat")

nnb_temp = left_join(dat_all, food_cat, by='sm_cat') %>% 
  select(date, age, sex, large_cat, sm_cat)
nnb_temp$date = as.integer(gsub('-','',nnb_temp$date))

as_tibble(nnb_temp)

nnb_buy = buy_all %>% filter(big_cat == "냉난방가전") %>% 
  select(date, age, sex, sm_cat, qty) %>% 
  arrange(date, sm_cat, age, sex)

as_tibble(nnb_buy)

nnb_all = full_join(nnb_temp, nnb_buy, by=c("date" = "date", "age"="age", "sex"="sex", "sm_cat"="sm_cat"))
nnb_all[is.na(nnb_all)] = 0


sp = buy_all_2 %>% filter(big_cat == '식품') %>%
  select(date, age, sex, large_cat, mid_cat, sm_cat, qty) %>% 
  arrange(date, large_cat, mid_cat, sm_cat, age, sex)

sp_sm_cat = sp %>% distinct(sm_cat)

dat[,4] = sp_sm_cat[1,]
dat_all = dat
for(i in 2:nrow(sp_sm_cat)){
  dat[,4] = sp_sm_cat[i,]
  dat_all = rbind(dat_all, dat)
}
nrow(dat_all)
names(dat_all) = c("date", "age", "sex", "sm_cat")

sp_temp = left_join(dat_all, food_cat, by='sm_cat') %>% 
  select(date, age, sex, large_cat, mid_cat, sm_cat)
sp_temp$date = as.integer(gsub('-','',sp_temp$date))

as_tibble(sp_temp)

sp_buy = buy_all %>% filter(big_cat == "식품") %>% 
  select(date, age, sex, sm_cat, qty) %>% 
  arrange(date, sm_cat, age, sex)

as_tibble(sp_buy)

sp_all = full_join(sp_temp, sp_buy, by=c("date" = "date", "age"="age", "sex"="sex", "sm_cat"="sm_cat"))
sp_all[is.na(sp_all)] = 0


write.csv(beauty_all, "beauty_all.csv", fileEncoding = 'utf-8')
write.csv(nnb_all, "nnb_all.csv", fileEncoding = 'utf-8')
write.csv(sp_all, "sp_all.csv", fileEncoding = 'utf-8')


#################--------------------2.standardization ---------------######################  

sm_sum = sqldf("select date, large_cat, mid_cat, sm_cat, sum(qty) as sum
                from sp_all
                group by date, large_cat, mid_cat, sm_cat")

sm_mean_sd = sqldf("select sm_cat, avg(sum) as mean, stdev(sum) as sd
                    from sm_sum
                    group by sm_cat")

sp_std = sqldf("select a.*, b.mean, b.sd
             from sm_sum as a left join sm_mean_sd as b
             on a.sm_cat = b.sm_cat
             order by a.sm_cat")

sp_std$z = (sp_std$sum - sp_std$mean)/sp_std$sd

with(sp_std, tapply(z,sm_cat,sd)) 
subset(sp_std, subset = (sd == 0)) 


sm_sum = sqldf("select date, large_cat, sm_cat, sum(qty) as sum
                from nnb_all
                group by date, large_cat, sm_cat")

sm_mean_sd = sqldf("select sm_cat, avg(sum) as mean, stdev(sum) as sd
                    from sm_sum
                    group by sm_cat")

nnb_std = sqldf("select a.*, b.mean, b.sd
             from sm_sum as a left join sm_mean_sd as b
             on a.sm_cat = b.sm_cat
             order by a.sm_cat")

nnb_std$z = (nnb_std$sum - nnb_std$mean)/nnb_std$sd

with(nnb_std, tapply(z,sm_cat,sd)) 
subset(nnb_std, subset = (sd == 0)) 


sm_sum = sqldf("select date, large_cat, sm_cat, sum(qty) as sum
                from beauty_all
                group by date, large_cat, sm_cat")

sm_mean_sd = sqldf("select sm_cat, avg(sum) as mean, stdev(sum) as sd
                    from sm_sum
                    group by sm_cat")

beauty_std = sqldf("select a.*, b.mean, b.sd
             from sm_sum as a left join sm_mean_sd as b
             on a.sm_cat = b.sm_cat
             order by a.sm_cat")

beauty_std$z = (beauty_std$sum - beauty_std$mean)/beauty_std$sd

with(beauty_std, tapply(z,sm_cat,sd))
subset(beauty_std, subset = (sd == 0)) 


write.csv(sp_std, "sp_std.csv", fileEncoding = 'utf-8')
write.csv(nnb_std, "nnb_std.csv", fileEncoding = 'utf-8')
write.csv(beauty_std, "beauty_std.csv", fileEncoding = 'utf-8')

#################----------------------3.TEST ---------------------------------###############

food = subset(buy_all_2, subset = (big_cat == "식품"))
beauty = subset(buy_all_2, subset = (big_cat == "뷰티"))
appliances = subset(buy_all_2, subset = (big_cat == "냉난방가전"))

t.test(qty ~ sex, buy_all_2)
t.test(qty ~ sex, food)
t.test(qty ~ sex, beauty)
t.test(qty ~ sex, appliances)

#tapply(qty, age, mean)
oneway.test(qty ~ age, data = buy_all_2)

with(food, tapply(qty, age, mean))
oneway.test(qty ~ age, data = food)

with(beauty, tapply(qty, age, mean))
oneway.test(qty ~ age, data = beauty)

with(appliances, tapply(qty, age, mean))
oneway.test(qty ~ age, data = appliances)


#################--------------------4.PCA ---------------######################


weather = WTHR
wthr = weather[,-1]


navec <-NULL
for (i in 1:ncol(wthr)) {
  navec[i] <- wthr[,i] %>% is.na() %>% sum()  
}

wthr_mice = mice(wthr, m=5)
wthr_fin = complete(wthr_mice)

navec <-NULL
for (i in 1:ncol(wthr_fin)) {
  navec[i] <- wthr_fin[,i] %>% is.na() %>% sum()  
};navec

pca_wthr = prcomp(wthr_fin, center=TRUE, scale=TRUE)
pca_wthr
summary(pca_wthr)


pca_ta = prcomp(wthr_fin[,1:9], center=TRUE, scale=TRUE)
summary(pca_ta)

pca_rn = prcomp(wthr_fin[,10:18], center=TRUE, scale=TRUE)
summary(pca_rn)

pca_wind = prcomp(wthr_fin[,19:27], center = TRUE, scale = TRUE)
summary(pca_wind)

pca_pm = prcomp(wthr_fin[,28:33], center = TRUE, scale = TRUE)
summary(pca_pm)


plot(pca_wthr, type="l") 
plot(pca_ta, type="l") 
plot(pca_rn, type="l") 
plot(pca_wind, type="l") 
plot(pca_pm, type="l") 

wthr_index = array(0,c(730,5))

wthr_index[,1] = WTHR$tma_date
wthr_index[,2] = pca_ta$x[,1]
wthr_index[,3] = pca_rn$x[,1]
wthr_index[,4] = pca_wind$x[,1]
wthr_index[,5] = pca_pm$x[,1]

wthr_index = data.frame(wthr_index)
names(wthr_index) = c("date", "ta_index", "rn_index", "wind_index", "pm_index")
head(wthr_index)

weather = wthr_index
write.csv(weather, file = "WEATHER.csv", fileEncoding = "utf-8")

as_tibble(weather)

PCA_기온 = pca_ta$rotation[,1]
PCA_강수 = pca_rn$rotation[,1]
PCA_풍속 = pca_wind$rotation[,1]
PCA_먼지 = pca_pm$rotation[,1]


yv <- predict(pca_ta)[, 1] 
for(i in 1:9){
  plot(wthr_fin[,i], yv, pch = 16, xlab = colnames(wthr_fin)[i], ylab = "기온지수", col = "navy") 
}
yv <- predict(pca_rn)[, 1] 
for(i in 10:18){
  plot(wthr_fin[,i], yv, pch = 16, xlab = colnames(wthr_fin)[i], ylab = "강수/습도지수", col = "navy") 
}
yv <- predict(pca_wind)[, 1] 
for(i in 19:27){
  plot(wthr_fin[,i], yv, pch = 16, xlab = colnames(wthr_fin)[i], ylab = "풍속지수", col = "navy") 
}

yv <- predict(pca_pm)[, 1] 
for(i in 28:33){
  plot(wthr_fin[,i], yv, pch = 16, xlab = colnames(wthr_fin)[i], ylab = "미세먼지지수", col = "navy") 
}


#################--------------------5.hierarchical clustering ---------------######################

nnb_std <- read.csv("nnb_std.csv", header=TRUE, sep=',',fileEncoding = "utf-8") 
bt_std <- read.csv("beauty_std.csv", header=TRUE, sep=',',fileEncoding = "utf-8") 
sp_std <- read.csv("sp_std.csv", header=TRUE, sep=',',fileEncoding = "utf-8") 

sp_full <- sp_std %>% 
  select(date,mid_cat,z) %>% 
  group_by(date,mid_cat) %>% 
  summarize(mid_z=sum(z)) %>% 
  select(mid_cat,mid_z) %>% 
  group_by(mid_cat) %>% 
  summarize(max_z=max(mid_z),min_z=min(mid_z)) %>% 
  mutate(diff_z=max_z-min_z) %>% 
  select(mid_cat,diff_z) %>% 
  arrange(desc(diff_z))


sp_full_c = sp_full[,1:2]
sp_full_t = t(sp_full_c)[2,]
names(sp_full_t) = t(sp_full_c)[1,]

hc.complete_sp = hclust(dist(sp_full_t), method = "complete")
plot(hc.complete_sp, main="complete linkage")

sp_full %>% nrow()
clust <- numeric(57)
for(k in 3:57){
  clust[[k]] <- pam(sp_full_c, k) $ silinfo$ avg.width 
  k.best <- which.max(clust)}  

k.best  
rect.hclust(hc.complete_sp,k=3,border="red")
plot(silhouette(cutree(hc.complete_sp,k=3), dist=dist(sp_full_t),col=1:2))


bt_full <-bt_std %>% 
  select(date,large_cat,z) %>% 
  group_by(date,large_cat) %>% 
  summarize(large_z=sum(z)) %>% 
  select(large_cat,large_z) %>% 
  group_by(large_cat) %>% 
  summarize(max_z=max(large_z),min_z=min(large_z)) %>% 
  mutate(diff_z=max_z-min_z) %>% 
  select(large_cat,diff_z) %>% 
  arrange(desc(diff_z))


bt_full_c = bt_full[,1:2] 
bt_full_t = t(bt_full_c)[2,]
names(bt_full_t) = t(bt_full_c)[1,]


hc.complete_bt = hclust(dist(bt_full_t), method = "complete")
plot(hc.complete_bt, main="complete linkage")

bt_full_c %>% nrow()
clust <- numeric(14)
for(k in 3:13){
  clust[[k]] <- pam(bt_full_c, k) $ silinfo$ avg.width 
  k.best <- which.max(clust)}  

k.best 
rect.hclust(hc.complete_bt,k=3,border="red")
plot(silhouette(cutree(hc.complete_bt,k=3), dist=dist(bt_full_t),col=1:2))


nnb_full <-nnb_std %>% 
  select(date,large_cat,z) %>% 
  group_by(date,large_cat) %>% 
  summarize(large_z=sum(z)) %>% 
  select(large_cat,large_z) %>% 
  group_by(large_cat) %>% 
  summarize(max_z=max(large_z),min_z=min(large_z)) %>% 
  mutate(diff_z=max_z-min_z) %>% 
  select(large_cat,diff_z) %>% 
  arrange(desc(diff_z))

nnb_full_c = nnb_full[,1:2]
head(nnb_full_c)

nnb_full_t = t(nnb_full_c)[2,]
names(nnb_full_t) = t(nnb_full_c)[1,]

hc.complete_nnb = hclust(dist(nnb_full_t), method = "complete")
plot(hc.complete_nnb, main="complete linkage")

clust <- numeric(9)
for(k in 2:8){
  clust[[k]] <- pam(nnb_full_c, k) $ silinfo$ avg.width 
  k.best <- which.max(clust)}  

k.best 
rect.hclust(hc.complete_nnb,k=3,border="red")
plot(silhouette(cutree(hc.complete_nnb,k=3), dist=dist(nnb_full_t),col=1:2))



#################--------------------6.regression & VIF ---------------###################### 

nnb_Y <- read.csv("nnb_Y.csv", header=TRUE, sep=',',fileEncoding = "utf-8") 
beauty_Y <- read.csv("beauty_Y.csv", header=TRUE, sep=',',fileEncoding = "utf-8") 
sp_Y <- read.csv("sp_Y.csv", header=TRUE, sep=',',fileEncoding = "utf-8") 

cat_index = (sp_Y %>% distinct(mid_cat))$mid_cat; cat_index

for( i in 1: length(cat_index)){
  sp_temp = sp_Y %>% filter(mid_cat == cat_index[i]) %>% 
    select(buy_cnt, sns_cnt, ta_index, rn_index, wind_index, pm_index)
  head(sp_temp)
  
  m = lm(buy_cnt ~ sns_cnt + ta_index + rn_index + wind_index + pm_index,data = sp_temp)
  result = step(m, scope = list(lower ~ 1, upper = ~ sns_cnt + ta_index + rn_index + wind_index + pm_index), direction = "both")
  
  
  print("------------------------------------------")
  print(cat_index[i])
  print(vif(m) > 10)
  print(result$coefficients)
  print("------------------------------------------")
  
}


cat_index = (beauty_Y %>% distinct(large_cat))$large_cat; cat_index


for( i in 1: length(cat_index)){
  sp_temp = beauty_Y %>% filter(large_cat == cat_index[i]) %>% 
    select(buy_cnt, sns_cnt, ta_index, rn_index, wind_index, pm_index)
  head(sp_temp)
  
  m = lm(buy_cnt ~ sns_cnt + ta_index + rn_index + wind_index + pm_index, data = sp_temp)
  result = step(m, scope = list(lower ~ 1, upper = ~ sns_cnt + ta_index + rn_index + wind_index + pm_index), direction = "both")
  
  
  print("------------------------------------------")
  print(cat_index[i])
  print(vif(m) > 10)
  print(result$coefficients)
  print("------------------------------------------")
}



cat_index = (nnb_Y %>% distinct(large_cat))$large_cat; cat_index

for( i in 1: length(cat_index)){
  nnb_temp = nnb_Y %>% filter(large_cat == cat_index[i]) %>% 
    select(buy_cnt, sns_cnt, ta_index, rn_index, wind_index, pm_index)
  head(nnb_temp)
  
  m = lm(buy_cnt ~ sns_cnt + ta_index + rn_index + wind_index + pm_index, data = nnb_temp)
  result = step(m, scope = list(lower ~ 1, upper = ~ sns_cnt + ta_index + rn_index + wind_index + pm_index), direction = "both")
  
  
  print("------------------------------------------")
  print(cat_index[i])
  print(vif(m) > 10)
  print(result$coefficients)
  print("------------------------------------------")
  
}


#################--------------------7.VARX&ARIMAX---------------######################  


nnb_Y <- read.csv("nnb_Y.csv", header=TRUE, sep=',', fileEncoding = 'utf-8')
sp_Y <- read.csv("sp_Y.csv", header=TRUE, sep=',', fileEncoding = 'utf-8')
beauty_Y <- read.csv("beauty_Y.csv", header=TRUE, sep=',', fileEncoding = 'utf-8')


nnb_temp <- nnb_Y %>% select(date,large_cat,buy_cnt) %>% 
  group_by(date,large_cat) %>% summarize(tot_cnt=sum(buy_cnt))
nnb_temp %>% head()
nnb_Y_ts <-nnb_temp %>% spread(large_cat,tot_cnt)

sp_temp <- sp_Y %>% select(date,mid_cat,buy_cnt) %>% 
  group_by(date,mid_cat) %>% summarize(tot_cnt=sum(buy_cnt))
sp_temp %>% head()
sp_Y_ts = sp_temp %>% spread(mid_cat,tot_cnt)


beauty_temp <- beauty_Y %>% select(date,large_cat,buy_cnt) %>% 
  group_by(date,large_cat) %>% summarize(tot_cnt=sum(buy_cnt))
beauty_temp %>% head()
beauty_Y_ts <- beauty_temp %>% spread(large_cat,tot_cnt)

all_Y_ts <- full_join(sp_Y_ts,beauty_Y_ts, by='date')
all_Y_ts <- full_join(all_Y_ts,nnb_Y_ts, by='date')

all_Y_ts %>% head()

all_Y_ts = all_Y_ts[,-1]

#ARIMAX 

exogen0 = sp_Y %>% distinct(date, ta_index, rn_index, wind_index, pm_index);head(exogen0)
VARselect(all_Y_ts[,-1], type="trend", exogen = exogen0[,-1]);head(exogen0[,-1])


y = all_Y_ts[,-2];head(y)
x = exogen0[,-1];head(x)
tot = c(584:729);length(584:729)
forc_result = list()
forc_all = list()
for(j in 1:28){
  for(i in tot){
    timepoints_a = 1:i
    y_temp = ts(y[timepoints_a,j])  
    x_temp = ts(exogen0[timepoints_a,-1])
    var_temp = auto.arima(y_temp, xreg = as.matrix(x_temp))
    dum_temp = ts(x[(i+1),])
    forc_temp = forecast(var_temp, h=1, level=95, xreg = as.matrix(dum_temp))
    forc_result[[i]] = as.data.frame(forc_temp)
  }
  forc_fin = forc_result[[584]]
  for(i in c(585:729)){
    temp = forc_result[[i]]
    forc_fin = rbind(forc_fin, temp)
  }
  forc_all[[j]] = forc_fin
}  


VARselect(all_Y_ts[,-2], type="trend", exogen = exogen0[,-1]);head(exogen0[,-1])

y = all_Y_ts[,];
x = exogen0[,-1];
tot = c(584:729);
forc_result = list()

for(i in tot){
  timepoints_a = 1:i
  
  y_temp = ts(all_Y_ts[timepoints_a,-2])  
  x_temp = ts(exogen0[timepoints_a,-1])
  var_temp = VAR(y_temp, p=2, type='trend', exogen=x_temp)
  dum_temp = ts(x[(i+1),])
  forc_temp = forecast(var_temp, h=1, level=95, dumvar = dum_temp)
  forc_result[[i]] = as.data.frame(forc_temp)
}

forc_fin = forc_result[[584]]
tot = c(585:729);
for(i in tot){
  temp = forc_result[[i]]
  forc_fin = rbind(forc_fin, temp)
}
dim(forc_fin)
head(forc_fin)
tail(forc_fin)

names(forc_fin)=c("Time","cat",  "PointForecast", "Lo95", "Hi95")
as_tibble(forc_fin)
forc_fin %>% distinct(cat) %>% nrow()

result = forc_fin %>% select(Time, cat, PointForecast) %>% 
  spread(cat, PointForecast)
result$Time = as.numeric(result$Time)
result = result %>% arrange(Time) %>% select(-Time)

as_tibble(result)
as_tibble(all_Y_ts)

varx_forc = result

for(i in 1:28){ 
  temp[i] = sqrt(((sum((y[585:730,i] - varx_forc[,i])^2))/146))
}

mean(temp)  

temp=0
for(i in 1:28){ 
  temp[i] = sqrt((sum((as.data.frame(y[585:730,i]) - forc_all[[i]][1])^2))/146)
}
mean(temp)


var_x_fit <- VAR(all_Y_ts[1:90,-2], 2, type = 'trend',  
                 exogen = exogen0[1:90,-1])
forc_varx <- predict(var_x_fit, n.ahead = 2, dumvar = exogen0[91:92,-1])
plot(forc,main="")




###############--------8.model comparision (linear regression & random forest)---------###################### 

nnb_Y <-read.csv('nnb_Y.csv',header = T,sep=",",fileEncodin='utf-8') ;head(nnb_Y)
sp_Y <-read.csv('sp_Y.csv',header = T,sep=",",fileEncodin='utf-8') ;head(sp_Y)
bt_Y <-read.csv('beauty_Y.csv',header = T,sep=",",fileEncodin='utf-8') ;head(bt_Y)


set.seed(123) 
cat_index = (sp_Y %>% distinct(mid_cat))$mid_cat; cat_index
sp_result <- data.frame(Method = cat_index,
                        RMSE   = rep(0,length(cat_index)),
                        MAE    = rep(0,length(cat_index)))

for( i in 1: length(cat_index)){
  sp_temp = sp_Y%>% filter(mid_cat == cat_index[i]) %>% 
    select(buy_cnt, sns_cnt, ta_index, rn_index, wind_index, pm_index)
  
  index <- sample(1:nrow(sp_temp),size = 0.7*nrow(sp_temp)) 
  sp_train <-sp_temp[index,] 
  sp_test <-sp_temp[-index,] 
  
  m = lm(buy_cnt ~ sns_cnt + ta_index + rn_index + wind_index + pm_index,data = sp_train)
  result = step(m, scope = list(lower ~ 1, upper = ~ sns_cnt + ta_index + rn_index + wind_index + pm_index),
                direction = "both")
  
  test.pred.lin <- (predict(m,sp_test))
  
  RMSE.lin.reg <- sqrt(mean((test.pred.lin-sp_test$buy_cnt)^2))
  sp_result[i,2] <-RMSE.lin.reg
  
  MAE.lin.reg <- mean(abs(test.pred.lin-sp_test$buy_cnt))
  sp_result[i,3] <-MAE.lin.reg
}
sp_result 


set.seed(123) 
cat_index = (bt_Y %>% distinct(large_cat))$large_cat; cat_index
bt_result <- data.frame(Method = cat_index,
                        RMSE   = rep(0,length(cat_index)),
                        MAE    = rep(0,length(cat_index)))

bt_result

for( i in 1: length(cat_index)){
  bt_temp = bt_Y%>% filter(large_cat == cat_index[i]) %>% 
    select(buy_cnt, sns_cnt, ta_index, rn_index, wind_index, pm_index)
  
  index <- sample(1:nrow(bt_temp),size = 0.8*nrow(bt_temp)) 
  bt_train <- bt_temp[index,] 
  bt_test <-bt_temp[-index,] 
  
  m = lm(buy_cnt ~ sns_cnt + ta_index + rn_index + wind_index + pm_index,data = bt_train)
  result = step(m, scope = list(lower ~ 1, upper = ~ sns_cnt + ta_index + rn_index + wind_index + pm_index), direction = "both")
  
  test.pred.lin <- (predict(m,bt_test))
  
  RMSE.lin.reg <- sqrt(mean((test.pred.lin-bt_test$buy_cnt)^2))
  bt_result[i,2] <-RMSE.lin.reg
  
  MAE.lin.reg <- mean(abs(test.pred.lin-bt_test$buy_cnt))
  bt_result[i,3] <-MAE.lin.reg
}
bt_result 

set.seed(123) 


nnb_result <- data.frame(Method = cat_index,
                         RMSE   = rep(0,length(cat_index)),
                         MAE    = rep(0,length(cat_index)))

nnb_result
head(nnb_train)

cat_index = (nnb_Y %>% distinct(large_cat))$large_cat; cat_index


for( i in 1: length(cat_index)){
  nnb_temp = nnb_Y%>% filter(large_cat == cat_index[i]) %>% 
    select(buy_cnt, sns_cnt, ta_index, rn_index, wind_index, pm_index)
  
  index <- sample(1:nrow(nnb_temp),size = 0.7*nrow(nnb_temp)) 
  nnb_train <- nnb_temp[index,] 
  nnb_test <-nnb_temp[-index,] 
  
  m = lm(buy_cnt ~ sns_cnt + ta_index + rn_index + wind_index + pm_index,data = nnb_train)
  result = step(m, scope = list(lower ~ 1, upper = ~ sns_cnt + ta_index + rn_index + wind_index + pm_index), direction = "both")
  
  test.pred.lin <- (predict(m,nnb_test))
  
  RMSE.lin.reg <- sqrt(mean((test.pred.lin-nnb_test$buy_cnt)^2))
  nnb_result[i,2] <-RMSE.lin.reg
  
  MAE.lin.reg <- mean(abs(test.pred.lin-nnb_test$buy_cnt))
  nnb_result[i,3] <-MAE.lin.reg
}
nnb_result


a <-rbind(sp_result,bt_result,nnb_result) %>%filter(!(Method %in% c('건강기능식품'))) %>% select(RMSE)
apply(a,2,mean)



set.seed(123)
nnb_Y <-nnb_Y%>%rename(cat=large_cat) %>%select(-X.1,-X)
sp_Y <-sp_Y %>%rename(cat=mid_cat) %>%select(-X) %>% filter(!(cat %in% c('건강기능식품')))
bt_Y <-bt_Y%>%rename(cat=large_cat) %>%select(-X.1,-X)
full_Y<-rbind(nnb_Y,sp_Y,bt_Y)

cat_index = (full_Y %>% distinct(cat))$cat 


RMSE_BOX <- 0
for ( i in 1: length(cat_index)) {
  full_temp = full_Y %>% filter(cat == cat_index[i]) %>% 
    select(buy_cnt,sns_cnt,ta_index,rn_index,wind_index,pm_index)
  index<- sample(1:nrow(full_temp), size=0.8*nrow(full_temp))
  train <- full_temp[index, ] 
  test <- full_temp[-index,]
  rf <- randomForest(buy_cnt ~ ., data = train, importance = TRUE, ntree=200)
  which.min(rf$mse)
  test.pred.forest <- predict(rf,test)
  RMSE.forest <- sqrt(mean((test.pred.forest-test$buy_cnt)^2))
  MAE.forest <- mean(abs(test.pred.forest-test$buy_cnt))
  
  RMSE_BOX <-c(RMSE_BOX , RMSE.forest)
  
}

mean(RMSE_BOX[2:29])



#################--------------------9.correlation coefficient---------------------######################  

sp_raw <- read.csv("sp_Y.csv", header=TRUE, sep=',',fileEncoding = "utf-8") 
nnb_raw <- read.csv("nnb_Y.csv", header=TRUE, sep=',',fileEncoding = "utf-8") 
bt_raw <- read.csv("beauty_Y.csv", header=TRUE, sep=',',fileEncoding = "utf-8") 


full_raw <-rbind(nnb_raw %>% 
                   dplyr::select(-X.1,-X,date,large_cat,sns_cnt,buy_cnt),
                 bt_raw %>% 
                   dplyr::select(-X.1,-X,date,large_cat,sns_cnt,buy_cnt),
                 sp_raw %>% 
                   dplyr::select(-X,date,mid_cat,sns_cnt,buy_cnt) %>%
                   rename(large_cat=mid_cat)) %>% 
  arrange(large_cat,date)

list=full_raw%>%distinct(large_cat)
list=list$large_cat

cor_result <- data.frame(list,cor=rep(0,length(list)))
rep(0,length(list))

for (i in 1:length(list)){
  cat=NULL
  cat=full_raw%>%filter(large_cat==list[i])
  cor_result$cor[i]=cor(cat$sns_cnt,cat$buy_cnt)
}

cor_result


#################-------------------------------10. graphs---------------------------###################### 


# 2) ETC -----------------------


#  Box plot ---------------------------------------------

sp_std <- read.csv("sp_std.csv", header=TRUE, sep=',',fileEncoding = "utf-8") 
nnb_std <- read.csv("nnb_std.csv", header=TRUE, sep=',',fileEncoding = "utf-8") 
bt_std <- read.csv("beauty_std.csv", header=TRUE, sep=',',fileEncoding = "utf-8") 

temp1 <-sp_std %>% filter(mid_cat %in% c('인과류','채소류')) %>% 
  dplyr::select(date,mid_cat,z) %>% group_by(date,mid_cat) %>% summarize(buy_cnt=sum(z)) %>% 
  mutate(year=substr(date,1,4),
         day=substr(date,5,8)) %>% dplyr::select(year,day,mid_cat,buy_cnt)

ggplot(temp1 %>% filter(mid_cat %in% c('인과류','채소류')) ,
       aes(x=mid_cat, y=buy_cnt ,  color=mid_cat)) +theme_test() + geom_boxplot()


temp2 <-nnb_std %>% filter(large_cat %in% c('난방기기','에어컨','냉난방기','가습기','선풍기','가전기타')) %>% 
  dplyr::select(date,large_cat,z) %>% 
  group_by(date,large_cat) %>% summarize(buy_cnt=sum(z)) %>% 
  mutate(year=substr(date,1,4),
         day=substr(date,5,8)) %>% dplyr::select(year,day,large_cat,buy_cnt)

ggplot(temp2 %>% filter(large_cat %in% c('난방기기','가전기타')) ,
       aes(x=large_cat, y=buy_cnt ,  color=large_cat)) +theme_test() + geom_boxplot()


temp3 <-bt_std %>% filter(large_cat %in% c('페이셜케어','메이크업리무버')) %>% 
  select(date,large_cat,z) %>% 
  group_by(date,large_cat) %>% summarize(buy_cnt=sum(z)) %>% 
  mutate(year=substr(date,1,4),
         day=substr(date,5,8)) %>% select(year,day,large_cat,buy_cnt)

ggplot(temp3 %>% filter(large_cat %in% c('페이셜케어','메이크업리무버')) ,
       aes(x=large_cat, y=buy_cnt ,  color=large_cat)) +theme_test() + geom_boxplot()


# Line plot   -----------------------------


full_raw <- full_raw %>% mutate(year=substr(date,1,4),day=substr(date,6,10))

p1 <-ggplot(full_raw %>% filter(large_cat=='난방기기') %>% 
              select(day,year,large_cat,sns_cnt,buy_cnt)
            , aes(x=day, y=sns_cnt, colour=year, group=year)) +
  geom_line(linetype="solid", size=1) + theme_test() +
  geom_vline(xintercept=c('03-01','06-01','09-01','12-01'),linetype='dashed', color='blue', size = 0.1)  +
  theme_test() +
  ggtitle("난방기기_sns")

p2 <-ggplot(full_raw %>% filter(large_cat=='난방기기') %>% 
              select(day,year,large_cat,sns_cnt,buy_cnt)
            , aes(x=day, y=buy_cnt, colour=year, group=year)) + 
  geom_line(linetype="solid", size=1) +
  geom_vline(xintercept=c('03-01','06-01','09-01','12-01'), linetype='dashed', color='blue', size = 0.1) +
  theme_test() +
  ggtitle("난방기기_buy")

grid.arrange(p1,p2,nrow=2, ncol=1)



# word cloud   -----------------------------


F20 <- buy_all_3 %>% group_by(sex,age,sm_cat)%>%
  summarize(qty=sum(qty))%>%
  filter(age==20 & sex=="F") %>% arrange(desc(qty))%>%select(sm_cat,qty,sex,age)%>%head(100)
as_tibble(F20)
F20 <- F20[, c(1, 2)]

wordcloud2(data=F20,shape="circle",fontFamily = '나눔바름고딕',color =brewer.pal(n = 9, name = "Blues"))
letterCloud(data=F20,word='R',wordSize=1,fontFamily='나눔바른고딕')


wordcloud2(F20, minRotation = -pi/6, maxRotation = -pi/6, minSize = 10,
           rotateRatio = 1,fontFamily='나눔바른고딕',color =rev(brewer.pal(3,'Blues')))



figPath = system.file("examples/cloud.png",package = "wordcloud2")
wordcloud2(F20, figPath = figPath, size = 1.5,color = "skyblue")

M60 <- buy_all_2 %>% group_by(sex,age,sm_cat)%>%
  summarize(qty=sum(qty))%>%
  filter(age==60 & sex=="M") %>% arrange(desc(qty))%>%select(sm_cat,qty,sex,age)%>%head(50)

M60 <- M60[, c(1, 2)]

wordcloud2(data=M60,shape="circle",fontFamily = '나눔바름고딕')


wordcloud2(M60, minRotation = -pi/6, maxRotation = -pi/6, minSize = 10,
           rotateRatio = 1,fontFamily='나눔바른고딕',color =rev(brewer.pal(3,'Reds')))

