한국어 형태소 분석기가 적용된 ElasticSearch 2.3.1 베이스 도커 이미지입니다.

```sh
$ docker run -d \
    -p 9200:9200 \
    -p 9300:9300 \
    -v data:/usr/share/elasticsearch/data \
    appkr/es-base:2.3.1
```
