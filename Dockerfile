FROM golang:latest
LABEL maintainer="Whitespots.io"
RUN go get -u -v github.com/lc/gau
CMD echo https://$DOMAIN > /tmp/result.txt &&\
 site=$(echo $DOMAIN); \
 gau "$site" >> /tmp/result.txt && \
 cat /tmp/result.txt | \
  grep -v _Incapsula_Resource |\
  grep -v .js |\
  grep -v .woff |\
  grep -v 'data:image' |\
  grep -v .svg \
  | awk -F'?' '{print $1}' | sort -u > /tmp/result.txt \
  && cat /tmp/result.txt \
    | while read url; \
      do target=$(curl -s -I -H "Origin: some$DOMAIN" -X GET $url) \
      | if echo $target | grep -q some$DOMAIN\|'Access-Control-Allow-Origin: *'; \
        then echo "{\"vulnerable\": \"True\", \"vuln_id\": \"$VULN_ID\", \"details\": \"$url\"}";\
        else echo "{\"vulnerable\": \"False\", \"vuln_id\": \"$VULN_ID\", \"details\": \"$url\"}";\
        fi; \
      done
