한국어 형태소 분석기가 적용된 ElasticSearch 5.5 베이스 도커 이미지입니다.

```sh
~/es-base $ docker build --tag es-base:5.5-with-arirang .
```

```sh
~/es-base $ docker run -d \
    --name elasticsearch \
    -p 9200:9200 \
    -p 9300:9300 \
    -v `pwd`/es-data:/usr/share/elasticsearch/data \
    es-base:5.5-with-arirang
```

## Test

Head over to `http://localhost:9200`

## Elastic Search

[ES는 검색 전용 데이터베이스](https://www.elastic.co/guide/index.html) 엔진입니다. REST 인터페이스를 제공합니다.

### In a Nutshell

ES 클라이언트는 크게 보면 다음 작업을 수행할 수 있습니다.
 
1. Indexing - Upsert로 동작합니다. 즉, 기존 레코드가 없으면 만들고, 있으면 업데이트합니다.
2. Searching - 필터링, 검색, 집합, 랭킹 및 정렬 등을 위한 다양한 옵션을 제공합니다. 자세한 내용은 공식 문서를 참고합니다.

ES 용어는 다음과 같습니다.

ElasticSearch|RDB
---|---
Index|Database
Type|Table
Document|Row
Field|Column
Mapping|Schema

### Initial Config

ES SDK 또는 REST API를 이용하면 대부분의 데이터 타입은 자동으로 맵핑됩니다. 경험적으로 아직 `geo_point`라는 ES의 특수한 데이터 타입을 인덱싱할 때 맵핑하는 방법은 찾지 못했습니다. 따라서 위경도 좌표값을 ES에 인덱싱하려면 깨끗한 ES 설치본에 `geo_point`로 사용할 프로퍼티를 알려줘야 합니다.

또 한글 검색을 위해서 한글 형태소 분석기 플러그인을 활성화해야 합니다.

```bash
~/es-base $ curl -X PUT -H "Content-Type: application/json" -d '{
  "mappings": {
    "name_of_the_type": {
      "properties": {
        "name_of_the_property_holding_latlng": {
          "type": "geo_point"
        },
        "name_of_the_property_holding_korean": {
          "type" : "string",
          "analyzer": "arirang_analyzer"
        }
      }
    }
  }
}
' "http://localhost:9200/name_of_the_index"
```

형태소 분석기(Mecab) 적용 결과는 다음과 같이 확인할 수 있습니다.

```bash
~/es-base $ curl -X GET "http://localhost:9200/_analyze?analyzer=arirang_analyzer&pretty=&text=대법관은 대법원장의 제청으로 국회의 동의를 얻어 대통령이 임명한다. 국회의원과 정부는 법률안을 제출할 수 있다. 각급 선거관리위원회의 조직·직무범위 기타 필요한 사항은 법률로 정한다."
```

### List Properties

```bash
~/es-base $ curl -X GET "http://localhost:9200/name_of_the_index"
```

### Delete Index

> 인덱스를 삭제하면 처음부터 다시 인덱싱해야 합니다.

```bash
~/es-base $ curl -X DELETE "http://localhost:9200/name_of_the_index"
```

### Search against Document

아래는 ElsaticSearch의 다양한 겅색 옵션 중 하나의 예일 뿐입니다. 더 자세한 내용은 공식 문서를 참고하세요.

```bash
~/es-base $ curl -X POST -H "Content-Type: application/json" -d '{
  "query": {
    "filtered": {
      "filter": {
        "bool": {
          "must": [
            {
              "term": {
                "key": "value"
              }
            },
            {
              "term": {
                "second_key": "second_value"
              }
            }
          ],
          "should": [
            {
              "term": {
                "third_key": "third_value"
              }
            },
            {
              "geo_distance": {
                "distance": "3km",
                "location": {
                  "lat": 37.0000000,
                  "lon": 127.0000000
                }
              }
            }
          ],
          "minimum_should_match": 1
        }
      },
      "query": {
        "query_string": {
          "query": "검색할 키워드",
          "default_operator": "OR",
          "fields": [
            "searchable_field_1",
            "searchable_field_2",
            "searchable_field_3"
          ]
        }
      }
    }
  },
  "sort": [
    {
      "sort_field_1": {
        "order": "asc"
      }
    },
    {
      "sort_field_2": {
        "order": "desc"
      }
    },
    {
      "sort_field_3": {
        "order": "desc"
      }
    },
    {
      "_geo_distance": {
        "location": {
          "lat": 37.0000000,
          "lon": 127.0000000
        },
        "order": "asc"
      }
    }
  ],
  "aggs": {
    "distinct_fields": {
      "terms": {
        "field": "distinct_field_1",
        "size": 0
      }
    }
  }
}' "http://localhost:9200/name_of_the_index/name_of_the_type/_search"
```

이상의 내용은 [미리 만들어 둔 포스트맨 콜렉션](https://www.getpostman.com/collections/11321fc3356d122acb13)을 이용하면 편리하게 확인해 볼 수 있습니다.
